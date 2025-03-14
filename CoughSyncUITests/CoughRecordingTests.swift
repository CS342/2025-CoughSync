//
// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
//  CoughRecordingTests.swift
//  CoughSyncUITests
//
//  Created by Miguel Fuentes on 3/13/25.
//

import XCTest
import XCTestExtensions


final class CoughRecordingTests: XCTestCase {
    @MainActor
    override func setUp() async throws {
        continueAfterFailure = false
        
        let app = XCUIApplication()
        app.launchArguments = ["--setupTestAccount", "--skipOnboarding"]
        app.deleteAndLaunch(withSpringboardAppName: "CoughSync")
    }
    
    @MainActor
    func testcoughRecording() async throws {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        
        // Test Cough Tracking exists
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Summary"].exists)
        app.tabBars["Tab Bar"].buttons["Summary"].tap()
        XCTAssertTrue(app.staticTexts["Summary"].waitForExistence(timeout: 2))
        
        XCTAssertTrue(app.buttons["Start tracking"].waitForExistence(timeout: 2))
        app.buttons["Start tracking"].tap()
        
        XCTAssertTrue(app.buttons["OK"].waitForExistence(timeout: 2))
        app.buttons["OK"].tap()
        
        
        XCTAssertTrue(app.buttons["Stop tracking"].waitForExistence(timeout: 2))
        app.buttons["Stop tracking"].tap()
    }
}
