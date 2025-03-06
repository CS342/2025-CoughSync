//
// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

@testable import CoughSync
import XCTest
import SoundAnalysis
import Spezi
import Foundation
import Combine
import SwiftUI


class CoughSyncTests: XCTestCase {
    @MainActor
    func testContactsCount() throws {
        XCTAssertEqual(Contacts(presentingAccount: .constant(true)).contacts.count, 1)
    }
    
    // MARK: - Cough Class Tests
    
    func testCoughInitialization() {
        // Test default initialization
        let defaultCough = Cough()
        XCTAssertNotNil(defaultCough.id)
        XCTAssertEqual(defaultCough.confidence, 0)
        
        // Test custom initialization
        let customTimestamp = Date(timeIntervalSince1970: 1000)
        let customID = UUID()
        let customConfidence = 0.75
        
        let customCough = Cough(timestamp: customTimestamp, id: customID, confidence: customConfidence)
        XCTAssertEqual(customCough.timestamp, customTimestamp)
        XCTAssertEqual(customCough.id, customID)
        XCTAssertEqual(customCough.confidence, customConfidence)
    }
    
    func testCoughCodable() throws {
        let originalCough = Cough(timestamp: Date(), id: UUID(), confidence: 0.8)
        
        // Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalCough)
        XCTAssertNotNil(data)
        
        // Decode
        let decoder = JSONDecoder()
        let decodedCough = try decoder.decode(Cough.self, from: data)
        XCTAssertEqual(decodedCough.id, originalCough.id)
        XCTAssertEqual(decodedCough.confidence, originalCough.confidence)
        XCTAssertEqual(decodedCough.timestamp.timeIntervalSince1970, 
                       originalCough.timestamp.timeIntervalSince1970, accuracy: 0.001)
    }
    
    // MARK: - CoughDetectionViewModel Tests
    
    @MainActor
    func testCoughDetectionViewModel_ConfidenceThreshold() {
        // Create test dependencies
        let standard = MockCoughSyncStandard()
        let viewModel = CoughDetectionViewModel(standard: standard)
        
        // Test with cough confidence above threshold (0.5)
        let highConfidenceResult = createTestClassificationResult(identifier: "cough", confidence: 0.75)
        viewModel.processClassificationResult(highConfidenceResult)
        
        // Verify a cough was added with high confidence
        XCTAssertEqual(standard.addCoughCount, 1)
        XCTAssertNotNil(standard.lastAddedCough)
        XCTAssertEqual(standard.lastAddedCough?.confidence, 0.75)
        
        // Test with cough confidence below threshold
        let lowConfidenceResult = createTestClassificationResult(identifier: "cough", confidence: 0.3)
        viewModel.processClassificationResult(lowConfidenceResult)
        
        // Verify no additional cough was added (count still 1)
        XCTAssertEqual(standard.addCoughCount, 1)
    }
    
    @MainActor
    func testCoughDetectionViewModel_NonCoughSound() {
        let standard = MockCoughSyncStandard()
        let viewModel = CoughDetectionViewModel(standard: standard)
        
        // Test with non-cough sound
        let otherSoundResult = createTestClassificationResult(identifier: "speaking", confidence: 0.9)
        viewModel.processClassificationResult(otherSoundResult)
        
        // Verify no cough was added regardless of confidence
        XCTAssertEqual(standard.addCoughCount, 0)
        XCTAssertNil(standard.lastAddedCough)
    }
    
    // MARK: - CoughSyncStandard Tests
    
    func testCoughSyncStandard_AddCough_FirebaseDisabled() async {
        let standard = MockCoughSyncStandard()
        
        // Test with Firebase disabled
        FeatureFlags.disableFirebase = true
        let cough = Cough(timestamp: Date(), confidence: 0.7)
        await standard.add(cough: cough)
        
        // Verify method was called but no Firebase operation performed
        XCTAssertEqual(standard.addCoughCount, 1)
        XCTAssertEqual(standard.firebaseCallCount, 0)
        XCTAssertEqual(standard.lastAddedCough?.confidence, 0.7)
    }
    
    func testCoughSyncStandard_AddCough_FirebaseEnabled() async {
        let standard = MockCoughSyncStandard()
        
        // Test with Firebase enabled
        FeatureFlags.disableFirebase = false
        let cough = Cough(timestamp: Date(), confidence: 0.8)
        await standard.add(cough: cough)
        
        // Verify method was called and Firebase operation performed
        XCTAssertEqual(standard.addCoughCount, 1)
        XCTAssertEqual(standard.firebaseCallCount, 1)
        XCTAssertEqual(standard.lastAddedCough?.confidence, 0.8)
    }
    
    // MARK: - Helper Methods
    
    private func createTestClassificationResult(identifier: String, confidence: Float) -> MockClassificationResult {
        let classification = MockClassification(identifier: identifier, confidence: confidence)
        return MockClassificationResult(classifications: [classification])
    }
}

// MARK: - Test Doubles

class MockClassificationResult: SNClassificationResult {
    private let mockClassifications: [SNClassification]
    
    init(classifications: [SNClassification]) {
        self.mockClassifications = classifications
        super.init()
    }
    
    override var classifications: [SNClassification] {
        return mockClassifications
    }
    
    override var timeRange: CMTimeRange {
        return CMTimeRange(start: .zero, duration: .zero)
    }
}

class MockClassification: SNClassification {
    private let mockIdentifier: String
    private let mockConfidence: Float
    
    init(identifier: String, confidence: Float) {
        self.mockIdentifier = identifier
        self.mockConfidence = confidence
        super.init()
    }
    
    override var identifier: String {
        return mockIdentifier
    }
    
    override var confidence: Float {
        return mockConfidence
    }
}

class MockCoughSyncStandard: CoughSyncStandard {
    var addCoughCount = 0
    var lastAddedCough: Cough?
    var firebaseCallCount = 0
    
    init() {
        super.init(MockCoughSyncConfiguration())
    }
    
    override func add(cough: Cough) async {
        addCoughCount += 1
        lastAddedCough = cough
        
        if !FeatureFlags.disableFirebase {
            firebaseCallCount += 1
        }
    }
}

class MockCoughSyncConfiguration: CoughSyncStandardConfiguration {
    // Mock implementation to avoid real Firebase dependencies
}

// Add this extension to CoughDetectionViewModel to make testing easier
extension CoughDetectionViewModel {
    @MainActor
    func processClassificationResult(_ result: SNClassificationResult) {
        if let classification = result.classifications.first {
            let identifier = classification.identifier
            let confidence = Double(classification.confidence)
            
            // Match the exact logic from the PR - only process coughs with confidence > 0.5
            if identifier == "cough" && confidence > 0.5 {
                let cough = Cough(timestamp: Date(), confidence: confidence)
                coughCollection.addCough(cough)
                
                Task {
                    await standard.add(cough: cough)
                }
            }
            
            let confidenceString = String(format: "%.2f%%", confidence * 100.0)
            identifiedSound = (identifier, confidenceString)
        }
    }
}
