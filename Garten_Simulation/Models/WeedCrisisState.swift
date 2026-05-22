import Foundation

/// Verfolgt eine Unkraut-Krise für den Comeback-Bonus (Anti-Exploit).
struct WeedCrisisState: Codable, Equatable {
    var startedAt: Date?
    var peakWeedCount: Int = 0
    var weedsClearedByHabits: Int = 0
    var weedsClearedByCoins: Int = 0
    var decorationSpawnsDuringCrisis: Int = 0
    var lastComebackGrantedAt: Date?
}

enum ComebackBonusLogic {
    /// Prüft, ob nach einer abgeschlossenen Krise der Wachstumsschub verdient ist.
    static func isEligible(crisis: WeedCrisisState, now: Date = Date()) -> Bool {
        guard crisis.peakWeedCount >= GameConstants.comebackMinimumPeakWeeds else { return false }
        guard crisis.weedsClearedByHabits >= GameConstants.comebackMinimumHabitClears else { return false }
        guard let startedAt = crisis.startedAt else { return false }

        let crisisHours = now.timeIntervalSince(startedAt) / 3600
        guard crisisHours >= GameConstants.comebackMinimumCrisisHours else { return false }

        if let lastGranted = crisis.lastComebackGrantedAt {
            let days = Calendar.current.dateComponents([.day], from: lastGranted, to: now).day ?? 0
            guard days >= GameConstants.comebackCooldownDays else { return false }
        }

        // Rein-Deko-Krisen, die zu schnell abgearbeitet werden: kein Boost-Farming
        let totalCleared = crisis.weedsClearedByHabits + crisis.weedsClearedByCoins
        let decorationOnlyCrisis = crisis.decorationSpawnsDuringCrisis >= crisis.peakWeedCount
            && totalCleared > 0
        if decorationOnlyCrisis && crisisHours < GameConstants.comebackDecorationOnlyMinHours {
            return false
        }

        return true
    }
}
