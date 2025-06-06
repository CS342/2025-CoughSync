//

// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

//  CoughDetectionViewModel.swift
//  CoughSync
//
//  Created by Ethan Bell on 12/2/2025.
//

import Combine
import Foundation
import Observation
import SoundAnalysis
import Spezi
import SwiftUI

/// A view model that manages cough detection and analysis.
///
/// This class coordinates between the UI and the cough analysis components,
/// processing detected sounds, tracking cough events, and storing cough data.
@Observable
@MainActor
class CoughDetectionViewModel {
    @ObservationIgnored let coughAnalysisManager = CoughAnalysisManager.shared
    
    // Environment property to access the standard
    private let standard: CoughSyncStandard
    
    @ObservationIgnored var lastTime: Double = 0
    
    var detectionStarted = false
    var detectionStatedDate: Date?
    var coughCollection = CoughCollection()
    var coughCount: Int {
        let coughCount = coughCollection.coughCount
        return coughCount
    }
    var identifiedSound: (identifier: String, confidence: String)?
    private var detectionCancellable: AnyCancellable?
    
    // Add these new properties
    var weeklyAverage: Int = 0
    var monthlyAverage: Int = 0
    
    /// Initializes the view model with the cough sync standard.
    ///
    /// - Parameter standard: The standard used for storing and retrieving cough data.
    init(standard: CoughSyncStandard) {
        self.standard = standard
    }
    
    /// Processes a sound classification result and determines if a cough was detected.
    ///
    /// This method evaluates the classification result, formats the display information,
    /// and adds a cough to the collection if one is detected with sufficient confidence.
    ///
    /// - Parameter result: The sound classification result from the analysis.
    /// - Returns: A tuple containing the identified sound name and confidence level, or nil if none.
    private func formattedDetectionResult(_ result: SNClassificationResult) -> (identifier: String, confidence: String)? {
        guard let classification = result.classifications.first else {
            return nil }
        
        if lastTime == 0 {
            lastTime = result.timeRange.start.seconds
        }
        
        let formattedTime = String(format: "%.2f", result.timeRange.start.seconds - lastTime)
        print("Analysis result for audio at time: \(formattedTime)")
        
        let displayName = classification.identifier.replacingOccurrences(of: "_", with: " ").capitalized
        let confidence = classification.confidence
        let confidencePercentString = String(format: "%.2f%%", confidence * 100.0)
        print("\(displayName): \(confidencePercentString) confidence.\n")
        
        if displayName == "Coughs" && confidence > 0.5 {
            let cough = Cough(timestamp: Date(), confidence: confidence)
            coughCollection.addCough(cough)
            
            // Store the cough in Firebase
            Task {
                await standard.add(cough: cough)
            }
        }
        
        return (displayName, confidencePercentString)
    }
    
    /// Starts the cough detection process.
    ///
    /// This method initializes a publisher for classification results and begins
    /// monitoring audio for cough sounds using the cough analysis manager.
    func startListening() {
        let classificationSubject = PassthroughSubject<SNClassificationResult, Error>()
        
        detectionCancellable = classificationSubject
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in
                    self.detectionStarted = false
                },
                receiveValue: { result in
                    self.identifiedSound = self.formattedDetectionResult(result)
                }
            )
        
        coughAnalysisManager.startCoughDetection(subject: classificationSubject)
    }
    
    /// Stops the cough detection process.
    ///
    /// This method resets the detection state and stops the audio analysis.
    func stopListening() {
        lastTime = 0
        identifiedSound = nil
        coughAnalysisManager.stopCoughDetection()
    }
    
    // Add this new method
    func fetchCoughData(completion: @escaping (Bool) -> Void) {
        Task {
            do {
                // Fetch today's cough count
                let todayCount = try await standard.fetchTodayCoughCount()
                
                // Update the cough collection to reflect the current count
                coughCollection.setCount(todayCount)
                
                // Fetch weekly average
                weeklyAverage = try await standard.fetchWeeklyAverageCoughCount()
                
                // Fetch monthly average
                monthlyAverage = try await standard.fetchMonthlyAverageCoughCount()
                
                completion(true)
            } catch {
                print("Error fetching cough data: \(error)")
                completion(false)
            }
        }
    }
}
