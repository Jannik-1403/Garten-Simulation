import SwiftUI
import Combine

enum ScreenSize {
    static var width: CGFloat { 390 }
    static var height: CGFloat { 844 }
}

class SettingsStore: ObservableObject {
    @AppStorage("isHapticEnabled")        var isHapticEnabled: Bool = true
    @AppStorage("isNotificationsEnabled") var isNotificationsEnabled: Bool = true
    @AppStorage("isAnalyticsEnabled")     var isAnalyticsEnabled: Bool = true
    @AppStorage("showHabitInsteadOfName") var showHabitInsteadOfName: Bool = false
    @AppStorage("onboardingAbgeschlossen") var onboardingAbgeschlossen: Bool = false
    @AppStorage("ausgewaehltesZiel")       var ausgewaehltesZiel: String = ""
    
    @Published var habitStartStunde: Int {
        didSet { SharedUserDefaults.suite.set(habitStartStunde, forKey: "habitStartStunde") }
    }
    

    // Default 8:00 AM
    @AppStorage("erinnerungsZeit") private var erinnerungsZeitInternal: Double = 8 * 3600

    var erinnerungsZeit: Date {
        get {
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
            SharedUserDefaults.suite.set(appLanguage, forKey: "appLanguage")
        }
    }


    init() {
        self.habitStartStunde = SharedUserDefaults.suite.object(forKey: "habitStartStunde") as? Int ?? 7

        if let saved = SharedUserDefaults.suite.string(forKey: "appLanguage") {
            self.appLanguage = saved
        } else {
            // Detect system language on first start
            let supported = ["de", "en", "es", "fr", "it", "pt", "ja", "ko", "pl", "nl", "tr"]
            let preferred = Bundle.main.preferredLocalizations.first ?? "en"
            let languageCode = preferred.split(separator: "-").first.map(String.init) ?? "en"
            
            if supported.contains(languageCode) {
                self.appLanguage = languageCode
            } else {
                self.appLanguage = "en"
            }
            SharedUserDefaults.suite.set(self.appLanguage, forKey: "appLanguage")
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
        return NSLocalizedString(key, comment: "")
    }

    // MARK: - Actions
    func exportData()        { /* print("Exporting data...") */ }
    func importData()        { /* print("Importing data...") */ }
    func deleteAccount()     { /* print("Deleting account...") */ }
    func shareApp() {
        // Not available in Widget
    }
    
    func contactSupport() {
        // Not available in Widget
    }
    
    static let alleIgelAssets: [String] = [
        "Igel-Sport", "Igel-PflanzeGießen", "Igel-Backen", "Igel-Schach", "Igel-Foto", 
        "Igel-Kochen", "Igel-Golf", "Igel-Welttraum", "Igel-Schlagzeug", "Igel-Meditieren", 
        "Igel-König", "Igel-Malen", "Igel-Schlafen", "Igel-Lesen", "Igel-Schreiben", 
        "Igel-Fischen", "Igel-Zelten", "Igel-Duschen", "Igel-rennen", "Igel-Musik", 
        "Igel-Surfen", "Igel-Skatboard", "Igel-Töpfern", "Igel-Code", "Igel-Essen", 
        "Igel-wandern"
    ]
}
