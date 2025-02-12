//
//  CoughSyncDetection.swift
//  CoughSync
//
//  Created by Ethan Bell on 10/2/2025.
//

import Foundation
import class FirebaseFirestore.FirestoreSettings
import class FirebaseFirestore.MemoryCacheSettings
import Spezi
import SpeziAccount
import SpeziFirebaseAccount
import SpeziFirebaseAccountStorage
import SpeziFirebaseStorage
import SpeziFirestore
import SpeziHealthKit
import SpeziNotifications
import SpeziOnboarding
import SpeziScheduler
import SwiftUI
import AVFoundation
import SoundAnalysis

@Observable
@MainActor
class CoughDetection: NSObject, SNResultsObserving {
    private let audioRecorder = AVAudioEngine()
    private let analyser: SNAudioStreamAnalyzer
    private var request: SNClassifySoundRequest?
    
    var coughCount = 0
    private var coughTime: Date?
    var coughTimeStamps: [Date] = []
    
    private let syncQueue = DispatchQueue(label: "com.coughDetection.syncqueue", attributes: .concurrent)
    
    override init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, options: .mixWithOthers)
        } catch {
            print ("error \(error)")
        }
        let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 44100, channels: 1, interleaved: false)!
        self.analyser = SNAudioStreamAnalyzer(format: format)
        super.init()
    }
                             
    func listen() {
        let inputNode = audioRecorder.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.coughTime = Date()
            self.coughTimeStamps = []
        }
        
        
        do {
            self.request = try SNClassifySoundRequest(mlModel: CoughClassifier().model)
            try self.analyser.add(self.request!, withObserver: self)
            
            inputNode.installTap(
                onBus: 0,
                bufferSize: 1024,
                format: recordingFormat
            ) { [weak self] (buffer, time) in
                guard let self = self else { return }
                self.analyser.analyze(
                    buffer,
                    atAudioFramePosition: time.sampleTime
                )
            }
            
            self.audioRecorder.prepare()
            
           // DispatchQueue.main.async {
               // guard let self = self else { return }
                do {
                    try self.audioRecorder.start()
                } catch {
                    print("error with analysis \(error)")
                }
            //}
        } catch {
            print("error \(error)")
        }
    }

    func analyseAudio(buffer: AVAudioBuffer, at time: AVAudioTime) {
        self.analyser.analyze(buffer, atAudioFramePosition: time.sampleTime)
    }
                             
    func stopListen() {
        audioRecorder.stop()
        audioRecorder.inputNode.removeTap(onBus: 0)
    }
                             
    nonisolated func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let result = result as? SNClassificationResult else { return }
        
        if let bestClassification = result.classifications.first, bestClassification.identifier  == "Cough",
            bestClassification.confidence > 0.8 {
            
            syncQueue.async(flags: .barrier) { [weak self] in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.coughCount += 1
                    let timestamp = Date()
                    self.coughTimeStamps.append(timestamp)
                }
            }
            
            
        }
    }
    
    func getCoughTimestamps() -> [Date] {
        return coughTimeStamps
    }
    
}
