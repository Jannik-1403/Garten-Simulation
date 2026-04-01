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
    @Published var gesamtGegossen: Int = 0
    @Published var tageAktiv: Int = 0
    
    var gekauftePflanzenAnzahl: Int { pflanzen.count }
    
    var diamantPflanzenAnzahl: Int {
        pflanzen.filter { $0.stufe == .diamant3 || $0.stufe == .diamant2 || $0.stufe == .diamant1 }.count
    }
    
    @Published var activePowerUps: [ActivePowerUp] = [] {
        didSet {
            saveActivePowerUps()
        }
    }
    
    // Inventory for non-plant items
    @Published var gekaufteItems: [ShopDetailPayload] = []
    @Published var placedDecorations: [DecorationItem] = [] {
        didSet {
            saveDecorations()
        }
    }
    
    // Level-Up Animation State
    @Published var showLevelUpAnimation: Bool = false
    @Published var newlyReachedGartenStufe: PflanzenStufe? = nil

    // Daily Spin States
    @Published var showDailySpinOverlay: Bool = false
    @Published var lastSpinTimestamp: Date?
    @Published var isWeedActive: Bool = false
    @Published var dailyQuestsCompletedSinceWeed: Int = 0

    var totalItemsCount: Int {
        pflanzen.count + gekaufteItems.count + placedDecorations.count
    }

    var gartenStufe: PflanzenStufe {
        PflanzenStufe.allCases.reversed().first {
            GameConstants.xpSchwelleGarten(fuer: $0) <= gesamtXP
        } ?? .bronze1
    }
    
    // Streak-Integration
    var onWatering: (() -> Void)?

    init() {
        loadStats()
        loadPlants()
        loadTransactions()
        loadInventory()
        loadActivePowerUps()
        loadDecorations()
        updateTageAktiv()
    }

    // MARK: Pflanze gießen
    func giessen(pflanze: HabitModel, powerUpStore: PowerUpStore) {
        guard !pflanze.istBewässert else { return }

        // 1. Garten-Stufe VOR dem Gießen merken
        let gartenStufeVorher = gartenStufe

        // 2. XP zur Pflanze addieren (Pflanzen-Progression bleibt unverändert)
        var xpGewonnen = Int(Double(pflanze.xpPerCompletion) * xpMultiplikator(for: pflanze.id))
        var coinsGewonnen = GameConstants.coinsProGiessen

        if isWeedActive {
            xpGewonnen = max(1, xpGewonnen - 5)
            coinsGewonnen = max(1, coinsGewonnen - 5)
        }

        pflanze.currentXP += xpGewonnen

        // 3. XP zum Garten-Gesamt addieren
        gesamtXP += xpGewonnen

        // 4. Garten-Stufe NACH dem Gießen prüfen
        let gartenStufeDanach = gartenStufe

        // 5. Nur triggern wenn GARTEN-Level gestiegen (nicht Pflanzen-Level)
        if gartenStufeDanach.rawValue > gartenStufeVorher.rawValue {
            newlyReachedGartenStufe = gartenStufeDanach
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                showLevelUpAnimation = true
            }
        }
        
        
        pflanze.istBewässert = true
        pflanze.letzteBewaesserung = Date()
        pflanze.streak += 1
        
        savePlants()

        // Globale Stats
        withAnimation(.spring(response: 0.4)) {
            coins    += coinsGewonnen
            // gesamtXP ist bereits oben addiert
            gesamtVerdient += coinsGewonnen
            
            // Add real transaction
            let lang = UserDefaults.standard.string(forKey: "appLanguage") ?? "de"
            let transaction = CoinTransaction(
                datum: Date(),
                beschreibung: AppStrings.get("profile.coins.tip.watering", language: lang),
                betrag: coinsGewonnen,
                icon: "drop.fill",
                farbeHex: "#2B75D8" // blauPrimary
            )
            transactions.insert(transaction, at: 0)
            saveTransactions()
            
            gesamtGegossen += 1
            saveStats()
        }

        // Gesamt-Streak: nur +1 wenn ALLE Pflanzen heute gegossen
        if pflanzen.allSatisfy({ $0.istBewässert }) {
            withAnimation {
                gesamtStreak += 1
            }
        }
        
        // Cure Condition für Unkraut
        if isWeedActive {
            dailyQuestsCompletedSinceWeed += 1
            if dailyQuestsCompletedSinceWeed >= 3 {
                withAnimation {
                    isWeedActive = false
                    dailyQuestsCompletedSinceWeed = 0
                }
            }
            saveStats() // Speichert den Status der Quests/Weed
        }
        
        // Notify StreakStore that we did a "habit" action today
        onWatering?()

        // Seltenheitsstufe prüfen
        pruefeSeltenheitUpgrade(pflanze: pflanze)
    }

    // MARK: Pflanze entfernen
    func pflanzEntfernen(pflanze: HabitModel) {
        withAnimation(.spring(response: 0.4)) {
            pflanzen.removeAll { $0.id == pflanze.id }
            savePlants()
        }
    }

    // MARK: Pflanze hinzufügen
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
            savePlants()
        }
    }

    // MARK: Item aus Shop hinzufügen (Wunder-Box etc.)
    func itemHinzufuegen(shopItem: ShopDetailPayload) {
        withAnimation(.spring(response: 0.4)) {
            if shopItem.itemType == .decoration {
                // If it's a decoration, we add it to placedDecorations
                // We need to find the base DecorationItem from GameDatabase
                if let base = GameDatabase.allDecorations.first(where: { $0.id == shopItem.id }) {
                    placedDecorations.append(base)
                }
            } else {
                gekaufteItems.append(shopItem)
                saveInventory()
            }
            logPurchase(shopItem: shopItem)
        }
    }

    func removeDecoration(_ item: DecorationItem) {
        withAnimation(.spring(response: 0.4)) {
            placedDecorations.removeAll { $0.id == item.id }
        }
    }

    // MARK: Item entfernen (Verkauf)
    func itemEntfernen(id: String) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.72)) {
            placedDecorations.removeAll(where: { $0.id == id })
            gekaufteItems.removeAll(where: { $0.id == id })
            saveInventory()
            saveDecorations()
        }
    }

    // MARK: Coins gutschreiben (Verdienst)
    func coinsGutschreiben(amount: Int, beschreibung: String) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            coins += amount
            gesamtVerdient += amount
            
            let transaction = CoinTransaction(
                datum: Date(),
                beschreibung: beschreibung,
                betrag: amount,
                icon: "dollarsign.circle.fill",
                farbeHex: "#F5D66B" // belohnungGoldHighlight
            )
            transactions.insert(transaction, at: 0)
            saveStats()
            saveTransactions()
        }
    }

    // MARK: Coins abziehen (Ausgabe)
    func coinsAbziehen(amount: Int, beschreibung: String) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            coins -= amount
            gesamtAusgegeben += amount
            
            let transaction = CoinTransaction(
                datum: Date(),
                beschreibung: beschreibung,
                betrag: -amount,
                icon: "cart.fill",
                farbeHex: "#FF4B4B" // red
            )
            transactions.insert(transaction, at: 0)
            saveStats()
            saveTransactions()
        }
    }

    // MARK: Item verbrauchen (Inventar)
    func itemVerbrauchen(shopItem: ShopDetailPayload) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.72)) {
            if let index = gekaufteItems.firstIndex(where: { $0.id == shopItem.id }) {
                gekaufteItems.remove(at: index)
                saveInventory()
            }
        }
    }

    private func logPurchase(shopItem: ShopDetailPayload) {
        // Deduct coins and log transaction
        if shopItem.price > 0 {
            let lang = UserDefaults.standard.string(forKey: "appLanguage") ?? "de"
            let desc = "\(AppStrings.get("shop.buy.success", language: lang)) \(shopItem.title)"
            coinsAbziehen(amount: shopItem.price, beschreibung: desc)
        }
    }

    // MARK: Streak-Check (täglich aufrufen, z.B. in .onReceive(timer))
    func taeglicherStreakCheck() {
        for pflanze in pflanzen {
            if pflanze.streakAbgelaufen && !hatZeitkapsel {
                pflanze.streak = 0
            }
        }
        // Mitternacht: istBewässert zurücksetzen
        let heute = Calendar.current.startOfDay(for: Date())
        for pflanze in pflanzen {
            if let letzte = pflanze.letzteBewaesserung,
               Calendar.current.startOfDay(for: letzte) < heute {
                if !hatRegenmacher {
                    pflanze.istBewässert = false
                }
            }
        }
        
        objectWillChange.send() // UI-Update erzwingen (z.B. für Debug-Button)
        savePlants()
        checkDailySpin()
    }

    // MARK: Daily Spin Check
    func checkDailySpin() {
        let heute = Calendar.current.startOfDay(for: Date())
        if let lastSpin = lastSpinTimestamp, Calendar.current.startOfDay(for: lastSpin) >= heute {
            // Already spun today
            return
        }
        // Need to spin
        withAnimation {
            showDailySpinOverlay = true
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

    // MARK: Power-Up Management
    func applyPowerUp(_ powerUp: PowerUpItem, targetPlantId: String? = nil) {
        guard let duration = powerUp.durationHours else { return }
        
        // Letzte abgelaufene direkt bereinigen
        activePowerUps.removeAll { !$0.isActive }
        
        let active = ActivePowerUp(
            id: UUID(),
            powerUpId: powerUp.id,
            appliedAt: Date(),
            durationHours: duration,
            targetPlantId: targetPlantId
        )
        
        withAnimation {
            activePowerUps.append(active)
        }
    }

    func activePowerUpsFor(plantId: String) -> [ActivePowerUp] {
        activePowerUps.filter { $0.isActive && ($0.targetPlantId == plantId || $0.targetPlantId == nil) }
    }

    /// NUR PowerUps die explizit auf DIESE Pflanze angewendet wurden
    func plantSpecificActivePowerUps(plantId: String) -> [ActivePowerUp] {
        activePowerUps.filter { $0.isActive && $0.targetPlantId == plantId }
    }

    func hasActivePowerUp(powerUpId: String, plantId: String? = nil) -> Bool {
        activePowerUps.contains { active in
            active.isActive &&
            active.powerUpId == powerUpId &&
            (plantId == nil || active.targetPlantId == plantId || active.targetPlantId == nil)
        }
    }

    var globalXPMultiplier: Double {
        activePowerUps
            .filter { $0.isActive && $0.targetPlantId == nil }
            .reduce(1.0) { result, active in
                let base = GameDatabase.allPowerUps.first { $0.id == active.powerUpId }
                return result * (base?.effectMultiplier ?? 1.0)
            }
    }
    /// Berechnet den XP-Multiplikator für eine bestimmte Pflanze
    func xpMultiplikator(for plantId: String) -> Double {
        var mult = 1.0
        
        // 1. Globale Power-Ups
        for aktiv in activePowerUps where aktiv.isActive && aktiv.targetPlantId == nil {
            if let base = GameDatabase.allPowerUps.first(where: { $0.id == aktiv.powerUpId }) {
                mult *= base.effectMultiplier
            }
        }
        
        // 2. Pflanzenspezifische Power-Ups
        for aktiv in activePowerUps where aktiv.isActive && aktiv.targetPlantId == plantId {
            if let base = GameDatabase.allPowerUps.first(where: { $0.id == aktiv.powerUpId }) {
                mult *= base.effectMultiplier
            }
        }
        
        return mult
    }

    var hatZeitkapsel: Bool {
        activePowerUps.contains { $0.isActive && $0.powerUpId == "powerup.zeitkapsel" }
    }

    var hatRegenmacher: Bool {
        activePowerUps.contains { $0.isActive && $0.powerUpId == "powerup.regenmacher" }
    }

    /// Ist Schädlingsschutz aktiv?
    var hatSchaedlingsschutz: Bool {
        activePowerUps.contains { $0.isActive && $0.powerUpId == "powerup.schaedlingsschutz" }
    }

    // MARK: Notiz speichern
    func notizSpeichern(pflanze: HabitModel, notiz: String) {
        pflanze.notiz = notiz
        savePlants()
    }

    // MARK: Timer setzen
    func timerSetzen(pflanze: HabitModel, datum: Date) {
        pflanze.timerDatum = datum
        savePlants()
        
        let lang = UserDefaults.standard.string(forKey: "appLanguage") ?? "de"
        let name = AppStrings.get(pflanze.name, language: lang)
        NotificationManager.shared.scheduleReminder(plantId: pflanze.id, plantName: name, date: datum)
    }

    // MARK: Timer entfernen
    func timerEntfernen(pflanze: HabitModel) {
        pflanze.timerDatum = nil
        savePlants()
        NotificationManager.shared.cancelReminder(plantId: pflanze.id)
    }

    private func saveActivePowerUps() {
        if let encoded = try? JSONEncoder().encode(activePowerUps) {
            UserDefaults.standard.set(encoded, forKey: "active_powerups_garden")
        }
    }

    private func loadActivePowerUps() {
        if let data = UserDefaults.standard.data(forKey: "active_powerups_garden"),
           let decoded = try? JSONDecoder().decode([ActivePowerUp].self, from: data) {
            activePowerUps = decoded
        }
    }

    private func saveDecorations() {
        if let encoded = try? JSONEncoder().encode(placedDecorations) {
            UserDefaults.standard.set(encoded, forKey: "garden_decorations")
        }
    }

    private func loadDecorations() {
        if let data = UserDefaults.standard.data(forKey: "garden_decorations"),
           let decoded = try? JSONDecoder().decode([DecorationItem].self, from: data) {
            placedDecorations = decoded
        }
    }

    private func saveStats() {
        UserDefaults.standard.set(coins, forKey: "stats_coins")
        UserDefaults.standard.set(gesamtXP, forKey: "stats_gesamt_xp")
        UserDefaults.standard.set(gesamtStreak, forKey: "stats_gesamt_streak")
        UserDefaults.standard.set(gesamtGegossen, forKey: "stats_gesamt_gegossen")
        UserDefaults.standard.set(tageAktiv, forKey: "stats_tage_aktiv")
        UserDefaults.standard.set(gesamtVerdient, forKey: "stats_gesamt_verdient")
        UserDefaults.standard.set(gesamtAusgegeben, forKey: "stats_gesamt_ausgegeben")
        UserDefaults.standard.set(lastSpinTimestamp, forKey: "last_spin_timestamp")
        UserDefaults.standard.set(isWeedActive, forKey: "is_weed_active")
        UserDefaults.standard.set(dailyQuestsCompletedSinceWeed, forKey: "daily_quests_completed_since_weed")
    }

    private func loadStats() {
        coins = UserDefaults.standard.object(forKey: "stats_coins") != nil ? UserDefaults.standard.integer(forKey: "stats_coins") : GameConstants.startCoins
        gesamtXP = UserDefaults.standard.integer(forKey: "stats_gesamt_xp")
        gesamtStreak = UserDefaults.standard.integer(forKey: "stats_gesamt_streak")
        gesamtGegossen = UserDefaults.standard.integer(forKey: "stats_gesamt_gegossen")
        tageAktiv = UserDefaults.standard.integer(forKey: "stats_tage_aktiv")
        gesamtVerdient = UserDefaults.standard.integer(forKey: "stats_gesamt_verdient")
        gesamtAusgegeben = UserDefaults.standard.integer(forKey: "stats_gesamt_ausgegeben")
        lastSpinTimestamp = UserDefaults.standard.object(forKey: "last_spin_timestamp") as? Date
        isWeedActive = UserDefaults.standard.bool(forKey: "is_weed_active")
        dailyQuestsCompletedSinceWeed = UserDefaults.standard.integer(forKey: "daily_quests_completed_since_weed")
    }

    private func savePlants() {
        if let encoded = try? JSONEncoder().encode(pflanzen) {
            UserDefaults.standard.set(encoded, forKey: "garden_plants")
        }
    }

    private func loadPlants() {
        if let data = UserDefaults.standard.data(forKey: "garden_plants"),
           let decoded = try? JSONDecoder().decode([HabitModel].self, from: data) {
            pflanzen = decoded
        } else {
            onboardingGratisPflanzen()
        }
    }

    private func saveTransactions() {
        if let encoded = try? JSONEncoder().encode(transactions) {
            UserDefaults.standard.set(encoded, forKey: "garden_transactions")
        }
    }

    private func loadTransactions() {
        if let data = UserDefaults.standard.data(forKey: "garden_transactions"),
           let decoded = try? JSONDecoder().decode([CoinTransaction].self, from: data) {
            transactions = decoded
        }
    }

    private func saveInventory() {
        if let encoded = try? JSONEncoder().encode(gekaufteItems) {
            UserDefaults.standard.set(encoded, forKey: "garden_inventory")
        }
    }

    private func loadInventory() {
        if let data = UserDefaults.standard.data(forKey: "garden_inventory"),
           let decoded = try? JSONDecoder().decode([ShopDetailPayload].self, from: data) {
            gekaufteItems = decoded
        }
    }

    private func updateTageAktiv() {
        let lastActiveKey = "last_active_date"
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastActive = UserDefaults.standard.object(forKey: lastActiveKey) as? Date {
            let lastActiveDay = Calendar.current.startOfDay(for: lastActive)
            if lastActiveDay < today {
                tageAktiv += 1
                UserDefaults.standard.set(today, forKey: lastActiveKey)
                saveStats()
            }
        } else {
            // Erstmaliger Start
            tageAktiv = 1
            UserDefaults.standard.set(today, forKey: lastActiveKey)
            saveStats()
        }
    }

    func resetAllData() {
        withAnimation {
            pflanzen.removeAll()
            coins = GameConstants.startCoins
            gesamtStreak = 0
            gesamtXP = 0
            transactions.removeAll()
            gesamtVerdient = 0
            gesamtAusgegeben = 0
            gesamtGegossen = 0
            tageAktiv = 1
            activePowerUps.removeAll()
            gekaufteItems.removeAll()
            placedDecorations.removeAll()
            
            lastSpinTimestamp = nil
            isWeedActive = false
            dailyQuestsCompletedSinceWeed = 0
            
            let keys = [
                "garden_plants", "stats_coins", "stats_gesamt_xp", "stats_gesamt_streak",
                "stats_gesamt_gegossen", "stats_tage_aktiv", "stats_gesamt_verdient",
                "stats_gesamt_ausgegeben", "coin_transactions", "garden_transactions",
                "garden_inventory", "active_powerups_garden", "garden_decorations",
                "last_active_date", "last_spin_timestamp", "is_weed_active",
                "daily_quests_completed_since_weed"
            ]
            keys.forEach { UserDefaults.standard.removeObject(forKey: $0) }
            
            // Set today as last active immediately after reset
            let today = Calendar.current.startOfDay(for: Date())
            UserDefaults.standard.set(today, forKey: "last_active_date")
            
            savePlants()
            saveStats()
            saveTransactions()
            saveInventory()
            saveActivePowerUps()
            saveDecorations()
        }
    }
}
