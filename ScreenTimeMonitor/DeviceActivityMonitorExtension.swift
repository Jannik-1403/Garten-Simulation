import DeviceActivity
import Foundation
import ManagedSettings
import FamilyControls

// MARK: - DeviceActivityMonitorExtension
// This extension runs in the background and is called by iOS when a DeviceActivitySchedule
// interval starts or ends. It activates/deactivates the App Shield without needing
// the main app to be open.

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    
    // Shared App Group so this extension can read the block selection stored by the main app
    let sharedDefaults = UserDefaults(suiteName: "group.com.jannik.grovy")
    let store = ManagedSettingsStore()
    
    // MARK: - Interval Start → Block apps
    
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        
        guard activity.rawValue.hasPrefix("com.jannik.grovy.screentime.block") else {
            // Not one of our block activities — handle screentime limit tracking
            sharedDefaults?.set(false, forKey: "screenTimeLimitExceededToday")
            return
        }
        
        // Load the saved blockSelection from the App Group
        if let data = sharedDefaults?.data(forKey: "screenTimeBlockSelectionData_appGroup"),
           let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data),
           !selection.applicationTokens.isEmpty || !selection.categoryTokens.isEmpty {
            // Block only the selected apps/categories
            store.shield.applications = selection.applicationTokens
            store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(selection.categoryTokens)
            store.shield.webDomains = selection.webDomainTokens
            store.shield.webDomainCategories = ShieldSettings.ActivityCategoryPolicy.specific(selection.categoryTokens)
        } else {
            // No specific selection → block all categories
            store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.all()
            store.shield.webDomainCategories = ShieldSettings.ActivityCategoryPolicy.all()
        }
        
        // Store in App Group so the main app knows the block is active
        sharedDefaults?.set(true, forKey: "screenTimeBlockCurrentlyActive")
        sharedDefaults?.synchronize()
    }
    
    // MARK: - Interval End → Unblock apps
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        
        guard activity.rawValue.hasPrefix("com.jannik.grovy.screentime.block") else {
            return
        }
        
        // Remove all scheduled shields
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
        store.shield.webDomainCategories = nil
        
        sharedDefaults?.set(false, forKey: "screenTimeBlockCurrentlyActive")
        sharedDefaults?.synchronize()
    }
    
    // MARK: - Threshold Reached → User exceeded their screen time limit
    
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        
        if event.rawValue == "screenTimeLimit" {
            sharedDefaults?.set(true, forKey: "screenTimeLimitExceededToday")
            sharedDefaults?.synchronize()
        }
    }
    
    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
    }
    
    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
    }
    
    override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventWillReachThresholdWarning(event, activity: activity)
    }
}
