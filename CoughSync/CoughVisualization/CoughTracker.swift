//
// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestore
import Foundation
import Spezi
@_spi(TestingSupport) import SpeziAccount

struct CoughEvent: Identifiable, Codable {
    var id = UUID()
    var date: Date
}

class CoughTracker: ObservableObject {
    @Published var coughEvents: [CoughEvent] = []
    @Published var errorMessage: String?
    
    var standard: CoughSyncStandard?
    
    init(standard: CoughSyncStandard? = nil) {
        self.standard = standard
    }
    
    @MainActor
    func loadCoughEvents() async {
        guard let standard = standard else {
            errorMessage = "Standard not available"
            return
        }
        
        errorMessage = nil
        
        do {
            coughEvents = try await standard.fetchCoughEvents()
            // Only use real data from Firebase, no fallback to fake data
        } catch {
            errorMessage = "Failed to load cough data: \(error.localizedDescription)"
            coughEvents = []
        }
    }
    
    func getCoughsBetweenDates(startDate: Date, endDate: Date) -> [CoughEvent] {
        // Filter coughEvents to find events between the specified dates (inclusive)
        coughEvents.filter { coughEvent in
            // Get calendar date components (ignoring time) for comparison
            let calendar = Calendar.current
            let eventDate = calendar.startOfDay(for: coughEvent.date)
            let start = calendar.startOfDay(for: startDate)
            let end = calendar.startOfDay(for: endDate)
            
            // Check if the event date is on or after the start date AND on or before the end date
            return eventDate >= start && eventDate <= end
        }
    }
    
    /**
     * Calculate percentage change in coughs between two time periods
     * @param currentPeriodCoughs Array of cough events in the current period
     * @param previousPeriodCoughs Array of cough events in the previous period
     * @return Percentage change (positive for increase, negative for decrease)
     */
    func calculatePercentageChange(currentPeriodCoughs: [CoughEvent], previousPeriodCoughs: [CoughEvent]) -> Double {
        let currentCount = currentPeriodCoughs.count
        let previousCount = previousPeriodCoughs.count
        
        // Avoid division by zero
        guard previousCount > 0 else {
            return currentCount > 0 ? 100.0 : 0.0 // If we went from 0 to something, that's a 100% increase
        }
        
        let change = Double(currentCount - previousCount) / Double(previousCount) * 100.0
        
        // Round to 1 decimal place
        return (change * 10).rounded() / 10
    }

    func findPeakCoughingTime(coughs: [CoughEvent], periodType: String) -> String {
        guard !coughs.isEmpty else {
            return "No data available"
        }
        
        let coughsByTimePeriod = groupCoughsByPeriod(coughs: coughs, periodType: periodType)
        
        return findPeakPeriod(from: coughsByTimePeriod) ?? "No data available"
    }

    private func groupCoughsByPeriod(coughs: [CoughEvent], periodType: String) -> [String: Int] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        var coughsByTimePeriod: [String: Int] = [:]
        
        switch periodType.lowercased() {
        case "daily":
            for cough in coughs {
                let timeBlock = getTimeBlock(cough: cough, calendar: calendar, formatter: formatter)
                coughsByTimePeriod[timeBlock, default: 0] += 1
            }
        case "weekly":
            for cough in coughs {
                let timeBlock = getWeeklyTimeBlock(cough: cough, calendar: calendar, formatter: formatter)
                coughsByTimePeriod[timeBlock, default: 0] += 1
            }
        case "monthly":
            for cough in coughs {
                let timeBlock = getMonthlyTimeBlock(cough: cough, calendar: calendar, formatter: formatter)
                coughsByTimePeriod[timeBlock, default: 0] += 1
            }
        default:
            return [:]
        }
        
