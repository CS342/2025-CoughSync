//
// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziAccount
import SwiftUI

/// A view that displays a summary of cough reports.
struct CoughReportView: View {
    @Environment(Account.self) private var account: Account?
    @Environment(CoughSyncStandard.self) private var standard
    @StateObject private var coughTracker = CoughTracker()
    @Binding var presentingAccount: Bool
    @State private var isLoadingData: Bool = true
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                reportContent
            }
            .onAppear {
                setupAndLoad()
            }
            .navigationTitle("Report")
            .padding(.horizontal)
            .toolbar {
                if account != nil {
                    AccountButton(isPresented: $presentingAccount)
                }
            }
            .refreshable {
                await coughTracker.loadCoughEvents()
            }
        }
    }

    private var reportContent: some View {
        let dailyData = coughTracker.generateDailyReportData()
        let weeklyData = coughTracker.generateWeeklyReportData()
        let monthlyData = coughTracker.generateMonthlyReportData()
        
        return ScrollView {
            if !isLoadingData {
                VStack(spacing: 10) {
                    ReportCard(title: "Daily Report", percentage: dailyData.percentage, peakTime: dailyData.peakTime)
                    ReportCard(title: "Weekly Report", percentage: weeklyData.percentage, peakTime: weeklyData.peakTime)
                    ReportCard(title: "Monthly Report", percentage: monthlyData.percentage, peakTime: monthlyData.peakTime)

                    NavigationLink(destination: CoughTrackerView()) {
                        Text("View Cough Frequency Trends →")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 10)
                }
                .padding()
                .frame(maxWidth: .infinity)
            } else {
                ProgressView("Loading cough data...")
                    .padding()
            }
        }
    }
    
    private func setupAndLoad() {
        coughTracker.standard = standard
        isLoadingData = true
        
        Task {
            await coughTracker.loadCoughEvents()
            isLoadingData = false
        }
    }
}

#Preview {
    CoughReportView(
        presentingAccount: .constant(false)
    )
}
