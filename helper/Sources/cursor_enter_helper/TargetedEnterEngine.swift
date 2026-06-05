import Foundation

public struct TargetedEnterEngine {
    private let appScanner: CursorRunningAppScanner
    private let axScanner: AXWindowScanner
    private let poster: KeyPoster

    public init(
        appScanner: CursorRunningAppScanner = CursorRunningAppScanner(),
        axScanner: AXWindowScanner = AXWindowScanner(),
        poster: KeyPoster = KeyPoster()
    ) {
        self.appScanner = appScanner
        self.axScanner = axScanner
        self.poster = poster
    }

    @discardableResult
    public func sendEnter(
        windowTitle: String,
        requireAXTarget: Bool
    ) throws -> Bool {
        guard let target = appScanner.findCursorAgentsTarget(
            windowTitle: windowTitle,
            axScanner: axScanner
        ) else {
            return false
        }

        if requireAXTarget,
           !axScanner.prepareTargetWindow(pid: target.app.pid, window: target.window) {
            return false
        }

        try poster.postEnter(to: target.app.pid)
        return true
    }
}
