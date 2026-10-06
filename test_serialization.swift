import Foundation

let jsonString = """
[
  {
    "id": "123",
    "name": "habit.test",
    "symbolName": "leaf",
    "symbolColor": "green",
    "habitCategory": "lifestyle",
    "symbolism": "Test",
    "currentXP": 100,
    "streak": 5,
    "gekauftAm": 612312312,
    "maxLevel": 10,
    "xpPerCompletion": 100,
    "waterNeedPerDay": 1,
    "decayDays": 3,
    "missedCycles": 0,
    "lastNotifiedCycle": 0,
    "totalCoinsEarned": 50,
    "strafTage": 3,
    "wateringDates": [],
    "lebenBereitsAbgezogen": false,
    "isDead": false,
    "isNegative": false,
    "pfadCheckedDates": [],
    "allowManualTrackingForHealth": false,
    "isAppleHealthUnlinked": false,
    "isRoutineOnly": false,
    "isGenericFocus": false,
    "challengeJokers": 0,
    "priority": "medium",
    "todos": [],
    "sliderProgress": 0.0,
    "intradayProgressHistory": [],
    "scheduledWeekdays": [1, 2, 3, 4, 5, 6, 7],
    "trackingMode": "slider",
    "counterTarget": 10,
    "targetHistory": [],
    "dailyTargetSnapshots": {},
    "counterProgress": 0,
    "showStats": true,
    "showTodos": true,
    "showNotes": true,
    "showTimer": true,
    "showGoals": true,
    "showWeight": true,
    "showMeasurements": true,
    "manualWeightEntries": [],
    "bodyMeasurements": {},
    "targetMeasurements": {},
    "targetMeasurementsDates": {}
  }
]
"""

let data = jsonString.data(using: .utf8)!

if var jsonArray = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [[String: Any]] {
    print("JSONSerialization SUCCESS. Contains \(jsonArray.count) objects")
} else {
    print("JSONSerialization FAILED")
}
