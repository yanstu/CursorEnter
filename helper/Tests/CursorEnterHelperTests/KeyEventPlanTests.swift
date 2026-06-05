import XCTest
@testable import cursor_enter_helper

final class KeyEventPlanTests: XCTestCase {
    func test_modifierResetPlanCoversCommonModifierKeys() {
        XCTAssertEqual(
            KeyEventPlan.modifierResetVirtualKeys,
            [56, 60, 59, 62, 58, 61, 57]
        )
    }

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
}
