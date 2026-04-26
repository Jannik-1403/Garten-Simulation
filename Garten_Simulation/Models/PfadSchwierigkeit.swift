import SwiftUI

enum PfadSchwierigkeit: String, Codable, CaseIterable {
    case anfaenger
    case fortgeschritten
    case experte

    var titelKey: String {
        switch self {
        case .anfaenger:       return "pfad_schwierigkeit_anfaenger"
        case .fortgeschritten: return "pfad_schwierigkeit_fortgeschritten"
        case .experte:         return "pfad_schwierigkeit_experte"
        }
    }

    var beschreibungKey: String {
        switch self {
        case .anfaenger:       return "pfad_schwierigkeit_anfaenger_desc"
        case .fortgeschritten: return "pfad_schwierigkeit_fortgeschritten_desc"
        case .experte:         return "pfad_schwierigkeit_experte_desc"
        }
    }

    var icon: String {
        switch self {
        case .anfaenger:       return "🌱"
        case .fortgeschritten: return "🔥"
        case .experte:         return "⚡"
        }
    }

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
}
