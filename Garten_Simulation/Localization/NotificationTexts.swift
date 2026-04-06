import Foundation

struct NotificationTexts {
    
    // MARK: - Trigger A: Wartet (18h)
    static func wartet(pflanzenName: String, stunden: Int) -> (title: String, body: String) {
        let variants: [(title: String, body: String)] = [
            ("🌿 \(pflanzenName) wartet…", "Schon \(stunden)h kein Wasser. Dein Garten vermisst dich."),
            ("💧 Zeit zum Gießen", "\(pflanzenName) streckt die Blätter nach dir aus."),
            ("🪴 \(pflanzenName) schaut dich an", "Nur 10 Sekunden — dann ist sie glücklich.")
        ]
        return variants.randomElement() ?? variants[0]
    }
    
    // MARK: - Trigger B: Streak-Gefahr (22h)
    static func streakGefahr(pflanzenName: String, streak: Int) -> (title: String, body: String) {
        let variants: [(title: String, body: String)] = [
            ("🔥 Streak in Gefahr!", "\(pflanzenName) bricht deinen \(streak)-Tage-Streak. Noch nicht aufgeben."),
            ("⚠️ \(streak) Tage — nicht jetzt verlieren", "\(pflanzenName) braucht dich in den nächsten 2 Stunden."),
            ("😰 Fast zu spät", "Dein \(streak)-Tage-Streak mit \(pflanzenName) hängt am seidenen Faden.")
        ]
        return variants.randomElement() ?? variants[0]
    }
    
    // MARK: - Trigger C: Morgen-Motivation (8:00 Uhr)
    static func morgenMotivation(streak: Int) -> (title: String, body: String) {
        let variants: [(title: String, body: String)] = [
            ("🌅 Guten Morgen, Gärtner!", "Gestern perfekt. Heute wieder? Dein Garten glaubt an dich."),
            ("✨ \(streak) Tage stark", "Du baust gerade echte Gewohnheiten auf. Weiter so."),
            ("🏆 Perfekter Vortag!", "Alle Pflanzen wurden gegossen. Dein Garten strahlt heute.")
        ]
        return variants.randomElement() ?? variants[0]
    }
    
    // MARK: - Trigger D: Stiller Abend (20:00 Uhr)
    static func stillerAbend(anzahlUngegossen: Int) -> (title: String, body: String) {
        let bodyPlural = anzahlUngegossen == 1 ? "Pflanze wartet" : "Pflanzen warten"
        let bodyPlural2 = anzahlUngegossen == 1 ? "Pflanze würde" : "Pflanzen würden"

        let variants: [(title: String, body: String)] = [
            ("🌙 Fast geschafft", "Noch \(anzahlUngegossen) \(bodyPlural) auf heute Abend."),
            ("🪴 Kurz vor Schluss", "Ein schnelles Gießen — dann ist der Tag perfekt."),
            ("💤 Bevor du schläfst", "\(anzahlUngegossen) \(bodyPlural2) sich über Wasser freuen.")
        ]
        return variants.randomElement() ?? variants[0]
    }
}
