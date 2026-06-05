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
    public static let enterEvents: [PlannedKeyEvent] = [
        PlannedKeyEvent(virtualKey: 36, keyDown: true, flags: []),
        PlannedKeyEvent(virtualKey: 36, keyDown: false, flags: [])
    ]
}
