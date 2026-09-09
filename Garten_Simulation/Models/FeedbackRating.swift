import Foundation

// MARK: - FeedbackRatingValue

enum FeedbackRatingValue: String, Codable {
    case up
    case down
    case none
}

// MARK: - FeedbackRating

struct FeedbackRating: Codable, Identifiable {
    var id: UUID
    /// Der Kalendertag, für den das Feedback galt (00:00:00 Uhr des jeweiligen Tages)
    var date: Date
    /// z. B. "feedbackWasserKritisch"
    var templateKey: String
    /// Die Platzhalterwerte zum Anzeigezeitpunkt, z. B. ["tage": 3]
    var contextValues: [String: Int]
    var rating: FeedbackRatingValue
    var ratedAt: Date

    init(date: Date, templateKey: String, contextValues: [String: Int] = [:]) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.templateKey = templateKey
        self.contextValues = contextValues
        self.rating = .none
        self.ratedAt = Date()
    }
}
