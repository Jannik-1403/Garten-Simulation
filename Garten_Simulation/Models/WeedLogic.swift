import Foundation

// MARK: - SpinResult
enum SpinResult: Equatable {
    case safe           // Grünes Feld – kein Unkraut
    case weed           // Rotes Feld  – Unkraut aktiv
    case coins(Int)     // Goldenes Feld – Münzen-Gewinn
}

// MARK: - DailySpinLogic
struct DailySpinLogic {
    static var baseWeedProbability: Double = 0.0
    static var weedProbabilityPerItem: Double = 0.05
    /// Max weed prob is 90 % because gold always occupies 5 %
    static var maxWeedProbability: Double = 0.90
    static let goldProbability: Double = 0.05
    static let goldCoins: Int = 200

    static func currentWeedProbability(ownedItemsCount: Int) -> Double {
        let p = baseWeedProbability + Double(ownedItemsCount) * weedProbabilityPerItem
        return min(p, maxWeedProbability)
    }

    /// Returns one of three outcomes.
    /// Zones: [0 .. weedProb) = weed | [weedProb .. 0.95) = safe | [0.95 .. 1) = coins
    static func spin(ownedItemsCount: Int) -> SpinResult {
        let weedProb = currentWeedProbability(ownedItemsCount: ownedItemsCount)
        let safeEnd  = 1.0 - goldProbability   // 0.95
        let roll = Double.random(in: 0.0..<1.0)
        if roll < weedProb  { return .weed }
        if roll < safeEnd   { return .safe }
        return .coins(goldCoins)
    }
}
