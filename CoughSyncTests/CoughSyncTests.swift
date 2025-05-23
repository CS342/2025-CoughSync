//
// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

@testable import CoughSync
import XCTest


class CoughSyncTests: XCTestCase {
    // Removing the testContactsCount test as it references a non-existent Contacts class
    
    // MARK: - CoughCollection Tests
    
    func testCoughCollectionCount() {
        // Setup
        let coughCollection = CoughCollection()
        let cough1 = Cough(timestamp: Date(), confidence: 0.9)
        let cough2 = Cough(timestamp: Date(), confidence: 0.8)
        
        // Add coughs and verify count
        coughCollection.addCough(cough1)
        coughCollection.addCough(cough2)
        XCTAssertEqual(coughCollection.coughCount, 2, "CoughCollection should have 2 coughs")
    }
    
    func testCoughCollectionResetCoughs() {
        // Setup
        let coughCollection = CoughCollection()
        let cough1 = Cough(timestamp: Date(), confidence: 0.9)
        let cough2 = Cough(timestamp: Date(), confidence: 0.8)
        
        // Add coughs and verify count
        coughCollection.addCough(cough1)
        coughCollection.addCough(cough2)
        XCTAssertEqual(coughCollection.coughCount, 2, "CoughCollection should have 2 coughs")
        
        // Reset coughs and verify count is zero
        coughCollection.resetCoughs()
        XCTAssertEqual(coughCollection.coughCount, 0, "CoughCollection should have 0 coughs after reset")
    }
    
    func testCoughCollectionSetCount() {
        // Setup
        let coughCollection = CoughCollection()
        let initialCount = 5
        
        // Set count and verify
        coughCollection.setCount(initialCount)
        XCTAssertEqual(coughCollection.coughCount, initialCount, "CoughCollection should have \(initialCount) coughs")
        
        // Set a different count and verify
        let newCount = 3
        coughCollection.setCount(newCount)
        XCTAssertEqual(coughCollection.coughCount, newCount, "CoughCollection should have \(newCount) coughs after setCount")
    }
    
    func testCoughsToday() {
        // Setup
        let coughCollection = CoughCollection()
        let todayCough = Cough(timestamp: Date(), confidence: 0.9)
        
        // Yesterday's date
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        let yesterdayCough = Cough(timestamp: yesterday, confidence: 0.85)
        
        // Add coughs
        coughCollection.addCough(todayCough)
        coughCollection.addCough(yesterdayCough)
        
        // Verify
        XCTAssertEqual(coughCollection.coughsToday(), 1, "Should count only today's coughs")
        XCTAssertEqual(coughCollection.coughCount, 2, "Total cough count should be 2")
    }
    
    @MainActor
    func testCoughViewModelPropertiesUpdated() {
        // Create a standard
        let standard = CoughSyncStandard()
        
        // Create a view model
        let viewModel = CoughDetectionViewModel(standard: standard)
        
        // Test initial values
        XCTAssertEqual(viewModel.coughCount, 0, "Initial cough count should be 0")
        XCTAssertEqual(viewModel.weeklyAverage, 0, "Initial weekly average should be 0")
        XCTAssertEqual(viewModel.monthlyAverage, 0, "Initial monthly average should be 0")
        
        // Manually update properties
        viewModel.weeklyAverage = 5
        viewModel.monthlyAverage = 10
        
        // Check that properties were updated correctly
        XCTAssertEqual(viewModel.weeklyAverage, 5, "Weekly average should be updated to 5")
        XCTAssertEqual(viewModel.monthlyAverage, 10, "Monthly average should be updated to 10")
    }
    
    // MARK: - CoughEvent Tests
    
    func testCoughEventCreation() {
        let testDate = Date()
        let coughEvent = CoughEvent(date: testDate)
        XCTAssertEqual(coughEvent.date, testDate, "CoughEvent should store the date correctly")
    }
}
