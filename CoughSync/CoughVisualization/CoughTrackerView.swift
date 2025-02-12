import SwiftUI

struct CoughTrackerView: View {
    @StateObject private var coughTracker = CoughTracker()
    @StateObject private var coughDataReceiver = CoughDataReceiver()

    var body: some View {
        NavigationStack {
            List {
                Section {
                    CoughChartView(
                        coughEvents: coughTracker.coughEvents,
                        xName: "Time",
                        yName: "Cough Count",
                        title: "Hourly Coughs (Today)",
                        isWeekly: false
                    )
                }

              
                Section {
                    CoughChartView(
                        coughEvents: coughTracker.coughEvents,
                        xName: "Day",
                        yName: "Cough Count",
                        title: "Daily Coughs (Past 7 Days)",
                        isWeekly: true
                    )
                }
            }
            .navigationTitle("Cough Tracker")
            .onAppear {
                if coughTracker.coughEvents.isEmpty {
                    coughTracker.coughEvents = coughDataReceiver.generateFakeCoughData()
                }
            }
        }
    }
}

#Preview {
    CoughTrackerView()
}