        return coughsByTimePeriod
    }

    private func getTimeBlock(cough: CoughEvent, calendar: Calendar, formatter: DateFormatter) -> String {
        let hour = calendar.component(.hour, from: cough.date)
        let block = hour / 2 * 2
        
        formatter.dateFormat = "h:00 a"
        let startDate = calendar.date(bySettingHour: block, minute: 0, second: 0, of: cough.date) ?? Date()
        let endDate = calendar.date(bySettingHour: block + 2, minute: 0, second: 0, of: cough.date) ?? Date()
        
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }

    private func getWeeklyTimeBlock(cough: CoughEvent, calendar: Calendar, formatter: DateFormatter) -> String {
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEEE"
        let day = dayFormatter.string(from: cough.date)
        
        return "\(day) \(getTimeBlock(cough: cough, calendar: calendar, formatter: formatter))"
    }

    private func getMonthlyTimeBlock(cough: CoughEvent, calendar: Calendar, formatter: DateFormatter) -> String {
        let day = calendar.component(.day, from: cough.date)
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM"
        let monthName = monthFormatter.string(from: cough.date)
        
        return "\(monthName) \(day) at \(getTimeBlock(cough: cough, calendar: calendar, formatter: formatter))"
    }

    private func findPeakPeriod(from coughsByTimePeriod: [String: Int]) -> String? {
        coughsByTimePeriod.max(by: { $0.value < $1.value })?.key
    }


    /**
     * Generate data for a daily report
     * @param coughTracker The CoughTracker instance with cough data
     * @return Tuple containing percentage change and peak time
     */
    func generateDailyReportData() -> (percentage: Double, peakTime: String) {
        let calendar = Calendar.current
        
        // Get current date
        let now = Date()
        
        // Create start and end of today (00:00:00 to 23:59:59)
        let todayStart = calendar.startOfDay(for: now)
        let todayEnd = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: todayStart) ?? Date()
        
        // Create start and end of yesterday (00:00:00 to 23:59:59)
        let yesterdayStart = calendar.date(byAdding: .day, value: -1, to: todayStart) ?? Date()
        let yesterdayEnd = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: yesterdayStart) ?? Date()
        
        // Get coughs for the full 24-hour periods
        let todayCoughs = getCoughsBetweenDates(startDate: todayStart, endDate: todayEnd)
        let yesterdayCoughs = getCoughsBetweenDates(startDate: yesterdayStart, endDate: yesterdayEnd)
        
        let percentageChange = calculatePercentageChange(
            currentPeriodCoughs: todayCoughs,
            previousPeriodCoughs: yesterdayCoughs
        )
        
        let peakTime = findPeakCoughingTime(coughs: todayCoughs, periodType: "daily")
        
        return (percentageChange, peakTime)
    }

    /**
     * Generate data for a weekly report
     * @return Tuple containing percentage change and peak time
     */
    func generateWeeklyReportData() -> (percentage: Double, peakTime: String) {
        let calendar = Calendar.current
        var calendarWithMonday = calendar
        calendarWithMonday.firstWeekday = 2  // Set Monday as the first day of week (1 is Sunday, 2 is Monday)
        
        let today = Date()
        
        // Current week - Monday 00:00 to Sunday 23:59:59
        let startOfCurrentWeek = calendarWithMonday.date(
            from: calendarWithMonday.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        ) ?? Date()
        let endOfCurrentWeek = calendarWithMonday.date(byAdding: .day, value: 6, to: startOfCurrentWeek) ?? Date()
        let endOfCurrentWeekFinal = calendarWithMonday.date(bySettingHour: 23, minute: 59, second: 59, of: endOfCurrentWeek) ?? Date()
        
        // Previous week - Monday 00:00 to Sunday 23:59:59
        let startOfPreviousWeek = calendarWithMonday.date(byAdding: .weekOfYear, value: -1, to: startOfCurrentWeek) ?? Date()
        let endOfPreviousWeek = calendarWithMonday.date(byAdding: .day, value: 6, to: startOfPreviousWeek) ?? Date()
        let endOfPreviousWeekFinal = calendarWithMonday.date(bySettingHour: 23, minute: 59, second: 59, of: endOfPreviousWeek) ?? Date()
        
        let currentWeekCoughs = getCoughsBetweenDates(startDate: startOfCurrentWeek, endDate: endOfCurrentWeekFinal)
        let previousWeekCoughs = getCoughsBetweenDates(startDate: startOfPreviousWeek, endDate: endOfPreviousWeekFinal)
        
        let percentageChange = calculatePercentageChange(
            currentPeriodCoughs: currentWeekCoughs,
            previousPeriodCoughs: previousWeekCoughs
        )
        
        let peakTime = findPeakCoughingTime(coughs: currentWeekCoughs, periodType: "weekly")
        
        return (percentageChange, peakTime)
    }

    /**
     * Generate data for a monthly report
     * @return Tuple containing percentage change and peak time
     */
    func generateMonthlyReportData() -> (percentage: Double, peakTime: String) {
        let calendar = Calendar.current
        let today = Date()
        
        // Current month - 1st day 00:00 to last day 23:59:59
        let startOfCurrentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today)) ?? Date()
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: startOfCurrentMonth) ?? Date()
        let startOfNextMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: nextMonth)) ?? Date()
        let endOfCurrentMonth = calendar.date(byAdding: .second, value: -1, to: startOfNextMonth) ?? Date()
        
        // Previous month - 1st day 00:00 to last day 23:59:59
        let startOfPreviousMonth = calendar.date(byAdding: .month, value: -1, to: startOfCurrentMonth) ?? Date()
        let endOfPreviousMonth = calendar.date(byAdding: .second, value: -1, to: startOfCurrentMonth) ?? Date()
        
        let currentMonthCoughs = getCoughsBetweenDates(startDate: startOfCurrentMonth, endDate: endOfCurrentMonth)
        let previousMonthCoughs = getCoughsBetweenDates(startDate: startOfPreviousMonth, endDate: endOfPreviousMonth)
        
        let percentageChange = calculatePercentageChange(
            currentPeriodCoughs: currentMonthCoughs,
            previousPeriodCoughs: previousMonthCoughs
        )
        
        let peakTime = findPeakCoughingTime(coughs: currentMonthCoughs, periodType: "monthly")
        
        return (percentageChange, peakTime)
    }}
