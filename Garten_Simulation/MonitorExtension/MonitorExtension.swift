import DeviceActivity
import ManagedSettings
import Foundation

class MonitorExtension: DeviceActivityMonitor {
    
    // In order to share data between the extension and the main app, use App Groups
    private let sharedUserDefaults = UserDefaults(suiteName: "group.com.jannik.grovy")
    
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        // Reset the flag for the new day if needed
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        // End of the day or interval
    }
    
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        
        // This is called when the user exceeds their screen time limit!
        if event.rawValue == "screenTimeLimit" {
            // Signal the main app to buy the bad habit
            sharedUserDefaults?.set(true, forKey: "didExceedScreenTime")
            
            // Note: We cannot extract the exact app name that was used the most from this callback directly
            // due to Apple's strict privacy limitations. The best we can do is flag it.
            sharedUserDefaults?.set("Limit überschritten", forKey: "screenTimeExceededReason")
            sharedUserDefaults?.synchronize()
        }
    }
}
