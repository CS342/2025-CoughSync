import Foundation

struct CoughBurden: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let severity: Int // Scale of 1-10
    let notes: String?
    
    init(id: UUID = UUID(), 
         timestamp: Date = Date(), 
         severity: Int,
         notes: String? = nil) {
        precondition(severity >= 1 && severity <= 10, "Severity must be between 1 and 10")
        self.id = id
        self.timestamp = timestamp
        self.severity = severity
        self.notes = notes
    }
} 