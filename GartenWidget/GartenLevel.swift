import SwiftUI

/// Beschreibt was bei einem bestimmten Garten-Level freigeschaltet wird.
struct GartenLevelFreischaltung: Identifiable {
    let id = UUID()
    let level: Int
    let titel: String          // Lokalisierungskey
    let beschreibung: String   // Lokalisierungskey
    let typ: FreischaltungTyp
    let symbolName: String     // SF Symbol
}

enum FreischaltungTyp {
    case gluecksradDrehung(anzahl: Int)
    case pflanze(datenbankID: String)   // ID aus GameDatabase
    case powerUp(powerUpID: String)
    case dekoration
    case coinBonus(prozent: Int)
    case neuePflanzenkategorie
    case titelMeisterGaertner
    case gartenSkin
}

/// Helper-Struct für das 50-Level Garten-System.
/// Nutzt die XP-Schwellen aus `GameConstants.gartenLevelSchwellen`.
enum GartenLevel {
    
    static let alleFreischaltungen: [GartenLevelFreischaltung] = [
        // Level 2
        .init(level: 2,  titel: "level_unlock_spin_titel",
              beschreibung: "level_unlock_spin_1_desc",
              typ: .gluecksradDrehung(anzahl: 1),
              symbolName: "arrow.2.circlepath"),
        // Level 3
        .init(level: 3,  titel: "level_unlock_pflanze_titel",
              beschreibung: "level_unlock_pflanze_exklusiv_desc",
              typ: .pflanze(datenbankID: "bambus"),
              symbolName: "leaf.fill"),
        // Level 5
        .init(level: 5,  titel: "level_unlock_deko_titel",
              beschreibung: "level_unlock_deko_desc",
              typ: .dekoration,
              symbolName: "sparkles"),
        // Level 8
        .init(level: 8,  titel: "level_unlock_coin_bonus_titel",
              beschreibung: "level_unlock_coin_5_desc",
              typ: .coinBonus(prozent: 5),
              symbolName: "bitcoinsign.circle.fill"),
        // Level 10
        .init(level: 10, titel: "level_unlock_powerup_titel",
              beschreibung: "level_unlock_powerup_desc",
              typ: .powerUp(powerUpID: "duenger_x2"),
              symbolName: "bolt.fill"),
        // Level 12
        .init(level: 12, titel: "level_unlock_kategorie_titel",
              beschreibung: "level_unlock_kategorie_desc",
              typ: .neuePflanzenkategorie,
              symbolName: "rectangle.grid.2x2.fill"),
        // Level 15
        .init(level: 15, titel: "level_unlock_spin_titel",
              beschreibung: "level_unlock_spin_1_desc",
              typ: .gluecksradDrehung(anzahl: 1),
              symbolName: "arrow.2.circlepath"),
        // Level 20
        .init(level: 20, titel: "level_unlock_coin_bonus_titel",
              beschreibung: "level_unlock_coin_10_desc",
              typ: .coinBonus(prozent: 10),
              symbolName: "bitcoinsign.circle.fill"),
        // Level 23
        .init(level: 23, titel: "level_unlock_pflanze_titel",
              beschreibung: "level_unlock_kategorie_selten_desc",
              typ: .neuePflanzenkategorie,
              symbolName: "staroflife.fill"),
        // Level 25
        .init(level: 25, titel: "level_unlock_spin_titel",
              beschreibung: "level_unlock_spin_2_desc",
              typ: .gluecksradDrehung(anzahl: 2),
              symbolName: "arrow.2.circlepath"),
        // Level 30
        .init(level: 30, titel: "level_unlock_coin_bonus_titel",
              beschreibung: "level_unlock_coin_15_desc",
              typ: .coinBonus(prozent: 15),
              symbolName: "bitcoinsign.circle.fill"),
        // Level 35
        .init(level: 35, titel: "level_unlock_powerup_titel",
              beschreibung: "level_unlock_powerup_slot_desc",
              typ: .powerUp(powerUpID: "extra_slot"),
              symbolName: "bolt.fill"),
        // Level 40
        .init(level: 40, titel: "level_unlock_prestige_titel",
              beschreibung: "level_unlock_coin_20_desc",
              typ: .coinBonus(prozent: 20),
              symbolName: "crown.fill"),
        // Level 45
        .init(level: 45, titel: "level_unlock_pflanze_titel",
              beschreibung: "level_unlock_legendaer_desc",
              typ: .pflanze(datenbankID: "weltenbaum"),
              symbolName: "leaf.fill"),
        // Level 48
        .init(level: 48, titel: "level_unlock_spin_titel",
              beschreibung: "level_unlock_spin_bonus_desc",
              typ: .gluecksradDrehung(anzahl: 2),
              symbolName: "arrow.2.circlepath"),
        // Level 50
        .init(level: 50, titel: "level_unlock_meister_titel",
              beschreibung: "level_unlock_meister_desc",
              typ: .titelMeisterGaertner,
              symbolName: "crown.fill"),
    ]

