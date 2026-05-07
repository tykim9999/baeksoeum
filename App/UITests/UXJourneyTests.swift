import XCTest

// Walks through the app's UX states and attaches a screenshot of each.
// Screenshots end up in the .xcresult bundle; extract via:
//
//   xcrun xcresulttool get --legacy --path <result>.xcresult --format json
//
// Or use the helper `Tools/extract-screenshots.sh` which dumps all
// XCTAttachments to /tmp/ux-journey/.
final class UXJourneyTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = true
        app = XCUIApplication()
        app.launch()
    }

    private func snap(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func settle(_ seconds: Double = 0.6) {
        let exp = expectation(description: "settle")
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { exp.fulfill() }
        wait(for: [exp], timeout: seconds + 1)
    }

    #if os(iOS)
    func test_iOS_journey() {
        // 1 -- launch / sound tab default (whatever was persisted, likely 분홍 or 갈색)
        XCTAssertTrue(app.buttons["play-button"].waitForExistence(timeout: 5))
        settle(0.5)
        snap("01-ios-sound-default")

        // 2 -- white noise selected
        app.buttons["noise-white"].tap()
        settle(1.5)
        snap("02-ios-sound-white")

        // 3 -- pink noise selected
        app.buttons["noise-pink"].tap()
        settle(1.5)
        snap("03-ios-sound-pink")

        // 4 -- brown noise selected
        app.buttons["noise-brown"].tap()
        settle(1.5)
        snap("04-ios-sound-brown")

        // 5 -- lullaby selected (tap brahms)
        let brahms = app.buttons["lullaby-brahms"]
        if brahms.exists {
            brahms.tap()
            settle(1.5)
            snap("05-ios-sound-lullaby-brahms")
        }

        // 6 -- womb heartbeat
        let heart = app.buttons["womb-heartbeat"]
        if heart.exists {
            heart.tap()
            settle(1.5)
            snap("06-ios-sound-womb-heartbeat")
        }

        // 7 -- play active (peach glow)
        app.buttons["play-button"].tap()
        settle(0.6)
        snap("07-ios-playing")

        // 8 -- glow mode
        let glow = app.buttons["glow-toggle"]
        if glow.exists {
            glow.tap()
            settle(1.0)
            snap("08-ios-glow-mode")
            // tap to exit
            app.tap()
            settle(0.6)
        }

        // 9 -- Sleep tab
        let tabBar = app.tabBars.firstMatch
        if tabBar.waitForExistence(timeout: 3), tabBar.buttons.count >= 2 {
            tabBar.buttons.element(boundBy: 1).tap()
            settle(0.6)
            snap("09-ios-sleep-tab")

            // 10 -- Routine tab
            tabBar.buttons.element(boundBy: 2).tap()
            settle(0.6)
            snap("10-ios-routine-tab")
        }
    }
    #endif

    #if os(tvOS)
    func test_tvOS_journey() {
        // 1 -- default (focus on play, hero visible)
        XCTAssertTrue(app.buttons["play-button"].waitForExistence(timeout: 5))
        settle(0.6)
        snap("01-tvos-hero-default")

        // 2 -- press select to play
        XCUIRemote.shared.press(.select)
        settle(0.8)
        snap("02-tvos-playing")

        // 3 -- pause again
        XCUIRemote.shared.press(.select)
        settle(0.6)

        // 4 -- navigate to a swatch (down then to white)
        XCUIRemote.shared.press(.down)
        settle(0.4)
        // try 백색
        let white = app.buttons["noise-white"]
        if white.waitForExistence(timeout: 2) {
            // step left until white is focused
            for _ in 0..<3 {
                if white.hasFocus { break }
                XCUIRemote.shared.press(.left)
                settle(0.3)
            }
            XCUIRemote.shared.press(.select)
            settle(1.5)
            snap("03-tvos-noise-white")
        }

        // 5 -- pick a lullaby
        XCUIRemote.shared.press(.down)
        settle(0.4)
        let brahms = app.buttons["lullaby-brahms"]
        if brahms.waitForExistence(timeout: 2) {
            for _ in 0..<5 {
                if brahms.hasFocus { break }
                XCUIRemote.shared.press(.left)
                settle(0.3)
            }
            XCUIRemote.shared.press(.select)
            settle(1.5)
            snap("04-tvos-lullaby-brahms")
        }

        // 6 -- enter glow mode (navigate up to controls, find glow toggle, select)
        XCUIRemote.shared.press(.up)
        settle(0.3)
        XCUIRemote.shared.press(.up)
        settle(0.3)
        let glow = app.buttons["glow-toggle"]
        if glow.exists {
            // Step right through controls until focused
            for _ in 0..<6 {
                if glow.hasFocus { break }
                XCUIRemote.shared.press(.right)
                settle(0.3)
            }
            if glow.hasFocus {
                XCUIRemote.shared.press(.select)
                settle(1.0)
                snap("05-tvos-glow-mode")
                XCUIRemote.shared.press(.menu)
                settle(0.6)
            }
        }

        // 7 -- enter tummy time slideshow
        let tummy = app.buttons["tummy-toggle"]
        if tummy.exists {
            for _ in 0..<6 {
                if tummy.hasFocus { break }
                XCUIRemote.shared.press(.right)
                settle(0.3)
            }
            if tummy.hasFocus {
                XCUIRemote.shared.press(.select)
                settle(1.5)
                snap("06-tvos-tummy-slideshow")
            }
        }
    }
    #endif
}
