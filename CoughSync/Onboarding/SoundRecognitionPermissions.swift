import SpeziOnboarding
import SwiftUI

struct SoundRecognitionPermissions: View {
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath
    
    private let steps = [
        "Open Settings → Accessibility",
        "Tap Sound Recognition",
        "Enable Sound Recognition toggle",
        "Select Sounds and enable Cough"
    ]
    
    var body: some View {
        OnboardingView(
            contentView: {
                VStack(spacing: 20) {
                    OnboardingTitleView(
                        title: "Sound Recognition",
                        subtitle: "Enable cough detection"
                    )
                    
                    Image(systemName: "waveform.circle.fill")
                        .font(.system(size: 150))
                        .foregroundColor(.accentColor)
                        .accessibilityHidden(true)
                    
                    Text("To track your coughs automatically, we need you to enable Sound Recognition in your iPhone settings.")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top, spacing: 8) {
                                Text("\(index + 1).")
                                    .bold()
                                Text(step)
                            }
                        }
                    }
                    .padding()
                }
            },
            actionView: {
                VStack {
                    OnboardingActionsView(
                        "Open Settings",
                        action: {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                    )
                    
                    Button("Continue") {
                        onboardingNavigationPath.nextStep()
                    }
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 8)
                }
            }
        )
    }
} 