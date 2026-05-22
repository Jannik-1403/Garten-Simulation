import Foundation

enum WeedSource: String, Codable {
    case decoration
    case dailySpin
    case plantDeath
}

struct WeedPatch: Codable, Identifiable, Equatable {
    let id: UUID
    let spawnDate: Date
    let removalCost: Int
    var habitsCompleted: Int
    let source: WeedSource

    init(
        id: UUID = UUID(),
        spawnDate: Date = Date(),
        removalCost: Int,
        habitsCompleted: Int = 0,
        source: WeedSource
    ) {
        self.id = id
        self.spawnDate = spawnDate
        self.removalCost = removalCost
        self.habitsCompleted = habitsCompleted
        self.source = source
    }

    var isCleared: Bool {
        habitsCompleted >= GameConstants.habitsRequiredPerWeed
    }
}

enum WeedMechanics {
    static func xpMultiplier(weedCount: Int) -> Double {
        guard weedCount > 0 else { return 1.0 }
        let raw = pow(GameConstants.weedXPMultiplierPerPatch, Double(weedCount))
        return max(GameConstants.weedMinimumXPMultiplier, raw)
    }

    static func coinPenalty(weedCount: Int) -> Int {
        guard weedCount > 0 else { return 0 }
        return GameConstants.weedCoinPenaltyPerPatch * weedCount
    }

    /// Nie ins Minus; maximal 50 % des aktuellen Guthabens pro Gießen.
    static func appliedCoinPenalty(currentCoins: Int, weedCount: Int) -> Int {
        let theoretical = coinPenalty(weedCount: weedCount)
        let wallet = max(0, currentCoins)
        let walletCap = Int(Double(wallet) * GameConstants.weedCoinPenaltyMaxWalletFraction)
        return min(theoretical, wallet, walletCap)
    }

    static func effectiveRewardPercent(weedCount: Int) -> Int {
        Int((xpMultiplier(weedCount: weedCount) * 100).rounded())
    }
}
