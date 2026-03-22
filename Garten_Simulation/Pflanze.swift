import SwiftData
import SwiftUI

enum Seltenheit: String, Codable {
    case gewoehnlich
    case selten
    case episch
    case legendaer

    var bezeichnung: String {
        switch self {
        case .gewoehnlich: return "Gewöhnlich"
        case .selten: return "Selten"
        case .episch: return "Episch"
        case .legendaer: return "Legendär"
        }
    }

    var ringFarbe: Color {
        switch self {
        case .gewoehnlich: return .gewoehnlichPrimary
        case .selten: return .seltenPrimary
        case .episch: return .epischPrimary
        case .legendaer: return .legendaerPrimary
        }
    }

    var ringFarbeSekundaer: Color {
        switch self {
        case .gewoehnlich: return .gewoehnlichSecondary
        case .selten: return .seltenSecondary
        case .episch: return .epischSecondary
        case .legendaer: return .legendaerSecondary
        }
    }

    var tagHintergrund: Color {
        ringFarbe.opacity(0.18)
    }

    var tagTextFarbe: Color {
        ringFarbe
    }

    var iconName: String {
        switch self {
        case .gewoehnlich: return "bonsai_stufe1"
        case .selten: return "bonsai_stufe2"
        case .episch: return "bonsai_stufe3"
        case .legendaer: return "bonsai_stufe4"
        }
    }
}

@Model
class Pflanze {
    var name: String
    var bildName: String
    var streak: Int
    var gesundheit: Double
    var fortschritt: Double
    var gewaessert: Bool
    var istGesperrt: Bool
    var seltenheit: Seltenheit

    var iconName: String {
        seltenheit.iconName
    }

    init(name: String, bildName: String, seltenheit: Seltenheit = .gewoehnlich) {
        self.name = name
        self.bildName = bildName
        self.streak = 0
        self.gesundheit = 1.0
        self.fortschritt = 0.0
        self.gewaessert = false
        self.istGesperrt = false
        self.seltenheit = seltenheit
    }
}
