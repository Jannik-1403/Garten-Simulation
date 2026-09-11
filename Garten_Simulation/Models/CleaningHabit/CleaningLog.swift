import Foundation

struct CleaningLog: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var taskId: UUID
    var timestamp: Date
}
