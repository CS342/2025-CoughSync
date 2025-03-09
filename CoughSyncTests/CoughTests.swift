//
// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
//
//  CoughTests.swift
//  CoughSyncTests
//
//  Created by Miguel Fuentes on 3/6/25.
//

@testable import CoughSync
import Foundation
import XCTest

class CoughTests: XCTestCase {
    @MainActor
    func testCoughInstance() throws {
        let date = Date()
        let cough = Cough(
            timestamp: date,
            confidence: 0.5
        )
        XCTAssertNotNil(cough.id)
        XCTAssertEqual(cough.timestamp, date)
        XCTAssertEqual(cough.confidence, 0.5)
    }
    
    @MainActor
    func testCoughCollection() throws {
        let coughCollection = CoughCollection()
        XCTAssertEqual(coughCollection.coughCount, 0)
        
        let cough1 = Cough(timestamp: Date(), confidence: 0.5)
        let cough2 = Cough(timestamp: Date(), confidence: 0.5)
        coughCollection.addCough(cough1)
        coughCollection.addCough(cough2)
        XCTAssertEqual(coughCollection.coughCount, 2)
        XCTAssertEqual(coughCollection.coughsToday(), 2)
    }
}
