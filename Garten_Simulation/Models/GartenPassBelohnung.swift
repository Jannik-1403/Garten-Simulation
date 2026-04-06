import SwiftUI

enum BelohnungsTyp: Codable, Equatable {
    case coins(Int)
    case gluecksradDrehung(Int)
    case powerUp(id: String)
    case pflanze(id: String)
    case dekoration(id: String)
    case paket(titel: String, coins: Int, powerUpID: String?)
    case seeds(Int)
}

struct GartenPassBelohnung: Identifiable {
    let id: Int          // = Level-Nummer
    let typ: BelohnungsTyp
    let istMeilenstein: Bool   // true bei Level 10, 20, 30, 40, 50
    
    var symbolName: String {
        switch typ {
        case .coins:               return "bitcoinsign.circle.fill"
        case .gluecksradDrehung:   return "arrow.2.circlepath"
        case .powerUp:             return "bolt.fill"
        case .pflanze:             return "leaf.fill"
        case .dekoration:          return "sparkles"
        case .paket:               return "giftcard.fill"
        case .seeds:               return "leaf.arrow.triangle.circlepath"
        }
    }
    
    var beschriftung: String {
        getDisplayInfo().name
    }
    
    var kategorieFarbe: Color {
        switch typ {
        case .coins:               return Color(hex: "#49D6BE") // Helles Türkis
        case .gluecksradDrehung:   return Color(hex: "#5BA8D4") // Hellblau (Diamant)
        case .powerUp:             return Color(hex: "#A855F7") // Lila
        case .pflanze:             return .gruenPrimary         // Grün
        case .dekoration:          return .orange              // Orange
        case .paket:               return .pink                 // Meilenstein-Paket
        case .seeds:               return .purple               // Samen (Lila)
        }
    }
    
    /// Holt detaillierte Anzeige-Informationen (Asset-Name & Klartext-Name) aus der Datenbank
    func getDisplayInfo() -> (name: String, icon: String, isAsset: Bool) {
        switch typ {
        case .coins(let n):
            return ("\(n) Coins", "coin", true)
            
        case .gluecksradDrehung(let n):
            let label = n == 1 ? NSLocalizedString("reward_type_spin_singular", comment: "") : NSLocalizedString("reward_type_spin_plural", comment: "")
            return ("\(n) \(label)", "arrow.2.circlepath", false)
            
        case .powerUp(let id):
            if let pu = GameDatabase.allPowerUps.first(where: { $0.id == id }) {
                return (NSLocalizedString(pu.name, comment: ""), pu.symbolName, true)
            }
            return (NSLocalizedString("reward_type_powerup", comment: ""), "bolt.fill", false)
            
        case .pflanze(let id):
            if let pl = GameDatabase.allPlants.first(where: { $0.id == id }) {
                return (NSLocalizedString(pl.name, comment: ""), pl.symbolName, false)
            }
            return (NSLocalizedString("reward_type_plant", comment: ""), "leaf.fill", false)
            
        case .dekoration(let id):
            if let dk = GameDatabase.allDecorations.first(where: { $0.id == id }) {
                return (NSLocalizedString(dk.nameKey, comment: ""), dk.sfSymbol, false)
            }
            return (NSLocalizedString("reward_type_decoration", comment: ""), "sparkles", false)
            
        case .paket(let titel, _, _):
            return (NSLocalizedString(titel, comment: ""), "reward_type_paket", false)
            
        case .seeds(let n):
            return ("\(n) Samen", "leaf.arrow.triangle.circlepath", false)
        }
    }
    
    var tier: GartenTier {
        switch id {
        case 1...10:  return .bronze
        case 11...25: return .silber
        case 26...40: return .gold
        default:      return .diamant
        }
    }
}

enum GartenTier {
    case bronze, silber, gold, diamant
    
    var farbe: Color {
        switch self {
        case .bronze:  return Color(hex: "#CD7F32")
        case .silber:  return Color(hex: "#9EA5B0")
        case .gold:    return Color(hex: "#E8A020")
        case .diamant: return Color(hex: "#5BA8D4")
        }
    }
    
    var hellFarbe: Color {
        switch self {
        case .bronze:  return Color(hex: "#F5E6D3")
        case .silber:  return Color(hex: "#EEF0F3")
        case .gold:    return Color(hex: "#FDF3DC")
        case .diamant: return Color(hex: "#E0F0FA")
        }
    }
    
    var dunkelFarbe: Color {
        switch self {
        case .bronze:  return Color(hex: "#7A4A1A")
        case .silber:  return Color(hex: "#4A5260")
        case .gold:    return Color(hex: "#7A4E08")
        case .diamant: return Color(hex: "#1A4A6A")
        }
    }
    
    var kontrastFarbe: Color {
        switch self {
        case .bronze:  return Color(hex: "#EFE1D1") // Sehr helles Bronze-Grau
        case .silber:  return Color(hex: "#F4F5F7") // Kühles Hellgrau
        case .gold:    return Color(hex: "#FFF9E6") // Zartes Gold-Gelb
        case .diamant: return Color(hex: "#F0F7FB") // Frisches Hellblau
        }
    }
    
    var bezeichnung: String {
        switch self {
        case .bronze:  return NSLocalizedString("tier_bronze", comment: "")
        case .silber:  return NSLocalizedString("tier_silber", comment: "")
        case .gold:    return NSLocalizedString("tier_gold", comment: "")
        case .diamant: return NSLocalizedString("tier_diamant", comment: "")
        }
    }
    
