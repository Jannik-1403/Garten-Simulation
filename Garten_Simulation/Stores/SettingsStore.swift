import SwiftUI
import Combine

class SettingsStore: ObservableObject {
    @AppStorage("isHapticEnabled")        var isHapticEnabled: Bool = true
    @AppStorage("isNotificationsEnabled") var isNotificationsEnabled: Bool = true
    @AppStorage("isAnalyticsEnabled")     var isAnalyticsEnabled: Bool = true
    @AppStorage("showHabitInsteadOfName") var showHabitInsteadOfName: Bool = false
    @AppStorage("onboardingAbgeschlossen") var onboardingAbgeschlossen: Bool = false
    @AppStorage("ausgewaehltesZiel")       var ausgewaehltesZiel: String = ""

    // Default 8:00 AM
    @AppStorage("erinnerungsZeit") private var erinnerungsZeitInternal: Double = 8 * 3600

    var erinnerungsZeit: Date {
        get {
            Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
            // We use the internal double (seconds from midnight) to reconstruct a Date for the picker
            let totalSeconds = Int(erinnerungsZeitInternal)
            let hours = totalSeconds / 3600
            let minutes = (totalSeconds % 3600) / 60
            return Calendar.current.date(bySettingHour: hours, minute: minutes, second: 0, of: Date()) ?? Date()
        }
        set {
            let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            let totalSeconds = Double((components.hour ?? 8) * 3600 + (components.minute ?? 0) * 60)
            erinnerungsZeitInternal = totalSeconds
        }
    }


    // Published so every View re-renders when language changes
    @Published var appLanguage: String {
        didSet {
            UserDefaults.standard.set(appLanguage, forKey: "appLanguage")
        }
    }


    init() {
        if let saved = UserDefaults.standard.string(forKey: "appLanguage") {
            self.appLanguage = saved
        } else {
            // Detect system language on first start
            let supported = ["de", "en", "es", "fr", "it", "pt"]
            let preferred = Bundle.main.preferredLocalizations.first ?? "en"
            let languageCode = preferred.split(separator: "-").first.map(String.init) ?? "en"
            
            if supported.contains(languageCode) {
                self.appLanguage = languageCode
            } else {
                self.appLanguage = "en"
            }
            UserDefaults.standard.set(self.appLanguage, forKey: "appLanguage")
        }
        
        Task {
            await refreshNotificationStatus()
        }
    }

    @MainActor
    func refreshNotificationStatus() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        isNotificationsEnabled = settings.authorizationStatus == .authorized
    }

    // MARK: - Localization
    func localizedString(for key: String) -> String {
        // Priority 1: Check the specific language bundle (e.g. es.lproj)
        if let path = Bundle.main.path(forResource: appLanguage, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            let localized = NSLocalizedString(key, tableName: nil, bundle: bundle, value: key, comment: "")
            if localized != key {
                return localized
            }
        }
        
        // Priority 2: Fallback to AppStrings inline dictionary
        let appString = AppStrings.get(key, language: appLanguage)
        if appString != key {
            return appString
        }
        
        // Priority 3: Ultimate fallback to system language default NSLocalizedString
        return NSLocalizedString(key, comment: "")
    }

    // MARK: - Actions
    func exportData()        { /* print("Exporting data...") */ }
    func importData()        { /* print("Importing data...") */ }
    func deleteAccount()     { /* print("Deleting account...") */ }
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

