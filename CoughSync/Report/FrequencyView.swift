//
// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Charts
import SwiftUI

struct FrequencyView: View {
    let dailyCoughs = CoughReportData.getDailyCoughs()
    let weeklyCoughs = CoughReportData.getWeeklyCoughs()
    let monthlyCoughs = CoughReportData.getMonthlyCoughs()

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 15) {
                        Text("Cough Trends")
                            .font(.largeTitle.bold())
                            .padding(.top)

                        CoughTrendChart(
                            title: "Daily Coughs (Past Week)",
                            data: dailyCoughs,
                            xLabels: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
                            chartHeight: geometry.size.height * 0.3 // Limits chart height
                        )

                        CoughTrendChart(
                            title: "Weekly Coughs (Past Month)",
                            data: weeklyCoughs,
                            xLabels: ["Week 1", "Week 2", "Week 3", "Week 4"],
                            chartHeight: geometry.size.height * 0.3
                        )

                        CoughTrendChart(
                            title: "Monthly Coughs (Past Year)",
                            data: monthlyCoughs,
                            xLabels: [
                                "Jan", "Feb", "Mar", "Apr", "May", "Jun",
                                "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
                            ],
                            chartHeight: geometry.size.height * 0.3
                        )
                    }
                    .padding()
                }
                .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 60) } // Prevents tab bar overlap
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    FrequencyView()
}
