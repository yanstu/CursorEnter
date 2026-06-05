@preconcurrency import CoreGraphics
import Foundation

public struct WindowRow: Equatable {
    public let ownerName: String
    public let windowName: String
    public let pid: pid_t

    public init(ownerName: String, windowName: String, pid: pid_t) {
        self.ownerName = ownerName
        self.windowName = windowName
        self.pid = pid
    }
}

public struct WindowMatch: Equatable, CustomStringConvertible {
    public let ownerName: String
    public let windowName: String
    public let pid: pid_t

    public init(ownerName: String, windowName: String, pid: pid_t) {
        self.ownerName = ownerName
        self.windowName = windowName
        self.pid = pid
    }

    public var description: String {
        "\(ownerName)\t\(windowName)\t\(pid)"
    }
}

public enum WindowMatcher {
    public static func findWindow(
        rows: [WindowRow],
        ownerName: String,
        windowTitle: String
    ) -> WindowMatch? {
        rows.first {
            $0.ownerName == ownerName && $0.windowName == windowTitle
        }.map {
            WindowMatch(ownerName: $0.ownerName, windowName: $0.windowName, pid: $0.pid)
        }
    }
}

public struct WindowScanner {
    public init() {}

    public func findCursorAgentsWindow(
        ownerName: String = "Cursor",
        windowTitle: String
    ) -> WindowMatch? {
        WindowMatcher.findWindow(
            rows: currentRows(),
            ownerName: ownerName,
            windowTitle: windowTitle
        )
    }

    private func currentRows() -> [WindowRow] {
        guard let infoList = CGWindowListCopyWindowInfo([.optionAll], kCGNullWindowID) as? [[String: Any]] else {
            return []
        }

        return infoList.compactMap { row in
            guard let ownerName = row[kCGWindowOwnerName as String] as? String,
                  let windowName = row[kCGWindowName as String] as? String,
                  let pidNumber = row[kCGWindowOwnerPID as String] as? NSNumber else {
                return nil
            }

            return WindowRow(
                ownerName: ownerName,
                windowName: windowName,
                pid: pidNumber.int32Value
            )
        }
    }
}
