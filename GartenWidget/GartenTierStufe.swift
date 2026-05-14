import SwiftUI

/// 12 Tier-Stufen aus den 50 Garten-Leveln.
/// Bronze I–III = Level 1–10, Silber I–III = 11–25,
/// Gold I–III = 26–40, Diamant I–III = 41–50
enum GartenTierStufe: CaseIterable {
    case bronzeI, bronzeII, bronzeIII
    case silberI, silberII, silberIII
    case goldI, goldII, goldIII
    case diamantI, diamantII, diamantIII

    // MARK: - Level-Mapping

    /// Welche Garten-Level (1–50) fallen in diese Stufe?
    var levelBereich: ClosedRange<Int> {
        switch self {
        case .bronzeI:   return 1...3
        case .bronzeII:  return 4...6
        case .bronzeIII: return 7...10
        case .silberI:   return 11...15
        case .silberII:  return 16...20
        case .silberIII: return 21...25
        case .goldI:     return 26...30
        case .goldII:    return 31...35
        case .goldIII:   return 36...40
        case .diamantI:  return 41...44
        case .diamantII: return 45...47
        case .diamantIII:return 48...50
        }
    }

    static func fuer(level: Int) -> GartenTierStufe {
        return GartenTierStufe.allCases.first { $0.levelBereich.contains(level) } ?? .bronzeI
    }

    // MARK: - Anzeige-Name

    // MARK: - Anzeige-Name
    
    /// Lokalisiert den Namen der Stufe basierend auf dem SettingsStore (wichtig für In-App Sprachwahl)
    func lokalisiertTitel(settings: SettingsStore) -> String {
        switch self {
        case .bronzeI:    return settings.localizedString(for: "tier_stufe_bronze_1")
        case .bronzeII:   return settings.localizedString(for: "tier_stufe_bronze_2")
        case .bronzeIII:  return settings.localizedString(for: "tier_stufe_bronze_3")
        case .silberI:    return settings.localizedString(for: "tier_stufe_silber_1")
        case .silberII:   return settings.localizedString(for: "tier_stufe_silber_2")
        case .silberIII:  return settings.localizedString(for: "tier_stufe_silber_3")
        case .goldI:      return settings.localizedString(for: "tier_stufe_gold_1")
        case .goldII:     return settings.localizedString(for: "tier_stufe_gold_2")
        case .goldIII:    return settings.localizedString(for: "tier_stufe_gold_3")
        case .diamantI:   return settings.localizedString(for: "tier_stufe_diamant_1")
        case .diamantII:  return settings.localizedString(for: "tier_stufe_diamant_2")
        case .diamantIII: return settings.localizedString(for: "tier_stufe_diamant_3")
        }
    }

    /// Alt-Property (Fallback auf System-Sprache), sollte in SwiftUI Views durch lokalisiertTitel ersetzt werden.
    @available(*, deprecated, message: "Nutze lokalisiertTitel(settings:) für korrekte In-App Sprachwahl")
    var bezeichnung: String {
        switch self {
        case .bronzeI:    return NSLocalizedString("tier_stufe_bronze_1", comment: "")
        case .bronzeII:   return NSLocalizedString("tier_stufe_bronze_2", comment: "")
        case .bronzeIII:  return NSLocalizedString("tier_stufe_bronze_3", comment: "")
        case .silberI:    return NSLocalizedString("tier_stufe_silber_1", comment: "")
        case .silberII:   return NSLocalizedString("tier_stufe_silber_2", comment: "")
        case .silberIII:  return NSLocalizedString("tier_stufe_silber_3", comment: "")
        case .goldI:      return NSLocalizedString("tier_stufe_gold_1", comment: "")
        case .goldII:     return NSLocalizedString("tier_stufe_gold_2", comment: "")
        case .goldIII:    return NSLocalizedString("tier_stufe_gold_3", comment: "")
        case .diamantI:   return NSLocalizedString("tier_stufe_diamant_1", comment: "")
        case .diamantII:  return NSLocalizedString("tier_stufe_diamant_2", comment: "")
        case .diamantIII: return NSLocalizedString("tier_stufe_diamant_3", comment: "")
        }
    }