    var levelRange: String {
        switch self {
        case .bronze:  return "1–10"
        case .silber:  return "11–25"
        case .gold:    return "26–40"
        case .diamant: return "41–50"
        }
    }
}

// MARK: - Alle Belohnungen

extension GartenPassBelohnung {
    static let alle: [GartenPassBelohnung] = [
        .init(id: 1,  typ: .coins(50),                          istMeilenstein: false),
        .init(id: 2,  typ: .gluecksradDrehung(1),                istMeilenstein: false),
        .init(id: 3,  typ: .pflanze(id: "plant.bambus"),        istMeilenstein: false),
        .init(id: 4,  typ: .powerUp(id: "powerup.gartenschutz"), istMeilenstein: false),
        .init(id: 5,  typ: .coins(100),                         istMeilenstein: false),
        .init(id: 6,  typ: .dekoration(id: "trash.ultra_konsole"), istMeilenstein: false),
        .init(id: 7,  typ: .pflanze(id: "plant.wildgras"),       istMeilenstein: false),
        .init(id: 8,  typ: .powerUp(id: "powerup.wunder_wasser"), istMeilenstein: false),
        .init(id: 9,  typ: .coins(100),                         istMeilenstein: false),
        .init(id: 10, typ: .seeds(10),                          istMeilenstein: true),
        .init(id: 11, typ: .pflanze(id: "plant.lavendel"),      istMeilenstein: false),
        .init(id: 12, typ: .coins(120),                          istMeilenstein: false),
        .init(id: 13, typ: .dekoration(id: "trash.fast_food_abo"), istMeilenstein: false),
        .init(id: 14, typ: .gluecksradDrehung(1),                istMeilenstein: false),
        .init(id: 15, typ: .gluecksradDrehung(1),                istMeilenstein: false),
        .init(id: 16, typ: .powerUp(id: "powerup.sturmfest"),    istMeilenstein: false),
        .init(id: 17, typ: .pflanze(id: "plant.apfelbaum"),      istMeilenstein: false),
        .init(id: 18, typ: .powerUp(id: "powerup.zeitkapsel"),   istMeilenstein: false),
        .init(id: 19, typ: .pflanze(id: "plant.sonnenblume"),   istMeilenstein: false),
        .init(id: 20, typ: .seeds(10),                          istMeilenstein: true),
        .init(id: 21, typ: .dekoration(id: "trash.luxus_auto"),  istMeilenstein: false),
        .init(id: 22, typ: .coins(180),                          istMeilenstein: false),
        .init(id: 23, typ: .pflanze(id: "plant.kirschbaum"),    istMeilenstein: false),
        .init(id: 24, typ: .gluecksradDrehung(1),                istMeilenstein: false),
        .init(id: 25, typ: .powerUp(id: "powerup.tier_freund"),  istMeilenstein: false),
        .init(id: 26, typ: .pflanze(id: "plant.eiche"),         istMeilenstein: false),
        .init(id: 27, typ: .dekoration(id: "trash.party_pass"),  istMeilenstein: false),
        .init(id: 28, typ: .gluecksradDrehung(1),                istMeilenstein: false),
        .init(id: 29, typ: .pflanze(id: "plant.lotus"),         istMeilenstein: false),
        .init(id: 30, typ: .seeds(10),                          istMeilenstein: true),
        .init(id: 31, typ: .pflanze(id: "plant.kaktus"),        istMeilenstein: false),
        .init(id: 32, typ: .coins(225),                          istMeilenstein: false),
        .init(id: 33, typ: .dekoration(id: "trash.energy_drink_kiste"), istMeilenstein: false),
        .init(id: 34, typ: .powerUp(id: "powerup.diamant_erde"), istMeilenstein: false),
        .init(id: 35, typ: .pflanze(id: "plant.weinrebe"),       istMeilenstein: false),
        .init(id: 36, typ: .powerUp(id: "powerup.zauberstab"),   istMeilenstein: false),
        .init(id: 37, typ: .pflanze(id: "plant.minzpflanze"),    istMeilenstein: false),
        .init(id: 38, typ: .gluecksradDrehung(1),                istMeilenstein: false),
        .init(id: 39, typ: .pflanze(id: "plant.erdbeerpflanze"), istMeilenstein: false),
        .init(id: 40, typ: .seeds(10),                          istMeilenstein: true),
        .init(id: 41, typ: .dekoration(id: "trash.online_shopping_app"), istMeilenstein: false),
        .init(id: 42, typ: .gluecksradDrehung(1),                istMeilenstein: false),
        .init(id: 43, typ: .coins(300),                          istMeilenstein: false),
        .init(id: 44, typ: .pflanze(id: "plant.zitronenbaum"),   istMeilenstein: false),
        .init(id: 45, typ: .powerUp(id: "powerup.gluecks_segen"), istMeilenstein: false),
        .init(id: 46, typ: .pflanze(id: "plant.weizenfeld"),     istMeilenstein: false),
        .init(id: 47, typ: .dekoration(id: "trash.zigaretten_automat"), istMeilenstein: false),
        .init(id: 48, typ: .gluecksradDrehung(2),                istMeilenstein: false),
        .init(id: 49, typ: .coins(500),                          istMeilenstein: false),
        .init(id: 50, typ: .seeds(10),                          istMeilenstein: true)
    ]
}
