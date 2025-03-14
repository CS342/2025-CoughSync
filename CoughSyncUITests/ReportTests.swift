//
// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
//  ReportTests.swift
//  CoughSyncUITests
//
//  Created by Miguel Fuentes on 3/13/25.
//

import XCTest
import XCTestExtensions


final class ReportTests: XCTestCase {
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
        
        // Test Cough Tracking exists
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Report"].exists)
        app.tabBars["Tab Bar"].buttons["Report"].tap()
        XCTAssertTrue(app.staticTexts["Report"].waitForExistence(timeout: 2))
        
        XCTAssertTrue(app.buttons["View Cough Frequency Trends →"].exists)
        app.buttons["View Cough Frequency Trends →"].tap()
        
        XCTAssertTrue(app.staticTexts["Hourly Coughs (Today)"].waitForExistence(timeout: 2))
    }
}
