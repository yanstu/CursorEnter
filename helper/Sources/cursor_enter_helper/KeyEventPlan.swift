@preconcurrency import CoreGraphics
import Foundation

public struct PlannedKeyEvent: Equatable, Sendable {
    public let virtualKey: CGKeyCode
    public let keyDown: Bool
    public let flags: CGEventFlags

    public init(
        virtualKey: CGKeyCode,
        keyDown: Bool,
        flags: CGEventFlags
    ) {
        self.virtualKey = virtualKey
        self.keyDown = keyDown
        self.flags = flags
    }
}

public enum KeyEventPlan {
    public static let modifierResetVirtualKeys: [CGKeyCode] = [
        56, // left shift
        60, // right shift
        59, // left control
        62, // right control
        58, // left option
        61, // right option
        57  // caps lock
    ]

    public static let enterEvents: [PlannedKeyEvent] = [
        PlannedKeyEvent(virtualKey: 36, keyDown: true, flags: []),
        PlannedKeyEvent(virtualKey: 36, keyDown: false, flags: [])
    ]

    public static let modifierResetEvents: [PlannedKeyEvent] = modifierResetVirtualKeys.map {
        PlannedKeyEvent(virtualKey: $0, keyDown: false, flags: [])
    }
}
