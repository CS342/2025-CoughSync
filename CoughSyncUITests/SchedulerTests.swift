//
// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions


class SchedulerTests: XCTestCase {
    @MainActor
    override func setUp() async throws {
        continueAfterFailure = false
        
        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding"]
        app.deleteAndLaunch(withSpringboardAppName: "CoughSync")
    }
    

    @MainActor
    func testScheduler() throws {
        let app = XCUIApplication()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))

        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Schedule"].exists)
        app.tabBars["Tab Bar"].buttons["Schedule"].tap()
        
        XCTAssertTrue(app.buttons["Start Questionnaire"].waitForExistence(timeout: 2))
        app.buttons["Start Questionnaire"].tap()
        
        XCTAssertTrue(app.staticTexts["In the last week, how many times a day have you had coughing bouts?"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.navigationBars.buttons["Cancel"].exists)

        XCTAssertTrue(app.staticTexts["7 - None"].exists)
        let noButton = app.staticTexts["7 - None"]

        let nextButton = app.buttons["Next"]
        XCTAssertFalse(nextButton.isEnabled)
        noButton.tap()
        nextButton.tap()
        
        XCTAssertTrue(
            app.staticTexts["In the last week, which of the following factors triggered or worsened your cough?"]
                .waitForExistence(timeout: 2)
        )
        XCTAssertTrue(app.staticTexts["Air pollution"].exists)
        let airPollutionButton = app.staticTexts["Air pollution"]
        airPollutionButton.tap()
        nextButton.tap()
        
        XCTAssertTrue(app.staticTexts["In the last week, have you had a lot of energy?"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["7 - None of the time"].exists)
        let energyButton = app.staticTexts["7 - None of the time"]
        energyButton.tap()
        nextButton.tap()
        
        XCTAssertTrue(app.staticTexts["In the last week, has your cough disturbed your sleep?"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["7 - None of the time"].exists)
        let sleepButton = app.staticTexts["7 - None of the time"]
        sleepButton.tap()
        nextButton.tap()
        
        XCTAssertTrue(app.staticTexts["In the last week, my cough has interfered with my job, or other daily tasks."].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["7 - None of the time"].exists)
        let dailyTasksButton = app.staticTexts["7 - None of the time"]
        dailyTasksButton.tap()
        app.buttons["Done"].tap()

        XCTAssert(app.staticTexts["Completed"].waitForExistence(timeout: 0.5))
    }
}
