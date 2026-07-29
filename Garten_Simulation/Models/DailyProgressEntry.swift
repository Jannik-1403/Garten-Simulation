import Foundation

struct DailyProgressEntry: Codable, Equatable, Hashable {
    let timestamp: Date
    let progress: Double
}
