import AppKit
import Foundation

public struct ForegroundWindowEnterEngine {
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
    public func sendEnter(windowTitle: String) throws -> Bool {
        guard let match = appScanner.findCursorAgentsApp(
            windowTitle: windowTitle,
            axScanner: axScanner
        ) else {
            return false
        }

        let previousFrontmostApp = NSWorkspace.shared.frontmostApplication
        guard let cursorApp = NSRunningApplication(processIdentifier: match.pid) else {
            return false
        }

        _ = axScanner.prepareTargetWindow(pid: match.pid, windowTitle: windowTitle)

        let activated = cursorApp.activate(options: [.activateIgnoringOtherApps])
        if !activated {
            return false
        }

        usleep(60_000)
        _ = axScanner.prepareTargetWindow(pid: match.pid, windowTitle: windowTitle)
        usleep(30_000)
        try poster.postEnter(to: match.pid)
        usleep(20_000)

        if let previousFrontmostApp,
           previousFrontmostApp.processIdentifier != cursorApp.processIdentifier,
           previousFrontmostApp.processIdentifier != ProcessInfo.processInfo.processIdentifier {
            _ = previousFrontmostApp.activate(options: [.activateIgnoringOtherApps])
        }

        return true
    }
}
