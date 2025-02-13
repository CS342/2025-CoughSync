//
//  SoundAnalysisManager.swift
//  CoughSync
//
//  Created by Ethan Bell on 12/2/2025.
//

import Combine
import Foundation
@preconcurrency import SoundAnalysis


final class SoundAnalysisManager: NSObject, @unchecked Sendable {
    @MainActor static let shared = SoundAnalysisManager()
    private let bufferSize = 8192
    
    private var audioRecorder: AVAudioEngine?
    private var inputBus: AVAudioNodeBus?
    private var inputFormat: AVAudioFormat?
    
    private var streamAnalyzer: SNAudioStreamAnalyzer?
    
    private let analysisQueue = DispatchQueue(label: "com.createwithswift.AnalysisQueue")
    
    private var retainedObserver: SNResultsObserving?
    private var subject: PassthroughSubject<SNClassificationResult, Error>?
    
    override private init() {}
    
    func startSoundClassification(
        subject: PassthroughSubject<SNClassificationResult, Error>,
        inferenceWindowSize: Double? = nil,
        overlapFactor: Double? = nil
    ) {
        do {
            let observer = ResultsObserver(subject: subject)
            
            let soundClassifier = try CoughClassifier(configuration: MLModelConfiguration())
            let model = soundClassifier.model
            let request = try SNClassifySoundRequest(mlModel: model)
            
            if let inferenceWindowSize = inferenceWindowSize {
                request.windowDuration = CMTimeMakeWithSeconds(inferenceWindowSize, preferredTimescale: 48_000)
            }
            if let overlapFactor = overlapFactor {
                request.overlapFactor = overlapFactor
            }
            
            self.subject = subject
            try startAnalysis((request, observer))
        } catch {
            print("Unable to prepare request with Sound Classifier: \(error.localizedDescription)")
            subject.send(completion: .failure(error))
            self.subject = nil
        }
    }
    
    func stopSoundClassification() {
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
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            audioRecorder = AVAudioEngine()
            guard let audioRecorder = audioRecorder else {
                print("Failed to create audio engine")
                return
            }
            
            let inputNode = audioRecorder.inputNode
            let inputBus = AVAudioNodeBus(0)
            self.inputBus = inputBus
            
            self.inputFormat = audioRecorder.inputNode.inputFormat(forBus: inputBus)
            
            print("Audio format configured: \(String(describing: inputFormat))")
        } catch {
            print("Error setting up audio engine: \(error.localizedDescription)")
        }
    }

    private func startAnalysis(_ requestAndObserver: (request: SNRequest, observer: SNResultsObserving)) throws {
        setupAudioEngine()
        
        guard let audioRecorder = audioRecorder,
              let inputBus = inputBus,
              let inputFormat = inputFormat else { return }

        let streamAnalyzer = SNAudioStreamAnalyzer(format: inputFormat)
        self.streamAnalyzer = streamAnalyzer
        try streamAnalyzer.add(requestAndObserver.request, withObserver: requestAndObserver.observer)
        retainedObserver = requestAndObserver.observer
        self.audioRecorder?.inputNode.installTap(
            onBus: inputBus,
            bufferSize: UInt32(bufferSize),
            format: inputFormat
        ) { buffer, time in
            self.analysisQueue.async {
                self.streamAnalyzer?.analyze(buffer, atAudioFramePosition: time.sampleTime)
            }
        }
        
        do {
            try audioRecorder.start()
        } catch {
            print("Unable to start AVAudioEngine: \(error.localizedDescription)")
        }
    }
}
