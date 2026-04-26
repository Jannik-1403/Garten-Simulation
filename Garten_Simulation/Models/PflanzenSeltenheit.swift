import SwiftUI

enum PflanzenSeltenheit: String, Codable, CaseIterable {
    case bronze  = "bronze"
    case silber  = "silber"
    case gold    = "gold"
    case diamant = "diamant"

    var lokalisiertTitel: String {
        let lang = SharedUserDefaults.suite.string(forKey: "appLanguage") ?? "de"
        return AppStrings.get("rarity.\(rawValue)", language: lang)
    }

    var farbe: Color {
        switch self {
        case .bronze:  return Color(red: 0.8,  green: 0.5,  blue: 0.2)
        case .silber:  return Color(red: 0.50, green: 0.52, blue: 0.60)
        case .gold:    return Color.goldPrimary
        case .diamant: return Color.blauPrimary
        }
    }
    
    var secondaryColor: Color {
        switch self {
        case .bronze:  return Color(red: 0.6, green: 0.3, blue: 0.1)
        case .silber:  return Color(red: 0.32, green: 0.35, blue: 0.42)
        case .gold:    return Color.orange
        case .diamant: return Color.cyan
        }
    }

    var iconName: String {
        switch self {
        case .bronze:  return "medal.fill"
        case .silber:  return "seal.fill"
        case .gold:    return "trophy.fill"
        case .diamant: return "crown.fill"
        }
    }

    var gradient: LinearGradient {
        LinearGradient(
            colors: [farbe, secondaryColor],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var xpSchwelle: Int {
        switch self {
        case .bronze:  return 0
        case .silber:  return GameConstants.xpFuerSilber
        case .gold:    return GameConstants.xpFuerGold
        case .diamant: return GameConstants.xpFuerDiamant
        }
    }

    /// Nächste Seltenheit
    var naechste: PflanzenSeltenheit? {
        switch self {
        case .bronze:  return .silber
        case .silber:  return .gold
        case .gold:    return .diamant
        case .diamant: return nil
        }
    }

    /// XP bis zur nächsten Stufe
    func xpBisNaechste(aktuelleXP: Int) -> Int? {
        guard let naechste = naechste else { return nil }
        return max(0, naechste.xpSchwelle - aktuelleXP)
    }

    /// Fortschritt 0.0–1.0 innerhalb der aktuellen Stufe
    func fortschritt(aktuelleXP: Int) -> Double {
        let von = xpSchwelle
        let bis = naechste?.xpSchwelle ?? (xpSchwelle + GameConstants.xpFuerDiamant)
        guard bis > von else { return 1.0 }
        return min(Double(aktuelleXP - von) / Double(bis - von), 1.0)
    }
}
