//
//  CoughClass.swift
//  CoughSync
//
//  Created by Ethan Bell on 22/2/2025.

// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
//
//

import Foundation

class Cough: Identifiable, Codable {
    let timestamp: Date
    let id: UUID
    let confidence: Double
    
    init(timestamp: Date = Date(), id: UUID = UUID(), confidence: Double = 0) {
        self.timestamp = timestamp
        self.id = id
        self.confidence = confidence
    }
}

class CoughCollection {
    private var coughArray: [Cough] = []
    
    var coughCount: Int {
        let coughCount = coughArray.count
        return coughCount
    }
    
    func addCough(_ cough: Cough) {
        coughArray.append(cough)
    }
    
    func coughsToday() -> Int {
        let coughToday = coughArray.filter { Calendar.current.isDateInToday($0.timestamp) }.count
        return coughToday
    }
    
    func coughDiffDay() -> Int {
        let coughToday = coughArray.filter { Calendar.current.isDateInToday($0.timestamp) }.count
        let coughYesterday = coughArray.filter { Calendar.current.isDateInYesterday($0.timestamp) }.count
        return coughToday - coughYesterday
    }
}
