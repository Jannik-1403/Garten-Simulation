import Foundation

struct GratitudeJournalEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var date: Date = Date()
    var mood: Int // 1 to 5
    var thankfulFor: String
    var wentWell: String
    var doDifferently: String
    var improveTomorrow: String
}
