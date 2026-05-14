import SwiftUI

struct Erfolg: Identifiable {
    let id: String
    let titelKey: String         // Localizable.strings Key für den Namen
    let beschreibungKey: String  // Key für Beschreibung
    let sfSymbol: String
    let farbe: Color
    let zielWert: Int            // z.B. 7 für "7 Tage Streak"
    let aktuellerWert: Int       // wird vom Store befüllt
    let kategorie: ErfolgKategorie
    let imageName: String
    var freigeschaltetAm: Date?
    
    var istFreigeschaltet: Bool { aktuellerWert >= zielWert }
    
    // Zeigt "6/9" oder "✓" an
    var fortschrittLabel: String {
        istFreigeschaltet ? "✓" : "\(aktuellerWert)/\(zielWert)"
    }
}

enum ErfolgKategorie: String, CaseIterable, Identifiable {
    case streak      = "🔥 Streak"
    case garten      = "🌿 Garten"
    case shop        = "🛒 Shop"
    case sammler     = "⭐ Sammler"
    
    var id: String { self.rawValue }
}
