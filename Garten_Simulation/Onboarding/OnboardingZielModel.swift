import Foundation
import SwiftUI

enum OnboardingZiel: String, CaseIterable, Identifiable {
    case gesund, produktiv, mental, fit, lernen
    
    var id: String { self.rawValue }
    
    var localizationKey: String {
        "onboarding_ziel_\(self.rawValue)"
    }
    
    var emoji: String {
        switch self {
        case .gesund:    return "🍏"
        case .produktiv: return "🎯"
        case .mental:    return "🧘"
        case .fit:       return "🏃"
        case .lernen:    return "📚"
        }
    }
    
    var labelKey: String {
        "onboarding_ziel_\(self.rawValue)_label"
    }
    
    var iconName: String {
        switch self {
        case .gesund:    return "fork.knife"
        case .produktiv: return "target"
        case .mental:    return "brain.head.profile"
        case .fit:       return "figure.run"
        case .lernen:    return "book.closed"
        }
    }
    
    var color: Color {
        switch self {
        case .gesund:    return Color(red: 0.2, green: 0.84, blue: 0.53) // Vibrant Mint/Green
        case .produktiv: return Color(red: 0.11, green: 0.55, blue: 0.96) // Deep Sky Blue
        case .mental:    return Color(red: 0.64, green: 0.45, blue: 1.0) // Soft Radiant Purple
        case .fit:       return Color(red: 1.0, green: 0.44, blue: 0.26) // Vivid Coral/Orange
        case .lernen:    return Color(red: 0.36, green: 0.39, blue: 0.94) // Intelligent Indigo
        }
    }
    
    var pflanzenIDs: [String] {
        switch self {
        case .gesund:    return ["plant.apfelbaum", "plant.zitronenbaum", "plant.erdbeerpflanze", "plant.weinrebe", "plant.minzpflanze"]
        case .produktiv: return ["plant.bambus", "plant.weizenfeld", "plant.kirschbaum", "plant.mandelbaum", "plant.apfelbaum"]
        case .mental:    return ["plant.lotus", "plant.lavendel", "plant.klee", "plant.aloe_vera", "plant.sonnenblume"]
        case .fit:       return ["plant.wildgras", "plant.kaktus", "plant.efeu", "plant.bambus", "plant.sonnenblume"]
        case .lernen:    return ["plant.weizenfeld", "plant.mandelbaum", "plant.minzpflanze", "plant.lotus", "plant.bambus"]
        }
    }
}
