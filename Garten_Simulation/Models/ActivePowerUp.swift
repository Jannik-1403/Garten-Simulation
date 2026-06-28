import Foundation

struct ActivePowerUp: Identifiable, Codable {
    let id: UUID
    let powerUpId: String        // z.B. "powerup.duenger_blitz"
    let appliedAt: Date
    let durationHours: Double?    // nil if permanent
    let targetPlantId: String?   // nil wenn target == .garden
    
    var expiresAt: Date? {
        guard let duration = durationHours else { return nil }
        return appliedAt.addingTimeInterval(duration * 3600)
    }
    
    var isActive: Bool {
        guard let expiresAt = expiresAt else { return true }
        return Date() < expiresAt
    }
    
    var timeRemainingFormatted: String {
        guard let expiresAt = expiresAt else { return NSLocalizedString("powerup.status.permanent", comment: "") }
        let remaining = expiresAt.timeIntervalSinceNow
        guard remaining > 0 else { return NSLocalizedString("powerup.status.abgelaufen", comment: "") }
        let hours = Int(remaining / 3600)
        let minutes = Int((remaining.truncatingRemainder(dividingBy: 3600)) / 60)
        let hStr = NSLocalizedString("common.hour_short", comment: "")
        let mStr = NSLocalizedString("common.min_short", comment: "")
        if hours > 0 { return "\(hours)\(hStr) \(minutes)\(mStr)" }
        return "\(minutes)\(mStr)"
    }
}
