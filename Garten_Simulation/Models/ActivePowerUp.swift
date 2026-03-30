import Foundation

struct ActivePowerUp: Identifiable, Codable {
    let id: UUID
    let powerUpId: String         // Referenz auf PowerUpItem.id
    let name: String
    let symbolName: String
    let symbolColor: String
    let effectMultiplier: Double
    let activatedAt: Date
    let expiresAt: Date?        // nil = permanent (z.B. Diamant-Erde)
    let howToUse: String
    let targetPlantId: String?

    init(
        powerUpId: String,
        name: String,
        symbolName: String,
        symbolColor: String,
        effectMultiplier: Double,
        durationHours: Double?,
        howToUse: String,
        targetPlantId: String? = nil
    ) {
        self.id = UUID()
        self.powerUpId = powerUpId
        self.name = name
        self.symbolName = symbolName
        self.symbolColor = symbolColor
        self.effectMultiplier = effectMultiplier
        self.activatedAt = Date()
        if let hours = durationHours {
            self.expiresAt = Date().addingTimeInterval(hours * 3600)
        } else {
            self.expiresAt = nil
        }
        self.howToUse = howToUse
        self.targetPlantId = targetPlantId
    }

    var isExpired: Bool {
        guard let expires = expiresAt else { return false }
        return Date() > expires
    }

    var isActive: Bool { !isExpired }

    var verbleibendeZeit: String? {
        guard let expires = expiresAt else { return nil }
        let remaining = expires.timeIntervalSince(Date())
        guard remaining > 0 else { return nil }
        let hours = Int(remaining / 3600)
        let minutes = Int((remaining.truncatingRemainder(dividingBy: 3600)) / 60)
        if hours > 0 { return "\(hours)h \(minutes)m" }
        return "\(minutes)m"
    }
}
