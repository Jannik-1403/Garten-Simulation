import SwiftUI
import Combine
import LinkPresentation

enum ScreenSize {
    static var width: CGFloat {
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds.width ?? 390
    }
    
    static var height: CGFloat {
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds.height ?? 844
    }
}


enum AutoBackupInterval: String, Codable, CaseIterable, Identifiable {
    case never = "nie"
    case onSave = "beiSpeicherung"
    case daily = "täglich"
    case weekly = "wöchentlich"
    case monthly = "monatlich"
    
    var id: String { rawValue }
    
    var localizedName: String {
        return localizedName(for: Locale.current.identifier)
    }
    
    func localizedName(for localeIdentifier: String) -> String {
        let loc = Locale(identifier: localeIdentifier)
        switch self {
        case .never: return String(localized: "backup.interval.never", defaultValue: "Nie", locale: loc)
        case .onSave: return String(localized: "backup.interval.onSave", defaultValue: "Bei jeder Speicherung", locale: loc)
        case .daily: return String(localized: "backup.interval.daily", defaultValue: "Täglich", locale: loc)
        case .weekly: return String(localized: "backup.interval.weekly", defaultValue: "Wöchentlich", locale: loc)
        case .monthly: return String(localized: "backup.interval.monthly", defaultValue: "Monatlich", locale: loc)
        }
    }
}

class SettingsStore: ObservableObject {
    static let shared = SettingsStore()
    
    @Published var isHapticEnabled: Bool {
        didSet { UserDefaults.standard.set(isHapticEnabled, forKey: "isHapticEnabled") }
    }
    
    @Published var autoBackupInterval: AutoBackupInterval {
        didSet {
            SharedUserDefaults.suite.set(autoBackupInterval.rawValue, forKey: "autoBackupInterval")
        }
    }
    @Published var isNotificationsEnabled: Bool {
        didSet { 
            UserDefaults.standard.set(isNotificationsEnabled, forKey: "isNotificationsEnabled") 
            SharedUserDefaults.suite.set(isNotificationsEnabled, forKey: "isNotificationsEnabled")
        }
    }
    @Published var isAnalyticsEnabled: Bool {
        didSet { UserDefaults.standard.set(isAnalyticsEnabled, forKey: "isAnalyticsEnabled") }
    }
    @Published var showHabitInsteadOfName: Bool {
        didSet { UserDefaults.standard.set(showHabitInsteadOfName, forKey: "showHabitInsteadOfName") }
    }
    @Published var onboardingAbgeschlossen: Bool {
        didSet { UserDefaults.standard.set(onboardingAbgeschlossen, forKey: "onboardingAbgeschlossen") }
    }
    @Published var appTourPromptShown: Bool {
        didSet { UserDefaults.standard.set(appTourPromptShown, forKey: "appTourPromptShown") }
    }
    @Published var appTourAbgeschlossen: Bool {
        didSet { UserDefaults.standard.set(appTourAbgeschlossen, forKey: "appTourAbgeschlossen") }
    }
    @Published var routineOnboardingAbgeschlossen: Bool {
        didSet { UserDefaults.standard.set(routineOnboardingAbgeschlossen, forKey: "routineOnboardingAbgeschlossen") }
    }
    @Published var ausgewaehltesZiel: String {
        didSet { UserDefaults.standard.set(ausgewaehltesZiel, forKey: "ausgewaehltesZiel") }
    }
    
    @Published var habitStartStunde: Int {
        didSet { SharedUserDefaults.suite.set(habitStartStunde, forKey: "habitStartStunde") }
    }
    
    @Published var ritualReihenfolgeIDs: [String] {
        didSet { SharedUserDefaults.suite.set(ritualReihenfolgeIDs, forKey: "ritualReihenfolgeIDs") }
    }
    
    @Published var igelCustomization: IgelCustomization {
        didSet {
            if let encoded = try? JSONEncoder().encode(igelCustomization) {
                SharedUserDefaults.suite.set(encoded, forKey: "igelCustomization")
            }
        }
    }
    
    @Published private var erinnerungsZeitInternal: Double {
        didSet { UserDefaults.standard.set(erinnerungsZeitInternal, forKey: "erinnerungsZeit") }
    }

