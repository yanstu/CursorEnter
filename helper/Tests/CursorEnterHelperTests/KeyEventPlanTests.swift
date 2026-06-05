import XCTest
@testable import cursor_enter_helper

final class KeyEventPlanTests: XCTestCase {
    func test_enterPlanUsesEmptyModifierFlags() {
        let plan = KeyEventPlan.enterEvents

        XCTAssertEqual(plan.count, 2)
        XCTAssertEqual(plan[0].virtualKey, 36)
        XCTAssertTrue(plan[0].keyDown)
        XCTAssertEqual(plan[0].flags, [])
        XCTAssertEqual(plan[1].virtualKey, 36)
        XCTAssertFalse(plan[1].keyDown)
        XCTAssertEqual(plan[1].flags, [])
    }

    func test_enterPlanContainsOnlyReturnKey() {
        for event in KeyEventPlan.enterEvents {
            XCTAssertEqual(event.virtualKey, 36)
            XCTAssertEqual(event.flags, [])
        }
    }
}
