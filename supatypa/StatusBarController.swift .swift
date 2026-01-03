import AppKit

class StatusBarController {

    private let statusItem = NSStatusBar.system.statusItem(
        withLength: NSStatusItem.variableLength
    )

    private let statsItem = NSMenuItem(title: "Loading...", action: nil, keyEquivalent: "")
    private var timer: Timer?

    init() {
        if let button = statusItem.button {
            button.title = "⌨️"
        }

        let menu = NSMenu()
        menu.addItem(statsItem)
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
    }

    @objc private func quit() {
        NSApplication.shared.stop(nil)
        NSApplication.shared.terminate(nil)
        exit(0)
    }
}
