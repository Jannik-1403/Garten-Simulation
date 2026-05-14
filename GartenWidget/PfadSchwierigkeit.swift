import SwiftUI

enum PfadSchwierigkeit: String, Codable, CaseIterable {
    case anfaenger
    case fortgeschritten
    case experte

    var farbe: Color {
        switch self {
        case .anfaenger:       return Color(hex: "#58CC02")
        case .fortgeschritten: return Color(hex: "#FF9600")
        case .experte:         return Color(hex: "#FF4040")
        }
    }

    // Welche Tage werden übersprungen (bereits bekannte Basics)
    var startTag: Int {
        switch self {
        case .anfaenger:       return 1   // Beginnt bei Tag 1
        case .fortgeschritten: return 8   // Überspringt erste Woche
        case .experte:         return 15  // Beginnt direkt bei Phase 2
        }
    }

    var anzeigeName: String {
        switch self {
        case .anfaenger:       return NSLocalizedString("schwierigkeit.anfaenger", comment: "")
        case .fortgeschritten: return NSLocalizedString("schwierigkeit.fortgeschritten", comment: "")
        case .experte:         return NSLocalizedString("schwierigkeit.experte", comment: "")
        }
    }

    var beschreibung: String {
        switch self {
        case .anfaenger:       return NSLocalizedString("schwierigkeit.anfaenger.desc", comment: "")
        case .fortgeschritten: return NSLocalizedString("schwierigkeit.fortgeschritten.desc", comment: "")
        case .experte:         return NSLocalizedString("schwierigkeit.experte.desc", comment: "")
        }
    }

    var emoji: String {
        switch self {
        case .anfaenger:       return "🌱"
        case .fortgeschritten: return "🌿"
        case .experte:         return "🌳"
        }
    }
}
