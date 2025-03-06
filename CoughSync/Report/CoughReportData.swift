//
// This source file is part of the CoughSync based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation

enum CoughReportData {
    // Fake data for now (replace with actual logic later)
    static func getDailyCoughs() -> [Int] {
        (0..<7).map { _ in Int.random(in: 10...50) } // 7 days of cough counts
    }
    
    static func getWeeklyCoughs() -> [Int] {
        (0..<4).map { _ in Int.random(in: 50...200) } // 4 weeks of cough counts
    }
    
    static func getMonthlyCoughs() -> [Int] {
        (0..<12).map { _ in Int.random(in: 200...800) } // 12 months of cough counts
    }
}
