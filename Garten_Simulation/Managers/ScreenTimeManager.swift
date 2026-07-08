import Combine
import Foundation
import FamilyControls
import ManagedSettings
import SwiftUI

@MainActor
class ScreenTimeManager: ObservableObject {
    static let shared = ScreenTimeManager()
    
    @AppStorage("screenTimeAllowedSelectionData") private var allowedSelectionData: Data?
    
    /// Apps/Kategorien, die der Nutzer beim "Mit Handy"-Modus NICHT blockiert haben möchte
    @Published var allowedSelection = FamilyActivitySelection() {
        didSet { saveAllowedSelection() }
    }
    
    @Published var isAuthorized = false
    
    let store = ManagedSettingsStore()
    
    private init() {
        loadAllowedSelection()
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
    
    /// "Ohne Handy" – blockiert alle App-Kategorien komplett
    func blockAllApps() {
        guard isAuthorized else { return }
        store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.all()
        store.shield.webDomainCategories = ShieldSettings.ActivityCategoryPolicy.all()
    }
    
    /// "Mit Handy" – blockiert alles AUSSER den Apps/Domains, die der Nutzer als erlaubt markiert hat
    func blockAllExcept(selection: FamilyActivitySelection) {
        guard isAuthorized else { return }
        // applicationCategories.all(except:) erwartet Set<ApplicationToken>
        store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.all(except: selection.applicationTokens)
        // webDomainCategories.all(except:) erwartet Set<WebDomainToken>
        store.shield.webDomainCategories = ShieldSettings.ActivityCategoryPolicy.all(except: selection.webDomainTokens)
    }
    
    func unblockApps() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomainCategories = nil
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
}
