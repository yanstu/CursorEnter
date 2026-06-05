import XCTest
@testable import cursor_enter_helper

final class CursorRunningAppMatcherTests: XCTestCase {
    func test_matchesCursorAppByLocalizedName() {
        let rows = [
            RunningAppRow(localizedName: "Notes", bundleName: "Notes.app", pid: 100),
            RunningAppRow(localizedName: "Cursor", bundleName: "Cursor.app", pid: 101)
        ]

        let matches = CursorRunningAppMatcher.findCursorApps(rows: rows)

        XCTAssertEqual(matches.map(\.pid), [101])
    }

    func test_matchesCursorAppByBundleName() {
        let rows = [
            RunningAppRow(localizedName: "Electron", bundleName: "Cursor.app", pid: 101)
        ]

        let matches = CursorRunningAppMatcher.findCursorApps(rows: rows)

        XCTAssertEqual(matches.map(\.pid), [101])
    }
}
