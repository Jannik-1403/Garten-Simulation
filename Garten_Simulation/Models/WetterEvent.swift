import SwiftUI

// MARK: - Wetter Event Enum
enum WetterEvent: String, CaseIterable {
    case normal
    case regen
    case schnee
    case sturm
    case perfekt

    // MARK: - Texte
    var titel: String {
        switch self {
        case .normal: return String(localized: "weather.normal.title", defaultValue: "Ruhiger Tag")
        case .regen: return String(localized: "weather.regen.title", defaultValue: "Regen")
        case .schnee: return String(localized: "weather.schnee.title", defaultValue: "Frostwarnung")
        case .sturm: return String(localized: "weather.sturm.title", defaultValue: "Sturm im Anmarsch")
        case .perfekt: return String(localized: "weather.perfekt.title", defaultValue: "Perfektes Wetter!")
        }
    }

    var untertitel: String {
        switch self {
        case .normal: return String(localized: "weather.normal.subtitle", defaultValue: "Alles wächst wie geplant")
        case .regen: return String(localized: "weather.regen.subtitle", defaultValue: "Heute gibt es doppelte XP!")
        case .schnee: return String(localized: "weather.schnee.subtitle", defaultValue: "Heute nur 50% Belohnung")
        case .sturm: return String(localized: "weather.sturm.subtitle", defaultValue: "Pflanzentod kostet 2 Leben!")
        case .perfekt: return String(localized: "weather.perfekt.subtitle", defaultValue: "Heute doppelte Belohnung!")
        }
    }

    var regel: String {
        switch self {
        case .normal: return String(localized: "weather.rule.normal", defaultValue: "Alles normal. Einmal gießen.")
        case .regen: return String(localized: "weather.rule.regen", defaultValue: "Regen: Heute erhältst du doppelte XP.")
        case .schnee: return String(localized: "weather.rule.schnee", defaultValue: "Frost: Nur die Hälfte der Coins erhalten.")
        case .sturm: return String(localized: "weather.rule.sturm", defaultValue: "Sturm: Wenn eine Pflanze stirbt, verlierst du 2 Leben statt 1.")
        case .perfekt: return String(localized: "weather.rule.perfekt", defaultValue: "Perfektes Wetter: Heute doppelte Coins.")
        }
    }

    var icon: String {
        switch self {
        case .normal: return ""
        case .regen: return ""
        case .schnee: return ""
        case .sturm: return ""
        case .perfekt: return ""
        }
    }

    var customIconName: String {
        switch self {
        case .normal: return "WetterNormal"
        case .regen: return "WetterRegen"
        case .schnee: return "WetterFrost"
        case .sturm: return "WetterSturm"
        case .perfekt: return "WetterPerfekt"
        }
    }

    var systemIcon: String {
        switch self {
        case .normal: return "sun.max.fill"
        case .regen: return "cloud.rain.fill"
        case .schnee: return "snowflake"
        case .sturm: return "cloud.bolt.rain.fill"
        case .perfekt: return "rainbow"
        }
    }

    // MARK: - Farben
    var bannerFarbe: Color {
        switch self {
        case .normal: return .gruenPrimary
        case .regen: return Color(red: 0.2, green: 0.5, blue: 0.9)
        case .schnee: return Color(red: 0.5, green: 0.8, blue: 1.0)
        case .sturm: return Color(red: 0.3, green: 0.3, blue: 0.35)
        case .perfekt: return Color(red: 0.9, green: 0.7, blue: 0.1)
        }
    }

    var bannerFarbeSekundaer: Color {
        switch self {
        case .normal: return .gruenSecondary
        case .regen: return Color(red: 0.1, green: 0.35, blue: 0.7)
        case .schnee: return Color(red: 0.3, green: 0.6, blue: 0.85)
        case .sturm: return Color(red: 0.2, green: 0.2, blue: 0.25)
        case .perfekt: return Color(red: 0.75, green: 0.55, blue: 0.0)
        }
    }

    var hintergrundFarbe: Color {
        switch self {
        case .normal: return Color(red: 0.95, green: 0.95, blue: 0.97)
        case .regen: return Color(red: 0.88, green: 0.93, blue: 1.00)
        case .schnee: return Color(red: 0.90, green: 0.95, blue: 1.00)
        case .sturm: return Color(red: 0.88, green: 0.88, blue: 0.90)
        case .perfekt: return Color(red: 1.00, green: 0.98, blue: 0.88)
        }
    }

    var kartenBorder: Color {
        switch self {
        case .normal: return Color.clear
        case .regen: return Color.blue.opacity(0.3)
        case .schnee: return Color.blue.opacity(0.3)
        case .sturm: return Color.gray.opacity(0.4)
        case .perfekt: return Color.yellow.opacity(0.6)
        }
    }

    // MARK: - Spiel Logik
    var xpMultiplikator: Double {
        switch self {
        case .regen: return 1.5
        case .perfekt: return 1.5
        default: return 1.0
        }
    }

    var gemMultiplikator: Double {
        switch self {
        case .perfekt: return 1.5
        case .schnee: return 0.7
        default: return 1.0
        }
    }

    var gesundheitsVerlust: Double {
        switch self {
        case .sturm: return 0.03
        case .schnee: return 0.015
        case .perfekt: return 0.005
        default: return 0.01
        }
    }

    var kannGiessen: Bool {
        switch self {
        default: return true
        }
    }
}
