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
    @MainActor
    func testContactsCount() throws {
        XCTAssertEqual(Contacts(presentingAccount: .constant(true)).contacts.count, 1)
    }
    
    // MARK: - CoughCollection Tests
    
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
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let yesterdayCough = Cough(timestamp: yesterday, confidence: 0.85)
        
        // Add coughs
        coughCollection.addCough(todayCough)
        coughCollection.addCough(yesterdayCough)
        
        // Verify
        XCTAssertEqual(coughCollection.coughsToday(), 1, "Should count only today's coughs")
        XCTAssertEqual(coughCollection.coughCount, 2, "Total cough count should be 2")
    }
    
    // MARK: - CoughDetectionViewModel Tests
    
    @MainActor
    func testCoughDetectionViewModelFetchData() async throws {
        // Enable Firebase disabling flag to avoid actual network calls
        FeatureFlags.disableFirebase = true
        
        // Create a standard
        let standard = CoughSyncStandard()
        
        // Create a view model
        let viewModel = CoughDetectionViewModel(standard: standard)
        
        // Create an expectation
        let expectation = XCTestExpectation(description: "Fetch cough data")
        
        // Fetch data
        viewModel.fetchCoughData { success in
            XCTAssertTrue(success, "Data fetch should succeed with disabled Firebase")
            expectation.fulfill()
        }
        
        // Wait for the expectation
        await fulfillment(of: [expectation], timeout: 2.0)
        
        // Verify the data was loaded (with Firebase disabled, values should be 0)
        XCTAssertEqual(viewModel.coughCount, 0)
        XCTAssertEqual(viewModel.weeklyAverage, 0)
        XCTAssertEqual(viewModel.monthlyAverage, 0)
        
        // Reset the flag
        FeatureFlags.disableFirebase = false
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
        // Create a date
        let testDate = Date()
        
        // Create a CoughEvent
        let coughEvent = CoughEvent(date: testDate)
        
        // Verify the date was stored correctly
        XCTAssertEqual(coughEvent.date, testDate, "CoughEvent should store the date correctly")
    }
}
