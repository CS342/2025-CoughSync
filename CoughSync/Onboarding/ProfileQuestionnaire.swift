//
// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//


import SpeziOnboarding
import SpeziQuestionnaire
import SwiftUI


struct ProfileQuestionnaire: View {
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath
    @Environment(CoughSyncStandard.self) private var standard
    
    var body: some View {
        QuestionnaireView(
            questionnaire: Bundle.main.questionnaire(withName: "ProfileQuestionnaire")
        ) { result in
            guard case let .completed(response) = result else {
                return // user cancelled the task
            }
            await standard.add(
                response: response,
                questionnaireType: QuestionnaireType.profile
            )
            onboardingNavigationPath.nextStep()
        }
            .navigationBarBackButtonHidden()
            .toolbarVisibility(.hidden, for: .navigationBar)
    }
}

#if DEBUG
#Preview {
    OnboardingStack {
        ProfileQuestionnaire()
    }
}
#endif
