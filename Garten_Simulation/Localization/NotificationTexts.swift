import Foundation

struct NotificationTexts {

    // MARK: - Individuelle Pflanzen-Erinnerung

    static func pflanzeErinnerung(pflanzenName: String, habitKey: String = "") -> (title: String, body: String) {
        let cleanHabitKey = habitKey.lowercased()
        
        let specificBodyKey = "notification.body.\(cleanHabitKey)"
        let specificTitleKey = "notification.title.\(cleanHabitKey)"
        
        // Prüfen ob es einen spezifischen Text in Localizable.xcstrings gibt
        let specificBody = Bundle.main.localizedString(forKey: specificBodyKey, value: nil, table: nil)
        let hasSpecificBody = specificBody != specificBodyKey
        
        let title: String
        let body: String
        
        if hasSpecificBody {
            let specificTitle = Bundle.main.localizedString(forKey: specificTitleKey, value: nil, table: nil)
            let finalTitle = specificTitle == specificTitleKey ? String(localized: "notification.title.generic", defaultValue: "Erinnerung") : specificTitle
            
            title = String(format: finalTitle, pflanzenName)
            body = String(format: specificBody, pflanzenName)
        } else {
            title = String(format: String(localized: "notification.title.generic", defaultValue: "Erinnerung"), pflanzenName)
            let fallbackBody = String(localized: "notification.body.generic", defaultValue: "Vergiss nicht: %@ wartet auf dich!")
            body = String(format: fallbackBody, pflanzenName)
        }
        
        return (title, body)
    }

    // MARK: - Legacy (kept for any remaining callers)

    static func wartet(pflanzenName: String, stunden: Int) -> (title: String, body: String) {
        return pflanzeErinnerung(pflanzenName: pflanzenName)
    }

    static func streakGefahr(pflanzenName: String, streak: Int) -> (title: String, body: String) {
        return pflanzeErinnerung(pflanzenName: pflanzenName)
    }

    static func morgenMotivation(streak: Int) -> (title: String, body: String) {
        return (" Guten Morgen!", "Heute ist ein neuer Tag. Vergiss deine Pflanzen nicht!")
    }

    static func stillerAbend(anzahlUngegossen: Int) -> (title: String, body: String) {
        return (String(localized: "notification.title.generic", defaultValue: "Erinnerung"), String(format: String(localized: "notification.body.generic", defaultValue: "Vergiss nicht: %@ wartet auf dich!"), "Pflanzen"))
    }
}
