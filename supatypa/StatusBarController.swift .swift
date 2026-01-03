import AppKit

class StatusBarController {
    private var statusItem: NSStatusItem

    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            button.title = "⌨️"
        }

        let menu = NSMenu()

        menu.addItem(NSMenuItem(title: "Today: 0 chars", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))

        statusItem.menu = menu
    }
    

    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
}
