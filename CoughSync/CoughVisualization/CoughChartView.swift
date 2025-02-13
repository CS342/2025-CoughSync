//
// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Charts
import SwiftUI

struct CoughChartView: View {
    struct CoughData: Identifiable {
        var id = UUID()
        var date: Date
        var count: Int
    }

    let coughEvents: [CoughEvent]
    let xName: LocalizedStringResource
    let yName: LocalizedStringResource
    let title: LocalizedStringResource
    let isWeekly: Bool

    @State private var selectedElement: CoughData?

    let calendar = Calendar.current

    // Ensure every hour is displayed
    var groupedCoughsHourly: [CoughData] {
        let today = calendar.startOfDay(for: Date())

        var hourlyData: [Date: Int] = [:]
        for hour in 0..<24 {
            if let date = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: today) {
                hourlyData[date] = 0
            }
        }

        for event in coughEvents.filter({ calendar.isDate($0.date, inSameDayAs: today) }) {
            let hourStart = calendar.date(bySetting: .minute, value: 0, of: event.date) ?? event.date
            hourlyData[hourStart, default: 0] += 1
        }

        return hourlyData.map { CoughData(date: $0.key, count: $0.value) }
            .sorted { $0.date < $1.date }
    }

    // Ensure every day of the week is displayed
    var groupedCoughsWeekly: [CoughData] {
        let today = calendar.startOfDay(for: Date())
        let startOfWeek = calendar.date(byAdding: .day, value: -6, to: today) ?? today

        var dailyData: [Date: Int] = [:]
        for dayOffset in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) {
                dailyData[date] = 0
            }
        }

        for event in coughEvents.filter({ $0.date >= startOfWeek }) {
            let dayStart = calendar.startOfDay(for: event.date)
            dailyData[dayStart, default: 0] += 1
        }

        return dailyData.map { CoughData(date: $0.key, count: $0.value) }
            .sorted { $0.date < $1.date }
    }

    var maxCoughCount: Int {
        let maxHourly = groupedCoughsHourly.map(\.count).max() ?? 5
        let maxWeekly = groupedCoughsWeekly.map(\.count).max() ?? 5
        return max(maxHourly, maxWeekly) + 5
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(self.title)
                .font(.title3.bold())
                .listRowSeparator(.hidden)

            if let latest = (isWeekly ? groupedCoughsWeekly.last : groupedCoughsHourly.last) {
                Text("\(latest.date.formatted(isWeekly ? .dateTime.weekday() : .dateTime.hour().minute())): \(latest.count) coughs")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }

            chart
        }
    }

    private var chart: some View {
        Chart {
            let data = isWeekly ? groupedCoughsWeekly : groupedCoughsHourly

            ForEach(data) { dataPoint in
                BarMark(
                    x: .value(.init(self.xName), dataPoint.date, unit: isWeekly ? .day : .hour),
                    y: .value(.init(self.yName), dataPoint.count)
                )
                .foregroundStyle(.blue)
            }

            RuleMark(y: .value("Threshold", 5))
                .foregroundStyle(.primary)
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
        }
        .padding(.top, 10)
        .chartYScale(domain: 0...maxCoughCount)
        .chartXAxis {
            AxisMarks(values: .automatic) { date in
                AxisValueLabel {
                    if let date = date.as(Date.self) {
                        Text(date.formatted(isWeekly ? .dateTime.weekday(.abbreviated) : .dateTime.hour()))
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }
                AxisTick()
                AxisGridLine()
            }
        }
    }
}

#Preview {
    CoughChartView(
        coughEvents: [],
        xName: "Time",
        yName: "Cough Count",
        title: "COUGH_PLOT_TITLE",
        isWeekly: false
    )
}
