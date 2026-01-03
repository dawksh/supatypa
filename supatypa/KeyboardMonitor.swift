import Foundation
import ApplicationServices

class KeyboardMonitor {

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    
    private var lastWasWhitespace = true

    func start() -> Bool {
        guard CGPreflightListenEventAccess() else { return false }

        let mask = CGEventMask(1 << CGEventType.keyDown.rawValue)

        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
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
            return false
        }

        guard let source = CFMachPortCreateRunLoopSource(
            kCFAllocatorDefault,
            eventTap,
            0
        ) else {
            print("❌ Failed to create run loop source")
            return false
        }

        runLoopSource = source

        CFRunLoopAddSource(
            CFRunLoopGetCurrent(),
            source,
            .commonModes
        )

        CGEvent.tapEnable(tap: eventTap, enable: true)
        return true
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
        
        for char in string {
            let isWhitespace = char.isWhitespace
            
            if !isWhitespace && lastWasWhitespace {
                StatsStore.shared.incrementWord()
            }
            
            if !isWhitespace {
                StatsStore.shared.incrementChar()
            }
            
            lastWasWhitespace = isWhitespace
        }
    }
}
