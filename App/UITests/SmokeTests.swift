import XCTest

// Cross-platform smoke tests for BaekSoeum.
// Runs on both iOS and tvOS via the UI test target's supportedDestinations.
final class SmokeTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func test_launches_with_play_button_visible() {
        let play = app.buttons["play-button"]
        XCTAssertTrue(play.waitForExistence(timeout: 5),
                      "play-button should be in hierarchy after launch")
    }

    func test_play_button_toggles_label() {
        let play = app.buttons["play-button"]
        XCTAssertTrue(play.waitForExistence(timeout: 5))

        let initialLabel = play.label
        #if os(tvOS)
        XCUIRemote.shared.press(.select)  // play already has default focus
        #else
        play.tap()
        #endif

        // After action, label should swap (재생 <-> 일시정지)
        let waitForToggle = NSPredicate(format: "label != %@", initialLabel)
        let exp = expectation(for: waitForToggle, evaluatedWith: play)
        wait(for: [exp], timeout: 3)
    }

    #if os(iOS)
    func test_iOS_has_three_tabs() {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        XCTAssertEqual(tabBar.buttons.count, 3, "expected 3 tabs (소리/잠/루틴)")
    }
    #endif

    #if os(tvOS)
    func test_tvOS_play_button_receives_default_focus() {
        let play = app.buttons["play-button"]
        XCTAssertTrue(play.waitForExistence(timeout: 5))
        XCTAssertTrue(play.hasFocus, "play-button should have default focus on launch")
    }
    #endif
}
