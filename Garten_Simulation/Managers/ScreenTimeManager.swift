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

struct LimitEntry: Codable {
    var limit: Int
    var selection: FamilyActivitySelection
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
            sanitizeSelections()
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
    
    /// Auswahl für Focus Timer "Handy weglegen" (alles was blockiert werden soll)
    @Published var focusFullBlockSelection = FamilyActivitySelection() {
        didSet { saveFocusFullBlockSelection() }
    }
    
    /// Auswahl für Focus Timer "Handy behalten" (ausgewählte Apps, die blockiert werden sollen)
    @Published var focusPartialBlockSelection = FamilyActivitySelection() {
        didSet { saveFocusPartialBlockSelection() }
    }
    
    /// Apps/Kategorien, die explizit im Block-Zeitplan gesperrt werden sollen
    @Published var blockSelection = FamilyActivitySelection() {
        didSet { saveBlockSelection() }
    }
    
    /// Ebene 1: Tägliches Zeitlimit Apps
    @Published var dailyLimitSelection = FamilyActivitySelection() {
        didSet { 
            saveDailyLimitSelection()
            // NOTE: syncIndividualLimits() is NOT called here automatically.
            // It must be called explicitly from the View when the user changes
            // the picker selection, to avoid wiping limits on every assignment.
        }
    }
    
    @Published var limitSelections: [Int: FamilyActivitySelection] = [:] {
        didSet { saveIndividualLimits() }
    }
    
    @Published var isAuthorized = false
    @Published var isDenied = false
    
    let permanentStore = ManagedSettingsStore(named: .init("permanent"))
    let scheduledStore = ManagedSettingsStore(named: .init("scheduled"))
    
    private init() {
        self.isAdultFilterEnabled = UserDefaults.standard.bool(forKey: "screenTimeAdultFilterEnabled")
        self.isScheduleActive = UserDefaults.standard.bool(forKey: "isScreenTimeScheduleActive")
        
        if let data = UserDefaults.standard.data(forKey: "screenTimeDaySchedulesData"),
           let decoded = try? JSONDecoder().decode([Int: DaySchedule].self, from: data) {
            self.daySchedules = decoded
        } else {
            self.daySchedules = [1: .defaultWeekend, 2: .defaultWeekday, 3: .defaultWeekday,
                                 4: .defaultWeekday, 5: .defaultWeekday, 6: .defaultWeekday, 7: .defaultWeekend]
        }
        
        if let data = UserDefaults.standard.data(forKey: "screenTimeAllowedSelectionData"),
           let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            self.allowedSelection = selection
        }
        
