import DeviceActivity
import ManagedSettings
import Foundation

class MonitorExtension: DeviceActivityMonitor {
    
    nonisolated required override init() {
        super.init()
    }
    
    nonisolated override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        // Reset the flag for the new day if needed
    }
    
    nonisolated override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        // End of the day or interval
    }
    
    nonisolated override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        
        // This is called when the user exceeds their screen time limit!
        if event.rawValue == "screenTimeLimit" {
            // Create UserDefaults locally – avoids @MainActor isolation issues
            let defaults = UserDefaults(suiteName: "group.com.jannik.grovy")
            defaults?.set(true, forKey: "didExceedScreenTime")
            defaults?.set("Limit überschritten", forKey: "screenTimeExceededReason")
            defaults?.synchronize()
        }
    }
}
