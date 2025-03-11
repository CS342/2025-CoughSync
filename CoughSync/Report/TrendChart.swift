//
// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Charts
import SwiftUI

struct CoughTrendChart: View {
    let title: String
    let data: [Int]
    let xLabels: [String]
    let chartHeight: CGFloat
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title2.bold())

            Chart {
                ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                    LineMark(
                        x: .value("Time", xLabels[index]),
                        y: .value("Coughs", value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(.blue)
                }
            }
            .frame(height: chartHeight) // Use dynamic height
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 14).fill(.ultraThinMaterial))
        .padding(.horizontal)
    }
}

#Preview {
    CoughTrendChart(
        title: "Daily Coughs (Past Week)",
        data: [10, 20, 30, 40, 50, 30, 20],
        xLabels: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
        chartHeight: 200
    )
}
