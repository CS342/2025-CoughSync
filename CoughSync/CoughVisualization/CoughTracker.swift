//
// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestore
import Foundation
import Spezi
@_spi(TestingSupport) import SpeziAccount

struct CoughEvent: Identifiable, Codable {
    var id = UUID()
    var date: Date
}

class CoughTracker: ObservableObject {
    @Published var coughEvents: [CoughEvent] = []
    @Published var errorMessage: String?
    
    var standard: CoughSyncStandard?
    
    init(standard: CoughSyncStandard? = nil) {
        self.standard = standard
    }
    
    @MainActor
    func loadCoughEvents() async {
        guard let standard = standard else {
            errorMessage = "Standard not available"
            return
        }
        
        errorMessage = nil
        
        do {
            coughEvents = try await standard.fetchCoughEvents()
            // Only use real data from Firebase, no fallback to fake data
        } catch {
            errorMessage = "Failed to load cough data: \(error.localizedDescription)"
            coughEvents = []
        }
    }
}
