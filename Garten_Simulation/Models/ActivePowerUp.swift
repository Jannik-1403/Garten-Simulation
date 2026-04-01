import Foundation

struct ActivePowerUp: Identifiable, Codable {
    let id: UUID
    let powerUpId: String        // z.B. "powerup.duenger_blitz"
    let appliedAt: Date
    let durationHours: Double    // aus PowerUpItem.durationHours
    let targetPlantId: String?   // nil wenn target == .garden
    
    var expiresAt: Date {
        appliedAt.addingTimeInterval(durationHours * 3600)
    }
    
    var isActive: Bool {
        Date() < expiresAt
    }
    
    var timeRemainingFormatted: String {
        let remaining = expiresAt.timeIntervalSinceNow
        guard remaining > 0 else { return "Abgelaufen" }
        let hours = Int(remaining / 3600)
        let minutes = Int((remaining.truncatingRemainder(dividingBy: 3600)) / 60)
        if hours > 0 { return "\(hours)h \(minutes)m" }
        return "\(minutes)m"
    }
}
