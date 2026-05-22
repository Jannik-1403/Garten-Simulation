import SwiftUI

public enum ErfolgTier: Int, Codable, CaseIterable, Comparable {
    case bronze = 0
    case silber = 1
    case gold = 2
    case diamant = 3
    case max = 4
    
    public var nameKey: String {
        switch self {
        case .bronze: return "tier_stufe_bronze_1"
        case .silber: return "tier_stufe_silber_1"
        case .gold: return "tier_stufe_gold_1"
        case .diamant: return "tier_stufe_diamant_1"
        case .max: return "erfolg.max_reached"
        }
    }
    
    public var label: String {
        switch self {
        case .bronze: return "Bronze"
        case .silber: return "Silber"
        case .gold: return "Gold"
        case .diamant, .max: return "Diamant"
        }
    }
    
    public var color: Color {
        switch self {
        case .bronze:
            return Color(hex: "#CD7F32") // Bronze
        case .silber:
            return Color(hex: "#5A6268") // Darker metallic Slate Silver for enhanced contrast
        case .gold:
            return Color(hex: "#FFB300") // Gold
        case .diamant, .max:
            return Color(hex: "#00B0FF") // Diamant
        }
    }
    
    public static func < (lhs: ErfolgTier, rhs: ErfolgTier) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

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
    let tier: ErfolgTier
    let freigeschaltet: Bool
    var freigeschaltetAm: Date?
    
    var istFreigeschaltet: Bool {
        freigeschaltet
    }
    
    // Zeigt "6/9" oder "✓" an
    var fortschrittLabel: String {
        if tier == .max {
            return "✓"
        }
        return istFreigeschaltet ? "✓" : "\(aktuellerWert)/\(zielWert)"
    }
    
    // Gibt das passende neue SVG-Icon (Gold, Blau, Rot) zurück
    var mixedImageName: String {
        switch tier {
        case .bronze:
            return "Achievment_Rot"
        case .silber:
            return "Achievment_Blau"
        case .gold, .diamant, .max:
            return "Achievment_Gold"
        }
    }
}

enum ErfolgKategorie: String, CaseIterable, Identifiable {
    case streak      = "🔥 Streak"
    case garten      = "🌿 Garten"
    case shop        = "🛒 Shop"
    case sammler     = "⭐ Sammler"
    
    var id: String { self.rawValue }
}

