//
// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

@_spi(TestingSupport) import SpeziAccount
import Spezi
import FirebaseFirestore
import Foundation

struct CoughEvent: Identifiable, Codable {
    var id = UUID()
    var date: Date
}

class CoughTracker: ObservableObject {
    @Published var coughEvents: [CoughEvent] = []
    @Published var isLoading: Bool = false
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
        
        isLoading = true
        errorMessage = nil
        
        do {
            coughEvents = try await standard.fetchCoughEvents()
            // Only use real data from Firebase, no fallback to fake data
        } catch {
            errorMessage = "Failed to load cough data: \(error.localizedDescription)"
            coughEvents = []
        }
        
        isLoading = false
    }
    
    func addCoughEvent(_ cough: Cough) {
        let coughEvent = CoughEvent(date: cough.timestamp)
        coughEvents.append(coughEvent)
    }
}
