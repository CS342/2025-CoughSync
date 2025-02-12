import Foundation

struct CoughBurdenProfile: Codable, Identifiable {
    let id: UUID
    let date: Date
    let coughBurden: CoughBurden
    let triggers: Set<CoughTrigger>
    let patientReportedOutcomes: PatientReportedOutcomes
    
    init(id: UUID = UUID(),
         date: Date = Date(),
         coughBurden: CoughBurden,
         triggers: Set<CoughTrigger>,
         patientReportedOutcomes: PatientReportedOutcomes) {
        self.id = id
        self.date = date
        self.coughBurden = coughBurden
        self.triggers = triggers
        self.patientReportedOutcomes = patientReportedOutcomes
    }
} 