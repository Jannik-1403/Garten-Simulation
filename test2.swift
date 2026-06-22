import Foundation

let suiteName = "group.com.jannik.grovy"
let suite = UserDefaults(suiteName: suiteName) ?? .standard

struct WeedPatch: Codable {
    let removalCost: Int
}

// 1. Save an array with 1 item
let weeds = [WeedPatch(removalCost: 50)]
if let encoded = try? JSONEncoder().encode(weeds) {
    suite.set(encoded, forKey: "active_weeds")
}

// 2. Read it back
if let data1 = suite.data(forKey: "active_weeds"), let decoded1 = try? JSONDecoder().decode([WeedPatch].self, from: data1) {
    print("Step 1: Loaded \(decoded1.count) weeds")
}

// 3. Clear it
let emptyWeeds: [WeedPatch] = []
if let encoded2 = try? JSONEncoder().encode(emptyWeeds) {
    suite.set(encoded2, forKey: "active_weeds")
}

// 4. Read it back
if let data2 = suite.data(forKey: "active_weeds"), let decoded2 = try? JSONDecoder().decode([WeedPatch].self, from: data2) {
    print("Step 2: Loaded \(decoded2.count) weeds")
} else {
    print("Step 2: Failed to decode")
}

