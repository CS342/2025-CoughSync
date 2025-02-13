//
//  ResultsObserver.swift
//  CoughSync
//
//  Created by Ethan Bell on 12/2/2025.
//

import Foundation
import SoundAnalysis
import Combine

// Observer object that is called as analysis results are found.
class ResultsObserver : NSObject, SNResultsObserving {
    
    // 1.
    private let subject: PassthroughSubject<SNClassificationResult, Error>
    
    init(subject: PassthroughSubject<SNClassificationResult, Error>) {
        self.subject = subject
    }
    
    // 2.
    func request(_ request: SNRequest, didProduce result: SNResult) {
        if let result = result as? SNClassificationResult {
            subject.send(result)
        }
    }
    
    // 3.
    func request(_ request: SNRequest, didFailWithError error: Error) {
        print("The analysis failed: \\(error.localizedDescription)")
        subject.send(completion: .failure(error))
    }
    
    // 4.
    func requestDidComplete(_ request: SNRequest) {
        print("The request completed successfully!")
        subject.send(completion: .finished)
    }
}