    /// Berechnet das aktuelle Garten-Level basierend auf der Gesamt-XP.
    /// Level 1 = 0 XP, Level 2 = gartenLevelSchwellen[0] usw.
    static func level(fuerXP xp: Int) -> Int {
        var kumuliert = 0
        for i in 0..<GameConstants.gartenLevelSchwellen.count {
            kumuliert += GameConstants.gartenLevelSchwellen[i]
            if xp < kumuliert {
                return i + 1
            }
        }
        return 50
    }
    
    /// XP die im aktuellen Level bereits gesammelt wurden (für Fortschrittsbalken).
    static func xpImLevel(gesamtXP: Int) -> Int {
        let aktuellesLevel = level(fuerXP: gesamtXP)
        let xpBisAktuellesLevel = GameConstants.xpFuerLevel(aktuellesLevel)
        return gesamtXP - xpBisAktuellesLevel
    }
    
    /// XP die für den Aufstieg zum nächsten Level benötigt werden.
    static func xpFuerNaechstenLevel(gesamtXP: Int) -> Int {
        let aktuellesLevel = level(fuerXP: gesamtXP)
        guard aktuellesLevel < 50 else { return 0 }
        return GameConstants.gartenLevelSchwellen[aktuellesLevel - 1]
    }

    /// Gibt alle Freischaltungen für ein bestimmtes Level zurück
    static func freischaltungenFuer(level: Int) -> [GartenLevelFreischaltung] {
        alleFreischaltungen.filter { $0.level == level }
    }

    /// Coin-Bonus-Multiplikator basierend auf aktuellem Level (z.B. 1.15 = +15%)
    static func coinMultiplikator(fuerLevel level: Int) -> Double {
        let anwendbareBonus = GameConstants.coinBonusProLevel
            .filter { $0.key <= level }
            .values
            .max() ?? 0
        return 1.0 + Double(anwendbareBonus) / 100.0
    }
    
    // MARK: - UI Helpers (50-Level System)
    
    static func farbe(fuerLevel level: Int) -> Color {
        switch level {
        case 1...10:  return Color(hex: "#CD7F32") // Bronze
        case 11...25: return Color(.systemGray)    // Silber
        case 26...40: return Color.goldPrimary     // Gold
        case 41...50: return Color.blauPrimary     // Diamant/Blau
        default:      return .primary
        }
    }
    
    static func hellFarbe(fuerLevel level: Int) -> Color {
        farbe(fuerLevel: level).opacity(0.12)
    }
    
    static func dunkelFarbe(fuerLevel level: Int) -> Color {
        level > 10 && level <= 25 ? .primary : farbe(fuerLevel: level)
    }
    
    static func symbol(fuerLevel level: Int) -> String {
        switch level {
        case 1...10:  return "medal.fill"
        case 11...25: return "medal.fill"
        case 26...40: return "crown.fill"
        case 41...50: return "sparkles"
        default:      return "star.fill"
        }
    }
}
