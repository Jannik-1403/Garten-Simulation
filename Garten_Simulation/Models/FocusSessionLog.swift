import Foundation

struct FocusSessionLog: Codable, Identifiable {
    var id: UUID = UUID()
    let date: Date
    let durationMinutes: Int
    let isCompleted: Bool
    
    // New optional metadata
    var isRoutine: Bool?
    var routineNameKey: String?
    var habitId: String?
    var habitName: String?
    var tasks: [String]?
}
