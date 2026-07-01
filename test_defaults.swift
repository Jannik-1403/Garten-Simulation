import Foundation

if let defaults = UserDefaults(suiteName: "group.com.grovy.garden"),
   let data = defaults.data(forKey: "garden_plants") {
    if let jsonString = String(data: data, encoding: .utf8) {
        print("Plants JSON:")
        print(jsonString.prefix(500)) // Print the first 500 chars to avoid spam
    }
} else {
    print("No data found in UserDefaults")
}
