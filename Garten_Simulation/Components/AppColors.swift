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
    
    // NEU: Seltenheits-Farben
    // Bronze (dunkles, sattes Mahagoni/Kupfer)
    static let bronzePrimary = Color(red: 0.75, green: 0.30, blue: 0.05)
    static let bronzeSecondary = Color(red: 0.55, green: 0.15, blue: 0.00)
    
    // Silber (dunkler, kühler Stahl)
    static let silberPrimary = Color(red: 0.60, green: 0.65, blue: 0.70)
    static let silberSecondary = Color(red: 0.40, green: 0.45, blue: 0.55)
    
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
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
