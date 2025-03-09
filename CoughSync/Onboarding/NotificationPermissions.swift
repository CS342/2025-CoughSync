//
// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziNotifications
import SpeziOnboarding
import SwiftUI


struct NotificationPermissions: View {
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath

    @Environment(\.requestNotificationAuthorization) private var requestNotificationAuthorization

    @State private var notificationProcessing = false
    @State private var notifTime = Date()
    
    var body: some View {
        OnboardingView(
            contentView: {
                VStack {
                    OnboardingTitleView(
                        title: "Notifications",
                        subtitle: "Spezi Scheduler Notifications."
                    )
                    Spacer()
                    Image(systemName: "bell.square.fill")
                        .font(.system(size: 150))
                        .foregroundColor(.accentColor)
                        .accessibilityHidden(true)
                    Text("NOTIFICATION_PERMISSIONS_DESCRIPTION")
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 16)
                    Text("Set your preferred time to receive your daily reminder to start recording (before going to sleep!)")
                        .font(.headline)
                        .padding(.top, 16)
                    DatePicker("Choose Reminder Time", selection: $notifTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .padding()
                    
                    Spacer()
                }
            }, actionView: {
                OnboardingActionsView(
                    "Allow Notifications",
                    action: {
                        do {
                            notificationProcessing = true
                            // Notification Authorization is not available in the preview simulator.
                            if ProcessInfo.processInfo.isPreviewSimulator {
                                try await _Concurrency.Task.sleep(for: .seconds(5))
                            } else {
                                try await requestNotificationAuthorization(options: [.alert, .sound, .badge])
                            }
                            saveNotifTime()
                            scheduleNotif()
                        } catch {
                            print("Could not request notification permissions.")
                        }
                        notificationProcessing = false
                        
                        onboardingNavigationPath.nextStep()
                    }
                )
            }
        )
            .navigationBarBackButtonHidden(notificationProcessing)
            // Small fix as otherwise "Login" or "Sign up" is still shown in the nav bar
            .navigationTitle(Text(verbatim: ""))
    }
    
    private func saveNotifTime() {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: notifTime)
        let minute = calendar.component(.minute, from: notifTime)
        
        UserDefaults.standard.set(hour, forKey: "notifHour")
        UserDefaults.standard.set(minute, forKey: "notifMinute")
    }
    
    private func scheduleNotif() {
        let savedHour = UserDefaults.standard.integer(forKey: "notifHour")
        let savedMinute = UserDefaults.standard.integer(forKey: "notifMinute")
        
        let content = UNMutableNotificationContent()
        content.title = "Time to start recording!"
        content.body = "Open the app to start recording your coughs."
        content.sound = .default
        
        var date = DateComponents()
        date.hour = savedHour
        date.minute = savedMinute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(identifier: "CoughSyncNotif", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}


#if DEBUG
#Preview {
    OnboardingStack {
        NotificationPermissions()
    }
        .previewWith {
            CoughSyncScheduler()
        }
}
#endif
