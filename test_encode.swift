import Foundation

// Copying just enough of HabitModel to test encoding
struct TestModel: Codable {
    var customTrackerProgress: Double
}

let m = TestModel(customTrackerProgress: 0)
let encoder = JSONEncoder()
do {
    let data = try encoder.encode(m)
    print("Success: \(data)")
} catch {
    print("Error: \(error)")
}
