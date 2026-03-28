import Foundation

enum GameConstants {

    // MARK: Belohnungen pro Gießvorgang
    static let coinsProGiessen: Int = 10
    static let xpProGiessen: Int = 20

    // MARK: XP-Schwellen für Pflanzen-Seltenheit
    // Bronze ist der Startzustand (0 XP)
    static let xpFuerSilber: Int  = 50
    static let xpFuerGold: Int    = 150
    static let xpFuerDiamant: Int = 300

    // MARK: Streak
    static let streakTimerStunden: Double = 24  // Timer-Fenster in Stunden

    // MARK: Onboarding
    static let startCoins: Int = 1000
    static let gratisPflanzenAnzahl: Int = 2

    // MARK: Lokalisierung — Key-Präfix
    // Alle UI-Texte kommen aus Localizable.strings, nie hardcoden
}
