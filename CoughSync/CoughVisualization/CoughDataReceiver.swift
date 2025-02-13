//
// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
// 
import Foundation

class CoughDataReceiver: ObservableObject {
    func generateFakeCoughData() -> [CoughEvent] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var fakeCoughEvents: [CoughEvent] = []

        // Generate hourly data for today
        for hour in 0..<24 {
            if let date = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: today) {
                let coughCount = Int.random(in: 0...5) // 0-5 coughs per hour
                for _ in 0..<coughCount {
                    fakeCoughEvents.append(CoughEvent(date: date))
                }
            }
        }

        // Generate daily data for the past 7 days
        for dayOffset in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) {
                let coughCount = Int.random(in: 5...20) // 5-20 coughs per day
                for _ in 0..<coughCount {
                    fakeCoughEvents.append(CoughEvent(date: date))
                }
            }
        }
        print("Generated Fake Data: \(fakeCoughEvents.count) cough events")

        return fakeCoughEvents
    }
}
