import Foundation

enum GameConstants {

    // MARK: Belohnungen pro Gießvorgang
    static let coinsProGiessen: Int = 10
    static let xpProGiessen: Int = 100
    static let mlProGiessen: Double = 300
 
    // MARK: XP-Schwellen für Pflanzen-Seltenheit
    // Bronze ist der Startzustand (0 XP)
    static let xpFuerSilber: Int  = 800
    static let xpFuerGold: Int    = 2500
    static let xpFuerDiamant: Int = 7500
 
    // MARK: Streak
    static let streakTimerStunden: Double = 24  // Timer-Fenster in Stunden
 
    // MARK: Onboarding
    static let startCoins: Int = 1000
    static let gratisPflanzenAnzahl: Int = 2
 
    // MARK: - Lokalisierung — Key-Präfix
    // Alle UI-Texte kommen aus Localizable.strings, nie hardcoden
    
    // MARK: - PflanzenStufe XP Schwellen
    static func xpSchwelle(fuer stufe: PflanzenStufe) -> Int {
        switch stufe {
        case .bronze1:  return 0
        case .bronze2:  return 200
        case .bronze3:  return 400
        case .silber1:  return 800
        case .silber2:  return 1200
        case .silber3:  return 1600
        case .gold1:    return 2500
        case .gold2:    return 3500
        case .gold3:    return 5000
        case .diamant1: return 7500
        case .diamant2: return 10000
        case .diamant3: return 15000
        }
    }

    // MARK: - Garten Level System
    
    /// XP-Schwellen für jeden der 50 Garten-Level.
    /// Index 0 = XP benötigt für Level 1→2, Index 49 = Level 50 (kein Aufstieg mehr)
    static let gartenLevelSchwellen: [Int] = {
        // Kurve: frühe Level schnell, spätere Level deutlich mehr XP
        var thresholds: [Int] = []
        for level in 1...50 {
            let xp: Int
            switch level {
            case 1:  xp = 100
            case 2:  xp = 250
            case 3:  xp = 450
            case 4:  xp = 700
            case 5:  xp = 1_000
            case 6...10:
                xp = 1_000 + (level - 5) * 350
            case 11...20:
                xp = 2_750 + (level - 10) * 600
            case 21...35:
                xp = 8_750 + (level - 20) * 1_200
            case 36...50:
                xp = 26_750 + (level - 35) * 2_500
            default:
                xp = 999_999
            }
            thresholds.append(xp)
        }
        return thresholds
    }()
    
    /// Kumulierte XP-Gesamtsumme um Level X zu erreichen (für Fortschrittsbalken)
    static func xpFuerLevel(_ level: Int) -> Int {
        guard level >= 1 else { return 0 }
        return gartenLevelSchwellen.prefix(level - 1).reduce(0, +)
    }
    
    /// Maximale gespeicherte Glücksrad-Drehungen
    static let maxGluecksradDrehungen: Int = 10
    
    /// Kosten für die Wiederbelebung einer toten Pflanze
    static let wiederbelebungsKosten: Int = 50
    
    /// Coin-Bonus pro Stufe (kumulativ, in Prozent)
    static let coinBonusProLevel: [Int: Int] = [
        8:  5,
        20: 10,
        30: 15,
        40: 20
    ]
    
    // MARK: - PflanzenStufe ↔ Garten-Level Mapping
    /// XP-Schwelle für jede Garten-Stufe (PflanzenStufe) im 50-Level-System.
    /// Mappt die 12 PflanzenStufe-Werte auf kumulierte XP-Schwellen.
    static func xpSchwelleGarten(fuer stufe: PflanzenStufe) -> Int {
        switch stufe {
        case .bronze1:  return xpFuerLevel(1)    // 0
        case .bronze2:  return xpFuerLevel(4)    // Level 4
        case .bronze3:  return xpFuerLevel(8)    // Level 8
        case .silber1:  return xpFuerLevel(11)   // Level 11
        case .silber2:  return xpFuerLevel(15)   // Level 15
        case .silber3:  return xpFuerLevel(20)   // Level 20
        case .gold1:    return xpFuerLevel(26)   // Level 26
        case .gold2:    return xpFuerLevel(30)   // Level 30
        case .gold3:    return xpFuerLevel(35)   // Level 35
        case .diamant1: return xpFuerLevel(41)   // Level 41
        case .diamant2: return xpFuerLevel(45)   // Level 45
        case .diamant3: return xpFuerLevel(50)   // Level 50
        }
    }
}

