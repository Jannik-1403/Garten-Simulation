import SwiftUI
import Combine

class SettingsStore: ObservableObject {
    @AppStorage("isHapticEnabled")        var isHapticEnabled: Bool = true
    @AppStorage("isNotificationsEnabled") var isNotificationsEnabled: Bool = true
    @AppStorage("isAnalyticsEnabled")     var isAnalyticsEnabled: Bool = true
    @AppStorage("showHabitInsteadOfName") var showHabitInsteadOfName: Bool = false

    // Published so every View re-renders when language changes
    @Published var appLanguage: String {
        didSet {
            UserDefaults.standard.set(appLanguage, forKey: "appLanguage")
        }
    }

    init() {
        self.appLanguage = UserDefaults.standard.string(forKey: "appLanguage") ?? "de"
    }

    // MARK: - Localization
    func localizedString(for key: String) -> String {
        AppStrings.get(key, language: appLanguage)
    }

    // MARK: - Actions
    func restorePurchases() { print("Restoring purchases...") }
    func exportData()        { print("Exporting data...") }
    func importData()        { print("Importing data...") }
    func deleteAccount()     { print("Deleting account...") }
    func shareApp()          { print("Sharing app...") }
    func contactSupport()    { print("Contacting support...") }
}
