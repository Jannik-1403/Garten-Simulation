import SwiftUI

@MainActor
class ShopStore: ObservableObject {
    @Published var coins: Int = 1500
    @Published var purchasedIDs: Set<String> = []

    func canAfford(_ price: Int) -> Bool {
        coins >= price
    }

    func isPurchased(_ id: String) -> Bool {
        purchasedIDs.contains(id)
    }

    func buy(id: String, price: Int) {
        guard canAfford(price), !isPurchased(id) else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            coins -= price
            purchasedIDs.insert(id)
        }
    }
}
