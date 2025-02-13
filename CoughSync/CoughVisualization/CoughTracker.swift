//
// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

@_spi(TestingSupport) import SpeziAccount

import Foundation

struct CoughEvent: Identifiable, Codable {
    var id = UUID()
    var date: Date
}

class CoughTracker: ObservableObject {
    @Published var coughEvents: [CoughEvent] = []
    
    //private let storageKey = "coughData"
    
    init() {
       // loadCoughEvents()
    }
    
    //    func addCoughEvent(date: Date) {
    //        let newCough = CoughEvent(date: date)
    //        coughEvents.append(newCough)
    //        saveCoughEvents()
    //    }
    
    //    private func saveCoughEvents() {
    //        if let encoded = try? JSONEncoder().encode(coughEvents) {
    //            UserDefaults.standard.set(encoded, forKey: storageKey)
    //        }
    //    }
//    
//    //private func loadCoughEvents() {
//        if let savedData = UserDefaults.standard.data(forKey: storageKey),
//           let decoded = try? JSONDecoder().decode([CoughEvent].self, from: savedData) {
//            coughEvents = decoded
//            print("Loaded \(coughEvents.count) existing cough events from UserDefaults")
//        } else {
//            print("No existing cough data found in UserDefaults")
//        }
//    }
}
