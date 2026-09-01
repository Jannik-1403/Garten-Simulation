import Foundation

// Copying minimal parts of HabitModel to test DailyProgressEntry
struct DailyProgressEntry: Codable, Equatable, Hashable {
    let timestamp: Date
    let progress: Double
}

var dict: [String: [DailyProgressEntry]] = [:]
dict["body.measure.brust"] = [DailyProgressEntry(timestamp: Date(), progress: 100.0)]

let encoder = JSONEncoder()
do {
    let data = try encoder.encode(dict)
    print("Success: \(data.count) bytes")
} catch {
    print("Error: \(error)")
}
