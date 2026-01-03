import AppKit
import ApplicationServices

class StatusBarController {

    private let statusItem = NSStatusBar.system.statusItem(
        withLength: NSStatusItem.variableLength
    )

    private let statsItem = NSMenuItem(title: "Loading...", action: nil, keyEquivalent: "")
    private let permissionItem = NSMenuItem(title: "", action: #selector(requestPermission), keyEquivalent: "")
    private var timer: Timer?

    init() {
        if let button = statusItem.button {
            button.title = "⌨️"
        }

        let menu = NSMenu()
        menu.addItem(statsItem)
        menu.addItem(permissionItem)
        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(
            title: "Quit",
            action: #selector(quit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
        startUpdating()
    }

    private func startUpdating() {
        updateStats()

        timer = Timer.scheduledTimer(
            withTimeInterval: 2,
            repeats: true
        ) { _ in
            self.updateStats()
        }
    }

    private func updateStats() {
        let stats = StatsStore.shared.load()
        statsItem.title = "Today: \(stats.chars) chars • \(stats.words) words"
        
        let hasPermission = AXIsProcessTrusted()
        if !hasPermission {
            permissionItem.title = "⚠️ Enable Accessibility Permission"
            permissionItem.target = self
            permissionItem.isHidden = false
        } else {
            permissionItem.isHidden = true
        }
    }
    
    func updatePermissionStatus(hasPermission: Bool) {
        if hasPermission {
            permissionItem.isHidden = true
        } else {
            permissionItem.title = "⚠️ Enable Accessibility Permission"
            permissionItem.target = self
            permissionItem.isHidden = false
        }
    }
    
    @objc private func requestPermission() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }

    @objc private func quit() {
        NSApplication.shared.stop(nil)
        NSApplication.shared.terminate(nil)
        exit(0)
    }
}
