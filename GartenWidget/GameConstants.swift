import Foundation

enum GameConstants {

    // MARK: Belohnungen pro Gießvorgang
    static let coinsProGiessen: Int = 10
    static let xpProGiessen: Int = 100
    static let mlProGiessen: Double = 300
    static let gemsProGiessen: Int = 1
 
    static let bonusChance: Double = 0.15          // 15% Wahrscheinlichkeit
    static let bonusXPMultiplier: Double = 2.0     // Bonus: doppelte XP
    static let bonusGemAmount: Int = 1             // Bonus: +1 Gem
 
    // MARK: XP-Schwellen für Pflanzen-Seltenheit
    // Bronze ist der Startzustand (0 XP)
    static let xpFuerSilber: Int  = 250
    static let xpFuerGold: Int    = 750
    static let xpFuerDiamant: Int = 2000
 
    // MARK: Streak
    static let streakTimerStunden: Double = 24  // Timer-Fenster in Stunden
    static let streakLottieURL = "https://lottie.host/b8842b8d-669c-45fe-a8cb-92cbd20903dc/9KcW3VdzUV.lottie"
 
    // MARK: Onboarding
    static let startCoins: Int = 0
    static let gratisPflanzenAnzahl: Int = 2
 
    // MARK: - Lokalisierung — Key-Präfix
    // Alle UI-Texte kommen aus Localizable.strings, nie hardcoden
    
    // MARK: - PflanzenStufe XP Schwellen
    static func xpSchwelle(fuer stufe: PflanzenStufe) -> Int {
        switch stufe {
        case .bronze1:  return 0
        case .bronze2:  return 80
        case .bronze3:  return 160
        case .silber1:  return 250
        case .silber2:  return 400
        case .silber3:  return 550
        case .gold1:    return 750
        case .gold2:    return 1100
        case .gold3:    return 1500
        case .diamant1: return 2000
        case .diamant2: return 2750
        case .diamant3: return 4000
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

    // MARK: - Unkraut
    /// Gewohnheiten (Gießvorgänge), um ein einzelnes Unkraut zu entfernen
    static let habitsRequiredPerWeed: Int = 3
    /// XP-Multiplikator pro aktivem Unkraut (0.5 = 50 %)
    static let weedXPMultiplierPerPatch: Double = 0.5
    /// Untergrenze: selbst bei vielen Unkräutern mindestens 25 % XP
    static let weedMinimumXPMultiplier: Double = 0.25
    /// Coin-Abzug pro aktivem Unkraut beim Gießen
    static let weedCoinPenaltyPerPatch: Int = 5
    /// Münzkosten = Dekopreis × dieser Faktor
    static let weedRemovalCostMultiplier: Int = 3
    /// Fallback-Kosten, wenn Unkraut durch Pflanzentod entsteht
    static let weedRemovalCostPlantDeath: Int = 500
    /// Fallback-Kosten für Unkraut aus dem Glücksrad
    static let weedRemovalCostSpin: Int = 150
    /// Tage bis Unkraut Pflanzen schwächt
    static let weedSpreadDays: Int = 3
    /// Max. Coin-Strafe pro Gießen: Anteil am aktuellen Guthaben (0.5 = 50 %)
    static let weedCoinPenaltyMaxWalletFraction: Double = 0.5

    // MARK: - Comeback-Bonus (nach schwerer Unkraut-Krise)
    static let comebackMinimumPeakWeeds: Int = 3
    static let comebackMinimumHabitClears: Int = 2
    static let comebackMinimumCrisisHours: Double = 24
    /// Rein-Deko-Krisen müssen länger „reifen“, bevor der Boost auslöst
    static let comebackDecorationOnlyMinHours: Double = 72
    static let comebackCooldownDays: Int = 7
    static let comebackXPMultiplier: Double = 1.2
    static let comebackBoostDurationHours: Double = 24

    /// Zauberstab: sofort alle Unkräuter weg + Schutz vor neuem Unkraut
    static let zauberstabDurationHours: Double = 72

    // MARK: - Streak-Schutz-Blüte (Vorleistung)
    static let disciplineBloomStreakDays: Int = 7
    
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

