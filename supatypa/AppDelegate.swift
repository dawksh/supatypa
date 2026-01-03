import AppKit
import ApplicationServices
import Foundation

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarController: StatusBarController?
    var keyboardMonitor: KeyboardMonitor?

    func applicationWillFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        keyboardMonitor = KeyboardMonitor()
        statusBarController = StatusBarController()
        
        checkAccessibilityPermission()
    }
    
    func checkAccessibilityPermission() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.verifyAndRequestPermission()
        }
    }
    
    func verifyAndRequestPermission() {
        let trusted = AXIsProcessTrusted()
        
        if trusted {
            self.startMonitoring()
            statusBarController?.updatePermissionStatus(hasPermission: true)
        } else {
            statusBarController?.updatePermissionStatus(hasPermission: false)
            
            let options = [
                kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: true
            ] as CFDictionary
            
            AXIsProcessTrustedWithOptions(options)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.verifyPermissionAfterDelay()
            }
            
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] timer in
                guard let self = self else {
                    timer.invalidate()
                    return
                }
                
                if AXIsProcessTrusted() {
                    timer.invalidate()
                    self.startMonitoring()
                    self.statusBarController?.updatePermissionStatus(hasPermission: true)
                }
            }
        }
    }
    
    func verifyPermissionAfterDelay() {
        if AXIsProcessTrusted() {
            startMonitoring()
        } else {
            showPermissionAlert()
            
            NotificationCenter.default.addObserver(
                forName: NSApplication.didBecomeActiveNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if AXIsProcessTrusted() {
                        self.startMonitoring()
                        NotificationCenter.default.removeObserver(self)
                    }
                }
            }
        }
    }
    
    func startMonitoring() {
        guard AXIsProcessTrusted() else {
            return
        }
        
        guard keyboardMonitor?.start() == true else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if AXIsProcessTrusted() {
                    _ = self.keyboardMonitor?.start()
                }
            }
            return
        }
    }
    
    func showPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        
        var executablePath = ProcessInfo.processInfo.arguments[0]
        if !executablePath.hasPrefix("/") {
            if let cwd = FileManager.default.currentDirectoryPath as String? {
                executablePath = (cwd as NSString).appendingPathComponent(executablePath)
            }
        }
        var resolvedPath = (executablePath as NSString).standardizingPath
        while let attrs = try? FileManager.default.attributesOfItem(atPath: resolvedPath),
              let fileType = attrs[.type] as? FileAttributeType,
              fileType == .typeSymbolicLink,
              let destination = try? FileManager.default.destinationOfSymbolicLink(atPath: resolvedPath) {
            if destination.hasPrefix("/") {
                resolvedPath = destination
            } else {
                resolvedPath = ((resolvedPath as NSString).deletingLastPathComponent as NSString).appendingPathComponent(destination)
            }
            resolvedPath = (resolvedPath as NSString).standardizingPath
        }
        
        let informativeText = """
This app needs accessibility permissions to track your typing.

1. Open System Settings → Privacy & Security → Accessibility
2. Ensure this binary is enabled: \(resolvedPath)

If the binary is not in the list:
- Click the "+" button and add: \(resolvedPath)
- Enable the checkbox next to it

Note: For Homebrew-installed binaries, make sure you're adding the actual path (not the symlink).
"""
        
        alert.informativeText = informativeText
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Copy Path")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                NSWorkspace.shared.open(url)
            }
        } else if response == .alertSecondButtonReturn {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(resolvedPath, forType: .string)
        }
    }
}