    var erinnerungsZeit: Date {
        get {
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




    init() {
        if let intervalString = SharedUserDefaults.suite.string(forKey: "autoBackupInterval"),
           let interval = AutoBackupInterval(rawValue: intervalString) {
            self.autoBackupInterval = interval
        } else {
            self.autoBackupInterval = .never
        }
        self.isHapticEnabled = true
        UserDefaults.standard.set(true, forKey: "isHapticEnabled")
        self.isNotificationsEnabled = UserDefaults.standard.object(forKey: "isNotificationsEnabled") as? Bool ?? true
        self.isAnalyticsEnabled = UserDefaults.standard.object(forKey: "isAnalyticsEnabled") as? Bool ?? true
        self.showHabitInsteadOfName = UserDefaults.standard.object(forKey: "showHabitInsteadOfName") as? Bool ?? true
        self.onboardingAbgeschlossen = UserDefaults.standard.bool(forKey: "onboardingAbgeschlossen")
        self.appTourPromptShown = UserDefaults.standard.bool(forKey: "appTourPromptShown")
        self.appTourAbgeschlossen = UserDefaults.standard.bool(forKey: "appTourAbgeschlossen")
        self.routineOnboardingAbgeschlossen = UserDefaults.standard.bool(forKey: "routineOnboardingAbgeschlossen")
        self.ausgewaehltesZiel = UserDefaults.standard.string(forKey: "ausgewaehltesZiel") ?? ""
        self.erinnerungsZeitInternal = UserDefaults.standard.object(forKey: "erinnerungsZeit") as? Double ?? (8 * 3600)
        
        self.habitStartStunde = SharedUserDefaults.suite.object(forKey: "habitStartStunde") as? Int ?? 7
        self.ritualReihenfolgeIDs = SharedUserDefaults.suite.stringArray(forKey: "ritualReihenfolgeIDs") ?? []

        if let data = SharedUserDefaults.suite.data(forKey: "igelCustomization"),
           let decoded = try? JSONDecoder().decode(IgelCustomization.self, from: data) {
            self.igelCustomization = decoded
        } else {
            self.igelCustomization = IgelCustomization()
        }


        Task {
            await refreshNotificationStatus()
        }
    }

    @MainActor
    func refreshNotificationStatus() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        isNotificationsEnabled = (settings.authorizationStatus == .authorized)
        UserDefaults.standard.set(isNotificationsEnabled, forKey: "isNotificationsEnabled")
    }

    // MARK: - Locale
    /// Returns the Locale corresponding to the user's chosen app language.
    var appLocale: Locale { Locale(identifier: appLanguage) }
    
    var appLanguage: String {
        get { Locale.current.language.languageCode?.identifier ?? "en" }
        set { /* No-op, managed by iOS Native Settings */ }
    }

    // MARK: - Actions
    func exportData()        { /* print("Exporting data...") */ }
    func importData()        { /* print("Importing data...") */ }
    func deleteAccount()     { /* print("Deleting account...") */ }
    func shareApp(image: UIImage? = nil) {
        let text = NSLocalizedString("settings.share.desc", comment: "")
        let urlString = "https://apps.apple.com/app/grovy"
        
        let itemSource = GrovyShareItemSource(title: text, urlString: urlString, image: image)
        var items: [Any] = [itemSource]
        if let img = image {
            items.append(img)
        }
        
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
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
        let email = "grovy.support@gmail.com"
        let subject = "Support: Grovy"
        let mailto = "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        if let url = URL(string: mailto) {
            UIApplication.shared.open(url)
        }
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

class GrovyShareItemSource: NSObject, UIActivityItemSource {
    let title: String
    let urlString: String
    let image: UIImage?
    
    init(title: String, urlString: String, image: UIImage?) {
        self.title = title
        self.urlString = urlString
        self.image = image
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return title
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return "\(title)\n\n\(urlString)"
    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = title
        if let url = URL(string: urlString) {
            metadata.originalURL = url
            metadata.url = url
        }
        
        if let appIcon = UIImage(named: "Splash_Screenicon") ?? UIImage(named: "AppIcon") {
            metadata.iconProvider = NSItemProvider(object: appIcon)
        }
        
        if let img = image {
            metadata.imageProvider = NSItemProvider(object: img)
        }
        
        return metadata
    }
}
