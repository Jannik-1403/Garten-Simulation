import StoreKit
import Foundation
import Combine

// MARK: - IAPStore (StoreKit 2)

@MainActor
final class IAPStore: ObservableObject {

    // MARK: - Product IDs

    nonisolated static let productIDs = [
        "com.jannik.grovy.coins.pack_small",
        "com.jannik.grovy.coins.pack_medium",
        "com.jannik.grovy.coins.pack_large",
        "com.jannik.grovy.cosmetics.glasses",
        "com.jannik.grovy.pro.monthly",
        "com.jannik.grovy.pro.yearly",
        "com.jannik.grovy.pro.lifetime"
    ]

    nonisolated static let coinAmounts: [String: Int] = [
        "com.jannik.grovy.coins.pack_small":  500,
        "com.jannik.grovy.coins.pack_medium": 1800,
        "com.jannik.grovy.coins.pack_large":  3500
    ]

    // MARK: - Published State

    @Published var products: [Product] = []
    @Published var isPurchasing = false
    @Published var purchaseError: String? = nil
    @Published var hasLoaded = false
    @Published var isProUser = false
    @Published var activeProSubscriptionID: String? = nil

    // MARK: - Private

    private var transactionListener: Task<Void, Never>?

    // MARK: - Init / Deinit

    init() {
        self.isProUser = UserDefaults.standard.bool(forKey: "isProUser_active")
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
                    print(" [IAPStore] ACHTUNG: Sende diese IDs an StoreKit: \(IAPStore.productIDs)")
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
                purchaseError = String(localized: "iap_error_config", defaultValue: "StoreKit Konfiguration nicht gefunden oder ungültig.")
            } else {
                print(" [IAPStore]  Produkte erfolgreich sortiert und gespeichert.")
            }
        } catch {
            print(" [IAPStore]  CATCH-BLOCK ERREICHT! Exakter Fehler: \(error)")
            purchaseError = String(localized: "iap_error_load", defaultValue: "Produkte konnten nicht geladen werden.")
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
                } else if product.id == "com.jannik.grovy.cosmetics.glasses" {
                    characterStore?.unlockedGlasses = true
                } else if product.id == "com.jannik.grovy.pro.lifetime" || product.id == "com.jannik.grovy.pro.monthly" || product.id == "com.jannik.grovy.pro.yearly" {
                    self.isProUser = true
                    self.activeProSubscriptionID = product.id
                    UserDefaults.standard.set(true, forKey: "isProUser_active")
                    UserDefaults.standard.set(product.id, forKey: "activeProSubscriptionID")
                    UserDefaults(suiteName: "group.com.jannik.grovy")?.set(true, forKey: "isProUser_active")
                    UserDefaults.standard.synchronize()
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
            purchaseError = String(localized: "iap_error_purchase", defaultValue: "Kauf fehlgeschlagen.")
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
            
            if transaction.productID == "com.jannik.grovy.cosmetics.glasses" {
                hasGlasses = true
            } else if transaction.productID == "com.jannik.grovy.pro.lifetime" || transaction.productID == "com.jannik.grovy.pro.monthly" || transaction.productID == "com.jannik.grovy.pro.yearly" {
                hasPro = true
                
                // Keep the highest tier if multiple are active
                if transaction.productID == "com.jannik.grovy.pro.lifetime" {
                    self.activeProSubscriptionID = transaction.productID
                } else if transaction.productID == "com.jannik.grovy.pro.yearly" && self.activeProSubscriptionID != "com.jannik.grovy.pro.lifetime" {
                    self.activeProSubscriptionID = transaction.productID
                } else if self.activeProSubscriptionID == nil {
                    self.activeProSubscriptionID = transaction.productID
                }
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
            UserDefaults.standard.set(self.isProUser, forKey: "isProUser_active")
            UserDefaults(suiteName: "group.com.jannik.grovy")?.set(self.isProUser, forKey: "isProUser_active")
            UserDefaults.standard.synchronize()
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
            purchaseError = String(localized: "iap_error_restore", defaultValue: "Käufe konnten nicht wiederhergestellt werden.")
        }
    }

    func revokePro() {
        self.isProUser = false
        self.activeProSubscriptionID = nil
        UserDefaults.standard.set(false, forKey: "isProUser_active")
        UserDefaults.standard.removeObject(forKey: "activeProSubscriptionID")
        UserDefaults(suiteName: "group.com.jannik.grovy")?.set(false, forKey: "isProUser_active")
        #if DEBUG
        UserDefaults.standard.set(false, forKey: "debug_isProUser")
        UserDefaults(suiteName: "group.com.jannik.grovy")?.set(false, forKey: "debug_isProUser")
        #endif
        UserDefaults.standard.synchronize()
    }

    // MARK: - Errors

    enum StoreError: Error {
        case failedVerification
    }
}
