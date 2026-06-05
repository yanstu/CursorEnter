@preconcurrency import ApplicationServices
@preconcurrency import CoreGraphics
import CAXShim

public struct KeyPoster {
    public init() {}

    public func postEnter(to pid: pid_t) throws {
        let axResult = cax_post_enter_to_pid(pid)
        if axResult == .success {
            return
        }

        guard let down = CGEvent(keyboardEventSource: nil, virtualKey: 36, keyDown: true),
              let up = CGEvent(keyboardEventSource: nil, virtualKey: 36, keyDown: false) else {
            throw HelperError("failed to create keyboard event")
        }

        down.postToPid(pid)
        up.postToPid(pid)
    }
}
