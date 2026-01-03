import Foundation
import ApplicationServices

class KeyboardMonitor {

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    private(set) var charCount = 0
    private(set) var wordCount = 0

    func start() {
        let mask = CGEventMask(1 << CGEventType.keyDown.rawValue)

        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: { proxy, type, event, userInfo in
                guard type == .keyDown,
                      let userInfo = userInfo else {
                    return Unmanaged.passUnretained(event)
                }

                let monitor = Unmanaged<KeyboardMonitor>
                    .fromOpaque(userInfo)
                    .takeUnretainedValue()

                monitor.handle(event: event)
                return Unmanaged.passUnretained(event)
            },
            userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        )

        guard let eventTap else {
            print("❌ Failed to create event tap (check Accessibility permission)")
            return
        }

        runLoopSource = CFMachPortCreateRunLoopSource(
            kCFAllocatorDefault,
            eventTap,
            0
        )

        CFRunLoopAddSource(
            CFRunLoopGetCurrent(),
            runLoopSource,
            .commonModes
        )

        CGEvent.tapEnable(tap: eventTap, enable: true)
    }

    private func handle(event: CGEvent) {
        if event.flags.contains(.maskCommand) { return }

        var length = 0
        var buffer = [UniChar](repeating: 0, count: 8)

        event.keyboardGetUnicodeString(
            maxStringLength: buffer.count,
            actualStringLength: &length,
            unicodeString: &buffer
        )

        guard length > 0 else { return }

        let string = String(utf16CodeUnits: buffer, count: length)

        let chars = string.count
        let words = string.split(whereSeparator: { $0.isWhitespace }).count

        StatsStore.shared.increment(chars: chars, words: words)
    }
}
