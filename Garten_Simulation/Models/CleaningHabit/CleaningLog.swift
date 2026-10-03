import Foundation

/// Ein Erledigt-Eintrag für eine Aufräum-Aufgabe.
struct CleaningLog: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var taskId: UUID
    var timestamp: Date
}
