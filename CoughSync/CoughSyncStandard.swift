//
// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

@preconcurrency import FirebaseFirestore
@preconcurrency import FirebaseStorage
import HealthKitOnFHIR
import OSLog
@preconcurrency import PDFKit.PDFDocument
import Spezi
import SpeziAccount
import SpeziFirebaseAccount
import SpeziFirestore
import SpeziHealthKit
import SpeziOnboarding
import SpeziQuestionnaire
import SwiftUI


actor CoughSyncStandard: Standard,
                                   EnvironmentAccessible,
                                   HealthKitConstraint,
                                   ConsentConstraint,
                                   AccountNotifyConstraint {
    @Application(\.logger) private var logger

    @Dependency(FirebaseConfiguration.self) private var configuration

    init() {}


    func add(sample: HKSample) async {
        if FeatureFlags.disableFirebase {
            logger.debug("Received new HealthKit sample: \(sample)")
            return
        }
        
        do {
            try await healthKitDocument(id: sample.id)
                .setData(from: sample.resource)
        } catch {
            logger.error("Could not store HealthKit sample: \(error)")
        }
    }
    
    func remove(sample: HKDeletedObject) async {
        if FeatureFlags.disableFirebase {
            logger.debug("Received new removed healthkit sample with id \(sample.uuid)")
            return
        }
        
        do {
            try await healthKitDocument(id: sample.uuid).delete()
        } catch {
            logger.error("Could not remove HealthKit sample: \(error)")
        }
    }

    // periphery:ignore:parameters isolation
    func add(response: ModelsR4.QuestionnaireResponse, questionnaireType: QuestionnaireType, isolation: isolated (any Actor)? = #isolation) async {
        let id = response.identifier?.value?.value?.string ?? UUID().uuidString
        
        if FeatureFlags.disableFirebase {
            let jsonRepresentation = (try? String(data: JSONEncoder().encode(response), encoding: .utf8)) ?? ""
            await logger.debug("Received questionnaire response: \(jsonRepresentation)")
            return
        }
        
        do {
            try await configuration.userDocumentReference
                .collection("\(questionnaireType.rawValue)QuestionnaireResponse") // Add all HealthKit sources in a /QuestionnaireResponse collection.
                .document(id) // Set the document identifier to the id of the response.
                .setData(from: response)
        } catch {
            await logger.error("Could not store questionnaire response: \(error)")
        }
    }
    
    
    private func healthKitDocument(id uuid: UUID) async throws -> DocumentReference {
        try await configuration.userDocumentReference
            .collection("HealthKit") // Add all HealthKit sources in a /HealthKit collection.
            .document(uuid.uuidString) // Set the document identifier to the UUID of the document.
    }

    func respondToEvent(_ event: AccountNotifications.Event) async {
        if case let .deletingAccount(accountId) = event {
            do {
                try await configuration.userDocumentReference(for: accountId).delete()
            } catch {
                logger.error("Could not delete user document: \(error)")
            }
        }
    }
    
    @MainActor
    func store(consent: ConsentDocumentExport) async throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HHmmss"
        let dateString = formatter.string(from: Date())

        guard !FeatureFlags.disableFirebase else {
            guard let basePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                await logger.error("Could not create path for writing consent form to user document directory.")
                return
            }
            
            let filePath = basePath.appending(path: "consentForm_\(dateString).pdf")
            await consent.pdf.write(to: filePath)
            
            return
        }
        
        do {
            guard let consentData = await consent.pdf.dataRepresentation() else {
                await logger.error("Could not store consent form.")
                return
            }

            let metadata = StorageMetadata()
            metadata.contentType = "application/pdf"
            _ = try await configuration.userBucketReference
                .child("consent/\(dateString).pdf")
                .putDataAsync(consentData, metadata: metadata) { @Sendable _ in }
        } catch {
            await logger.error("Could not store consent form: \(error)")
        }
    }

    func add(cough: Cough) async {
        if FeatureFlags.disableFirebase {
            logger.debug("Received new cough event: \(cough.timestamp)")
            return
        }
        
        do {
            try await configuration.userDocumentReference
                .collection("CoughEvents") // Store all cough events in a /CoughEvents collection
                .document(UUID().uuidString) // Generate a unique ID for each cough event
                .setData([
                    "timestamp": cough.timestamp,
                    "confidence": cough.confidence
                ])
        } catch {
            logger.error("Could not store cough event: \(error)")
        }
    }

    func fetchCoughEvents() async throws -> [CoughEvent] {
        if FeatureFlags.disableFirebase {
            logger.debug("Firebase disabled - returning empty cough events list")
            return []
        }
        
        var coughEvents: [CoughEvent] = []
        
        do {
            let snapshot = try await configuration.userDocumentReference
                .collection("CoughEvents")
                .order(by: "timestamp", descending: false)
                .getDocuments()
            
            for document in snapshot.documents {
                let data = document.data()
                if let timestamp = data["timestamp"] as? Timestamp {
                    let date = timestamp.dateValue()
                    let coughEvent = CoughEvent(date: date)
                    coughEvents.append(coughEvent)
                }
            }
            
            return coughEvents
        } catch {
            logger.error("Error fetching cough events: \(error)")
            throw error
        }
    }
    
    func fetchTodayCoughCount() async throws -> Int {
        if FeatureFlags.disableFirebase {
            logger.debug("Firebase disabled - returning dummy today cough count")
            return 0
        }
        
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)
        
        do {
            let snapshot = try await configuration.userDocumentReference
                .collection("CoughEvents")
                .whereField("timestamp", isGreaterThanOrEqualTo: today)
                .whereField("timestamp", isLessThan: tomorrow ?? Date())
                .getDocuments()
            
            return snapshot.documents.count
        } catch {
            logger.error("Error fetching today's cough count: \(error)")
            throw error
        }
    }
    
    func fetchWeeklyAverageCoughCount() async throws -> Int {
        if FeatureFlags.disableFirebase {
            logger.debug("Firebase disabled - returning dummy weekly average")
            return 0
        }
        
        let today = Calendar.current.startOfDay(for: Date())
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: today) ?? Date()
        
        return try await fetchAverageCoughCount(from: weekAgo, to: today)
    }
    
    func fetchMonthlyAverageCoughCount() async throws -> Int {
        if FeatureFlags.disableFirebase {
            logger.debug("Firebase disabled - returning dummy monthly average")
            return 0
        }
        
        let today = Calendar.current.startOfDay(for: Date())
        let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: today) ?? Date()
        
        return try await fetchAverageCoughCount(from: monthAgo, to: today)
    }
    
    private func fetchAverageCoughCount(from startDate: Date, to endDate: Date) async throws -> Int {
        do {
            let coughEvents = try await fetchCoughEventsInRange(from: startDate, to: endDate)
            
            // Group events by day
            var dailyCounts: [Date: Int] = [:]
            for event in coughEvents {
                let day = Calendar.current.startOfDay(for: event.date)
                dailyCounts[day, default: 0] += 1
            }
            
            // Calculate average coughs per day
            let totalDays = max(1, dailyCounts.count) // Avoid division by zero
            let totalCoughs = coughEvents.count
            return Int(round(Double(totalCoughs) / Double(totalDays)))
        } catch {
            logger.error("Error calculating average cough count: \(error)")
            throw error
        }
    }
    
    private func fetchCoughEventsInRange(from startDate: Date, to endDate: Date) async throws -> [CoughEvent] {
        if FeatureFlags.disableFirebase {
            return []
        }
        
        var coughEvents: [CoughEvent] = []
        
        do {
            let snapshot = try await configuration.userDocumentReference
                .collection("CoughEvents")
                .whereField("timestamp", isGreaterThanOrEqualTo: startDate)
                .whereField("timestamp", isLessThan: endDate)
                .getDocuments()
            
            for document in snapshot.documents {
                let data = document.data()
                if let timestamp = data["timestamp"] as? Timestamp {
                    let date = timestamp.dateValue()
                    let coughEvent = CoughEvent(date: date)
                    coughEvents.append(coughEvent)
                }
            }
            
            return coughEvents
        } catch {
            logger.error("Error fetching cough events in range: \(error)")
            throw error
        }
    }
}
