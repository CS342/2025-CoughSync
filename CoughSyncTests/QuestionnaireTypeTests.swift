//
// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
//
//  QuestionnaireTypeTests.swift
//  CoughSyncTests
//
//  Created by Miguel Fuentes on 3/6/25.
//

@testable import CoughSync
import Testing
import XCTest

class QuestionnaireTypeTests: XCTestCase {
    @MainActor
    func testQuestionnaireTypeDisplayNames() throws {
        let profile = QuestionnaireType.profile
        let checkIn = QuestionnaireType.checkIn
        XCTAssertEqual(profile.rawValue, "Profile")
        XCTAssertEqual(checkIn.rawValue, "CheckIn")
    }
}
