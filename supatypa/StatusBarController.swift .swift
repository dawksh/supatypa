import AppKit
import ApplicationServices
import Foundation

class StatusBarController {

    private let statusItem = NSStatusBar.system.statusItem(
        withLength: NSStatusItem.variableLength
    )

    private let statsItem = NSMenuItem(title: "Loading...", action: nil, keyEquivalent: "")
    private let permissionItem = NSMenuItem(title: "", action: #selector(requestPermission), keyEquivalent: "")
    private let copyPathItem = NSMenuItem(title: "Copy Binary Path", action: #selector(copyBinaryPath), keyEquivalent: "")
    private var timer: Timer?

    init() {
        if let button = statusItem.button {
            button.title = "⌨️"
        }

        let menu = NSMenu()
        menu.addItem(statsItem)
        menu.addItem(permissionItem)
        menu.addItem(NSMenuItem.separator())
        copyPathItem.target = self
        menu.addItem(copyPathItem)
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
        
        let hasPermission = CGPreflightListenEventAccess()
        if !hasPermission {
            permissionItem.title = "⚠️ Enable Input Monitoring"
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
            permissionItem.title = "⚠️ Enable Input Monitoring"
            permissionItem.target = self
            permissionItem.isHidden = false
        }
    }
    
    @objc private func requestPermission() {
        if !CGPreflightListenEventAccess() {
            _ = CGRequestListenEventAccess()
        }
        
        _ = [
            "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent",
            "x-apple.systempreferences:com.apple.preference.security?Privacy_InputMonitoring",
            "x-apple.systempreferences:com.apple.preference.security?Privacy"
        ]
        .compactMap(URL.init(string:))
        .first
        .map(NSWorkspace.shared.open)
    }
    
    @objc private func copyBinaryPath() {
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
        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(resolvedPath, forType: .string)
    }

    @objc private func quit() {
        NSApplication.shared.stop(nil)
        NSApplication.shared.terminate(nil)
        exit(0)
    }
}
