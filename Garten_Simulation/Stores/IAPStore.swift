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
        "com.gartenapp.cosmetics.glasses",
        "com.gartenapp.pro.lifetime"
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
    @Published var hasLoaded = false
    @Published var isProUser = false

    // MARK: - Private

    private var transactionListener: Task<Void, Never>?

    // MARK: - Init / Deinit

    init() {
        #if DEBUG
        if UserDefaults.standard.bool(forKey: "debug_isProUser") {
            self.isProUser = true
        }
        #endif
        transactionListener = listenForTransactions()
        Task { await loadProducts() }
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Load Products

    func loadProducts() async {
        print(" [IAPStore] loadProducts() gestartet!")
        print(" [IAPStore] Suche nach folgenden Product IDs: \(IAPStore.productIDs)")
        
        do {
            // Use a 10-second timeout to prevent infinite loading in simulator
            let loaded = try await withThrowingTaskGroup(of: [Product].self) { group in
                group.addTask {
                    print(" [IAPStore] Starte Product.products(for:) Anfrage...")
                    let fetchedProducts = try await Product.products(for: IAPStore.productIDs)
                    print(" [IAPStore] Product.products(for:) erfolgreich zurückgekehrt!")
                    return fetchedProducts
                }
                group.addTask {
                    try await Task.sleep(nanoseconds: 10_000_000_000)
                    print(" [IAPStore]  10-Sekunden Timeout erreicht!")
                    throw StoreError.failedVerification // Timeout
                }
                
                let result = try await group.next()!
                group.cancelAll()
                return result
            }
            
            print(" [IAPStore] Anzahl gefundener Produkte: \(loaded.count)")
            for product in loaded {
                print(" [IAPStore] Gefundenes Produkt: \(product.id) - \(product.displayName) - \(product.displayPrice)")
            }
            
            products = loaded.sorted { $0.price < $1.price }
            hasLoaded = true
            
            if products.isEmpty {
                print(" [IAPStore]  FEHLER: 0 Produkte gefunden! StoreKit hat keine der angeforderten IDs in der Konfiguration gefunden.")
                purchaseError = "StoreKit configuration file not found or invalid."
            } else {
                print(" [IAPStore]  Produkte erfolgreich sortiert und gespeichert.")
            }
        } catch {
            print(" [IAPStore]  CATCH-BLOCK ERREICHT! Exakter Fehler: \(error)")
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
                } else if product.id == "com.gartenapp.pro.lifetime" {
                    self.isProUser = true
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

    // MARK: - Entitlements & Restore

    func syncEntitlements(characterStore: CharacterStore) async {
        var hasGlasses = false
        var hasPro = false
        
        // Loop through all current entitlements
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            
            if transaction.productID == "com.gartenapp.cosmetics.glasses" {
                hasGlasses = true
            } else if transaction.productID == "com.gartenapp.pro.lifetime" {
                hasPro = true
            }
        }
        
        // If the user refunded the glasses, this will be false and revoke access
        if characterStore.unlockedGlasses != hasGlasses {
            characterStore.unlockedGlasses = hasGlasses
        }
        
        DispatchQueue.main.async {
            #if DEBUG
            if UserDefaults.standard.bool(forKey: "debug_isProUser") {
                self.isProUser = true
            } else {
                self.isProUser = hasPro
            }
            #else
            self.isProUser = hasPro
            #endif
        }
    }

    func restorePurchases(characterStore: CharacterStore) async {
        isPurchasing = true
        purchaseError = nil
        defer { isPurchasing = false }
        
        do {
            // Force StoreKit to sync with App Store
            try await AppStore.sync()
            await syncEntitlements(characterStore: characterStore)
        } catch {
            purchaseError = NSLocalizedString("iap_error_restore", comment: "")
        }
    }

    // MARK: - Errors

    enum StoreError: Error {
        case failedVerification
    }
}
