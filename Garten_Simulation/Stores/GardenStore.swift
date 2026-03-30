import SwiftUI
import SwiftData
import Combine

@MainActor
class GardenStore: ObservableObject {
    @Published var pflanzen: [HabitModel] = []
    @Published var coins: Int = GameConstants.startCoins
    @Published var gesamtStreak: Int = 0
    @Published var gesamtXP: Int = 0
    @Published var transactions: [CoinTransaction] = []
    
    // Stats for Achievements
    @Published var gesamtVerdient: Int = 0
    @Published var gesamtAusgegeben: Int = 0
    
    // Inventory for non-plant items
    @Published var gekaufteItems: [ShopDetailPayload] = []
    @Published var aktiverMuell: [ShopDetailPayload] = []
    
    // Streak-Integration
    var onWatering: (() -> Void)?

    // MARK: Pflanze gießen
    func giessen(pflanze: HabitModel, powerUpStore: PowerUpStore) {
        guard !pflanze.istBewässert else { return }

        // XP + Coins gutschreiben
        let xpGewonnen = Int(Double(pflanze.xpPerCompletion) * powerUpStore.xpMultiplikator(for: pflanze.id))
        let coinsGewonnen = GameConstants.coinsProGiessen

        pflanze.currentXP  += xpGewonnen
        pflanze.istBewässert = true
        pflanze.letzteBewaesserung = Date()
        pflanze.streak += 1

        // Globale Stats
        withAnimation(.spring(response: 0.4)) {
            coins    += coinsGewonnen
            gesamtXP += xpGewonnen
            gesamtVerdient += coinsGewonnen
            
            // Add real transaction
            let lang = UserDefaults.standard.string(forKey: "appLanguage") ?? "de"
            let transaction = CoinTransaction(
                datum: Date(),
                beschreibung: AppStrings.get("profile.coins.tip.watering", language: lang),
                betrag: coinsGewonnen,
                icon: "drop.fill",
                farbe: .blauPrimary
            )
            transactions.insert(transaction, at: 0)
        }

        // Gesamt-Streak: nur +1 wenn ALLE Pflanzen heute gegossen
        if pflanzen.allSatisfy({ $0.istBewässert }) {
            withAnimation {
                gesamtStreak += 1
            }
        }
        
        // Notify StreakStore that we did a "habit" action today
        onWatering?()

        // Seltenheitsstufe prüfen
        pruefeSeltenheitUpgrade(pflanze: pflanze)
    }

    // MARK: Pflanze aus Shop hinzufügen
    func pflanzHinzufuegen(shopItem: ShopDetailPayload) {
        let neue = HabitModel(
            id: shopItem.id,
            name: shopItem.title,
            symbolName: shopItem.icon,
            symbolColor: shopItem.symbolColor,
            habitCategory: shopItem.habitCategory ?? .lifestyle,
            symbolism: shopItem.symbolism ?? ""
        )
        withAnimation(.spring(response: 0.4)) {
            pflanzen.append(neue)
            logPurchase(shopItem: shopItem)
        }
    }

    // MARK: Item aus Shop hinzufügen (Wunder-Box etc.)
    func itemHinzufuegen(shopItem: ShopDetailPayload) {
        withAnimation(.spring(response: 0.4)) {
            if shopItem.itemType == .trash {
                aktiverMuell.append(shopItem)
            } else {
                gekaufteItems.append(shopItem)
            }
            logPurchase(shopItem: shopItem)
        }
    }

    // MARK: Item verbrauchen (Inventar)
    func itemVerbrauchen(shopItem: ShopDetailPayload) {
        withAnimation(.spring(response: 0.4)) {
            if let index = gekaufteItems.firstIndex(where: { $0.id == shopItem.id }) {
                gekaufteItems.remove(at: index)
            }
        }
    }

    private func logPurchase(shopItem: ShopDetailPayload) {
        // Deduct coins and log transaction
        if shopItem.price > 0 {
            coins -= shopItem.price
            gesamtAusgegeben += shopItem.price
            
            let lang2 = UserDefaults.standard.string(forKey: "appLanguage") ?? "de"
            let transaction = CoinTransaction(
                datum: Date(),
                beschreibung: "\(AppStrings.get("shop.buy.success", language: lang2)) \(shopItem.title)",
                betrag: -shopItem.price,
                icon: "cart.fill",
                farbe: .red
            )
            transactions.insert(transaction, at: 0)
        }
    }

    // MARK: Streak-Check (täglich aufrufen, z.B. in .onReceive(timer))
    func taeglicherStreakCheck(powerUpStore: PowerUpStore) {
        for pflanze in pflanzen {
            if pflanze.streakAbgelaufen && !powerUpStore.hatZeitkapsel {
                pflanze.streak = 0
            }
        }
        // Mitternacht: istBewässert zurücksetzen
        let heute = Calendar.current.startOfDay(for: Date())
        for pflanze in pflanzen {
            if let letzte = pflanze.letzteBewaesserung,
               Calendar.current.startOfDay(for: letzte) < heute {
                if !powerUpStore.hatRegenmacher {
                    pflanze.istBewässert = false
                }
            }
        }
    }

    // MARK: Seltenheit-Upgrade
    private func pruefeSeltenheitUpgrade(pflanze: HabitModel) {
        // Seltenheit ist computed
    }

    // MARK: Onboarding — 2 Gratis-Pflanzen
    func onboardingGratisPflanzen() {
        guard pflanzen.isEmpty else { return }
        let gratis = [
            HabitModel(id: "gratis-1", name: "plant.bambus.name",    symbolName: "leaf.fill",     symbolColor: "green", habitCategory: .fitness),
            HabitModel(id: "gratis-2", name: "plant.aloe_vera.name", symbolName: "iphone.slash", symbolColor: "mint",  habitCategory: .lifestyle),
        ]
        pflanzen = gratis
    }
}
