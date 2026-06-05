@preconcurrency import CoreGraphics
import Foundation

public struct KeyPoster {
    public init() {}

    public func postEnter(to pid: pid_t) throws {
        for plannedEvent in KeyEventPlan.enterEvents {
            try post(plannedEvent, to: pid)
        }
    }

    private func post(_ plannedEvent: PlannedKeyEvent, to pid: pid_t) throws {
        guard let event = CGEvent(
            keyboardEventSource: nil,
            virtualKey: plannedEvent.virtualKey,
            keyDown: plannedEvent.keyDown
        ) else {
            throw HelperError("failed to create keyboard event")
        }

        event.flags = plannedEvent.flags
        event.postToPid(pid)
    }
}
