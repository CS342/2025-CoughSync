//
// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziOnboarding
import SwiftUI


struct OnboardingQuestionnaire: View {
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath
    @Environment(CoughSyncStandard.self) private var standard
    @State private var showQuestionnaire = false  // State to control when to show the questionnaire

    var body: some View {
        OnboardingView(
            contentView: {
                VStack {
                    OnboardingTitleView(
                        title: "Profile Questionnaire",
                        subtitle: "Help us understand your health better."
                    )
                    Spacer()
                    Image(systemName: "list.bullet.clipboard.fill")
                        .font(.system(size: 150))
                        .foregroundColor(.accentColor)
                        .accessibilityHidden(true)
                    Text("Please complete the questionnaire to personalize your experience.")
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 16)
                    Spacer()
                }
            },
            actionView: {
                OnboardingActionsView(
                    "Start Questionnaire",
                    action: {
                        onboardingNavigationPath.nextStep()
                    }
                )
            }
        )
    }
}


#Preview {
    OnboardingQuestionnaire()
}
