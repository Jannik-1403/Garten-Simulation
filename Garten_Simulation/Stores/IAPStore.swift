import StoreKit
import Foundation
import Combine

// MARK: - IAPStore (StoreKit 2)

@MainActor
final class IAPStore: ObservableObject {

    // MARK: - Product IDs

    static let productIDs = [
        "com.gartenapp.coins.pack_small",
        "com.gartenapp.coins.pack_medium",
        "com.gartenapp.coins.pack_large",
        "com.gartenapp.cosmetics.glasses"
    ]

    static let coinAmounts: [String: Int] = [
        "com.gartenapp.coins.pack_small":  500,
        "com.gartenapp.coins.pack_medium": 1800,
        "com.gartenapp.coins.pack_large":  3500
    ]

    // MARK: - Published State

    @Published var products: [Product] = []
    @Published var isPurchasing = false
    @Published var purchaseError: String? = nil

    // MARK: - Private

    private var transactionListener: Task<Void, Never>?

    // MARK: - Init / Deinit

    init() {
        transactionListener = listenForTransactions()
        Task { await loadProducts() }
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Load Products

    func loadProducts() async {
        do {
            let loaded = try await Product.products(for: IAPStore.productIDs)
            products = loaded.sorted { $0.price < $1.price }
        } catch {
            purchaseError = NSLocalizedString("iap_error_load", comment: "")
        }
    }

    // MARK: - Purchase

    func purchase(_ product: Product, gardenStore: GardenStore, characterStore: CharacterStore? = nil) async {
        isPurchasing = true
        purchaseError = nil
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                if let coins = IAPStore.coinAmounts[product.id] {
                    gardenStore.addCoins(
                        coins,
                        reason: product.displayName
                    )
                } else if product.id == "com.gartenapp.cosmetics.glasses" {
                    characterStore?.unlockedGlasses = true
                }
                await transaction.finish()

            case .userCancelled:
                break

            case .pending:
                break

            @unknown default:
                break
            }
        } catch {
            purchaseError = NSLocalizedString("iap_error_purchase", comment: "")
        }
    }

    // MARK: - Verification

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    // MARK: - Transaction Listener

    private func listenForTransactions() -> Task<Void, Never> {
        Task(priority: .background) {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                }
            }
        }
    }

    // MARK: - Errors

    enum StoreError: Error {
        case failedVerification
    }
}
