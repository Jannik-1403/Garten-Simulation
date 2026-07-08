import Foundation
import DeviceActivity
import FamilyControls
import SwiftUI

@MainActor
class DeviceActivityManager: ObservableObject {
    static let shared = DeviceActivityManager()
    
    let center = DeviceActivityCenter()
    let activityName = DeviceActivityName("ScreenTimeDailyActivity")
    let eventName = DeviceActivityEvent.Name("screenTimeLimit")
    
    @AppStorage("screenTimeGoalMinutes") var screenTimeGoalMinutes: Int = 120 // Default 2 hours
    
    func scheduleActivity(selection: FamilyActivitySelection) {
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true,
            warningTime: DateComponents(minute: 10)
        )
        
        let event = DeviceActivityEvent(
            applications: selection.applicationTokens,
            categories: selection.categoryTokens,
            webDomains: selection.webDomainTokens,
            threshold: DateComponents(minute: screenTimeGoalMinutes)
        )
        
        do {
            try center.startMonitoring(activityName, during: schedule, events: [eventName: event])
            print("Successfully scheduled DeviceActivityMonitor.")
        } catch {
            print("Failed to schedule DeviceActivityMonitor: \(error.localizedDescription)")
        }
    }
    
    func stopMonitoring() {
        center.stopMonitoring([activityName])
    }
}
