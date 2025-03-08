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

/// A model representing a single cough event with timestamp, identifier, and confidence score.
///
/// This class encapsulates the data related to a detected cough event, including
/// when it occurred and the confidence level of the detection.
class Cough: Identifiable, Codable {
    let timestamp: Date
    let id: UUID
    let confidence: Double
    
    /// Initializes a new cough instance.
    ///
    /// - Parameters:
    ///   - timestamp: The date and time when the cough occurred. Defaults to current date/time.
    ///   - id: A unique identifier for the cough. Defaults to a new UUID.
    ///   - confidence: The confidence score of the cough detection (0.0-1.0). Defaults to 0.
    init(timestamp: Date = Date(), id: UUID = UUID(), confidence: Double = 0) {
        self.timestamp = timestamp
        self.id = id
        self.confidence = confidence
    }
}

/// A collection that manages and provides analytics for multiple cough events.
///
/// This class stores cough events and provides methods to query and analyze cough data,
/// such as counting coughs for specific time periods and calculating differences.
class CoughCollection {
    private var coughArray: [Cough] = []
    
    /// The total number of coughs in the collection.
    var coughCount: Int {
        let coughCount = coughArray.count
        return coughCount
    }
    
    /// Adds a new cough event to the collection.
    ///
    /// - Parameter cough: The cough event to add to the collection.
    func addCough(_ cough: Cough) {
        coughArray.append(cough)
    }
    
    /// Counts the number of coughs that occurred today.
    ///
    /// - Returns: The count of coughs detected on the current day.
    func coughsToday() -> Int {
        let coughToday = coughArray.filter { Calendar.current.isDateInToday($0.timestamp) }.count
        return coughToday
    }
}
