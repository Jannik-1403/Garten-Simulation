import Foundation

let calendar = Calendar.current
let now = Date()
let weekday = calendar.component(.weekday, from: now)
let hour = calendar.component(.hour, from: now)
let minute = calendar.component(.minute, from: now)
let currentMinutes = hour * 60 + minute

print("Now: \(now)")
print("Weekday: \(weekday)")
print("Hour: \(hour)")
print("Minute: \(minute)")
print("Current Minutes: \(currentMinutes)")

let startMins = 7 * 60 + 0
let endMins = 17 * 60 + 0
print("Start Mins: \(startMins)")
print("End Mins: \(endMins)")

if startMins <= endMins {
    if currentMinutes >= startMins && currentMinutes < endMins {
        print("isCurrentlyBlocked = true")
    } else {
        print("isCurrentlyBlocked = false")
    }
} else {
    if currentMinutes >= startMins || currentMinutes < endMins {
        print("isCurrentlyBlocked = true")
    } else {
        print("isCurrentlyBlocked = false")
    }
}
