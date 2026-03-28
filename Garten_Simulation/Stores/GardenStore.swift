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
    
    // Inventory for non-plant items (Wunder-Box etc.)
    @Published var boughtItems: [ShopDetailPayload] = []
    
    // Streak-Integration
    var onWatering: (() -> Void)?

    // MARK: Pflanze gießen
    func giessen(pflanze: HabitModel) {
        guard !pflanze.istBewässert else { return }

        // XP + Coins gutschreiben
        pflanze.currentXP  += GameConstants.xpProGiessen
        pflanze.istBewässert = true
        pflanze.letzteBewaesserung = Date()
        pflanze.streak += 1

        // Globale Stats
        withAnimation(.spring(response: 0.4)) {
            coins    += GameConstants.coinsProGiessen
            gesamtXP += GameConstants.xpProGiessen
            gesamtVerdient += GameConstants.coinsProGiessen
            
            // Add real transaction
            let transaction = CoinTransaction(
                datum: Date(),
                beschreibung: NSLocalizedString("profile.coins.tip.watering", bundle: .main, comment: ""),
                betrag: GameConstants.coinsProGiessen,
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
            bildName: shopItem.icon
        )
        withAnimation(.spring(response: 0.4)) {
            pflanzen.append(neue)
            logPurchase(shopItem: shopItem)
        }
    }

    // MARK: Item aus Shop hinzufügen (Wunder-Box etc.)
    func itemHinzufuegen(shopItem: ShopDetailPayload) {
        withAnimation(.spring(response: 0.4)) {
            boughtItems.append(shopItem)
            logPurchase(shopItem: shopItem)
        }
    }

    private func logPurchase(shopItem: ShopDetailPayload) {
        // Deduct coins and log transaction (only if price > 0)
        if shopItem.price > 0 {
            coins -= shopItem.price
            gesamtAusgegeben += shopItem.price
            
            let transaction = CoinTransaction(
                datum: Date(),
                beschreibung: String(format: NSLocalizedString("shop.buy.success", bundle: .main, comment: ""), shopItem.title),
                betrag: -shopItem.price,
                icon: "cart.fill",
                farbe: .red
            )
            transactions.insert(transaction, at: 0)
        }
    }

    // MARK: Streak-Check (täglich aufrufen, z.B. in .onReceive(timer))
    func taeglicherStreakCheck() {
        for pflanze in pflanzen {
            if pflanze.streakAbgelaufen {
                pflanze.streak = 0
                pflanze.istBewässert = false
            }
        }
        // Mitternacht: istBewässert zurücksetzen
        let heute = Calendar.current.startOfDay(for: Date())
        for pflanze in pflanzen {
            if let letzte = pflanze.letzteBewaesserung,
               Calendar.current.startOfDay(for: letzte) < heute {
                pflanze.istBewässert = false
            }
        }
    }

    // MARK: Seltenheit-Upgrade
    private func pruefeSeltenheitUpgrade(pflanze: HabitModel) {
        // Seltenheit ist computed — wird automatisch neu berechnet
        // Hier kann man eine Notification / Overlay triggern
        // z.B.: NotificationCenter.default.post(name: .seltenheitUpgrade, object: pflanze)
    }

    // MARK: Onboarding — 2 Gratis-Pflanzen
    func onboardingGratisPflanzen() {
        guard pflanzen.isEmpty else { return }
        let gratis = [
            HabitModel(id: "gratis-1", name: NSLocalizedString("Erster Setzling", comment: ""), bildName: "bonsai_stufe1"),
            HabitModel(id: "gratis-2", name: NSLocalizedString("Kleiner Bonsai",  comment: ""), bildName: "bonsai_stufe2"),
        ]
        pflanzen = gratis
    }
}
