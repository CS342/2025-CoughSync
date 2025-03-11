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
        case summary
        case schedule
        case coughReport
    }
    
    @Environment(CoughSyncStandard.self) private var standard

    @AppStorage(StorageKeys.homeTabSelection) private var selectedTab = Tabs.summary
    @AppStorage(StorageKeys.tabViewCustomization) private var tabViewCustomization = TabViewCustomization()

    @State private var viewModel: CoughDetectionViewModel?
    @State private var presentingAccount = false

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Summary", systemImage: "rectangle.grid.2x2", value: .summary) {
                if viewModel != nil {
                    SummaryView(
                        presentingAccount: $presentingAccount,
                        viewModel: $viewModel
                    )
                } else {
                    ProgressView("Loading...")
                }
            }
            .customizationID("home.summary")
            
            Tab("Check In", systemImage: "list.clipboard", value: .schedule) {
                ScheduleView(presentingAccount: $presentingAccount)
            }
            .customizationID("home.schedule")

            Tab("Report", systemImage: "chart.bar.doc.horizontal", value: .coughReport) {
                CoughReportView(
                    presentingAccount: $presentingAccount,
                    viewModel: $viewModel
                )
            }
            .customizationID("home.coughreport")
        }
        .onAppear {
            // Initialize viewModel here when environment is available
            viewModel = CoughDetectionViewModel(standard: standard)
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
