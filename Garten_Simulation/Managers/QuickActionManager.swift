import SwiftUI
import Combine

class QuickActionManager: ObservableObject {
    static let shared = QuickActionManager()
    
    @Published var action: ShortcutType?
    
    enum ShortcutType: String {
        case deleteWarning = "delete_warning"
        case startFocus = "start_focus"
        case screenTime = "screen_time"
        case rateApp = "rate_app"
    }
    
    func handle(_ shortcutItem: UIApplicationShortcutItem) {
        if let type = ShortcutType(rawValue: shortcutItem.type) {
            DispatchQueue.main.async {
                self.action = type
            }
        }
    }
    
    static func setupDynamicShortcuts() {
        let deleteWarning = UIApplicationShortcutItem(
            type: ShortcutType.deleteWarning.rawValue,
            localizedTitle: String(localized: "shortcut.delete.title", defaultValue: "Du löschst Grovy?"),
            localizedSubtitle: String(localized: "shortcut.delete.subtitle", defaultValue: "Dein Garten wird verwelken."),
            icon: UIApplicationShortcutIcon(systemImageName: "eyes.inverse"),
            userInfo: nil
        )
        
        let startFocus = UIApplicationShortcutItem(
            type: ShortcutType.startFocus.rawValue,
            localizedTitle: String(localized: "shortcut.focus.title", defaultValue: "Fokus Timer starten"),
            localizedSubtitle: nil,
            icon: UIApplicationShortcutIcon(systemImageName: "timer"),
            userInfo: nil
        )
        
        let screenTime = UIApplicationShortcutItem(
            type: ShortcutType.screenTime.rawValue,
            localizedTitle: String(localized: "shortcut.screentime.title", defaultValue: "Bildschirmzeit"),
            localizedSubtitle: nil,
            icon: UIApplicationShortcutIcon(systemImageName: "hourglass"),
            userInfo: nil
        )
        
        let rateApp = UIApplicationShortcutItem(
            type: ShortcutType.rateApp.rawValue,
            localizedTitle: String(localized: "shortcut.rate.title", defaultValue: "App bewerten"),
            localizedSubtitle: nil,
            icon: UIApplicationShortcutIcon(systemImageName: "star.fill"),
            userInfo: nil
        )
        
        // Reversely ordered so Delete Warning is exactly above Delete App
        UIApplication.shared.shortcutItems = [rateApp, screenTime, startFocus, deleteWarning]
    }
}
