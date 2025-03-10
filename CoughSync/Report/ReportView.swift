//
// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

/// A view that displays a summary of cough reports.
struct CoughReportView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Cough Report")
                    .font(.largeTitle.bold())

                ScrollView {
                    VStack(spacing: 15) {
                        ReportCard(title: "Daily Report", percentage: 12.5, peakTime: "8:00 PM - 10:00 PM")
                        ReportCard(title: "Weekly Report", percentage: -8.3, peakTime: "Wednesday 9:00 AM - 11:00 AM")
                        ReportCard(title: "Monthly Report", percentage: 5.2, peakTime: "January 15 at 7:00 PM - 9:00 PM")

                        NavigationLink(destination: FrequencyView()) {
                            Text("View Cough Frequency Trends →")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        .padding(.top, 10)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .padding(.horizontal)
        }
    }
}

#Preview {
    CoughReportView()
}