        if let data = UserDefaults.standard.data(forKey: "screenTimeBlockSelectionData"),
           let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            self.blockSelection = selection
        }
        
        if let data = UserDefaults.standard.data(forKey: "screenTimePermanentBlockData"),
           let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            self.permanentBlockSelection = selection
        }
        
        if let data = UserDefaults.standard.data(forKey: "focusFullBlockSelectionData"),
           let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            self.focusFullBlockSelection = selection
        }
        
        if let data = UserDefaults.standard.data(forKey: "focusPartialBlockSelectionData"),
           let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            self.focusPartialBlockSelection = selection
        }
        
        if let data = UserDefaults.standard.data(forKey: "screenTimeDailyLimitSelection"),
           let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            self.dailyLimitSelection = selection
        }
        
        if let data = UserDefaults.standard.data(forKey: "st_limitSelectionsArray"),
           let entries = try? JSONDecoder().decode([LimitEntry].self, from: data) {
            var loadedDict = [Int: FamilyActivitySelection]()
            for entry in entries {
                loadedDict[entry.limit] = entry.selection
            }
            self.limitSelections = loadedDict
        } else if let data = UserDefaults.standard.data(forKey: "st_limitSelections"),
                  let dict = try? JSONDecoder().decode([Int: FamilyActivitySelection].self, from: data) {
            self.limitSelections = dict
        }
        
        // NOTE: syncIndividualLimits() is intentionally NOT called here.
        // Calling it during init causes token identity mismatches because
        // FamilyActivitySelection.applicationTokens from two separate
        // JSONDecoder calls are NOT Set-equal, which causes formIntersection
        // to wipe all saved limits on every app launch.
        
        checkAuthorizationStatus()
        
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in
                self?.checkAuthorizationStatus()
                self?.applyPermanentBlocks()
            }
        }
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            DispatchQueue.main.async {
                self.checkAuthorizationStatus()
            }
        } catch {
            print("Failed to authorize Family Controls: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.isAuthorized = false
            }
        }
    }
    
    func checkAuthorizationStatus() {
        let status = AuthorizationCenter.shared.authorizationStatus
        self.isAuthorized = status == .approved
        self.isDenied = status == .denied
        if self.isAuthorized {
            applyPermanentBlocks()
        }
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
        
        let dailyData = try? JSONEncoder().encode(dailyLimitSelection)
        defaults?.set(dailyData, forKey: "screenTimeDailyLimitSelectionData_appGroup")
        defaults?.synchronize()
        
        // Start individual monitoring for daily limits if active
        let dailySchedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
        
        var index = 0
        for (minutes, selection) in limitSelections {
            if minutes > 0 {
                let event = DeviceActivityEvent(applications: selection.applicationTokens, categories: selection.categoryTokens, webDomains: selection.webDomainTokens, threshold: DateComponents(minute: minutes))
                do {
                    try center.startMonitoring(DeviceActivityName("\(Self.activityNamePrefix).limit.\(index)"), during: dailySchedule, events: [.init("limitEvent"): event])
                    index += 1
                } catch { print("Failed to schedule limit: \(error)") }
            }
        }
        
        guard isScheduleActive else { return }
        
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
    
    /// Wendet spezifische Blockaden für die Focus Session an (Blacklist Ansatz)
    func applyFocusBlock(selection: FamilyActivitySelection) {
        guard isAuthorized else { return }
        scheduledStore.shield.applications = selection.applicationTokens
        scheduledStore.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(selection.categoryTokens)
        scheduledStore.shield.webDomains = selection.webDomainTokens
        scheduledStore.shield.webDomainCategories = ShieldSettings.ActivityCategoryPolicy.specific(selection.categoryTokens)
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
    
    private func saveFocusFullBlockSelection() {
        if let data = try? JSONEncoder().encode(focusFullBlockSelection) {
            UserDefaults.standard.set(data, forKey: "focusFullBlockSelectionData")
        }
    }
    
    private func saveFocusPartialBlockSelection() {
        if let data = try? JSONEncoder().encode(focusPartialBlockSelection) {
            UserDefaults.standard.set(data, forKey: "focusPartialBlockSelectionData")
        }
    }
    
    
    private func saveBlockSelection() {
        if let data = try? JSONEncoder().encode(blockSelection) {
            UserDefaults.standard.set(data, forKey: "screenTimeBlockSelectionData")
        }
    }
    
    
    private func savePermanentBlockSelection() {
        if let data = try? JSONEncoder().encode(permanentBlockSelection) {
            UserDefaults.standard.set(data, forKey: "screenTimePermanentBlockData")
        }
    }
    
    
    private func saveDailyLimitSelection() {
        if let data = try? JSONEncoder().encode(dailyLimitSelection) {
            UserDefaults.standard.set(data, forKey: "screenTimeDailyLimitSelection")
            UserDefaults.standard.synchronize()
        }
    }
    
    /// Updates and saves dailyLimitSelection without triggering syncIndividualLimits.
    /// Use this from the View's saveSettings() to avoid token-identity mismatch issues.
    func saveDailyLimitSelectionPublic(_ selection: FamilyActivitySelection) {
        self.dailyLimitSelection = selection
        // didSet only saves – syncIndividualLimits is NOT in didSet anymore
    }
    
    // MARK: - Limit Getters & Setters
    
    func getLimit(for token: ApplicationToken) -> Int {
        for (limit, selection) in limitSelections {
            if selection.applicationTokens.contains(token) { return limit }
        }
        return 0
    }
    func getLimit(for token: ActivityCategoryToken) -> Int {
        for (limit, selection) in limitSelections {
            if selection.categoryTokens.contains(token) { return limit }
        }
        return 0
    }
    func getLimit(for token: WebDomainToken) -> Int {
        for (limit, selection) in limitSelections {
            if selection.webDomainTokens.contains(token) { return limit }
        }
        return 0
    }
    
    func setLimit(for token: ApplicationToken, limit: Int) {
        for key in limitSelections.keys { limitSelections[key]?.applicationTokens.remove(token) }
        var selection = limitSelections[limit] ?? FamilyActivitySelection()
        selection.applicationTokens.insert(token)
        limitSelections[limit] = selection
    }
    func setLimit(for token: ActivityCategoryToken, limit: Int) {
        for key in limitSelections.keys { limitSelections[key]?.categoryTokens.remove(token) }
        var selection = limitSelections[limit] ?? FamilyActivitySelection()
        selection.categoryTokens.insert(token)
        limitSelections[limit] = selection
    }
    func setLimit(for token: WebDomainToken, limit: Int) {
        for key in limitSelections.keys { limitSelections[key]?.webDomainTokens.remove(token) }
        var selection = limitSelections[limit] ?? FamilyActivitySelection()
        selection.webDomainTokens.insert(token)
        limitSelections[limit] = selection
    }
    
    private func syncIndividualLimits() {
        // Clean up tokens that are no longer in dailyLimitSelection
        for (limit, selection) in limitSelections {
            var newSelection = selection
            newSelection.applicationTokens.formIntersection(dailyLimitSelection.applicationTokens)
            newSelection.categoryTokens.formIntersection(dailyLimitSelection.categoryTokens)
            newSelection.webDomainTokens.formIntersection(dailyLimitSelection.webDomainTokens)
            limitSelections[limit] = newSelection
        }
        
        // Find tokens that are in dailyLimitSelection but not in any limitSelections
        var assignedAppTokens = Set<ApplicationToken>()
        var assignedCatTokens = Set<ActivityCategoryToken>()
        var assignedWebTokens = Set<WebDomainToken>()
        for selection in limitSelections.values {
            assignedAppTokens.formUnion(selection.applicationTokens)
            assignedCatTokens.formUnion(selection.categoryTokens)
            assignedWebTokens.formUnion(selection.webDomainTokens)
        }
        
        let unassignedAppTokens = dailyLimitSelection.applicationTokens.subtracting(assignedAppTokens)
        let unassignedCatTokens = dailyLimitSelection.categoryTokens.subtracting(assignedCatTokens)
        let unassignedWebTokens = dailyLimitSelection.webDomainTokens.subtracting(assignedWebTokens)
        
        if !unassignedAppTokens.isEmpty || !unassignedCatTokens.isEmpty || !unassignedWebTokens.isEmpty {
            var zeroSelection = limitSelections[0] ?? FamilyActivitySelection()
            zeroSelection.applicationTokens.formUnion(unassignedAppTokens)
            zeroSelection.categoryTokens.formUnion(unassignedCatTokens)
            zeroSelection.webDomainTokens.formUnion(unassignedWebTokens)
            limitSelections[0] = zeroSelection
        }
    }
    
    /// Expose sync for use by the View when dailyLimitSelection changes via picker
    func syncLimitsAfterPickerChange() {
        syncIndividualLimits()
    }
    
    func sanitizeSelections() {
        let permanentTokens = permanentBlockSelection.applicationTokens
        let permanentCategories = permanentBlockSelection.categoryTokens
        let permanentWebDomains = permanentBlockSelection.webDomainTokens
        
        dailyLimitSelection.applicationTokens.subtract(permanentTokens)
        dailyLimitSelection.categoryTokens.subtract(permanentCategories)
        dailyLimitSelection.webDomainTokens.subtract(permanentWebDomains)
        
        for id in limitSelections.keys {
            limitSelections[id]?.applicationTokens.subtract(permanentTokens)
            limitSelections[id]?.categoryTokens.subtract(permanentCategories)
            limitSelections[id]?.webDomainTokens.subtract(permanentWebDomains)
        }
        
        applyPermanentBlocks()
        syncIndividualLimits()
    }
    
    private func saveIndividualLimits() {
        var entries = [LimitEntry]()
        for (limit, selection) in limitSelections {
            entries.append(LimitEntry(limit: limit, selection: selection))
        }
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: "st_limitSelectionsArray")
            UserDefaults.standard.synchronize()
        }
    }
    
}
