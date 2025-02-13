//
// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
@_spi(TestingSupport) import SpeziAccount
import SwiftUI
struct HomeView: View {
    enum Tabs: String {
        case schedule
        case contact
        case coughTracking
        case coughDetection
    }
    @AppStorage(StorageKeys.homeTabSelection) private var selectedTab = Tabs.schedule
    @AppStorage(StorageKeys.tabViewCustomization) private var tabViewCustomization = TabViewCustomization()
    @State private var presentingAccount = false
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Schedule", systemImage: "list.clipboard", value: .schedule) {
                ScheduleView(presentingAccount: $presentingAccount)
            }
            .customizationID("home.schedule")
            Tab("Cough Tracking", systemImage: "waveform.path.ecg", value: .coughTracking) {
                CoughTrackerView()
            }
            .customizationID("home.coughtracking")
            
            Tab("Cough Detection", systemImage: "speaker.wave.3.fill", value: .coughDetection) {
                CoughModelView()
            }
            .customizationID("home.coughdetection")

//            Tab("Contacts", systemImage: "person.fill", value: .contact) {
//                Contacts(presentingAccount: $presentingAccount)
//            }
//            .customizationID("home.contacts")
        }
        .tabViewStyle(.sidebarAdaptable)
        .tabViewCustomization($tabViewCustomization)
        .sheet(isPresented: $presentingAccount) {
            AccountSheet(dismissAfterSignIn: false) // presentation was user initiated, do not automatically dismiss
        }
        .accountRequired(!FeatureFlags.disableFirebase && !FeatureFlags.skipOnboarding) {
            AccountSheet()
        }
    }
}
#if DEBUG
#Preview {
    var details = AccountDetails()
    details.userId = "lelandstanford@stanford.edu"
    details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")
    return HomeView()
        .previewWith(standard: CoughSyncStandard()) {
            CoughSyncScheduler()
            AccountConfiguration(service: InMemoryAccountService(), activeDetails: details)
        }
}
#endif
