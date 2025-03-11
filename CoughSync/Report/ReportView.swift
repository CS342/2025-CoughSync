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
    @StateObject private var coughTracker = CoughTracker()
    @Binding var presentingAccount: Bool
    @Binding var viewModel: CoughDetectionViewModel?
    @State private var isLoadingData: Bool = true
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                let dailyData = coughTracker.generateDailyReportData()
                let weeklyData = coughTracker.generateWeeklyReportData()
                let monthlyData = coughTracker.generateMonthlyReportData()
                ScrollView {
                    if viewModel != nil, !isLoadingData {
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
            .onAppear {
                loadCoughData()
            }
            .navigationTitle("Report")
            .padding(.horizontal)
            .toolbar {
                if account != nil {
                    AccountButton(isPresented: $presentingAccount)
                }
            }
        }
    }
    
    private func loadCoughData() {
        isLoadingData = true
        viewModel?.fetchCoughData { success in
            isLoadingData = false
            if !success {
                // Handle error case if needed
                print("Failed to load cough data")
            }
        }
    }
}

#Preview {
    CoughReportView(
        presentingAccount: .constant(false),
        viewModel: .constant(CoughDetectionViewModel(
            standard: CoughSyncStandard()
        ))
    )
}
