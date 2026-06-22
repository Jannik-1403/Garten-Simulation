import Foundation

struct WeedPatch: Codable {
    let source: String
}

let activeWeeds: [WeedPatch] = []
if let encoded = try? JSONEncoder().encode(activeWeeds) {
    UserDefaults.standard.set(encoded, forKey: "active_weeds")
}

if let data = UserDefaults.standard.data(forKey: "active_weeds") {
    print("Data found: \(data.count) bytes")
    if let decoded = try? JSONDecoder().decode([WeedPatch].self, from: data) {
        print("Decoded array with \(decoded.count) items")
    } else {
        print("Failed to decode")
    }
} else {
    print("No data found")
}

