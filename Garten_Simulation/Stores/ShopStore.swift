import SwiftUI
import Combine

@MainActor
class ShopStore: ObservableObject {
    @Published var purchasedIDs: Set<String> = []

    // MARK: Closure-based coin delegation (linked to GardenStore at app startup)
    var coinsProvider: (() -> Int)?
    var coinsAbziehen: ((Int) -> Void)?

    // Fallback read-only: used in UI bindings that still read `shopStore.coins`
    var coins: Int {
        coinsProvider?() ?? 0
    }

    func canAfford(_ price: Int) -> Bool {
        coins >= price
    }

    func isPurchased(_ id: String) -> Bool {
        purchasedIDs.contains(id)
    }

    func buy(id: String, price: Int) {
        guard canAfford(price), !isPurchased(id) else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            coinsAbziehen?(price)
            purchasedIDs.insert(id)
        }
    }
}
