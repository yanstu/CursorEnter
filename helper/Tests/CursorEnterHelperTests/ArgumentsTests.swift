import XCTest
@testable import cursor_enter_helper

final class ArgumentsTests: XCTestCase {
    func test_parsesLoopModeAndInterval() throws {
        let args = try Arguments.parse([
            "--mode", "loop",
            "--window-title", "Cursor Agents",
            "--interval-ms", "300"
        ])

        XCTAssertEqual(args.mode, .loop)
        XCTAssertEqual(args.windowTitle, "Cursor Agents")
        XCTAssertEqual(args.intervalMs, 300)
    }

    func test_rejectsIntervalBelowMinimum() {
        XCTAssertThrowsError(try Arguments.parse([
            "--mode", "loop",
            "--window-title", "Cursor Agents",
            "--interval-ms", "10"
        ]))
    }

    func test_accepts40msInterval() throws {
        let args = try Arguments.parse([
            "--mode", "loop",
            "--window-title", "Cursor Agents",
            "--interval-ms", "40"
        ])

        XCTAssertEqual(args.intervalMs, 40)
    }

    func test_parsesAXLoopMode() throws {
        let args = try Arguments.parse([
            "--mode", "ax-loop",
            "--window-title", "Cursor Agents",
            "--interval-ms", "250"
        ])

        XCTAssertEqual(args.mode, .axLoop)
        XCTAssertEqual(args.windowTitle, "Cursor Agents")
        XCTAssertEqual(args.intervalMs, 250)
    }

    func test_parsesActiveLoopMode() throws {
        let args = try Arguments.parse([
            "--mode", "active-loop",
            "--window-title", "Cursor Agents",
            "--interval-ms", "250"
        ])

        XCTAssertEqual(args.mode, .activeLoop)
        XCTAssertEqual(args.windowTitle, "Cursor Agents")
        XCTAssertEqual(args.intervalMs, 250)
    }
}
