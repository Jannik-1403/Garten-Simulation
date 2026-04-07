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
        let appString = AppStrings.get(key, language: appLanguage)
        
        // Falls der Key in AppStrings nicht gefunden wurde (AppStrings gibt den Key selbst zurück),
        // probieren wir es mit dem Standard NSLocalizedString Mechanismus.
        if appString == key {
            return NSLocalizedString(key, comment: "")
        }
        
        return appString
    }

    // MARK: - Actions
    func exportData()        { print("Exporting data...") }
    func importData()        { print("Importing data...") }
    func deleteAccount()     { print("Deleting account...") }
    func shareApp() {
        let text = "Schau dir meine Garten-Simulation an! 🌿 Ich baue gerade einen wunderschönen Garten auf."
        let url = URL(string: "https://apps.apple.com/app/garten-simulation")!
        
        let activityVC = UIActivityViewController(activityItems: [text, url], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            
            // For iPad compatibility
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = rootVC.view
                popover.sourceRect = CGRect(x: rootVC.view.bounds.midX, y: rootVC.view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            rootVC.present(activityVC, animated: true)
        }
    }
    
    func contactSupport() {
        let email = "jannik.schill.2010@gmail.com"
        let subject = "Support: Garten-Simulation"
        let mailto = "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        if let url = URL(string: mailto) {
            UIApplication.shared.open(url)
        }
    }
}
