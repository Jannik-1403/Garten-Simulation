import Foundation

if let data = UserDefaults.standard.data(forKey: "screenTimeBlockSelectionData"),
   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
    print("Block Selection: \(json)")
} else {
    print("No block selection data found")
}

if let data = UserDefaults.standard.data(forKey: "screenTimeLimitsArray_appGroup"),
   let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
    print("Limits: \(json)")
} else {
    print("No limits data found")
}
