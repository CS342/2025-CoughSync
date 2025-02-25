//
// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import Spezi
import SpeziScheduler
import SpeziViews
import class ModelsR4.Questionnaire
import class ModelsR4.QuestionnaireResponse


@Observable
final class CoughSyncScheduler: Module, DefaultInitializable, EnvironmentAccessible {
    @Dependency(Scheduler.self) @ObservationIgnored private var scheduler

    @MainActor var viewState: ViewState = .idle

    init() {}
    
    /// Add or update the current list of task upon app startup.
    func configure() {
        do {
            try scheduler.createOrUpdateTask(
                id: "cough-sync-questionnaire",
                title: "Cough Sync",
                instructions: "Tell us about your cough every week.",
                category: .questionnaire,
                schedule: .weekly(hour: 8, minute: 0, startingAt: .today)
            ) { context in
                context.questionnaire = Bundle.main.questionnaire(withName: "CoughBurdenQuestionnaire")
            }
            
            try scheduler.createOrUpdateTask(
                id: "morning-checkin",
                title: "Morning Check-in",
                instructions: "Track your morning symptoms",
                category: .questionnaire,
                schedule: .daily(hour: 8, minute: 0)
            ) { context in
                context.questionnaire = Bundle.main.questionnaire(withName: "MorningCheckInQuestionnaire")
            }
        } catch {
            viewState = .error(AnyLocalizedError(error: error, defaultErrorDescription: "Failed to create or update scheduled tasks."))
        }
    }
}


extension Task.Context {
    @Property(coding: .json) var questionnaire: Questionnaire?
}


extension Outcome {
    // periphery:ignore - demonstration of how to store additional context within an outcome
    @Property(coding: .json) var questionnaireResponse: QuestionnaireResponse?
}
