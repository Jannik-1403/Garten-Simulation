import SwiftUI

extension Color {
    // Bestehende Farben bleiben!
    static let gruenPrimary = Color(red: 0.35, green: 0.8, blue: 0.2)
    static let gruenSecondary = Color(red: 0.25, green: 0.6, blue: 0.1)
    static let blauPrimary = Color(red: 0.16, green: 0.71, blue: 0.96)
    static let blauSecondary = Color(red: 0.1, green: 0.5, blue: 0.75)
    static let orangePrimary = Color(red: 1.0, green: 0.6, blue: 0.1)
    static let orangeSecondary = Color(red: 0.85, green: 0.4, blue: 0.05)
    static let rotPrimary = Color(red: 1.0, green: 0.3, blue: 0.3)
    static let rotSecondary = Color(red: 0.8, green: 0.1, blue: 0.1)
    static let lilaPrimary = Color(red: 0.7, green: 0.2, blue: 0.9)
    static let lilaSecondary = Color(red: 0.5, green: 0.1, blue: 0.7)
    
    // NEU: Coin-Farbe (aus GartenStatsBar)
    static let coinBlue = Color(hex: "#00919E")
    
    // NEU: Seltenheits-Farben
    // Bronze (dunkles, sattes Mahagoni/Kupfer)
    static let bronzePrimary = Color(red: 0.75, green: 0.30, blue: 0.05)
    static let bronzeSecondary = Color(red: 0.55, green: 0.15, blue: 0.00)
    
    // Silber (dunkler, kühler Stahl)
    static let silberPrimary = Color(red: 0.50, green: 0.55, blue: 0.62)
    static let silberSecondary = Color(red: 0.30, green: 0.35, blue: 0.45)
    
    // Gold (tiefes, dunkles Altgold)
    static let goldPrimary = Color(red: 0.80, green: 0.60, blue: 0.00)
    static let goldSecondary = Color(red: 0.65, green: 0.40, blue: 0.00)
    
    // Diamant (tiefes, sattes Ozeanblau/Cyan)
    static let diamantPrimary = Color(red: 0.00, green: 0.60, blue: 0.80)
    static let diamantSecondary = Color(red: 0.00, green: 0.30, blue: 0.65)

    /// Warmes Banner-/Belohnungs-Gold (harmoniert mit „Doppelte Belohnung“)
    static let belohnungGoldHighlight = Color(red: 0.96, green: 0.84, blue: 0.42)
    static let belohnungGoldMid = Color(red: 0.88, green: 0.68, blue: 0.22)
    static let belohnungGoldSchatten = Color(red: 0.62, green: 0.42, blue: 0.08)
    
    // Hintergrund
    static let appHintergrund = Color(red: 0.95, green: 0.95, blue: 0.97)
    
    // Hex Init Helper
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 255, 255, 255)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    static func fromHexString(_ hex: String) -> Color {
        return Color(hex: hex)
    }

    func darker(by amount: Double) -> Color {
        let uiColor = UIColor(self)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return Color(hue: h, saturation: s, brightness: max(0, b - amount), opacity: a)
    }

    func lighter(by amount: Double) -> Color {
        let uiColor = UIColor(self)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return Color(hue: h, saturation: s, brightness: min(1, b + amount), opacity: a)
    }

    // Helper to mix two colors
    static func mix(_ c1: Color, with c2: Color, pct: Double = 0.5) -> Color {
        let u1 = UIColor(c1)
        let u2 = UIColor(c2)
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        u1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        u2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        return Color(red: r1 + (r2 - r1) * pct, green: g1 + (g2 - g1) * pct, blue: b1 + (b2 - b1) * pct, opacity: a1 + (a2 - a1) * pct)
    }
}

struct AppColors {
    static func color(for name: String) -> Color {
        switch name.lowercased() {
        case "green", "gruen":   return .gruenPrimary
        case "blue", "blau":     return .blauPrimary
        case "orange":           return .orangePrimary
        case "red", "rot":       return .rotPrimary
        case "purple", "lila":   return .lilaPrimary
        case "yellow", "gelb":   return .yellow
        case "mint":             return .mint
        case "teal":             return .teal
        case "cyan":             return .cyan
        case "pink":             return .pink
        case "indigo":           return .indigo
        case "brown":            return .brown
        case "gray":             return .gray
        default:                 return .gruenPrimary
        }
    }
}
