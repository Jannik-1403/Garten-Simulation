import Combine
import Foundation
import FamilyControls
import ManagedSettings
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
    @AppStorage("screenTimePermanentBlockData") private var permanentBlockSelectionData: Data?
    @Published var permanentBlockSelection = FamilyActivitySelection() {
        didSet {
            savePermanentBlockSelection()
            applyPermanentBlocks()
        }
    }
    
    @AppStorage("screenTimeAdultFilterEnabled") var isAdultFilterEnabled: Bool = false {
        didSet {
            applyPermanentBlocks()
        }
    }
    
    // MARK: - Block Schedule (Per-Day)
    @AppStorage("isScreenTimeScheduleActive") var isScheduleActive: Bool = false
    
    /// Weekday schedule: key = Calendar weekday (1=Sun, 2=Mon ... 7=Sat)
    @AppStorage("screenTimeDaySchedulesData") private var daySchedulesData: Data = {
        let defaults: [Int: DaySchedule] = [
            1: .defaultWeekend,  // Sunday
            2: .defaultWeekday,  // Monday
            3: .defaultWeekday,  // Tuesday
            4: .defaultWeekday,  // Wednesday
            5: .defaultWeekday,  // Thursday
            6: .defaultWeekday,  // Friday
            7: .defaultWeekend   // Saturday
        ]
        return (try? JSONEncoder().encode(defaults)) ?? Data()
    }()
    
    var daySchedules: [Int: DaySchedule] {
        get {
            (try? JSONDecoder().decode([Int: DaySchedule].self, from: daySchedulesData)) ?? defaultSchedules
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                daySchedulesData = data
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
    
    @AppStorage("screenTimeBlockSelectionData") private var blockSelectionData: Data?
    
    /// Apps/Kategorien, die explizit im Block-Zeitplan gesperrt werden sollen
    @Published var blockSelection = FamilyActivitySelection() {
        didSet { saveBlockSelection() }
    }
    
    @Published var isAuthorized = false
    
    let store = ManagedSettingsStore()
    
    private init() {
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
        store.shield.applications = permanentBlockSelection.applicationTokens
        store.shield.webDomains = permanentBlockSelection.webDomainTokens
        
        if isAdultFilterEnabled {
            store.webContent.blockedByFilter = .auto()
        } else {
            store.webContent.blockedByFilter = nil
        }
    }
    
    /// „Ohne Handy" – blockiert alle App-Kategorien komplett
    func blockAllApps() {
        guard isAuthorized else { return }
        store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.all()
        store.shield.webDomainCategories = ShieldSettings.ActivityCategoryPolicy.all()
        applyPermanentBlocks()
    }
    
    /// „Mit Handy" – blockiert alles AUSSER den Apps/Domains, die der Nutzer als erlaubt markiert hat
    func blockAllExcept(selection: FamilyActivitySelection) {
        guard isAuthorized else { return }
        store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.all(except: selection.applicationTokens)
        store.shield.webDomainCategories = ShieldSettings.ActivityCategoryPolicy.all(except: selection.webDomainTokens)
        applyPermanentBlocks()
    }
    
    func unblockApps() {
        store.shield.applicationCategories = nil
        store.shield.webDomainCategories = nil
        applyPermanentBlocks()
    }
    
    // MARK: - Persistence
    
    private func saveAllowedSelection() {
        if let data = try? JSONEncoder().encode(allowedSelection) {
            allowedSelectionData = data
        }
    }
    
    private func loadAllowedSelection() {
        if let data = allowedSelectionData,
           let decoded = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            self.allowedSelection = decoded
        }
    }
    
    private func saveBlockSelection() {
        if let data = try? JSONEncoder().encode(blockSelection) {
            blockSelectionData = data
        }
    }
    
    private func loadBlockSelection() {
        if let data = blockSelectionData,
           let decoded = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            self.blockSelection = decoded
        }
    }
    
    private func savePermanentBlockSelection() {
        if let data = try? JSONEncoder().encode(permanentBlockSelection) {
            permanentBlockSelectionData = data
        }
    }
    
    private func loadPermanentBlockSelection() {
        if let data = permanentBlockSelectionData,
           let decoded = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            self.permanentBlockSelection = decoded
        }
    }
}
