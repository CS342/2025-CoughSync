//

// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

//  SoundDetectionViewModel.swift
//  CoughSync
//
//  Created by Ethan Bell on 12/2/2025.
//

import Combine
import Foundation
import Observation
import SoundAnalysis

@Observable
@MainActor
class SoundDetectionViewModel {
    @ObservationIgnored let soundAnalysisManager = SoundAnalysisManager.shared
    
    @ObservationIgnored var lastTime: Double = 0
    
    var detectionStarted = false
    var coughCount = 0
    var identifiedSound: (identifier: String, confidence: String)?
    private var detectionCancellable: AnyCancellable?
    
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
        
        if displayName == "Coughs" {
            coughCount += 1
        }
        
        return (displayName, confidencePercentString)
    }
    
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
        
        soundAnalysisManager.startSoundClassification(subject: classificationSubject)
    }
    
    func stopListening() {
        lastTime = 0
        identifiedSound = nil
        soundAnalysisManager.stopSoundClassification()
    }
}
