import XCTest
@testable import cursor_enter_helper

final class WindowMatcherTests: XCTestCase {
    func test_matchesCursorAgentsWindow() {
        let rows = [
            WindowRow(ownerName: "Cursor", windowName: "Project 1", pid: 101),
            WindowRow(ownerName: "Cursor", windowName: "Cursor Agents", pid: 101)
        ]

        let match = WindowMatcher.findWindow(
            rows: rows,
            ownerName: "Cursor",
            windowTitle: "Cursor Agents"
        )

        XCTAssertEqual(match?.windowName, "Cursor Agents")
        XCTAssertEqual(match?.pid, 101)
    }

    func test_matchesAXWindowByTitle() {
        let rows = [
            AXWindowRow(title: "Project 1", role: "AXWindow", subrole: "AXStandardWindow"),
            AXWindowRow(title: "Cursor Agents", role: "AXWindow", subrole: "AXStandardWindow")
        ]

        let match = AXWindowMatcher.findWindow(rows: rows, windowTitle: "Cursor Agents")

        XCTAssertEqual(match?.title, "Cursor Agents")
        XCTAssertEqual(match?.role, "AXWindow")
    }
}
