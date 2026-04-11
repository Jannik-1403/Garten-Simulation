import SwiftUI
import SwiftData
import Combine

@MainActor
class GardenStore: ObservableObject {
    @Published var pflanzen: [HabitModel] = []
    @Published var coins: Int = GameConstants.startCoins
    @Published var gesamtXP: Int = 0
    @Published var gesamtGekaufteItemsCount: Int = 0
    @Published var transactions: [CoinTransaction] = []
    @Published var leben: Int = 5
    @Published var gestorbenePflanzenLog: [String] = []
    @Published var zeigeGameOverOverlay: Bool = false
    @Published var plantToRescue: HabitModel? = nil
    @Published var selectedTab: Int = 0
    @Published var gluecksradDrehungen: Int = 0 {
        didSet { saveStats() }
    }
    @Published var seeds: Int = 0 {
        didSet { saveStats() }
    }
    
    // Level-Up System (50 Levels)
    @Published var zeigeGartenLevelUpOverlay: Bool = false
    @Published var neuerGartenLevel: Int = 1
    @Published var neueFreischaltungen: [GartenLevelFreischaltung] = []
    
    // Garten-Pass
    @Published var abgeholtePassLevel: Set<Int> = [] {
        didSet { speichereAbgeholte() }
    }
    
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
    
    // Daily Spin States
    @Published var showDailySpinOverlay: Bool = false
    @Published var lastSpinTimestamp: Date? {
        didSet { saveStats() }
    }
    @Published var isWeedActive: Bool = false {
        didSet { saveStats() }
    }
    @Published var dailyQuestsCompletedSinceWeed: Int = 0 {
        didSet { saveStats() }
    }
    @Published var aktivesWetter: WetterEvent = .normal
    @Published var pendingImportURL: URL? = nil
    
    var titelStore: TitelStore? = nil


    var totalItemsCount: Int {
        pflanzen.count + gekaufteItems.count + placedDecorations.count
    }

    var gekauftePowerUps: [ShopDetailPayload] {
        gekaufteItems.filter { $0.itemType == .powerUp }
    }

    var gartenStufe: Int {
        GartenLevel.level(fuerXP: gesamtXP)
    }

    var gesamtMlGegossen: Double {
        pflanzen.reduce(0) { $0 + $1.totalMlGegossen }
    }

    var gesamtLiterFormatiert: String {
        let liter = gesamtMlGegossen / 1000
        let lang = UserDefaults.standard.string(forKey: "appLanguage") ?? "de"
        
        if liter < 1 {
            let unit = AppStrings.get("common.ml", language: lang)
            return String(format: "%.0f %@", gesamtMlGegossen, unit)
        } else {
            let unit = AppStrings.get("common.liter", language: lang)
            return String(format: "%.1f %@", liter, unit)
        }
    }

    var pflanzenNachMlSortiert: [HabitModel] {
        pflanzen.sorted { $0.totalMlGegossen > $1.totalMlGegossen }
    }
    
    // Streak-Integration
    var onWatering: (() -> Void)?
    var onItemClaimed: ((String) -> Void)?

    init() {
        loadStats()
        loadPlants()
        loadTransactions()
        loadInventory()
        loadActivePowerUps()
        loadDecorations()
        ladeAbgeholte()
        updateTageAktiv()
        pruefePflanzenStatus()
    }

