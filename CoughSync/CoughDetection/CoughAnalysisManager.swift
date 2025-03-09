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

/// A singleton manager responsible for analyzing audio for cough detection.
///
/// This class handles the audio recording setup, processing, and analysis
/// using the `SoundAnalysis` framework to detect coughs in real-time audio.
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
    
    /// Starts a background task to prevent iOS from suspending the cough detection process.
    ///
    /// This method is called when starting cough detection to ensure the app
    /// can continue processing audio even when in the background.
    @MainActor
    func startBackgroundTask() {
        background = UIApplication.shared.beginBackgroundTask(withName: "CoughDetection") {
            UIApplication.shared.endBackgroundTask(self.background)
            self.background = .invalid
        }
    }
    
    /// Ends the background task when cough detection is no longer needed.
    @MainActor
    func endBackgroundTask() {
        if background != .invalid {
            UIApplication.shared.endBackgroundTask(background)
            background = .invalid
        }
    }
    
    /// Starts the cough detection process with the specified configuration.
    ///
    /// This method initializes the cough classifier, creates a sound classification request,
    /// and begins analyzing audio input for cough sounds. Results are published to the provided subject.
    ///
    /// - Parameters:
    ///   - subject: A `PassthroughSubject` that will publish classification results or errors.
    ///   - config: Configuration parameters for cough detection. Defaults to standard settings.
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
    
    /// Stops the cough detection process and cleans up resources.
    ///
    /// This method stops the audio engine, removes the analysis requests,
    /// and releases all related resources.
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
    
    /// Sets up the audio engine for recording with appropriate settings.
    ///
    /// Configures the audio session and AVAudioEngine for optimal cough detection.
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

    /// Starts the audio analysis with the specified request and observer.
    ///
    /// This method configures the audio stream analyzer and begins processing audio buffers.
    ///
    /// - Parameter requestAndObserver: A tuple containing the sound classification request and its observer.
    /// - Throws: An error if the analyzer cannot be set up or the audio engine cannot be started.
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
    
    /// Helper method to retain the observer object.
    private func useObserver() {
        _ = retainedObserver
    }
    
    /// Helper method to retain the subject object.
    private func useSubject() {
        _ = subject
    }
}
