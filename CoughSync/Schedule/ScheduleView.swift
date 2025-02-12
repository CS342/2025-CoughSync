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


struct ScheduleView: View {
    @Environment(Account.self) private var account: Account?
    @Environment(CoughSyncScheduler.self) private var scheduler: CoughSyncScheduler

    @State private var presentedEvent: Event?
    @Binding private var presentingAccount: Bool
    @State private var detector = CoughDetection()
    @State private var isListening = false

    
    var body: some View {
        @Bindable var scheduler = scheduler

        NavigationStack {
            VStack {
                TodayList { event in
                    InstructionsTile(event) {
                        EventActionButton(event: event, "Start Questionnaire") {
                            presentedEvent = event
                        }
                    }
                }
                .navigationTitle("Questionnaires")
                .viewStateAlert(state: $scheduler.viewState)
                .sheet(item: $presentedEvent) { event in
                    EventView(event)
                }
            }
            .toolbar {
                if account != nil {
                    AccountButton(isPresented: $presentingAccount)
                }
            }
        }
        VStack {
            Text("Cough Counter: \(detector.coughCount)")
                .font(.largeTitle)
                .padding()
            
            List(detector.coughTimeStamps, id: \.self) { timestamp in
                Text("Cough at \(timestamp, style: .date)")
            }
            .frame(height: 300)
            
            Button(action: {
                if isListening {
                    detector.stopListen()
                } else {
                    detector.listen()
                }
                isListening.toggle()
            }) {
                Text(isListening ? "Stop Listening" : "Start Listening")
                    .font(.title)
            }
            .padding()
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
