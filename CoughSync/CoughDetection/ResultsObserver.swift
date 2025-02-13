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

class ResultsObserver: NSObject, SNResultsObserving {
    private let subject: PassthroughSubject<SNClassificationResult, Error>
    
    init(subject: PassthroughSubject<SNClassificationResult, Error>) {
        self.subject = subject
    }
    
    func request(_ request: SNRequest, didProduce result: SNResult) {
        if let result = result as? SNClassificationResult {
            subject.send(result)
        }
    }

    func request(_ request: SNRequest, didFailWithError error: Error) {
        print("The analysis failed: \\(error.localizedDescription)")
        subject.send(completion: .failure(error))
    }
    
    func requestDidComplete(_ request: SNRequest) {
        print("The request completed successfully!")
        subject.send(completion: .finished)
    }
}
