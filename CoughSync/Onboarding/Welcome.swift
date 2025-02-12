//
// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziOnboarding
import SwiftUI


struct Welcome: View {
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath
    
    
    var body: some View {
        OnboardingView(
            title: "CoughSync",
            subtitle: "WELCOME_SUBTITLE",
            areas: [
                OnboardingInformationView.Content(
                    icon: {
                        Image(systemName: "apps.iphone")
                            .accessibilityHidden(true)
                    },
                    title: "Coughing Tracking",
                    description: "WELCOME_AREA1_DESCRIPTION"
                ),
                OnboardingInformationView.Content(
                    icon: {
                        Image(systemName: "list.bullet.clipboard.fill")
                            .accessibilityHidden(true)
                    },
                    title: "Well-Being Tracking",
                    description: "WELCOME_AREA2_DESCRIPTION"
                )
            ],
            actionText: "Get Started",
            action: {
                onboardingNavigationPath.nextStep()
            }
        )
            .padding(.top, 24)
    }
}


#if DEBUG
#Preview {
    OnboardingStack {
        Welcome()
    }
}
#endif
