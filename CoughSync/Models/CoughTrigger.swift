import Foundation

enum CoughTrigger: String, Codable, CaseIterable {
    case smoke = "Smoke"
    case pollen = "Pollen"
    case exercise = "Exercise"
    case coldWeather = "Cold Weather"
} 