import AppKit
import ApplicationServices

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarController: StatusBarController?
    var keyboardMonitor: KeyboardMonitor?



    func applicationDidFinishLaunching(_ notification: Notification) {
        keyboardMonitor = KeyboardMonitor()
        statusBarController = StatusBarController()
        
        checkAccessibilityPermission()
    }
    
    func checkAccessibilityPermission() {
        let trusted = AXIsProcessTrusted()
        
        if trusted {
            keyboardMonitor?.start()
        } else {
            let options = [
                kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: true
            ] as CFDictionary
            
            AXIsProcessTrustedWithOptions(options)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.verifyPermissionAfterDelay()
            }
        }
    }
    
    func verifyPermissionAfterDelay() {
        if AXIsProcessTrusted() {
            keyboardMonitor?.start()
        } else {
            showPermissionAlert()
            
            NotificationCenter.default.addObserver(
                forName: NSApplication.didBecomeActiveNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                if AXIsProcessTrusted() {
                    self.keyboardMonitor?.start()
                    NotificationCenter.default.removeObserver(self)
                }
            }
        }
    }
    
    func showPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = "This app needs accessibility permissions to track your typing. Please grant access in System Settings > Privacy & Security > Accessibility."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Cancel")
        
        if alert.runModal() == .alertFirstButtonReturn {
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                NSWorkspace.shared.open(url)
            }
        }
    }
}
