import Foundation

enum WidgetRoutineFilterType: String, Codable {
    case morning
    case afternoon
    case evening
    case custom
}

struct WidgetRoutineUIData: Identifiable, Codable {
    var id: UUID
    var titleKey: String
    var icon: String
    var colorHex: String
    var filterType: WidgetRoutineFilterType
    var assignedHabitIDs: [String]?
}

let json = """
[
  {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "titleKey": "Test",
    "icon": "A",
    "colorHex": "#FFFFFF",
    "filterType": "morning",
    "assignedHabitIDs": [],
    "isTimerMode": false
  }
]
"""
do {
    let routines = try JSONDecoder().decode([WidgetRoutineUIData].self, from: json.data(using: .utf8)!)
    print(routines)
} catch {
    print("Error: \(error)")
}
