import SwiftUI
import Combine

@MainActor
class GardenProgressStore: ObservableObject {
    @Published var currentXP: Int = 450
    @Published var currentRarity: SeltenheitsStufe = .bronze
    @Published var showLevelUp: Bool = false
    
    private let thresholds: [SeltenheitsStufe: Int] = [
        .bronze: 500,
        .silber: 1200,
        .gold: 3000,
        .diamant: 10000 // Max level
    ]
    
    var xpThreshold: Int {
        thresholds[currentRarity] ?? 500
    }
    
    var progress: Double {
        Double(currentXP) / Double(xpThreshold)
    }
    
    func addXP(_ amount: Int) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            currentXP += amount
            checkLevelUp()
        }
    }
    
    private func checkLevelUp() {
        if currentXP >= xpThreshold {
            // Level Up logic
            if let next = nextRarity() {
                currentXP = 0 // Reset for next level
                currentRarity = next
                showLevelUp = true // Trigger the popup
            } else {
                // Max level reached
                currentXP = xpThreshold
            }
        }
    }
    
    private func nextRarity() -> SeltenheitsStufe? {
        switch currentRarity {
        case .bronze: return .silber
        case .silber: return .gold
        case .gold: return .diamant
        case .diamant: return nil
        }
    }
}
