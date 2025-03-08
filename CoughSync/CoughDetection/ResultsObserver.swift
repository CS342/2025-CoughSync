//

// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
//  ResultsObserver.swift
//  CoughSync
//
//  Created by Ethan Bell on 12/2/2025.
//

import Combine
import Foundation
import SoundAnalysis

/// An observer that processes sound analysis results and forwards them through a Combine publisher.
///
/// This class implements the `SNResultsObserving` protocol to receive callbacks from the
/// sound analysis system and converts them into events on a Combine subject.
class ResultsObserver: NSObject, SNResultsObserving {
    private let subject: PassthroughSubject<SNClassificationResult, Error>
    
    /// Initializes a new observer with a subject to publish results.
    ///
    /// - Parameter subject: The Combine subject that will receive classification results or errors.
    init(subject: PassthroughSubject<SNClassificationResult, Error>) {
        self.subject = subject
    }
    
    /// Processes a new result from the sound analysis system.
    ///
    /// This method is called when the sound analyzer produces a new result.
    /// If the result is a classification result, it forwards it to the subject.
    ///
    /// - Parameters:
    ///   - request: The request that produced the result.
    ///   - result: The analysis result.
    func request(_ request: SNRequest, didProduce result: SNResult) {
        if let result = result as? SNClassificationResult {
            subject.send(result)
        }
    }

    /// Handles errors that occur during sound analysis.
    ///
    /// This method is called when a sound analysis request fails.
    /// It logs the error and forwards it to the subject.
    ///
    /// - Parameters:
    ///   - request: The request that failed.
    ///   - error: The error that occurred.
    func request(_ request: SNRequest, didFailWithError error: Error) {
        print("The analysis failed: \\(error.localizedDescription)")
        subject.send(completion: .failure(error))
    }
    
    /// Handles the completion of a sound analysis request.
    ///
    /// This method is called when a sound analysis request completes successfully.
    /// It logs the completion and signals the subject that the stream has finished.
    ///
    /// - Parameter request: The request that completed.
    func requestDidComplete(_ request: SNRequest) {
        print("The request completed successfully!")
        subject.send(completion: .finished)
    }
}
