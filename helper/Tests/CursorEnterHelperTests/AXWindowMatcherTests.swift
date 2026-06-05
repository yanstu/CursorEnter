import XCTest
@testable import cursor_enter_helper

final class AXWindowMatcherTests: XCTestCase {
    func test_matchesAXWindowByTitle() {
        let rows = [
            AXWindowRow(title: "Project 1", role: "AXWindow", subrole: "AXStandardWindow"),
            AXWindowRow(title: "Cursor Agents", role: "AXWindow", subrole: "AXStandardWindow")
        ]

        let match = AXWindowMatcher.findWindow(rows: rows, windowTitle: "Cursor Agents")

        XCTAssertEqual(match?.title, "Cursor Agents")
        XCTAssertEqual(match?.role, "AXWindow")
    }

    func test_returnsNilWhenNoTitleMatches() {
        let rows = [
            AXWindowRow(title: "Project 1", role: "AXWindow", subrole: "AXStandardWindow")
        ]

        let match = AXWindowMatcher.findWindow(rows: rows, windowTitle: "Cursor Agents")

        XCTAssertNil(match)
    }
}
