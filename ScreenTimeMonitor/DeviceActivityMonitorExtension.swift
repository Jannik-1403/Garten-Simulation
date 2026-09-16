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
    let store = ManagedSettingsStore(named: .init("scheduled"))
    let dailyLimitStore = ManagedSettingsStore(named: .init("dailyLimit"))
    
    // MARK: - Interval Start → Block apps
    
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        
        if activity.rawValue.hasPrefix("com.jannik.grovy.screentime.block.limit.") {
            // New day started for daily limit tracker, clear the shield
            dailyLimitStore.shield.applications = nil
            dailyLimitStore.shield.applicationCategories = nil
            dailyLimitStore.shield.webDomains = nil
            dailyLimitStore.shield.webDomainCategories = nil
            sharedDefaults?.set(false, forKey: "screenTimeLimitExceededToday")
            sharedDefaults?.removeObject(forKey: "screenTimeDailyBlockedTokensData_appGroup")
            sharedDefaults?.synchronize()
            return
        }
        
        guard activity.rawValue.hasPrefix("com.jannik.grovy.screentime.block") else {
            // Not one of our block activities
            return
        }
        
        // Load the saved blockSelection from the App Group
        if let data = sharedDefaults?.data(forKey: "screenTimeBlockSelectionData_appGroup"),
           let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data),
           !selection.applicationTokens.isEmpty || !selection.categoryTokens.isEmpty || !selection.webDomainTokens.isEmpty {
            // Block only the selected apps/categories
            store.shield.applications = selection.applicationTokens
            store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(selection.categoryTokens)
            store.shield.webDomains = selection.webDomainTokens
            store.shield.webDomainCategories = ShieldSettings.ActivityCategoryPolicy.specific(selection.categoryTokens)
        } else {
            // No specific selection → block NOTHING
            store.shield.applications = nil
            store.shield.applicationCategories = nil
            store.shield.webDomains = nil
            store.shield.webDomainCategories = nil
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
        
        if event.rawValue.hasPrefix("dailyLimitEvent.") {
            let components = event.rawValue.components(separatedBy: ".")
            if components.count == 2, let index = Int(components[1]) {
                if let data = sharedDefaults?.data(forKey: "screenTimeLimitsArray_appGroup"),
                   let selections = try? JSONDecoder().decode([FamilyActivitySelection].self, from: data),
                   index < selections.count {
                    
                    let newlyBlockedSelection = selections[index]
                    
                    // Merge with currently blocked selection
                    var currentBlockedSelection = FamilyActivitySelection()
                    if let blockedData = sharedDefaults?.data(forKey: "screenTimeDailyBlockedTokensData_appGroup"),
                       let loadedBlocked = try? JSONDecoder().decode(FamilyActivitySelection.self, from: blockedData) {
                        currentBlockedSelection = loadedBlocked
                    }
                    
                    currentBlockedSelection.applicationTokens.formUnion(newlyBlockedSelection.applicationTokens)
                    currentBlockedSelection.categoryTokens.formUnion(newlyBlockedSelection.categoryTokens)
                    currentBlockedSelection.webDomainTokens.formUnion(newlyBlockedSelection.webDomainTokens)
                    
                    if let newBlockedData = try? JSONEncoder().encode(currentBlockedSelection) {
                        sharedDefaults?.set(newBlockedData, forKey: "screenTimeDailyBlockedTokensData_appGroup")
                    }
                    
                    dailyLimitStore.shield.applications = currentBlockedSelection.applicationTokens
                    dailyLimitStore.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(currentBlockedSelection.categoryTokens)
                    dailyLimitStore.shield.webDomains = currentBlockedSelection.webDomainTokens
                    dailyLimitStore.shield.webDomainCategories = ShieldSettings.ActivityCategoryPolicy.specific(currentBlockedSelection.categoryTokens)
                    
                    sharedDefaults?.set(true, forKey: "screenTimeLimitExceededToday")
                    sharedDefaults?.synchronize()
                }
            }
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
