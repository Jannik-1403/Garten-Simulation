import SwiftUI

enum PflanzenStufe: Int, CaseIterable, Codable {
    case bronze1 = 0
    case bronze2 = 1
    case bronze3 = 2
    case silber1 = 3
    case silber2 = 4
    case silber3 = 5
    case gold1   = 6
    case gold2   = 7
    case gold3   = 8
    case diamant1 = 9
    case diamant2 = 10
    case diamant3 = 11
    
    var farbe: Color {
        switch self {
        case .bronze1:  return Color(hex: "#E8C49A")  // hellstes Bronze
        case .bronze2:  return Color(hex: "#D4A76A")
        case .bronze3:  return Color(hex: "#B8843A")  // dunkelstes Bronze
        case .silber1:  return Color(hex: "#BFCFDA")  // Abgedunkelt von #D8E4EC
        case .silber2:  return Color(hex: "#8EA5B5")  // Abgedunkelt von #A8BFD0
        case .silber3:  return Color(hex: "#668299")  // Abgedunkelt von #7A9BB5
        case .gold1:    return Color(hex: "#FFE566")  // hellstes Gold
        case .gold2:    return Color(hex: "#F5CC00")
        case .gold3:    return Color(hex: "#D4A800")  // dunkelstes Gold
        case .diamant1: return Color(hex: "#A8E6FF")  // hellstes Diamant
        case .diamant2: return Color(hex: "#5BC8F5")
        case .diamant3: return Color(hex: "#1A9FE0")  // dunkelstes Diamant
        }
    }
    
    var labelKey: String {
        switch self {
        case .bronze1:  return "stufe.bronze1"
        case .bronze2:  return "stufe.bronze2"
        case .bronze3:  return "stufe.bronze3"
        case .silber1:  return "stufe.silber1"
        case .silber2:  return "stufe.silber2"
        case .silber3:  return "stufe.silber3"
        case .gold1:    return "stufe.gold1"
        case .gold2:    return "stufe.gold2"
        case .gold3:    return "stufe.gold3"
        case .diamant1: return "stufe.diamant1"
        case .diamant2: return "stufe.diamant2"
        case .diamant3: return "stufe.diamant3"
        }
    }
    
    var sfSymbol: String {
        switch self {
        case .bronze1, .bronze2, .bronze3: return "seal.fill"
        case .silber1, .silber2, .silber3: return "star.fill"
        case .gold1, .gold2, .gold3:       return "crown.fill"
        case .diamant1, .diamant2, .diamant3: return "diamond.fill"
        }
    }
    var rarity: PflanzenSeltenheit {
        switch self {
        case .bronze1, .bronze2, .bronze3: return .bronze
        case .silber1, .silber2, .silber3: return .silber
        case .gold1, .gold2, .gold3:       return .gold
        case .diamant1, .diamant2, .diamant3: return .diamant
        }
    }
    
    var naechste: PflanzenStufe? {
        PflanzenStufe(rawValue: self.rawValue + 1)
    }
    
    /// Returns the first stage of the next rarity
    var naechsteRaritaetStufe: PflanzenStufe? {
        switch self.rarity {
        case .bronze:  return .silber1
        case .silber:  return .gold1
        case .gold:    return .diamant1
        case .diamant: return nil
        }
    }
    
    // MARK: - Level Detection from XP
    static func stufe(fuerXP xp: Int) -> PflanzenStufe {
        // Return the highest level where the threshold is <= current XP
        return PflanzenStufe.allCases.reversed().first {
            GameConstants.xpSchwelle(fuer: $0) <= xp
        } ?? .bronze1
    }
}
