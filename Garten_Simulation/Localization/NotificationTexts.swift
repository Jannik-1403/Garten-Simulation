import Foundation

struct NotificationTexts {
    
    // MARK: - Trigger A: Wartet (18h)
    static func wartet(pflanzenName: String, stunden: Int, lang: String) -> (title: String, body: String) {
        let title = AppStrings.get("notification.wait.1.title", language: lang)
            .replacingOccurrences(of: "%@", with: pflanzenName)
        let body = AppStrings.get("notification.wait.1.body", language: lang)
            .replacingOccurrences(of: "%d", with: "\(stunden)")
        
        return (title, body)
    }
    
    // MARK: - Trigger B: Streak-Gefahr (22h)
    static func streakGefahr(pflanzenName: String, streak: Int, lang: String) -> (title: String, body: String) {
        let title = AppStrings.get("notification.streak.1.title", language: lang)
        let body = AppStrings.get("notification.streak.1.body", language: lang)
            .replacingOccurrences(of: "%@", with: pflanzenName)
            .replacingOccurrences(of: "%d", with: "\(streak)")
        
        return (title, body)
    }
    
    // MARK: - Trigger C: Morgen-Motivation (8:00 Uhr)
    static func morgenMotivation(streak: Int, lang: String) -> (title: String, body: String) {
        let title = AppStrings.get("notification.morning.1.title", language: lang)
        let body = AppStrings.get("notification.morning.1.body", language: lang)
            .replacingOccurrences(of: "%d", with: "\(streak)")
        
        return (title, body)
    }
    
    // MARK: - Trigger D: Stiller Abend (20:00 Uhr)
    static func stillerAbend(anzahlUngegossen: Int, lang: String) -> (title: String, body: String) {
        let title = AppStrings.get("notification.evening.1.title", language: lang)
        
        // Handle pluralization for different languages
        let unit: String
        if lang == "de" {
            unit = anzahlUngegossen == 1 ? "Pflanze wartet" : "Pflanzen warten"
        } else if lang == "es" {
            unit = anzahlUngegossen == 1 ? "planta espera" : "plantas esperan"
        } else {
            unit = anzahlUngegossen == 1 ? "plant is waiting" : "plants are waiting"
        }
        
        let body = AppStrings.get("notification.evening.1.body", language: lang)
            .replacingOccurrences(of: "%d", with: "\(anzahlUngegossen)")
            .replacingOccurrences(of: "%@", with: unit)
        
        return (title, body)
    }
}
