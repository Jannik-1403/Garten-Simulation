import SwiftUI
import Combine

@MainActor
class ShopStore: ObservableObject {
    @Published var purchasedIDs: Set<String> = [] {
        didSet {
            savePurchasedIDs()
        }
    }

    // MARK: Closure-based coin delegation (linked to GardenStore at app startup)
    var coinsProvider: (() -> Int)?
    var coinsAbziehen: ((Int) -> Void)?
    var coinsHinzufuegen: ((Int, String) -> Void)?

    init() {
        loadPurchasedIDs()
    }

    private func savePurchasedIDs() {
        let array = Array(purchasedIDs)
        UserDefaults.standard.set(array, forKey: "shop_purchased_ids")
    }

    private func loadPurchasedIDs() {
        if let array = UserDefaults.standard.stringArray(forKey: "shop_purchased_ids") {
            purchasedIDs = Set(array)
        }
    }

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
            // Note: Deduction is handled by GardenStore via logPurchase to avoid double deduction
            purchasedIDs.insert(id)
        }
    }

    func sell(id: String, price: Int, title: String) {
        guard isPurchased(id) else { return }
        let returnAmount = Int(Double(price) * 0.5)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            purchasedIDs.remove(id)
            coinsHinzufuegen?(returnAmount, title)
        }
    }

    func removeFromPurchased(id: String) {
        _ = withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            purchasedIDs.remove(id)
        }
    }

    func reset() {
        purchasedIDs.removeAll()
        UserDefaults.standard.removeObject(forKey: "shop_purchased_ids")
    }
}
