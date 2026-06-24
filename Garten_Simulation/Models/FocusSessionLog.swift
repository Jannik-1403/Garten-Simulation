import Foundation

struct FocusSessionLog: Codable, Identifiable {
    var id: UUID = UUID()
    let date: Date
    let durationMinutes: Int
    let isCompleted: Bool
}
