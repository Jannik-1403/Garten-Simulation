import Foundation

// MARK: - SpinResult
enum SpinResult: Equatable {
    case klein      // +10 Gems
    case mittel     // +25 Gems
    case gross      // +50 Gems
    case xpBoost    // +100 XP
    case jackpot    // +150 Gems
}

// MARK: - DailySpinLogic
struct DailySpinLogic {
    /// Returns a reward based on probabilities:
    /// Klein: 35%, Mittel: 30%, Gross: 20%, XP-Boost: 10%, Jackpot: 5%
    static func spin(ownedItemsCount: Int) -> SpinResult {
        let roll = Double.random(in: 0.0..<1.0)
        
        if roll < 0.35 {
            return .klein
        } else if roll < 0.65 { // 0.35 + 0.30
            return .mittel
        } else if roll < 0.85 { // 0.65 + 0.20
            return .gross
        } else if roll < 0.95 { // 0.85 + 0.10
            return .xpBoost
        } else {
            return .jackpot
        }
    }
    
    // Legacy support for WheelOfFortuneView UI logic if needed
    static func currentWeedProbability(ownedItemsCount: Int) -> Double { 0 }
}
