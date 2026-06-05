import AppKit
import Foundation

public struct RunningAppRow: Equatable {
    public let localizedName: String
    public let bundleName: String
    public let pid: pid_t

    public init(localizedName: String, bundleName: String, pid: pid_t) {
        self.localizedName = localizedName
        self.bundleName = bundleName
        self.pid = pid
    }
}

public enum CursorRunningAppMatcher {
    public static func findCursorApps(rows: [RunningAppRow]) -> [RunningAppRow] {
        rows.filter {
            $0.localizedName == "Cursor" || $0.bundleName == "Cursor.app"
        }
    }
}

public struct CursorRunningAppScanner {
    public init() {}

    public func findCursorApps() -> [RunningAppRow] {
        CursorRunningAppMatcher.findCursorApps(rows: currentRows())
    }

    public func findCursorAgentsApp(
        windowTitle: String,
        axScanner: AXWindowScanner = AXWindowScanner()
    ) -> RunningAppRow? {
        findCursorApps().first { row in
            axScanner.findWindow(in: row.pid, windowTitle: windowTitle) != nil
        }
    }

    private func currentRows() -> [RunningAppRow] {
        NSWorkspace.shared.runningApplications.compactMap { application in
            let localizedName = application.localizedName ?? ""
            let bundleName = application.bundleURL?.lastPathComponent ?? ""

            guard !localizedName.isEmpty || !bundleName.isEmpty else {
                return nil
            }

            return RunningAppRow(
                localizedName: localizedName,
                bundleName: bundleName,
                pid: application.processIdentifier
            )
        }
    }
}
