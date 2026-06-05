import XCTest
@testable import cursor_enter_helper

final class AppPreferencesTests: XCTestCase {
    func test_intervalOptions_include40msAndExclude500ms() {
        XCTAssertEqual(EnterIntervalOptions.all, [40, 80, 120, 180, 250, 300])
    }

    func test_toggleHotKey_roundTripsThroughCodable() throws {
        let hotKey = ToggleHotKey(keyCode: 36, modifiers: 0b0110)

        let data = try JSONEncoder().encode(hotKey)
        let decoded = try JSONDecoder().decode(ToggleHotKey.self, from: data)

        XCTAssertEqual(decoded, hotKey)
    }
}
