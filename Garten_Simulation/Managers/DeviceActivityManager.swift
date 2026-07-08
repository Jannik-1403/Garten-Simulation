import Foundation
import DeviceActivity
import FamilyControls
import SwiftUI

private extension Int {
    /// Returns self if > 0, otherwise nil (useful for UserDefaults default fallback)
    var nonZero: Int? { self > 0 ? self : nil }
}

@MainActor
class DeviceActivityManager: ObservableObject {
    static let shared = DeviceActivityManager()
    
    let center = DeviceActivityCenter()
    let activityName = DeviceActivityName("ScreenTimeDailyActivity")
    let eventName = DeviceActivityEvent.Name("screenTimeLimit")
    
    @Published var screenTimeGoalMinutes: Int {
        didSet { UserDefaults.standard.set(screenTimeGoalMinutes, forKey: "screenTimeGoalMinutes") }
    }
    
    private init() {
        self.screenTimeGoalMinutes = UserDefaults.standard.integer(forKey: "screenTimeGoalMinutes").nonZero ?? 120
    }
    
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
