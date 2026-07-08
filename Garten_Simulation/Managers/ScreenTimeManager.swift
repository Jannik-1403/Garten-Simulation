import Foundation
import FamilyControls
import ManagedSettings
import SwiftUI

@MainActor
class ScreenTimeManager: ObservableObject {
    static let shared = ScreenTimeManager()
    
    @AppStorage("screenTimeSelection") private var screenTimeSelectionData: Data?
    
    @Published var selection = FamilyActivitySelection() {
        didSet {
            saveSelection()
        }
    }
    
    @Published var isAuthorized = false
    
    let store = ManagedSettingsStore()
    
    private init() {
        loadSelection()
        checkAuthorizationStatus()
    }
    
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
    
    private func saveSelection() {
        if let data = try? JSONEncoder().encode(selection) {
            screenTimeSelectionData = data
        }
    }
    
    private func loadSelection() {
        if let data = screenTimeSelectionData,
           let decoded = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            self.selection = decoded
        }
    }
    
    func blockApps() {
        guard isAuthorized else { return }
        
        let applications = selection.applicationTokens
        let categories = selection.categoryTokens
        
        store.shield.applications = applications.isEmpty ? nil : applications
        store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(categories)
        store.shield.webDomainCategories = ShieldSettings.ActivityCategoryPolicy.specific(categories)
    }
    
    func unblockApps() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomainCategories = nil
    }
}
