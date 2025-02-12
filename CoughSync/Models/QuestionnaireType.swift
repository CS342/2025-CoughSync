//
//  QuestionnaireType.swift
//  CoughSync
//
//  Created by Miguel Fuentes on 2/11/25.
//

import Foundation

enum QuestionnaireType: String {
    case profile = "Profile"
    case checkIn = "CheckIn"
    
    func toFormattedString() -> String {
        return "\(self.rawValue)questionnaire"
    }
}
