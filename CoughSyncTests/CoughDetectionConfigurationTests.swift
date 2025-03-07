//
// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
//
//  CoughDetectionConfigurationTests.swift
//  CoughSyncTests
//
//  Created by Miguel Fuentes on 3/6/25.
//

@testable import CoughSync
import XCTest

class CoughDetectionConfigurationTests: XCTestCase {
    @MainActor
    func testConfigurationProperties() throws {
        let config = CoughDetectionConfiguration(
            windowSize: 1.0, overlapFactor: 0.5, timescale: 48_000
        )
        XCTAssertEqual(config.windowSize, 1)
        XCTAssertEqual(config.overlapFactor, 0.5)
        XCTAssertEqual(config.timescale, 48_000)
    }
}
