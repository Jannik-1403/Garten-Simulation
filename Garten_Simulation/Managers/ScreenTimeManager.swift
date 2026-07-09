import Combine
import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity
import SwiftUI

// MARK: - Per-Day Schedule

struct DaySchedule: Codable, Equatable {
    var isActive: Bool
    var startHour: Int
    var startMinute: Int
    var endHour: Int
    var endMinute: Int
    
    static let defaultWeekday = DaySchedule(isActive: true, startHour: 9, startMinute: 0, endHour: 17, endMinute: 0)
    static let defaultWeekend = DaySchedule(isActive: false, startHour: 10, startMinute: 0, endHour: 14, endMinute: 0)
}

// MARK: - ScreenTimeManager

@MainActor
class ScreenTimeManager: ObservableObject {
    static let shared = ScreenTimeManager()
    
    @AppStorage("screenTimeAllowedSelectionData") private var allowedSelectionData: Data?
    
    // MARK: - Permanent Blocks
    @Published var permanentBlockSelection = FamilyActivitySelection() {
        didSet {
            savePermanentBlockSelection()
            applyPermanentBlocks()
        }
    }
    
    @Published var isAdultFilterEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(isAdultFilterEnabled, forKey: "screenTimeAdultFilterEnabled")
            applyPermanentBlocks()
        }
    }
    
    // MARK: - Block Schedule (Per-Day)
    @Published var isScheduleActive: Bool = false {
        didSet {
            UserDefaults.standard.set(isScheduleActive, forKey: "isScreenTimeScheduleActive")
        }
    }
    
    /// Weekday schedule: key = Calendar weekday (1=Sun, 2=Mon ... 7=Sat)
    @Published var daySchedules: [Int: DaySchedule] = [:] {
        didSet {
            if let data = try? JSONEncoder().encode(daySchedules) {
                UserDefaults.standard.set(data, forKey: "screenTimeDaySchedulesData")
            }
        }
    }
    
    private var defaultSchedules: [Int: DaySchedule] {
        [1: .defaultWeekend, 2: .defaultWeekday, 3: .defaultWeekday,
         4: .defaultWeekday, 5: .defaultWeekday, 6: .defaultWeekday, 7: .defaultWeekend]
    }
    
    private func loadDaySchedules() {
        if let data = UserDefaults.standard.data(forKey: "screenTimeDaySchedulesData"),
           let decoded = try? JSONDecoder().decode([Int: DaySchedule].self, from: data) {
            self.daySchedules = decoded
        } else {
            self.daySchedules = defaultSchedules
        }
    }
    
    var isCurrentlyInBlockWindow: Bool {
        guard isScheduleActive else { return false }
        let now = Date()
        let calendar = Calendar.current
        let currentWeekday = calendar.component(.weekday, from: now)
        let previousWeekday = currentWeekday == 1 ? 7 : currentWeekday - 1
        
        let schedules = daySchedules
        
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        let currentTime = currentHour * 60 + currentMinute
        
        // Check today's schedule
        if let todaySchedule = schedules[currentWeekday], todaySchedule.isActive {
            let startTime = todaySchedule.startHour * 60 + todaySchedule.startMinute
            let endTime = todaySchedule.endHour * 60 + todaySchedule.endMinute
            
            if startTime <= endTime {
                if currentTime >= startTime && currentTime < endTime { return true }
            } else {
                // Over-midnight: started today
                if currentTime >= startTime { return true }
            }
        }
        
        // Check if we're in the tail of yesterday's over-midnight block
        if let yesterdaySchedule = schedules[previousWeekday], yesterdaySchedule.isActive {
            let startTime = yesterdaySchedule.startHour * 60 + yesterdaySchedule.startMinute
            let endTime = yesterdaySchedule.endHour * 60 + yesterdaySchedule.endMinute
            if startTime > endTime && currentTime < endTime { return true }
        }
        
        return false
    }
    
    /// Apps/Kategorien, die der Nutzer beim „Mit Handy"-Modus NICHT blockiert haben möchte
    @Published var allowedSelection = FamilyActivitySelection() {
        didSet { saveAllowedSelection() }
    }
    
    /// Apps/Kategorien, die explizit im Block-Zeitplan gesperrt werden sollen
    @Published var blockSelection = FamilyActivitySelection() {
        didSet { saveBlockSelection() }
    }
    
    @Published var isAuthorized = false
    
    let permanentStore = ManagedSettingsStore(named: .init("permanent"))
    let scheduledStore = ManagedSettingsStore(named: .init("scheduled"))
    
    private init() {
        self.isAdultFilterEnabled = UserDefaults.standard.bool(forKey: "screenTimeAdultFilterEnabled")
        self.isScheduleActive = UserDefaults.standard.bool(forKey: "isScreenTimeScheduleActive")
        loadDaySchedules()
        
        loadAllowedSelection()
        loadBlockSelection()
        loadPermanentBlockSelection()
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            self.isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
        } catch {
            print("Failed to authorize Family Controls: \(error.localizedDescription)")
            self.isAuthorized = false
        }
    }
    
    func checkAuthorizationStatus() {
        self.isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
    }
    
    // MARK: - Blocking
    
    func applyPermanentBlocks() {
        guard isAuthorized else { return }
        permanentStore.shield.applications = permanentBlockSelection.applicationTokens
        permanentStore.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(permanentBlockSelection.categoryTokens)
        permanentStore.shield.webDomains = permanentBlockSelection.webDomainTokens
        permanentStore.shield.webDomainCategories = ShieldSettings.ActivityCategoryPolicy.specific(permanentBlockSelection.categoryTokens)
        
        if isAdultFilterEnabled {
            permanentStore.webContent.blockedByFilter = .auto()
        } else {
            permanentStore.webContent.blockedByFilter = nil
        }
    }
    
    // MARK: - DeviceActivity Scheduling
    
    static let activityNamePrefix = "com.jannik.grovy.screentime.block"
    
    /// Registers DeviceActivitySchedule entries for all active days.
    /// The MonitorExtension picks these up and activates/deactivates the shield automatically.
    func scheduleBlockActivities(daySchedules: [Int: DaySchedule], blockSelectionData: Data?) {
        let center = DeviceActivityCenter()
        
        // Cancel all existing schedules first
        center.stopMonitoring()
        
        // Save blockSelection data to App Group so the extension can read it
        let defaults = UserDefaults(suiteName: SharedUserDefaults.suiteName)
        defaults?.set(blockSelectionData, forKey: "screenTimeBlockSelectionData_appGroup")
        defaults?.synchronize()
        
        guard isScheduleActive else { return }
        
        let calendar = Calendar.current
        
        for (weekday, schedule) in daySchedules {
            guard schedule.isActive else { continue }
            
            let activityName = DeviceActivityName("\(Self.activityNamePrefix).\(weekday)")
            
            var startComponents = DateComponents()
            startComponents.weekday = weekday
            startComponents.hour = schedule.startHour
            startComponents.minute = schedule.startMinute
            
            var endComponents = DateComponents()
            // If end is on the next day (over-midnight), we keep the same weekday for end
            // DeviceActivity handles same-day intervals. For over-midnight, we use next weekday.
            let isOverMidnight = (schedule.startHour * 60 + schedule.startMinute) > (schedule.endHour * 60 + schedule.endMinute)
            endComponents.weekday = isOverMidnight ? (weekday % 7) + 1 : weekday
            endComponents.hour = schedule.endHour
            endComponents.minute = schedule.endMinute
            
            let activitySchedule = DeviceActivitySchedule(
                intervalStart: startComponents,
                intervalEnd: endComponents,
                repeats: true
            )
            
            do {
                try center.startMonitoring(activityName, during: activitySchedule)
            } catch {
                print("Failed to schedule activity for weekday \(weekday): \(error)")
            }
        }
    }
    
    /// „Ohne Handy" – blockiert alle App-Kategorien komplett (überschreibt Notfall-Modus)
    func blockAllApps() {
        guard isAuthorized else { return }
        scheduledStore.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.all()
        scheduledStore.shield.webDomainCategories = ShieldSettings.ActivityCategoryPolicy.all()
        applyPermanentBlocks()
    }
    
    /// „Mit Handy" – blockiert alles AUSSER den Apps/Domains, die der Nutzer als erlaubt markiert hat
    func blockAllExcept(selection: FamilyActivitySelection) {
        guard isAuthorized else { return }
        scheduledStore.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.all(except: selection.applicationTokens)
        scheduledStore.shield.webDomainCategories = ShieldSettings.ActivityCategoryPolicy.all(except: selection.webDomainTokens)
        applyPermanentBlocks()
    }
    
    func unblockApps() {
        scheduledStore.shield.applications = nil
        scheduledStore.shield.applicationCategories = nil
        scheduledStore.shield.webDomains = nil
        scheduledStore.shield.webDomainCategories = nil
        // Permanent blocks should remain active even in emergency unlock, 
        // as they are "permanent".
        applyPermanentBlocks()
    }
    
    // MARK: - Persistence
    
    private func saveAllowedSelection() {
        if let data = try? JSONEncoder().encode(allowedSelection) {
            UserDefaults.standard.set(data, forKey: "screenTimeAllowedSelectionData")
        }
    }
    
    private func loadAllowedSelection() {
        if let data = UserDefaults.standard.data(forKey: "screenTimeAllowedSelectionData"),
           let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            self.allowedSelection = selection
        }
    }
    
    private func saveBlockSelection() {
        if let data = try? JSONEncoder().encode(blockSelection) {
            UserDefaults.standard.set(data, forKey: "screenTimeBlockSelectionData")
        }
    }
    
    private func loadBlockSelection() {
        if let data = UserDefaults.standard.data(forKey: "screenTimeBlockSelectionData"),
           let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            self.blockSelection = selection
        }
    }
    
    private func savePermanentBlockSelection() {
        if let data = try? JSONEncoder().encode(permanentBlockSelection) {
            UserDefaults.standard.set(data, forKey: "screenTimePermanentBlockData")
        }
    }
    
    private func loadPermanentBlockSelection() {
        if let data = UserDefaults.standard.data(forKey: "screenTimePermanentBlockData"),
           let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            self.permanentBlockSelection = selection
        }
    }
}
