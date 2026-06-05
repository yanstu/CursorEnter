@preconcurrency import ApplicationServices
import Foundation

public struct AXWindowRow: Equatable {
    public let title: String
    public let role: String
    public let subrole: String
    let element: AXUIElement?

    public init(
        title: String,
        role: String,
        subrole: String,
        element: AXUIElement? = nil
    ) {
        self.title = title
        self.role = role
        self.subrole = subrole
        self.element = element
    }

    public static func == (lhs: AXWindowRow, rhs: AXWindowRow) -> Bool {
        lhs.title == rhs.title &&
        lhs.role == rhs.role &&
        lhs.subrole == rhs.subrole
    }
}

public enum AXWindowMatcher {
    public static func findWindow(
        rows: [AXWindowRow],
        windowTitle: String
    ) -> AXWindowRow? {
        rows.first { $0.title == windowTitle }
    }
}

public struct AXWindowScanner {
    public init() {}

    public func debugRows(for pid: pid_t) -> [AXWindowRow] {
        rows(for: AXUIElementCreateApplication(pid))
    }

    public func findWindow(in pid: pid_t, windowTitle: String) -> AXWindowRow? {
        AXWindowMatcher.findWindow(
            rows: debugRows(for: pid),
            windowTitle: windowTitle
        )
    }

    @discardableResult
    public func prepareTargetWindow(pid: pid_t, windowTitle: String) -> Bool {
        let application = AXUIElementCreateApplication(pid)
        guard let match = findWindow(in: pid, windowTitle: windowTitle),
        let element = match.element else {
            return false
        }

        if isApplicationPointingToTarget(application: application, window: element) {
            return true
        }

        let setMainWindowResult = AXUIElementSetAttributeValue(
            application,
            kAXMainWindowAttribute as CFString,
            element
        )

        let setFocusedWindowResult = AXUIElementSetAttributeValue(
            application,
            kAXFocusedWindowAttribute as CFString,
            element
        )

        let setWindowMainResult = AXUIElementSetAttributeValue(
            element,
            kAXMainAttribute as CFString,
            kCFBooleanTrue
        )

        let setWindowFocusedResult = AXUIElementSetAttributeValue(
            element,
            kAXFocusedAttribute as CFString,
            kCFBooleanTrue
        )

        _ = setMainWindowResult
        _ = setFocusedWindowResult
        _ = setWindowMainResult
        _ = setWindowFocusedResult

        return isApplicationPointingToTarget(application: application, window: element)
    }

    private func rows(for application: AXUIElement) -> [AXWindowRow] {
        guard let windows = copyWindows(from: application) else {
            return []
        }

        return windows.map { element in
            AXWindowRow(
                title: copyStringAttribute(kAXTitleAttribute, from: element) ?? "",
                role: copyStringAttribute(kAXRoleAttribute, from: element) ?? "",
                subrole: copyStringAttribute(kAXSubroleAttribute, from: element) ?? "",
                element: element
            )
        }.filter {
            !$0.title.isEmpty
        }
    }

    private func copyWindows(from application: AXUIElement) -> [AXUIElement]? {
        var value: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(
            application,
            kAXWindowsAttribute as CFString,
            &value
        )

        guard result == .success,
              let windows = value as? [AXUIElement] else {
            return nil
        }

        return windows
    }

    private func copyStringAttribute(
        _ attribute: String,
        from element: AXUIElement
    ) -> String? {
        var value: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(element, attribute as CFString, &value)

        guard result == .success else {
            return nil
        }

        return value as? String
    }

    private func isApplicationPointingToTarget(
        application: AXUIElement,
        window: AXUIElement
    ) -> Bool {
        if let focusedWindow = copyElementAttribute(kAXFocusedWindowAttribute, from: application),
           CFEqual(focusedWindow, window) {
            return true
        }

        if let mainWindow = copyElementAttribute(kAXMainWindowAttribute, from: application),
           CFEqual(mainWindow, window) {
            return true
        }

        return false
    }

    private func copyElementAttribute(
        _ attribute: String,
        from element: AXUIElement
    ) -> AXUIElement? {
        var value: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(element, attribute as CFString, &value)

        guard result == .success,
              let value,
              CFGetTypeID(value) == AXUIElementGetTypeID() else {
            return nil
        }

        return (value as! AXUIElement)
    }
}
