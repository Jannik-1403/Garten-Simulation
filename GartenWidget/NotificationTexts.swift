import Foundation

struct NotificationTexts {
    
    // MARK: - Helper for variants
    private static func randomVariant() -> Int {
        return Int.random(in: 1...3)
    }
    
    // MARK: - Trigger A: Wartet (18h)
    static func wartet(pflanzenName: String, stunden: Int, lang: String) -> (title: String, body: String) {
        let variant = randomVariant()
        let title = AppStrings.get("notification.wait.\(variant).title", language: lang)
            .replacingOccurrences(of: "%@", with: pflanzenName)
        let body = AppStrings.get("notification.wait.\(variant).body", language: lang)
            .replacingOccurrences(of: "%d", with: "\(stunden)")
            .replacingOccurrences(of: "%@", with: pflanzenName)
        
        return (title, body)
    }
    
    // MARK: - Trigger B: Streak-Gefahr (22h)
    static func streakGefahr(pflanzenName: String, streak: Int, lang: String) -> (title: String, body: String) {
        let variant = randomVariant()
        let title = AppStrings.get("notification.streak.\(variant).title", language: lang)
            .replacingOccurrences(of: "%@", with: pflanzenName)
        let body = AppStrings.get("notification.streak.\(variant).body", language: lang)
            .replacingOccurrences(of: "%@", with: pflanzenName)
            .replacingOccurrences(of: "%d", with: "\(streak)")
        
        return (title, body)
    }
    
    // MARK: - Trigger C: Morgen-Motivation (8:00 Uhr)
    static func morgenMotivation(streak: Int, lang: String) -> (title: String, body: String) {
        let variant = randomVariant()
        let title = AppStrings.get("notification.morning.\(variant).title", language: lang)
        let body = AppStrings.get("notification.morning.\(variant).body", language: lang)
            .replacingOccurrences(of: "%d", with: "\(streak)")
        
        return (title, body)
    }
    
    // MARK: - Trigger D: Stiller Abend (20:00 Uhr)
    static func stillerAbend(anzahlUngegossen: Int, lang: String) -> (title: String, body: String) {
        let variant = randomVariant()
        let title = AppStrings.get("notification.evening.\(variant).title", language: lang)
        
        // Handle pluralization for different languages
        let unit: String
        if lang == "de" {
            unit = anzahlUngegossen == 1 ? "Pflanze" : "Pflanzen"
        } else if lang == "es" {
            unit = anzahlUngegossen == 1 ? "planta" : "plantas"
        } else if lang == "fr" {
            unit = anzahlUngegossen == 1 ? "plante" : "plantes"
        } else if lang == "it" {
            unit = anzahlUngegossen == 1 ? "pianta" : "piante"
        } else if lang == "pt" {
            unit = anzahlUngegossen == 1 ? "planta" : "plantas"
        } else {
            unit = anzahlUngegossen == 1 ? "plant" : "plants"
        }
        
        let body = AppStrings.get("notification.evening.\(variant).body", language: lang)
            .replacingOccurrences(of: "%d", with: "\(anzahlUngegossen)")
            .replacingOccurrences(of: "%@", with: unit)
        
        return (title, body)
    }
}

