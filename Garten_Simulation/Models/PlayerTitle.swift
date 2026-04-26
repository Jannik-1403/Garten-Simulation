import SwiftUI

struct PlayerTitle: Identifiable, Codable, Equatable {
    let id: String           // z.B. "titel_bambus"
    let plantID: String?     // nil beim Anfänger-Titel
    let displayName: String  // Lokalisierungskey, z.B. "titel.bambus"
    let color: String        // Hex-String, z.B. "#4ECDC4"
    let isBonus: Bool        // true = Meilenstein-Bonus-Titel
}

extension PlayerTitle {
    var titleColor: Color {
        Color.fromHexString(color)
    }
}
