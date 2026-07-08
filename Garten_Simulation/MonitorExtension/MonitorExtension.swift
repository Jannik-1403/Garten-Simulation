import DeviceActivity
import ManagedSettings
import Foundation

class MonitorExtension: DeviceActivityMonitor {
    
    // In order to share data between the extension and the main app, use App Groups
    private let sharedUserDefaults = UserDefaults(suiteName: "group.com.jannik.grovy")
    
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
            // Signal the main app to buy the bad habit
            sharedUserDefaults?.set(true, forKey: "didExceedScreenTime")
            sharedUserDefaults?.set("Limit überschritten", forKey: "screenTimeExceededReason")
            sharedUserDefaults?.synchronize()
        }
    }
}
