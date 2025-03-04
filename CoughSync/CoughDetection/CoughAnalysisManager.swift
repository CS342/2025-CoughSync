//

// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

//  CoughAnalysisManager.swift
//  CoughSync
//
//  Created by Ethan Bell on 12/2/2025.
//

import Combine
import Foundation
@preconcurrency import SoundAnalysis
import UIKit


final class CoughAnalysisManager: NSObject, @unchecked Sendable {
    @MainActor static let shared = CoughAnalysisManager()
    private let bufferSize = 8192
    
    private var audioRecorder: AVAudioEngine?
    private var inputBus: AVAudioNodeBus?
    private var inputFormat: AVAudioFormat?
    
    private var streamAnalyzer: SNAudioStreamAnalyzer?
    
    private let analysisQueue = DispatchQueue(
        label: "com.createwithswift.AnalysisQueue"
    )
    
    private var retainedObserver: SNResultsObserving?
    private var subject: PassthroughSubject<SNClassificationResult, Error>?
    
    var background: UIBackgroundTaskIdentifier = .invalid
    
    override private init() {}
    
    // to prevent IOS from shutting down recording process
    @MainActor
    func startBackgroundTask() {
        background = UIApplication.shared.beginBackgroundTask(withName: "CoughDetection") {
            UIApplication.shared.endBackgroundTask(self.background)
            self.background = .invalid
        }
    }
    
    @MainActor
    func endBackgroundTask() {
        if background != .invalid {
            UIApplication.shared.endBackgroundTask(background)
            background = .invalid
        }
    }
    
    @MainActor
    func startCoughDetection(
        subject: PassthroughSubject<SNClassificationResult, Error>,
        config: CoughDetectionConfiguration = CoughDetectionConfiguration()
    ) {
        startBackgroundTask()
        
        do {
            let observer = ResultsObserver(subject: subject)
            
            let soundClassifier = try CoughClassifier(configuration: MLModelConfiguration())
            let model = soundClassifier.model
            let request = try SNClassifySoundRequest(mlModel: model)
            
            request.windowDuration = CMTimeMakeWithSeconds(
                config.windowSize,
                preferredTimescale: config.timescale
            )
            request.overlapFactor = config.overlapFactor
            
            self.subject = subject
            useSubject()
            try startAnalysis((request, observer))
        } catch {
            print(
                "Unable to prepare request with Sound Classifier: \(error.localizedDescription)"
            )
            subject.send(completion: .failure(error))
            self.subject = nil
        }
    }
    
    @MainActor
    func stopCoughDetection() {
        endBackgroundTask()
        autoreleasepool {
            if let audioRecorder = audioRecorder {
                audioRecorder.stop()
                audioRecorder.inputNode.removeTap(onBus: 0)
            }
            if let streamAnalyzer = streamAnalyzer {
                streamAnalyzer.removeAllRequests()
            }
            streamAnalyzer = nil
            retainedObserver = nil
            audioRecorder = nil
        }
    }
    
    private func setupAudioEngine() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(
                .playAndRecord,
                mode: .default,
                options: [.allowBluetooth, .allowBluetoothA2DP, .defaultToSpeaker, .mixWithOthers]
            )
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            audioRecorder = AVAudioEngine()
            guard let audioRecorder = audioRecorder else {
                print("Failed to create audio engine")
                return
            }
            
            _ = audioRecorder.inputNode
            let inputBus = AVAudioNodeBus(0)
            self.inputBus = inputBus
            
            self.inputFormat = audioRecorder.inputNode.inputFormat(forBus: inputBus)
            
            print("Audio format configured: \(String(describing: inputFormat))")
        } catch {
            print("Error setting up audio engine: \(error.localizedDescription)")
        }
    }

    private func startAnalysis(
        _ requestAndObserver: (request: SNRequest, observer: SNResultsObserving)
    ) throws {
        setupAudioEngine()
        
        guard let audioRecorder = audioRecorder,
              let inputBus = inputBus,
              let inputFormat = inputFormat else { return }

        let streamAnalyzer = SNAudioStreamAnalyzer(format: inputFormat)
        self.streamAnalyzer = streamAnalyzer
        try streamAnalyzer.add(
            requestAndObserver.request,
            withObserver: requestAndObserver.observer
        )
        retainedObserver = requestAndObserver.observer
        useObserver()
        self.audioRecorder?.inputNode.installTap(
            onBus: inputBus,
            bufferSize: UInt32(bufferSize),
            format: inputFormat
        ) { buffer, time in
            self.analysisQueue.async {
                self.streamAnalyzer?.analyze(
                    buffer,
                    atAudioFramePosition: time.sampleTime
                )
            }
        }
        
        do {
            try audioRecorder.start()
        } catch {
            print("Unable to start AVAudioEngine: \(error.localizedDescription)")
        }
    }
    
    private func useObserver() {
        _ = retainedObserver
    }
    private func useSubject() {
        _ = subject
    }
}