    func debugLevelUp() {
        let vor = gartenStufe
        let nextLevel = vor + 1
        guard nextLevel <= 50 else { return }
        
        // Berechne XP die benötigt werden um das NÄCHSTE Level zu ERREICHEN
        let xpFuerNaechstes = GameConstants.xpFuerLevel(nextLevel)
        gesamtXP = xpFuerNaechstes
        
        let nach = gartenStufe
        if nach > vor {
            // Belohnungen (Spins)
            let freigeschaltet = GartenLevel.freischaltungenFuer(level: nach)
            for f in freigeschaltet {
                if case .gluecksradDrehung(let anzahl) = f.typ {
                    gluecksradDrehungen = min(gluecksradDrehungen + anzahl, GameConstants.maxGluecksradDrehungen)
                }
            }

            neuerGartenLevel = nach
            neueFreischaltungen = freigeschaltet
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                zeigeGartenLevelUpOverlay = true
            }
        }
        saveStats()
    }
    
    func xpHinzufuegen(amount: Int) {
        let vor = gartenStufe
        gesamtXP += amount
        let nach = gartenStufe
        
        if nach > vor {
            // Level-Up Belohnungen verarbeiten (z.B. Spins)
            let freigeschaltet = GartenLevel.freischaltungenFuer(level: nach)
            for f in freigeschaltet {
                if case .gluecksradDrehung(let anzahl) = f.typ {
                    gluecksradDrehungen = min(gluecksradDrehungen + anzahl, GameConstants.maxGluecksradDrehungen)
                }
            }

            neuerGartenLevel = nach
            neueFreischaltungen = freigeschaltet
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                zeigeGartenLevelUpOverlay = true
            }
        }
        saveStats()
    }
    
    // MARK: Pflanze gießen
    func giessen(pflanze: HabitModel, powerUpStore: PowerUpStore) {
        guard !pflanze.istBewässert else { return }

        // 2. XP & Coins berechnen (Multiplikative Logik)
        let xpMult = xpMultiplikator(for: pflanze)
        let coinMult = coinMultiplikator(for: pflanze)

        let xpGewonnen = Int(Double(pflanze.xpPerCompletion) * xpMult)
        var coinsGewonnen = Int(Double(GameConstants.coinsProGiessen) * coinMult)

        if isWeedActive {
            coinsGewonnen = max(1, coinsGewonnen - 5)
        }

        pflanze.currentXP += xpGewonnen

        // XP Verlauf für die Pflanze speichern
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let key = formatter.string(from: Date())
        pflanze.xpHistory[key] = (pflanze.xpHistory[key] ?? 0) + xpGewonnen
        
        pflanze.totalCoinsEarned += coinsGewonnen

        // 3. XP zum Garten-Gesamt addieren
        xpHinzufuegen(amount: xpGewonnen)
        
        
        pflanze.istBewässert = true
        pflanze.letzteBewaesserung = Date()
        pflanze.streak += 1
        pflanze.missedCycles = 0 // Reset Gesundheit
        pflanze.lastNotifiedCycle = 0 // Reset Herz-Abzug-Trigger
        pflanze.totalMlGegossen += GameConstants.mlProGiessen
        
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
                icon: "Drop water",
                farbeHex: "#00919E" // coinBlue
            )
            transactions.insert(transaction, at: 0)
            saveTransactions()
            
            gesamtGegossen += 1
            saveStats()
        }


        // Notify StreakStore only if ALL plants are watered today
        if pflanzen.allSatisfy({ $0.istBewässert }) {
            onWatering?()
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
        

        // Seltenheitsstufe prüfen
        pruefeSeltenheitUpgrade(pflanze: pflanze)

        // Neue Benachrichtigungs-Logik
        NotificationManager.shared.rescheduleAfterWatering(habit: pflanze, allHabits: pflanzen)
    }

    // MARK: Pflanze entfernen
    func pflanzEntfernen(pflanze: HabitModel) {
        withAnimation(.spring(response: 0.4)) {
            pflanzen.removeAll { $0.id == pflanze.id }
            savePlants()
        }
    }

    // MARK: Pflanze wiederbeleben
    func revive(pflanze: HabitModel) {
        guard coins >= GameConstants.wiederbelebungsKosten else { return }
        
        let lang = UserDefaults.standard.string(forKey: "appLanguage") ?? "de"
        coinsAbziehen(amount: GameConstants.wiederbelebungsKosten, beschreibung: AppStrings.get("transaction.revive", language: lang))
        
        objectWillChange.send()
        withAnimation {
            pflanze.wiederbelebtAm = Date()
            pflanze.letzteBewaesserung = Date() // Reset the watering timer
            pflanze.missedCycles = 0
            pflanze.lastNotifiedCycle = 0
            savePlants()
        }
    }

    // MARK: Pflanze mit Wunder-Wasser retten
    func reviveWithWonderWater(pflanze: HabitModel) {
        if let index = gekaufteItems.firstIndex(where: { $0.id == "powerup.wunder_wasser" }) {
            gekaufteItems.remove(at: index)
            saveInventory()
            
            objectWillChange.send()
            withAnimation {
                pflanze.wiederbelebtAm = Date()
                pflanze.letzteBewaesserung = Date()
                pflanze.missedCycles = 0
                pflanze.lastNotifiedCycle = 0
                savePlants()
            }
            if plantToRescue?.id == pflanze.id {
                plantToRescue = nil
                pruefePflanzenStatus()
            }
        }
    }

    // MARK: Rettung ablehnen
    func declineRescue(pflanze: HabitModel) {
        if plantToRescue?.id == pflanze.id {
            plantToRescue = nil
            
            // Führe den Tod aus, da Rettung abgelehnt
            pflanze.missedCycles = 2
            if 2 > pflanze.lastNotifiedCycle {
                pflanzeGestorben(pflanze)
                pflanze.lastNotifiedCycle = 2
            }
            savePlants()
            
            // Setze den Gesundheits-Check für restliche Pflanzen fort
            pruefePflanzenStatus()
        }
    }

    // MARK: Pflanze hinzufügen
    func pflanzHinzufuegen(shopItem: ShopDetailPayload, isFree: Bool = false) {
        // Sicherstellen, dass wir den echten Pflanzennamen aus der DB nehmen (nicht den Payload-Titel, der evtl. die Gewohnheit ist)
        let dbPlant = GameDatabase.allPlants.first(where: { $0.id == shopItem.id })
        let dbName = dbPlant?.name ?? shopItem.title
        
        let neue = HabitModel(
            id: UUID().uuidString,
            name: dbName,
            symbolName: shopItem.icon,
            symbolColor: shopItem.colorHex,
            habitCategories: shopItem.habitCategories ?? [.lifestyle],
            symbolism: shopItem.description,
            habitName: shopItem.habitName ?? "",
            maxLevel: dbPlant?.maxLevel ?? 10,
            xpPerCompletion: dbPlant?.xpPerCompletion ?? 100,
            waterNeedPerDay: dbPlant?.waterNeedPerDay ?? 1,
            decayDays: dbPlant?.decayDays ?? 2,
            plantID: shopItem.id
        )
        withAnimation(.spring(response: 0.4)) {
            pflanzen.append(neue)
            logPurchase(shopItem: shopItem, isFree: isFree)
            savePlants()
            NotificationManager.shared.scheduleAll(for: pflanzen)
        }
    }

    // MARK: - Leben System
    func pflanzeGestorben(_ habit: HabitModel) {
        withAnimation(.spring) {
            leben = max(0, leben - 1)
            gestorbenePflanzenLog.append(habit.name)
        }
        
        if leben <= 0 {
            gartenGameOver()
        }
    }

    func gartenGameOver() {
        // Nur Pflanzen löschen (Coins/Items bleiben erhalten)
        withAnimation(.easeInOut(duration: 1.0)) {
            pflanzen.removeAll()
            savePlants()
            
            // Leben zurücksetzen
            leben = 5
            saveStats()
            
            // Overlay zeigen
            zeigeGameOverOverlay = true
        }
    }

    // MARK: - Item aus Shop hinzufügen (Wunder-Box etc.)
    func itemHinzufuegen(shopItem: ShopDetailPayload, isFree: Bool = false) {
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
            logPurchase(shopItem: shopItem, isFree: isFree)
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

    // MARK: Coins hinzufügen (IAP)
    /// Adds coins purchased via In-App Purchase and logs the transaction.
    func addCoins(_ amount: Int, reason: String) {
        coinsGutschreiben(amount: amount, beschreibung: "🛒 \(reason)")
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
                farbeHex: "#00919E" // coinBlue
            )
            transactions.insert(transaction, at: 0)
            saveStats()
            saveTransactions()
        }
    }

    // MARK: Coins abziehen (Ausgabe)
    func coinsAbziehen(amount: Int, beschreibung: String) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            coins = max(0, coins - amount)
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

    private func logPurchase(shopItem: ShopDetailPayload, isFree: Bool = false) {
        if !isFree && shopItem.price > 0 {
            let lang = UserDefaults.standard.string(forKey: "appLanguage") ?? "de"
            let desc = "\(AppStrings.get("shop.buy.success", language: lang)) \(shopItem.title)"
            coinsAbziehen(amount: shopItem.price, beschreibung: desc)
        }
        // Count all shop exchanges
        gesamtGekaufteItemsCount += 1
        saveStats()
    }

    func gluecksradDrehungVerbrauchen() -> Bool {
        guard gluecksradDrehungen > 0 else { return false }
        gluecksradDrehungen -= 1
        saveStats()
        return true
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
                pflanze.istBewässert = false
            }
        }
        
        objectWillChange.send() // UI-Update erzwingen
        savePlants()
    }

    var isDailySpinAvailable: Bool {
        let heute = Calendar.current.startOfDay(for: Date())
        if let lastSpin = lastSpinTimestamp {
            return Calendar.current.startOfDay(for: lastSpin) < heute
        }
        return true
    }

    // MARK: Daily Spin Check
    func checkDailySpin() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            self.showDailySpinOverlay = true
        }
    }

    // MARK: Seltenheit-Upgrade
    private func pruefeSeltenheitUpgrade(pflanze: HabitModel) {
        if pflanze.seltenheit == .diamant {
            titelStore?.pruefUndSchalteFreiSofern(plantID: pflanze.plantID)
        }
    }

    // MARK: Onboarding — 2 Gratis-Pflanzen
    func pflanzeHinzufuegenAusOnboarding(plantID: String, reminderTime: Date? = nil) {
        guard let dbPlant = GameDatabase.allPlants.first(where: { $0.id == plantID }) else { return }
        
        let neue = HabitModel(
            id: UUID().uuidString,
            name: dbPlant.name,
            symbolName: dbPlant.symbolName,
            symbolColor: dbPlant.symbolColor,
            habitCategories: dbPlant.habitCategories,
            symbolism: dbPlant.symbolism,
            habitName: dbPlant.habitName,
            maxLevel: dbPlant.maxLevel,
            xpPerCompletion: dbPlant.xpPerCompletion,
            waterNeedPerDay: dbPlant.waterNeedPerDay,
            decayDays: dbPlant.decayDays,
            plantID: dbPlant.id,
            reminderTime: reminderTime
        )
        
        withAnimation(.spring(response: 0.4)) {
            pflanzen.append(neue)
            savePlants()
            NotificationManager.shared.scheduleAll(for: pflanzen)
        }
    }

    func onboardingSetup() {
        // Initial setup for coins etc. - only if starting fresh
        if self.coins == 0 {
            self.coins = GameConstants.startCoins
            saveStats()
        }
    }

    // MARK: Power-Up Management
    func applyPowerUp(_ powerUp: PowerUpItem, targetPlantId: String? = nil) {
        // Sofortige Ausführung für Tier-Freund
        if powerUp.id == "powerup.tier_freund" {
            let targets = pflanzen.shuffled().prefix(3)
            for p in targets {
                p.currentXP += 50
            }
            FeedbackManager.shared.playSuccess()
            savePlants()
            return // nicht als anhaltendes Power-Up speichern
        }
        
        // Letzte abgelaufene direkt bereinigen
        activePowerUps.removeAll { !$0.isActive }
        
        let active = ActivePowerUp(
            id: UUID(),
            powerUpId: powerUp.id,
            appliedAt: Date(),
            durationHours: powerUp.durationHours,
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
    func xpMultiplikator(for pflanze: HabitModel) -> Double {
        var mult = 1.0
        
        // 1. Wetter
        mult *= aktivesWetter.gemMultiplikator
        
        // 2. Penalty (Revive)
        if let start = pflanze.wiederbelebtAm {
            let tage = Calendar.current.dateComponents([.day], from: start, to: Date()).day ?? 0
            if tage < pflanze.strafTage {
                mult *= 0.5
            }
        }

        // 3. Globale Power-Ups
        for aktiv in activePowerUps where aktiv.isActive && aktiv.targetPlantId == nil {
            if let base = GameDatabase.allPowerUps.first(where: { $0.id == aktiv.powerUpId }) {
                mult *= base.effectMultiplier
            }
        }
        
        // 4. Pflanzenspezifische Power-Ups
        for aktiv in activePowerUps where aktiv.isActive && aktiv.targetPlantId == pflanze.id {
            if let base = GameDatabase.allPowerUps.first(where: { $0.id == aktiv.powerUpId }) {
                mult *= base.effectMultiplier
            }
        }
        
        return mult
    }

    func coinMultiplikator(for pflanze: HabitModel) -> Double {
        var mult = GartenLevel.coinMultiplikator(fuerLevel: gartenStufe)
        
        // 1. Wetter
        mult *= aktivesWetter.gemMultiplikator
        
        // 2. Penalty (Revive)
        if let start = pflanze.wiederbelebtAm {
            let tage = Calendar.current.dateComponents([.day], from: start, to: Date()).day ?? 0
            if tage < pflanze.strafTage {
                mult *= 0.5
            }
        }
        
        // Power-Ups (Coins werden meistens nicht durch Power-Ups beeinflusst, außer explizit)
        // Aber falls wir welche haben:
        for aktiv in activePowerUps where aktiv.isActive && (aktiv.targetPlantId == nil || aktiv.targetPlantId == pflanze.id) {
            if let base = GameDatabase.allPowerUps.first(where: { $0.id == aktiv.powerUpId }), base.id.contains("coin") {
                mult *= base.effectMultiplier
            }
        }
        return mult
    }





    // MARK: - Wetter-Logik

    func ladeTagesWetter() {
        let kalender = Calendar.current
        let tagDesJahres = kalender.ordinality(of: .day, in: .year, for: Date()) ?? 0
        
        // Deterministische Wetter-Berechnung pro Tag (0-4)
        let index = tagDesJahres % WetterEvent.allCases.count
        self.aktivesWetter = WetterEvent.allCases[index]
        // print("DEBUG: Wetter heute (\(tagDesJahres)): \(aktivesWetter.titel)")
    }
    
    func cycleWetter() {
        let all = WetterEvent.allCases
        guard let currentIdx = all.firstIndex(of: aktivesWetter) else { return }
        let nextIdx = (currentIdx + 1) % all.count
        withAnimation(.easeInOut(duration: 0.8)) {
            aktivesWetter = all[nextIdx]
        }
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    func starteTageswechselTimer() {
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let jetzt = Date()
            let stunde = Calendar.current.component(.hour, from: jetzt)
            let minute = Calendar.current.component(.minute, from: jetzt)
            
            // Um Mitternacht Wetter aktualisieren
            if stunde == 0 && minute == 0 {
                self.ladeTagesWetter()
            }
        }
    }

    var hatZeitkapsel: Bool {
        activePowerUps.contains { $0.isActive && $0.powerUpId == "powerup.zeitkapsel" }
    }

    // MARK: - Garten-Pass
    
    func kannAbholen(level: Int) -> Bool {
        let aktuellerLevel = GartenLevel.level(fuerXP: gesamtXP)
        return level <= aktuellerLevel && !abgeholtePassLevel.contains(level)
    }
    
    func belohnungAbholen(belohnung: GartenPassBelohnung) {
        guard kannAbholen(level: belohnung.id) else { return }
        
        abgeholtePassLevel.insert(belohnung.id)
        
        switch belohnung.typ {
        case .coins(let n):
            coinsGutschreiben(amount: n, beschreibung: NSLocalizedString("pass_belohnung_coins", comment: ""))
        case .gluecksradDrehung(let n):
            gluecksradDrehungen = min(gluecksradDrehungen + n, GameConstants.maxGluecksradDrehungen)
            saveStats()
        case .powerUp(let id):
            if let pu = GameDatabase.allPowerUps.first(where: { $0.id == id }) {
                let payload = ShopDetailPayload.from(powerUp: pu)
                itemHinzufuegen(shopItem: payload, isFree: true)
                onItemClaimed?(pu.id) // Sync mit Shop
            }
        case .pflanze(let id):
            if let pl = GameDatabase.allPlants.first(where: { $0.id == id }) {
                let payload = ShopDetailPayload.from(plant: pl)
                pflanzHinzufuegen(shopItem: payload, isFree: true)
                onItemClaimed?(pl.id) // Sync mit Shop
            }
        case .dekoration(let id):
            if let dk = GameDatabase.allDecorations.first(where: { $0.id == id }) {
                let payload = ShopDetailPayload.from(decoration: dk)
                itemHinzufuegen(shopItem: payload, isFree: true)
                onItemClaimed?(dk.id) // Sync mit Shop
            }
        case .paket(let titel, let paketCoins, let powerUpID):
            coinsGutschreiben(amount: paketCoins, beschreibung: titel)
            if let puID = powerUpID, let pu = GameDatabase.allPowerUps.first(where: { $0.id == puID }) {
                let payload = ShopDetailPayload.from(powerUp: pu)
                itemHinzufuegen(shopItem: payload, isFree: true)
                onItemClaimed?(pu.id) // Sync mit Shop
            }
        case .seeds(let n):
            seeds += n
            saveStats()
        }
    }
    
    func einloesenGartenPassBelohnung(belohnung: GartenPassSpinBelohnung) {
        switch belohnung {
        case .coins(let amount):
            coinsGutschreiben(amount: amount, beschreibung: NSLocalizedString("ice_wheel_reward", comment: ""))
        case .xp(let amount):
            xpHinzufuegen(amount: amount)
        case .seeds(let amount):
            seeds += amount
        case .powerUp(let id):
            if let pu = GameDatabase.allPowerUps.first(where: { $0.id == id }) {
                let payload = ShopDetailPayload.from(powerUp: pu)
                itemHinzufuegen(shopItem: payload, isFree: true)
            }
        case .pflanze(let id):
            if let pl = GameDatabase.allPlants.first(where: { $0.id == id }) {
                let payload = ShopDetailPayload.from(plant: pl)
                pflanzHinzufuegen(shopItem: payload, isFree: true)
            }
        case .deko(let id):
            if let dk = GameDatabase.allDecorations.first(where: { $0.id == id }) {
                let payload = ShopDetailPayload.from(decoration: dk)
                itemHinzufuegen(shopItem: payload, isFree: true)
            }
        case .weed:
            withAnimation(.spring()) {
                isWeedActive = true
                dailyQuestsCompletedSinceWeed = 0
            }
            saveStats()
        }
    }

    func addCustomPlant(name: String, habit: String, icon: String, color: String) {
        guard seeds >= 10 else { return }
        seeds -= 10
        saveStats()
        
        createAndAddCustomPlant(name: name, habit: habit, icon: icon, color: color)
    }
    
    // Non-billed version for Onboarding
    func addCustomPlantFromOnboarding(name: String, habit: String, icon: String, color: String, reminderTime: Date? = nil) {
        createAndAddCustomPlant(name: name, habit: habit, icon: icon, color: color, reminderTime: reminderTime)
    }
    
    // Backwards compatibility for older onboarding code calling a German-named API
    func pflanzeHinzufuegenCustom(name: String, habit: String, icon: String, color: String, reminderTime: Date? = nil) {
        addCustomPlantFromOnboarding(name: name, habit: habit, icon: icon, color: color, reminderTime: reminderTime)
    }
    
    private func createAndAddCustomPlant(name: String, habit: String, icon: String, color: String, reminderTime: Date? = nil) {
        let newCustomID = "custom_\(UUID().uuidString)"
        let customPlant = HabitModel(
            id: newCustomID,
            name: name,
            symbolName: icon,
            symbolColor: color,
            habitCategories: [.mental],
            symbolism: "plant.create.custom_symbolism",
            habitName: habit,
            maxLevel: 10,
            xpPerCompletion: 100,
            waterNeedPerDay: 1,
            decayDays: 2,
            reminderTime: reminderTime
        )
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            pflanzen.append(customPlant)
            savePlants()
            NotificationManager.shared.scheduleAll(for: pflanzen)
        }
    }
    
    private func speichereAbgeholte() {
        UserDefaults.standard.set(Array(abgeholtePassLevel), forKey: "abgeholtePassLevel")
    }
    
    func ladeAbgeholte() {
        let gespeichert = UserDefaults.standard.array(forKey: "abgeholtePassLevel") as? [Int] ?? []
        abgeholtePassLevel = Set(gespeichert)
    }


    // MARK: Notizen Management
    func notizHinzufuegen(pflanze: HabitModel, text: String) {
        withAnimation(.spring(response: 0.4)) {
            pflanze.notizen.append(text)
            savePlants()
        }
    }

    func notizAktualisieren(pflanze: HabitModel, index: Int, text: String) {
        guard index >= 0 && index < pflanze.notizen.count else { return }
        pflanze.notizen[index] = text
        savePlants()
    }

    func notizEntfernen(pflanze: HabitModel, index: Int) {
        guard index >= 0 && index < pflanze.notizen.count else { return }
        withAnimation(.spring(response: 0.4)) {
            pflanze.notizen.remove(at: index)
            savePlants()
        }
    }

    // MARK: Timer setzen
    func timerSetzen(pflanze: HabitModel, datum: Date) {
        pflanze.timerDatum = datum
        savePlants()
        // Wir planen alles neu, damit der Timer (falls wir ihn unterstützen wollen) berücksichtigt wird.
        // Aktuell basiert das System auf lastWatered, aber wir halten uns an scheduleAll.
        NotificationManager.shared.scheduleAll(for: pflanzen)
    }

    // MARK: Timer entfernen
    func timerEntfernen(pflanze: HabitModel) {
        pflanze.timerDatum = nil
        savePlants()
        NotificationManager.shared.cancelAll(for: pflanze)
        NotificationManager.shared.scheduleAll(for: pflanzen)
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

    func saveStats() {
        UserDefaults.standard.set(coins, forKey: "stats_coins")
        UserDefaults.standard.set(gesamtXP, forKey: "stats_gesamt_xp")
        UserDefaults.standard.set(leben, forKey: "stats_leben")
        UserDefaults.standard.set(gluecksradDrehungen, forKey: "stats_gluecksrad_drehungen")
        UserDefaults.standard.set(gesamtGekaufteItemsCount, forKey: "stats_gesamt_gekaufte_items_count")
        UserDefaults.standard.set(gesamtGegossen, forKey: "stats_gesamt_gegossen")
        UserDefaults.standard.set(tageAktiv, forKey: "stats_tage_aktiv")
        UserDefaults.standard.set(gesamtVerdient, forKey: "stats_gesamt_verdient")
        UserDefaults.standard.set(gesamtAusgegeben, forKey: "stats_gesamt_ausgegeben")
        UserDefaults.standard.set(lastSpinTimestamp, forKey: "last_spin_timestamp")
        UserDefaults.standard.set(isWeedActive, forKey: "is_weed_active")
        UserDefaults.standard.set(dailyQuestsCompletedSinceWeed, forKey: "daily_quests_completed_since_weed")
        UserDefaults.standard.set(seeds, forKey: "stats_seeds")
    }

    private func loadStats() {
        coins = UserDefaults.standard.object(forKey: "stats_coins") != nil ? UserDefaults.standard.integer(forKey: "stats_coins") : GameConstants.startCoins
        gesamtXP = UserDefaults.standard.integer(forKey: "stats_gesamt_xp")
        leben = UserDefaults.standard.object(forKey: "stats_leben") != nil ? UserDefaults.standard.integer(forKey: "stats_leben") : 5
        gluecksradDrehungen = UserDefaults.standard.integer(forKey: "stats_gluecksrad_drehungen")
        gesamtGekaufteItemsCount = UserDefaults.standard.integer(forKey: "stats_gesamt_gekaufte_items_count")
        gesamtGegossen = UserDefaults.standard.integer(forKey: "stats_gesamt_gegossen")
        tageAktiv = UserDefaults.standard.integer(forKey: "stats_tage_aktiv")
        gesamtVerdient = UserDefaults.standard.integer(forKey: "stats_gesamt_verdient")
        gesamtAusgegeben = UserDefaults.standard.integer(forKey: "stats_gesamt_ausgegeben")
        lastSpinTimestamp = UserDefaults.standard.object(forKey: "last_spin_timestamp") as? Date
        isWeedActive = UserDefaults.standard.bool(forKey: "is_weed_active")
        dailyQuestsCompletedSinceWeed = UserDefaults.standard.integer(forKey: "daily_quests_completed_since_weed")
        seeds = UserDefaults.standard.integer(forKey: "stats_seeds")
    }

    func savePlants() {
        if let encoded = try? JSONEncoder().encode(pflanzen) {
            UserDefaults.standard.set(encoded, forKey: "garden_plants")
        }
    }

    private func loadPlants() {
        if let data = UserDefaults.standard.data(forKey: "garden_plants"),
           let decoded = try? JSONDecoder().decode([HabitModel].self, from: data) {
            
            // Sync with Database to apply balance changes (like XP 10 -> 100)
            for pflanze in decoded {
                if let dbPlant = GameDatabase.allPlants.first(where: { $0.id == pflanze.plantID }) {
                    pflanze.xpPerCompletion = dbPlant.xpPerCompletion
                    pflanze.maxLevel = dbPlant.maxLevel
                    pflanze.waterNeedPerDay = dbPlant.waterNeedPerDay
                    pflanze.decayDays = dbPlant.decayDays
                    
                    // Reparatur: Falls der Name ein Habit-Key ist, korrigieren wir ihn
                    if pflanze.name.starts(with: "habit.") {
                        pflanze.name = dbPlant.name
                    }
                } else if pflanze.plantID.starts(with: "custom_") && pflanze.xpPerCompletion < 100 {
                    // Update old custom plants to the new 100 XP standard
                    pflanze.xpPerCompletion = 100
                }
            }
            
            pflanzen = decoded
        } else {
            pflanzen = []
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
            gesamtXP = 0
            transactions.removeAll()
            gesamtVerdient = 0
            gesamtAusgegeben = 0
            gesamtGegossen = 0
            tageAktiv = 1
            activePowerUps.removeAll()
            gekaufteItems.removeAll()
            placedDecorations.removeAll()
            leben = 5
            gestorbenePflanzenLog.removeAll()
            gluecksradDrehungen = 0
            abgeholtePassLevel.removeAll()
            
            lastSpinTimestamp = nil
            isWeedActive = false
            dailyQuestsCompletedSinceWeed = 0
            
            let keys = [
                "garden_plants", "stats_coins", "stats_gesamt_xp", "stats_gesamt_streak",
                "stats_best_streak", "stats_gesamt_gekaufte_items_count",
                "stats_gesamt_gegossen", "stats_tage_aktiv", "stats_gesamt_verdient",
                "stats_gesamt_ausgegeben", "coin_transactions", "garden_transactions",
                "garden_inventory", "active_powerups_garden", "garden_decorations",
                "last_active_date", "last_spin_timestamp", "is_weed_active",
                "daily_quests_completed_since_weed", "abgeholtePassLevel",
                "stats_gluecksrad_drehungen", "daily_spin_last_shown_day_string"
            ]
            keys.forEach { UserDefaults.standard.removeObject(forKey: $0) }
            
            // Set today as last active immediately after reset
            let today = Calendar.current.startOfDay(for: Date())
            UserDefaults.standard.set(today, forKey: "last_active_date")
            
            savePlants()
            saveStats()
            saveTransactions()
            saveInventory()
            saveInventory()
            saveActivePowerUps()
            saveDecorations()
        }
    }

    // MARK: - Health Check
    func pruefePflanzenStatus() {
        if plantToRescue != nil { return } // Warten auf Benutzer-Antwort
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var changed = false
        
        for pflanze in pflanzen {
            // Referenz-Tag (letzte Bewässerung oder Kaufdatum)
            let letzte = pflanze.letzteBewaesserung ?? pflanze.gekauftAm
            let startLetzte = calendar.startOfDay(for: letzte)
            
            // Anzahl der vergangenen Kalendertage (0 = heute, 1 = seit gestern, etc.)
            let diff = calendar.dateComponents([.day], from: startLetzte, to: today).day ?? 0
            
            // Ein Zyklus gilt als verpasst, wenn mehr als ein Kalendertag vergangen ist 
            // (da man ja am nächsten Tag noch bis 0:00 Uhr Zeit hat zu gießen).
            // diff = 2 -> verpasst = 1 ("!"), diff = 3 -> verpasst = 2 (Tot)
            var verpasst = max(0, diff - 1)
            
            // Wächter-Turm (Sturmfest) Rettung vor dem sicheren Tod (Tot ab verpasst >= 2)
            if verpasst >= 2 {
                if let tower = activePowerUps.first(where: { $0.powerUpId == "powerup.sturmfest" && $0.targetPlantId == pflanze.id && $0.isActive }) {
                    pflanze.letzteBewaesserung = Date()
                    verpasst = 0
                    activePowerUps.removeAll { $0.id == tower.id }
                } else if pflanze.lastNotifiedCycle < 2 && verpasst >= 2 {
                    // Pflanze stirbt jetzt. Hat der Benutzer Wunder-Wasser?
                    let hasWunderWasser = gekaufteItems.contains(where: { $0.id == "powerup.wunder_wasser" })
                    if hasWunderWasser {
                        plantToRescue = pflanze
                        return // Logik unterbrechen, restliche Pflanzen warten auf den nächsten Lauf
                    }
                }
            }
            
            if pflanze.missedCycles != verpasst {
                pflanze.missedCycles = verpasst
                changed = true
            }

            // Herz-Abzug Logik: Nur bei endgültigem Tod (verpasst >= 2), nicht bei Warnung (verpasst == 1)
            if verpasst >= 2 && pflanze.lastNotifiedCycle < 2 {
                pflanzeGestorben(pflanze)
                pflanze.lastNotifiedCycle = verpasst
                changed = true
            } else if verpasst == 1 && pflanze.lastNotifiedCycle < 1 {
                pflanze.lastNotifiedCycle = 1
                changed = true
            }
        }
        
        if changed {
            savePlants()
            saveStats()
        }
    }

    func loeschePflanze(pflanze: HabitModel) {
        withAnimation {
            pflanzen.removeAll { $0.id == pflanze.id }
            savePlants()
        }
    }

    // MARK: - Debug Helpers
    func simulateTimeJump(hours: Double) {
        let seconds = hours * 3600
        for pflanze in pflanzen {
            if let letzte = pflanze.letzteBewaesserung {
                pflanze.letzteBewaesserung = letzte.addingTimeInterval(-seconds)
            }
        }
        pruefePflanzenStatus()
    }
}
