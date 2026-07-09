import Combine
import Foundation
import FamilyControls
import ManagedSettings
import SwiftUI

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
    
    // MARK: - Block Schedule
    @AppStorage("isScreenTimeScheduleActive") var isScheduleActive: Bool = false
    @AppStorage("screenTimeBlockStartHour") var blockStartHour: Int = 9
    @AppStorage("screenTimeBlockStartMinute") var blockStartMinute: Int = 0
    @AppStorage("screenTimeBlockEndHour") var blockEndHour: Int = 17
    @AppStorage("screenTimeBlockEndMinute") var blockEndMinute: Int = 0
    
    var isCurrentlyInBlockWindow: Bool {
        guard isScheduleActive else { return false }
        let now = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        let currentTime = currentHour * 60 + currentMinute
        let startTime = blockStartHour * 60 + blockStartMinute
        let endTime = blockEndHour * 60 + blockEndMinute
        
        if startTime < endTime {
            return currentTime >= startTime && currentTime <= endTime
        } else {
            // Over midnight
            return currentTime >= startTime || currentTime <= endTime
        }
    }
    
    /// Apps/Kategorien, die der Nutzer beim "Mit Handy"-Modus NICHT blockiert haben möchte
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
        // Set specific apps/domains to be always blocked
        store.shield.applications = permanentBlockSelection.applicationTokens
        store.shield.webDomains = permanentBlockSelection.webDomainTokens
        
        // Handle Adult Content filter
        if isAdultFilterEnabled {
            store.webContent.blockedByFilter = .auto()
        } else {
            store.webContent.blockedByFilter = nil
        }
    }
    
    /// "Ohne Handy" – blockiert alle App-Kategorien komplett
    func blockAllApps() {
        guard isAuthorized else { return }
        store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.all()
        store.shield.webDomainCategories = ShieldSettings.ActivityCategoryPolicy.all()
        applyPermanentBlocks()
    }
    
    /// "Mit Handy" – blockiert alles AUSSER den Apps/Domains, die der Nutzer als erlaubt markiert hat
    func blockAllExcept(selection: FamilyActivitySelection) {
        guard isAuthorized else { return }
        // applicationCategories.all(except:) erwartet Set<ApplicationToken>
        store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.all(except: selection.applicationTokens)
        // webDomainCategories.all(except:) erwartet Set<WebDomainToken>
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
