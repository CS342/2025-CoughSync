//
//  SoundAnalysisManager.swift
//  CoughSync
//
//  Created by Ethan Bell on 12/2/2025.
//

import Foundation
@preconcurrency import SoundAnalysis
import Combine


final class SoundAnalysisManager: NSObject {
    
    // 1.
    private let bufferSize = 8192
    
    private var audioEngine: AVAudioEngine?
    private var inputBus: AVAudioNodeBus?
    private var inputFormat: AVAudioFormat?
    
    private var streamAnalyzer: SNAudioStreamAnalyzer?
    
    private let analysisQueue = DispatchQueue(label: "com.createwithswift.AnalysisQueue")
    
    private var retainedObserver: SNResultsObserving?
    private var subject: PassthroughSubject<SNClassificationResult, Error>?
    
    @MainActor static let shared = SoundAnalysisManager()
    
    private override init() {}
    
    // 2.
    private func setupAudioEngine() {
        do {
            // 1. Configure audio session first
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            // 2. Initialize audio engine
            audioEngine = AVAudioEngine()
            guard let audioEngine = audioEngine else {
                print("Failed to create audio engine")
                return
            }
            
            // 3. Get input node format
            let inputNode = audioEngine.inputNode
            let inputBus = AVAudioNodeBus(0)
            self.inputBus = inputBus
            
            // 4. Get the format after audio session is properly configured
            self.inputFormat = audioEngine.inputNode.inputFormat(forBus: inputBus)
            
            print("Audio format configured: \(String(describing: inputFormat))") // Debug info
            
        } catch {
            print("Error setting up audio engine: \(error.localizedDescription)")
        }
    }
    
//    private func setupAudioEngine() {
//        audioEngine = AVAudioEngine()
//        let inputBus = AVAudioNodeBus(0)
//        self.inputBus = inputBus
//        inputFormat = audioEngine?.inputNode.inputFormat(forBus: inputBus)
////        inputFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 48000, channels: 1, interleaved: false)!
//    }

    // 3.
    private func startAnalysis(_ requestAndObserver: (request: SNRequest, observer: SNResultsObserving)) throws {
        // a.
        setupAudioEngine()
        
        // b.
        guard let audioEngine = audioEngine,
              let inputBus = inputBus,
              let inputFormat = inputFormat else { return }
        
        // c.
        let streamAnalyzer = SNAudioStreamAnalyzer(format: inputFormat)
        self.streamAnalyzer = streamAnalyzer
        // d.
        try streamAnalyzer.add(requestAndObserver.request, withObserver: requestAndObserver.observer)
        // e.
        retainedObserver = requestAndObserver.observer
        
        // f.
        self.audioEngine?.inputNode.installTap(
            onBus: inputBus,
            bufferSize: UInt32(bufferSize),
            format: inputFormat
        ) { buffer, time in
            self.analysisQueue.async {
                self.streamAnalyzer?.analyze(buffer, atAudioFramePosition: time.sampleTime)
            }
        }
        
        do {
            // g.
            try audioEngine.start()
        } catch {
            print("Unable to start AVAudioEngine: \(error.localizedDescription)")
        }
    }
    
    // 4
    func startSoundClassification(subject: PassthroughSubject<SNClassificationResult, Error>,
                                  inferenceWindowSize: Double? = nil,
                                  overlapFactor: Double? = nil) {
        do {
            let observer = ResultsObserver(subject: subject)
            
            // -- Request with custom Sound Classifier.
            let soundClassifier = try CoughClassifier(configuration: MLModelConfiguration())
            let model = soundClassifier.model
            let request = try SNClassifySoundRequest(mlModel: model)
            // ----------------
            
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
    
    // 5.
    func stopSoundClassification() {
        // a.
        autoreleasepool {
            // b.
            if let audioEngine = audioEngine {
                audioEngine.stop()
                audioEngine.inputNode.removeTap(onBus: 0)
            }
            // c.
            if let streamAnalyzer = streamAnalyzer {
                streamAnalyzer.removeAllRequests()
            }
            // d.
            streamAnalyzer = nil
            retainedObserver = nil
            audioEngine = nil
        }
    }
}
