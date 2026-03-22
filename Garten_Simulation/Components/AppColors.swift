import SwiftUI

extension Color {
    // Grün (Pflanzen, Erfolg)
    static let gruenPrimary = Color(red: 0.35, green: 0.8, blue: 0.2)
    static let gruenSecondary = Color(red: 0.25, green: 0.6, blue: 0.1)
    
    // Blau (Gießen Button)
    static let blauPrimary = Color(red: 0.16, green: 0.71, blue: 0.96)
    static let blauSecondary = Color(red: 0.1, green: 0.5, blue: 0.75)
    
    // Orange (Streak)
    static let orangePrimary = Color(red: 1.0, green: 0.6, blue: 0.1)
    static let orangeSecondary = Color(red: 0.85, green: 0.4, blue: 0.05)
    
    // Rot (Herzen, Gefahr)
    static let rotPrimary = Color(red: 1.0, green: 0.3, blue: 0.3)
    static let rotSecondary = Color(red: 0.8, green: 0.1, blue: 0.1)
    
    // Lila (Gems)
    static let lilaPrimary = Color(red: 0.7, green: 0.2, blue: 0.9)
    static let lilaSecondary = Color(red: 0.5, green: 0.1, blue: 0.7)
    
}
// Hex Farben Helper
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255
        let b = Double(rgbValue & 0x0000FF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
