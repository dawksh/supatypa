import AppKit
import ApplicationServices

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarController: StatusBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        checkAccessibilityPermission()
        statusBarController = StatusBarController()
    }
    
    func checkAccessibilityPermission() {
        let trusted = AXIsProcessTrusted()
        
        if !trusted {
            let options = [
                kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: true
            ] as CFDictionary
            
            if !AXIsProcessTrustedWithOptions(options) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.showPermissionAlert()
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
