import Foundation

struct PatientReportedOutcomes: Codable {
    /// Scale of 1-5 for all measurements
    let householdActivitiesLimitation: Int
    let strenuousPhysicalActivitiesLimitation: Int
    let socialInteractionsLimitation: Int
    let sleepDifficultyDueToCough: Int
    let sleepDisturbanceDueToCough: Int
    
    init(householdActivitiesLimitation: Int,
         strenuousPhysicalActivitiesLimitation: Int,
         socialInteractionsLimitation: Int,
         sleepDifficultyDueToCough: Int,
         sleepDisturbanceDueToCough: Int) {
        // Validate all inputs are between 1 and 5
        precondition(householdActivitiesLimitation >= 1 && householdActivitiesLimitation <= 5)
        precondition(strenuousPhysicalActivitiesLimitation >= 1 && strenuousPhysicalActivitiesLimitation <= 5)
        precondition(socialInteractionsLimitation >= 1 && socialInteractionsLimitation <= 5)
        precondition(sleepDifficultyDueToCough >= 1 && sleepDifficultyDueToCough <= 5)
        precondition(sleepDisturbanceDueToCough >= 1 && sleepDisturbanceDueToCough <= 5)
        
        self.householdActivitiesLimitation = householdActivitiesLimitation
        self.strenuousPhysicalActivitiesLimitation = strenuousPhysicalActivitiesLimitation
        self.socialInteractionsLimitation = socialInteractionsLimitation
        self.sleepDifficultyDueToCough = sleepDifficultyDueToCough
        self.sleepDisturbanceDueToCough = sleepDisturbanceDueToCough
    }
} 