import Foundation
import SwiftUI

enum OnboardingZiel: String, CaseIterable, Identifiable {
    case gesund, produktiv, mental, fit, lernen, schlafen

    var id: String { self.rawValue }

    var localizationKey: String { "onboarding_ziel_\(self.rawValue)" }

    var labelKey: String { "onboarding_ziel_\(self.rawValue)_label" }

    var iconName: String {
        switch self {
        case .gesund:    return "fork.knife"
        case .produktiv: return "target"
        case .mental:    return "brain.head.profile"
        case .fit:       return "figure.run"
        case .lernen:    return "book.closed"
        case .schlafen:  return "moon.stars.fill"
        }
    }

    var color: Color {
        switch self {
        case .gesund:    return Color(red: 0.2, green: 0.84, blue: 0.53)
        case .produktiv: return Color(red: 0.11, green: 0.55, blue: 0.96)
        case .mental:    return Color(red: 0.64, green: 0.45, blue: 1.0)
        case .fit:       return Color(red: 1.0, green: 0.44, blue: 0.26)
        case .lernen:    return Color(red: 0.36, green: 0.39, blue: 0.94)
        case .schlafen:  return Color(red: 0.3, green: 0.6, blue: 0.9)
        }
    }

    var pflanzenIDs: [String] {
        switch self {
        case .gesund:    return ["plant.apfelbaum", "plant.zitronenbaum", "plant.erdbeerpflanze", "plant.weinrebe", "plant.minzpflanze"]
        case .produktiv: return ["plant.bambus", "plant.weizenfeld", "plant.kirschbaum", "plant.mandelbaum", "plant.apfelbaum"]
        case .mental:    return ["plant.lotus", "plant.lavendel", "plant.klee", "plant.aloe_vera", "plant.sonnenblume"]
        case .fit:       return ["plant.wildgras", "plant.kaktus", "plant.efeu", "plant.bambus", "plant.sonnenblume"]
        case .lernen:    return ["plant.weizenfeld", "plant.mandelbaum", "plant.minzpflanze", "plant.lotus", "plant.bambus"]
        case .schlafen:  return ["plant.lavendel", "plant.lotus", "plant.aloe_vera", "plant.klee", "plant.minzpflanze"]
        }
    }
}