    /// Kurz-Label für den Balken (I / II / III)
    var kurzLabel: String {
        switch self {
        case .bronzeI, .silberI, .goldI, .diamantI:     return "I"
        case .bronzeII, .silberII, .goldII, .diamantII:  return "II"
        case .bronzeIII, .silberIII, .goldIII, .diamantIII: return "III"
        }
    }

    // MARK: - Farben (hell → dunkel innerhalb Tier)

    /// Hauptfarbe der Stufe (für Balken, Dot, Badge-Icon)
    var farbe: Color {
        switch self {
        case .bronzeI:    return Color(hex: "#D4956A")  // helles Braun
        case .bronzeII:   return Color(hex: "#A86830")  // mittleres Braun
        case .bronzeIII:  return Color(hex: "#7A4A1A")  // dunkles Braun

        case .silberI:    return Color(hex: "#C0C8D4")  // helles Silber
        case .silberII:   return Color(hex: "#9EA5B0")  // mittleres Silber
        case .silberIII:  return Color(hex: "#6A7380")  // dunkles Silber

        case .goldI:      return Color(hex: "#F5C842")  // helles Gold
        case .goldII:     return Color(hex: "#E8A020")  // mittleres Gold
        case .goldIII:    return Color(hex: "#BA7010")  // dunkles Gold

        case .diamantI:   return Color(hex: "#85C4E8")  // helles Diamant
        case .diamantII:  return Color(hex: "#5BA8D4")  // mittleres Diamant
        case .diamantIII: return Color(hex: "#2A78A8")  // dunkles Diamant
        }
    }

    /// Heller Hintergrund für Badge / Karte
    var hellFarbe: Color {
        switch self {
        case .bronzeI:    return Color(hex: "#FAF0E8")
        case .bronzeII:   return Color(hex: "#F2DEC4")
        case .bronzeIII:  return Color(hex: "#E8C89A")

        case .silberI:    return Color(hex: "#F4F5F7")
        case .silberII:   return Color(hex: "#EEF0F3")
        case .silberIII:  return Color(hex: "#E2E5EA")

        case .goldI:      return Color(hex: "#FFFAE6")
        case .goldII:     return Color(hex: "#FDF3DC")
        case .goldIII:    return Color(hex: "#F8E4B0")

        case .diamantI:   return Color(hex: "#EBF6FC")
        case .diamantII:  return Color(hex: "#E0F0FA")
        case .diamantIII: return Color(hex: "#C8E4F5")
        }
    }

    /// Textfarbe auf hellem Hintergrund
    var dunkelFarbe: Color {
        switch self {
        case .bronzeI, .bronzeII, .bronzeIII:       return Color(hex: "#7A4A1A")
        case .silberI, .silberII, .silberIII:       return Color(hex: "#4A5260")
        case .goldI, .goldII, .goldIII:             return Color(hex: "#7A4E08")
        case .diamantI, .diamantII, .diamantIII:    return Color(hex: "#1A4A6A")
        }
    }

    // MARK: - Nächste Stufe

    var naechsteStufe: GartenTierStufe? {
        let all = GartenTierStufe.allCases
        guard let idx = all.firstIndex(of: self), idx + 1 < all.count else { return nil }
        return all[idx + 1]
    }

    /// XP-Fortschritt innerhalb dieser Stufe (0.0 – 1.0)
    func fortschritt(gesamtXP: Int) -> Double {
        let xpStart = GameConstants.xpFuerLevel(levelBereich.lowerBound)
        let xpEnde  = GameConstants.xpFuerLevel(levelBereich.upperBound + 1)
        guard xpEnde > xpStart else { return 1.0 }
        return min(max(Double(gesamtXP - xpStart) / Double(xpEnde - xpStart), 0), 1)
    }

    /// XP die noch fehlen bis zur nächsten Stufe
    func xpBisNaechste(gesamtXP: Int) -> Int {
        let xpEnde = GameConstants.xpFuerLevel(levelBereich.upperBound + 1)
        return max(xpEnde - gesamtXP, 0)
    }
}
