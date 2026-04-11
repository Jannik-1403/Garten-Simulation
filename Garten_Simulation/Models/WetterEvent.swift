import SwiftUI

// MARK: - Wetter Event Enum
enum WetterEvent: String, CaseIterable {
    case normal
    case duerre
    case schnee
    case sturm
    case perfekt

    // MARK: - Texte
    var titel: String {
        let lang = UserDefaults.standard.string(forKey: "appLanguage") ?? "de"
        return localize("weather.\(rawValue).title", language: lang)
    }

    var untertitel: String {
        let lang = UserDefaults.standard.string(forKey: "appLanguage") ?? "de"
        return localize("weather.\(rawValue).subtitle", language: lang)
    }

    private func localize(_ key: String, language: String) -> String {
        // Preference 1: Try Localizable.strings bundle
        if let path = Bundle.main.path(forResource: language, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            let localized = NSLocalizedString(key, tableName: nil, bundle: bundle, value: key, comment: "")
            if localized != key {
                return localized
            }
        }
        // Preference 2: AppStrings dictionary
        return AppStrings.get(key, language: language)
    }

    var icon: String {
        switch self {
        case .normal: return "☀️"
        case .duerre: return "🌵"
        case .schnee: return "❄️"
        case .sturm: return "⛈️"
        case .perfekt: return "🌈"
        }
    }

    var systemIcon: String {
        switch self {
        case .normal: return "sun.max.fill"
        case .duerre: return "thermometer.sun.fill"
        case .schnee: return "snowflake"
        case .sturm: return "cloud.bolt.rain.fill"
        case .perfekt: return "rainbow"
        }
    }

    // MARK: - Farben
    var bannerFarbe: Color {
        switch self {
        case .normal: return .gruenPrimary
        case .duerre: return Color(red: 0.9, green: 0.4, blue: 0.1)
        case .schnee: return Color(red: 0.5, green: 0.8, blue: 1.0)
        case .sturm: return Color(red: 0.3, green: 0.3, blue: 0.35)
        case .perfekt: return Color(red: 0.9, green: 0.7, blue: 0.1)
        }
    }

    var bannerFarbeSekundaer: Color {
        switch self {
        case .normal: return .gruenSecondary
        case .duerre: return Color(red: 0.7, green: 0.25, blue: 0.05)
        case .schnee: return Color(red: 0.3, green: 0.6, blue: 0.85)
        case .sturm: return Color(red: 0.2, green: 0.2, blue: 0.25)
        case .perfekt: return Color(red: 0.75, green: 0.55, blue: 0.0)
        }
    }

    var hintergrundFarbe: Color {
        switch self {
        case .normal: return Color(red: 0.95, green: 0.95, blue: 0.97)
        case .duerre: return Color(red: 0.98, green: 0.93, blue: 0.88)
        case .schnee: return Color(red: 0.90, green: 0.95, blue: 1.00)
        case .sturm: return Color(red: 0.88, green: 0.88, blue: 0.90)
        case .perfekt: return Color(red: 1.00, green: 0.98, blue: 0.88)
        }
    }

    var kartenBorder: Color {
        switch self {
        case .normal: return Color.clear
        case .duerre: return Color.orange.opacity(0.4)
        case .schnee: return Color.blue.opacity(0.3)
        case .sturm: return Color.gray.opacity(0.4)
        case .perfekt: return Color.yellow.opacity(0.6)
        }
    }

    // MARK: - Spiel Logik
    var giessAnzahl: Int {
        switch self {
        case .duerre: return 2 // 2x Gießen nötig
        default: return 1 // 1x reicht
        }
    }

    var gemMultiplikator: Double {
        switch self {
        case .perfekt: return 2.0 // Doppelte Gems
        case .schnee: return 0.5 // Halbe Gems
        default: return 1.0 // Normal
        }
    }

    var gesundheitsVerlust: Double {
        switch self {
        case .duerre: return 0.02 // Mehr Verlust
        case .sturm: return 0.03 // Meister Verlust
        default: return 0.01 // Normal
        }
    }

    var kannGiessen: Bool {
        switch self {
        default: return true
        }
    }
}
