import Foundation

enum GameConstants {

    // MARK: Belohnungen pro Gießvorgang
    static let coinsProGiessen: Int = 20
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
    
    // MARK: - Pro-User Vorteile
    /// Coin-Multiplikator für Pro-User beim Gießen (+25%)
    static let proCoinBonus: Double = 1.25
    /// Rabatt-Faktor auf Pflanzen-Kaufpreis für Pro-User (50% günstiger)
    static let proUnlockDiscount: Double = 0.5
 
    // MARK: - Lokalisierung — Key-Präfix
    // Alle UI-Texte kommen aus Localizable.strings, nie hardcoden
    



    
    /// Maximale gespeicherte Glücksrad-Drehungen
    static let maxGluecksradDrehungen: Int = 10
    
    /// Kosten für die Wiederbelebung einer toten Pflanze
    static let wiederbelebungsKosten: Int = 300
    
    /// Kosten für die Wiederbelebung aller toten Pflanzen
    static let wiederbelebungsKostenAlle: Int = 800

    // MARK: - Unkraut
    /// Gewohnheiten (Gießvorgänge), um ein einzelnes Unkraut zu entfernen
    static let habitsRequiredPerWeed: Int = 3
    /// XP-Multiplikator pro aktivem Unkraut (0.5 = 50 %)
    static let weedXPMultiplierPerPatch: Double = 0.8
    /// Untergrenze: selbst bei vielen Unkräutern mindestens 25 % XP
    static let weedMinimumXPMultiplier: Double = 0.5
    /// Coin-Abzug pro aktivem Unkraut beim Gießen
    static let weedCoinPenaltyPerPatch: Int = 0
    /// Münzkosten = Dekopreis × dieser Faktor
    static let weedRemovalCostMultiplier: Int = 3
    /// Fallback-Kosten, wenn Unkraut durch Pflanzentod entsteht
    static let weedRemovalCostPlantDeath: Int = 500
    /// Fallback-Kosten für Unkraut aus dem Glücksrad
    static let weedRemovalCostSpin: Int = 150
    /// Kosten, um ALLE aktiven Unkräuter auf einmal zu entfernen
    static let weedRemoveAllCost: Int = 1000
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
    
}

