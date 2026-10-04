import Foundation

struct NotificationTexts {
    
    // MARK: - Helper for variants
    private static func randomVariant() -> Int {
        return Int.random(in: 1...3)
    }
    
    // MARK: - Trigger A: Wartet (18h)
    static func wartet(pflanzenName: String, stunden: Int) -> (title: String, body: String) {
        let lang = Locale.current.language.languageCode?.identifier ?? "de"
        _ = lang
        let variant = randomVariant()
        let title = NSLocalizedString("notification.wait.\(variant).title", comment: "")
            .replacingOccurrences(of: "%@", with: pflanzenName)
        let body = NSLocalizedString("notification.wait.\(variant).body", comment: "")
            .replacingOccurrences(of: "%d", with: "\(stunden)")
            .replacingOccurrences(of: "%@", with: pflanzenName)
        
        return (title, body)
    }
    
    // MARK: - Trigger B: Streak-Gefahr (22h)
    static func streakGefahr(pflanzenName: String, streak: Int) -> (title: String, body: String) {
        let lang = Locale.current.language.languageCode?.identifier ?? "de"
        _ = lang
        let variant = randomVariant()
        let title = NSLocalizedString("notification.streak.\(variant).title", comment: "")
            .replacingOccurrences(of: "%@", with: pflanzenName)
        let body = NSLocalizedString("notification.streak.\(variant).body", comment: "")
            .replacingOccurrences(of: "%@", with: pflanzenName)
            .replacingOccurrences(of: "%d", with: "\(streak)")
        
        return (title, body)
    }
    
    // MARK: - Trigger C: Morgen-Motivation (8:00 Uhr)
    static func morgenMotivation(streak: Int) -> (title: String, body: String) {
        let lang = Locale.current.language.languageCode?.identifier ?? "de"
        _ = lang
        let variant = randomVariant()
        let title = NSLocalizedString("notification.morning.\(variant).title", comment: "")
        let body = NSLocalizedString("notification.morning.\(variant).body", comment: "")
            .replacingOccurrences(of: "%d", with: "\(streak)")
        
        return (title, body)
    }
    
    // MARK: - Trigger D: Stiller Abend (20:00 Uhr)
    static func stillerAbend(anzahlUngegossen: Int) -> (title: String, body: String) {
        let lang = Locale.current.language.languageCode?.identifier ?? "de"
        _ = lang
        let variant = randomVariant()
        let title = NSLocalizedString("notification.evening.\(variant).title", comment: "")
        
        let unit = (anzahlUngegossen == 1) ? String(localized: "notification.plant.singular", defaultValue: "Pflanze") : String(localized: "notification.plant.plural", defaultValue: "Pflanzen")
        
        let body = NSLocalizedString("notification.evening.\(variant).body", comment: "")
            .replacingOccurrences(of: "%d", with: "\(anzahlUngegossen)")
            .replacingOccurrences(of: "%@", with: unit)
        
        return (title, body)
    }
}

