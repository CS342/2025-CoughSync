//
// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

@_spi(TestingSupport) import SpeziAccount
import SpeziScheduler
import SpeziSchedulerUI
import SpeziViews
import SwiftUI
import SpeziQuestionnaire


struct ScheduleView: View {
    @Environment(Account.self) private var account: Account?
    @Environment(CoughSyncScheduler.self) private var scheduler: CoughSyncScheduler
    @Environment(CoughSyncStandard.self) private var standard

    @State private var presentedEvent: Event?
    @Binding private var presentingAccount: Bool
    
    var body: some View {
        @Bindable var scheduler = scheduler

        NavigationStack {
            List {
                // Today's scheduled events
                Section {
                    TodayList { event in
                        InstructionsTile(event) {
                            EventActionButton(event: event, "Start Questionnaire") {
                                presentedEvent = event
                            }
                        }
                    }
                }
                
                // Daily Check-ins section
                Section(header: Text("Daily Check-ins")) {
                    ForEach(scheduler.events.filter { $0.task.id == "morning-checkin" }) { event in
                        InstructionsTile(event) {
                            EventActionButton(event: event, "Start Check-in") {
                                presentedEvent = event
                            }
                        }
                    }
                }
            }
            .navigationTitle("Questionnaires")
            .viewStateAlert(state: $scheduler.viewState)
            .sheet(item: $presentedEvent) { event in
                EventView(event)
            }
            .toolbar {
                if account != nil {
                    AccountButton(isPresented: $presentingAccount)
                }
            }
        }
    }
    
    init(presentingAccount: Binding<Bool>) {
        self._presentingAccount = presentingAccount
    }
}


#if DEBUG
#Preview("ScheduleView") {
    @Previewable @State var presentingAccount = false

    ScheduleView(presentingAccount: $presentingAccount)
        .previewWith(standard: CoughSyncStandard()) {
            Scheduler()
            CoughSyncScheduler()
            AccountConfiguration(service: InMemoryAccountService())
        }
}
#endif
