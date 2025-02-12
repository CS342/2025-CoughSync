import Foundation

class CoughDataReceiver: ObservableObject {
    func generateFakeCoughData() -> [CoughEvent] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var fakeCoughEvents: [CoughEvent] = []

        for hour in 0..<24 {
            if let date = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: today) {
                let coughCount = Int.random(in: 0...5) // 0-5 coughs per hour
                
                
                fakeCoughEvents.append(CoughEvent(date: date))
                
            }
        }

        for dayOffset in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) {
                let coughCount = Int.random(in: 5...20) // 5-20 coughs per day
                
                fakeCoughEvents.append(CoughEvent(date: date))
                
            }
        }

        return fakeCoughEvents
    }
}
