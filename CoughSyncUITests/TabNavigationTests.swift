//
// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
//
//  TabNavigationTests.swift
//  CoughSyncUITests
//
//  Created by Miguel Fuentes on 3/6/25.
//

import XCTest
import XCTestExtensions


final class TabNavigationTests: XCTestCase {
    @MainActor
    override func setUp() async throws {
        continueAfterFailure = false
        
        let app = XCUIApplication()
        app.launchArguments = ["--setupTestAccount", "--skipOnboarding"]
        app.deleteAndLaunch(withSpringboardAppName: "CoughSync")
    }
    
    @MainActor
    func testTabNavigation() async throws {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        
        // Test Dashboard exists
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Dashboard"].exists)
        app.tabBars["Tab Bar"].buttons["Dashboard"].tap()
        XCTAssertTrue(app.staticTexts["Summary"].waitForExistence(timeout: 2))
        
        // Test Check In exists
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Check In"].exists)
        app.tabBars["Tab Bar"].buttons["Check In"].tap()
        XCTAssertTrue(app.staticTexts["Questionnaires"].waitForExistence(timeout: 2))
        
        // Test Cough Tracking exists
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Cough Tracking"].exists)
        app.tabBars["Tab Bar"].buttons["Cough Tracking"].tap()
        XCTAssertTrue(app.staticTexts["Cough Tracker"].waitForExistence(timeout: 2))
    }
}
