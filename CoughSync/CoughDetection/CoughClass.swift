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

class Cough {
    let timestamp: Date
    
    init(timestamp: Date = Date()) {
        self.timestamp = timestamp
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
