import SwiftUI
import SwiftData
import Combine
import ActivityKit

struct GiessBonus: Equatable {
    let xp: Int
    let gems: Int
}

struct BadHabitExecution: Codable, Identifiable {
    var id: UUID = UUID()
    let date: Date
    let coinsLost: Int
    var triggers: [String]?
}

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
    @Published var triggerStreakDetail: Bool = false
    @Published var triggerWaterDetail: Bool = false
    @Published var triggerPaywall: Bool = false
    @Published var zeigeGeschafftPopup: Bool = false
    @Published var liveActivityDebugLog: String = ""
    @Published var gluecksradDrehungen: Int = 0 {
        didSet { saveStats() }
    }
    @Published var seeds: Int = 0 {
        didSet { saveStats() }
    }
    
    // MARK: - Pro User Integration
    /// Closure zur Abfrage des Pro-Status – wird aus App.swift via IAPStore verlinkt
    var isProUserProvider: () -> Bool = { false }
    var isProUser: Bool { isProUserProvider() }
    
    // Stats for Achievements
    @Published var dailySpinsVerfuegbar: Bool = true
    @Published var gesamtVerdient: Int = 0
    @Published var gesamtAusgegeben: Int = 0
    @Published var gesamtGegossen: Int = 0
    @Published var tageAktiv: Int = 0
    @Published var skillXP: [String: Int] = [:]
    @Published var completed90DayChallenges: Int = 0
    @Published var focusSessions: [FocusSessionLog] = [] {
        didSet { saveFocusSessions() }
    }

    
    var isMock: Bool = false
    
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
    @Published var badHabitExecutions: [String: [BadHabitExecution]] = [:] {
        didSet { saveBadHabits() }
    }
    
    @Published var savedCustomTriggers: [String] = [] {
        didSet { saveCustomTriggers() }
    }
    
    // Daily Spin States
    @Published var showDailySpinOverlay: Bool = false
    @Published var pendingDailySpin: Bool = false {
        didSet { saveStats() }
    }
    @Published var lastSpinTimestamp: Date? {
        didSet { saveStats() }
    }
    @Published var activeWeeds: [WeedPatch] = [] {
        didSet { saveStats() }
    }
    @Published var weedCrisis: WeedCrisisState = WeedCrisisState() {
        didSet { saveStats() }
    }
    @Published var comebackBoostExpiresAt: Date? = nil {
        didSet { saveStats() }
    }
    @Published var zeigeComebackBoostOverlay: Bool = false

    var isWeedActive: Bool { !activeWeeds.isEmpty }
    var isComebackBoostActive: Bool {
        guard let expires = comebackBoostExpiresAt else { return false }
        return Date() < expires
    }
    var comebackBoostRewardPercent: Int {
        Int((GameConstants.comebackXPMultiplier * 100).rounded())
    }
    var dailyQuestsCompletedSinceWeed: Int { activeWeeds.first?.habitsCompleted ?? 0 }
    var weedRemovalCost: Int { activeWeeds.first?.removalCost ?? 0 }
    var weedSpawnDate: Date? { activeWeeds.map(\.spawnDate).min() }
    var weedCount: Int { activeWeeds.count }
    var habitsRequiredForCurrentWeed: Int { GameConstants.habitsRequiredPerWeed }
    var weedEffectiveRewardPercent: Int {
        WeedMechanics.effectiveRewardPercent(weedCount: activeWeeds.count)
    }

    var blocksNewWeedSpawns: Bool {
        hasActivePowerUp(powerUpId: PowerUpWeedSupport.gartenschutzID)
            || hasActivePowerUp(powerUpId: PowerUpWeedSupport.zauberstabID)
    }

    var availableWeedPowerUpItems: [ShopDetailPayload] {
        gekaufteItems.filter { PowerUpWeedSupport.isWeedPowerUp($0.id) }
    }

    /// Inventar-Power-up oder laufender Gartenschutz/Zauberstab – Schild-Ritual möglich
    var hasWeedShieldOption: Bool {
        !availableWeedPowerUpItems.isEmpty || blocksNewWeedSpawns
    }

    /// Aus Inventar „Verwenden“ → Unkraut-Sheet mit vorausgewähltem Power-up
    @Published var pendingWeedPowerUpForRitual: ShopDetailPayload?
    @Published var aktivesWetter: WetterEvent = .normal
    @Published var pendingImportURL: URL? = nil
    /// Wird per Live Activity Deep Link gesetzt, um die passende FocusSessionView zu öffnen
    @Published var activeFocusHabitId: String? = nil
    
    private var isLoading = false
    
    // Für UI Feedback wenn eine Pflanze schon vorhanden war und durch Coins ersetzt wurde
    @Published var letzteErsatzCoins: Int? = nil
    
    // Gieß-Bonus & Feedback
    @Published var letzterBonus: GiessBonus? = nil
    @Published var letzteBonusPflanzeID: String? = nil
    @Published var letzteGiessXP: Int = 0
    @Published var letzteGiessCoins: Int = 0
    @Published var letzteGiessPflanzeID: String? = nil
    @Published var giessTriggerID = UUID()
    @Published var coinPopTrigger: Int = 0
    @Published var newlyAchievedRarity: PflanzenSeltenheit? = nil
    
    var titelStore: TitelStore? = nil

    // Live Activity was moved to Focus Timer


    var totalItemsCount: Int {
        pflanzen.count + gekaufteItems.count + placedDecorations.count
    }

    var heuteGegossen: Bool {
        pflanzen.contains(where: { $0.istBewässert })
    }

    var gekauftePowerUps: [ShopDetailPayload] {
        gekaufteItems.filter { $0.itemType == .powerUp }
    }

    var gartenStufe: Int {
        GartenLevel.level(fuerXP: gesamtXP)
    }

    var gesamtMlGegossen: Double {
        Double(gesamtGegossen) * GameConstants.mlProGiessen
    }

    var gesamtLiterFormatiert: String {
        let liter = gesamtMlGegossen / 1000
        
        if liter < 1 {
            let unit = NSLocalizedString("common.ml", comment: "")
            return String(format: "%.0f %@", gesamtMlGegossen, unit)
        } else {
            let unit = NSLocalizedString("common.liter", comment: "")
            return String(format: "%.1f %@", liter, unit)
        }
    }

    var pflanzenNachMlSortiert: [HabitModel] {
        pflanzen.sorted { $0.totalMlGegossen > $1.totalMlGegossen }
    }
    
    // Streak-Integration
    var onWatering: (() -> Void)?
    var onItemClaimed: ((String) -> Void)?

    func getIconForCategory(_ categoryKey: String) -> String? {
        if categoryKey.hasPrefix("decoration.category.") {
            let raw = categoryKey.replacingOccurrences(of: "decoration.category.", with: "")
            return DecorationCategory(rawValue: raw)?.icon
        }
        if categoryKey == "inventory.seeds" { return "Samen" }
        if categoryKey == "profile.inventory.powerups" { return "Powerup" }
        return nil
    }

    init(isMock: Bool = false) {
        self.isMock = isMock
        if !isMock {
            loadStats()
            loadPlants()
            loadTransactions()
            loadInventory()
            loadActivePowerUps()
            loadDecorations()
            loadBadHabits()
            loadBadHabitNotes()
            loadCustomTriggers()
            updateTageAktiv()
            pruefePflanzenStatus()
            taeglicherStreakCheck()
            checkUngegossenePflanzen()
            updateWidgetData()
        }
    }

    func reloadData() {
        loadStats()
        loadPlants()
        loadTransactions()
        loadInventory()
        loadActivePowerUps()
        loadDecorations()
        loadBadHabits()
        loadBadHabitNotes()
        loadCustomTriggers()
        updateTageAktiv()
        pruefePflanzenStatus()
        taeglicherStreakCheck()
        checkUngegossenePflanzen()
        updateWidgetData()
    }

    /// Öffnet das Unkraut-Sheet im Garten (z. B. aus Einstellungen → Debug).
    @Published var debugRequestWeedSheet = false

    func debugSpawnWeed() {
        spawnWeed(removalCost: GameConstants.weedRemovalCostSpin, source: .plantDeath)
    }

    func debugClearWeeds() {
        withAnimation {
            activeWeeds.removeAll()
        }
        saveStats()
    }

    func debugAddWeedPowerUpToInventory(powerUpId: String) {
        guard let powerUp = GameDatabase.allPowerUps.first(where: { $0.id == powerUpId }) else { return }
        let payload = ShopDetailPayload.from(powerUp: powerUp)
        guard !gekaufteItems.contains(where: { $0.id == powerUpId }) else { return }
        itemHinzufuegen(shopItem: payload, isFree: true)
    }

    func debugActivateGardenPowerUp(powerUpId: String) {
        guard let powerUp = GameDatabase.allPowerUps.first(where: { $0.id == powerUpId }) else { return }
        applyPowerUp(powerUp)
    }

    func debugClearWeedProtection() {
        activePowerUps.removeAll { PowerUpWeedSupport.isWeedPowerUp($0.powerUpId) }
        saveActivePowerUps()
    }

    func debugRequestOpenWeedSheet() {
        if !isWeedActive { debugSpawnWeed() }
        debugRequestWeedSheet = true
    }

    func debugOpenWeedSheetWithShieldPreselected() {
        debugAddWeedPowerUpToInventory(powerUpId: PowerUpWeedSupport.gartenschutzID)
        if !isWeedActive { debugSpawnWeed() }
        if let item = gekaufteItems.first(where: { $0.id == PowerUpWeedSupport.gartenschutzID }) {
            pendingWeedPowerUpForRitual = item
        }
        debugRequestWeedSheet = true
    }

    func debugGrantComebackBoost() {
        comebackBoostExpiresAt = Date().addingTimeInterval(
            GameConstants.comebackBoostDurationHours * 3600
        )
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            zeigeComebackBoostOverlay = true
        }
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
        }
        saveStats()
    }
    
    // MARK: Pflanze gießen
    func giessen(pflanze: HabitModel, powerUpStore: PowerUpStore, fromRoutine: Bool = false) {
        guard !pflanze.istBewässert else { return }

        // Tagesziel automatisch erfüllen (Andersrum-Sync)
        if let target = pflanze.customTrackerTarget, target > 0 {
            if pflanze.customTrackerProgress < target {
                pflanze.customTrackerProgress = target
                zeigeGeschafftPopup = true
            }
        }

        // 2. XP & Coins berechnen (Multiplikative Logik)
        let xpMult = xpMultiplikator(for: pflanze)
        let coinMult = coinMultiplikator(for: pflanze)

        // Bonus-Logik
        let bonusAusgeloest = Double.random(in: 0...1) < GameConstants.bonusChance
        let xpBasis = Int(Double(pflanze.xpPerCompletion) * xpMult)
        let xpGewonnen = bonusAusgeloest ? Int(Double(xpBasis) * GameConstants.bonusXPMultiplier) : xpBasis
        let gemsGewonnen = bonusAusgeloest ? GameConstants.bonusGemAmount : 0
        
        let coinsGewonnen = Int(Double(GameConstants.coinsProGiessen) * coinMult)
        var finalXPGewonnen = xpGewonnen
        
        let weedPenaltiesApply = isWeedActive && !hasActivePowerUp(powerUpId: PowerUpWeedSupport.zauberstabID)
        let weedCoinDeduction = weedPenaltiesApply
            ? WeedMechanics.appliedCoinPenalty(currentCoins: coins, weedCount: activeWeeds.count)
            : 0
        if weedPenaltiesApply {
            finalXPGewonnen = Int(Double(finalXPGewonnen) * WeedMechanics.xpMultiplier(weedCount: activeWeeds.count))
        }

        let alteRarity = pflanze.seltenheit
        pflanze.currentXP += finalXPGewonnen
        let neueRarity = pflanze.seltenheit
        
        let allRarities = PflanzenSeltenheit.allCases
        if let oldIdx = allRarities.firstIndex(of: alteRarity),
           let newIdx = allRarities.firstIndex(of: neueRarity),
           newIdx > oldIdx {
            
            // Wenn wir Diamant erreicht haben, schalten wir vielleicht einen Titel frei? (wird extern gemacht oder hier?)
            // Trigger das Overlay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.newlyAchievedRarity = neueRarity
            }
        }
        
        // Bonus-Info kommunizieren
        if bonusAusgeloest {
            self.letzteBonusPflanzeID = pflanze.id
            self.letzterBonus = GiessBonus(xp: xpGewonnen, gems: gemsGewonnen)
        } else {
            self.letzterBonus = nil
            self.letzteBonusPflanzeID = nil
        }
        self.letzteGiessXP = finalXPGewonnen
        self.letzteGiessCoins = coinsGewonnen
        self.letzteGiessPflanzeID = pflanze.id

        // XP Verlauf für die Pflanze speichern
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let key = formatter.string(from: Date())
        pflanze.xpHistory[key] = (pflanze.xpHistory[key] ?? 0) + finalXPGewonnen
        
        pflanze.totalCoinsEarned += coinsGewonnen

        // 3. XP zum Garten-Gesamt addieren
        xpHinzufuegen(amount: finalXPGewonnen)
        
        self.giessTriggerID = UUID()
        
        pflanze.istBewässert = true
        pflanze.letzteBewaesserung = Date()
        pflanze.wateringDates.append(Date()) // Log für Verlauf-Tab
        pflanze.streak += 1
        pflanze.missedCycles = 0 // Reset Gesundheit
        pflanze.lastNotifiedCycle = 0 // Reset Herz-Abzug-Trigger
        pflanze.totalMlGegossen += GameConstants.mlProGiessen
        
        // Auto-generierte Notiz
        let timeString = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short)
        let routineString = fromRoutine ? String(localized: "note.auto.routine", defaultValue: "(mit Routine)") : String(localized: "note.auto.no_routine", defaultValue: "(ohne Routine)")
        let noteText = "\(timeString) -  \(String(localized: "note.auto.completed", defaultValue: "Gewohnheit abgeschlossen")) \(routineString)"
        
        pflanze.notizen.insert(noteText, at: 0)
        
        savePlants()

        // Globale Stats
        withAnimation(.spring(response: 0.4)) {
            if weedCoinDeduction > 0 {
                coins = max(0, coins - weedCoinDeduction)
            }
            coins    += coinsGewonnen
            seeds    += gemsGewonnen // Gems werden hier in 'seeds' gespeichert
            // gesamtXP ist bereits oben addiert
            gesamtVerdient += coinsGewonnen
            
            // Add real transaction
            
            // Skill XP hinzufügen
            if let skill = SkillHelper.getSkill(for: pflanze) {
                skillXP[skill.rawValue, default: 0] += 10
            }
            let transaction = CoinTransaction(
                datum: Date(),
                beschreibung: NSLocalizedString("profile.coins.tip.watering", comment: ""),
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
        
        if isWeedActive {
            advanceWeedRemovalProgress()
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
        coinsAbziehen(amount: GameConstants.wiederbelebungsKosten, beschreibung: NSLocalizedString("transaction.revive", comment: ""))
        
        objectWillChange.send()
        withAnimation {
            pflanze.wiederbelebtAm = Date()
            pflanze.letzteBewaesserung = Date() // Reset the watering timer
            pflanze.missedCycles = 0
            pflanze.lastNotifiedCycle = 0
            pflanze.isDead = false
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
                pflanze.isDead = false
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
        let dbName = dbPlant?.name ?? shopItem.titleKey
        
        let neue = HabitModel(
            id: UUID().uuidString,
            name: dbName,
            symbolName: shopItem.icon,
            symbolColor: shopItem.colorHex,
            habitCategory: shopItem.habitCategory ?? .lifestyle,
            symbolism: shopItem.descriptionKey,
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
            updateWidgetData() // Update Home-Screen Widget
        }
    }

    func pflanzeHinzufuegen(id: String) {
        if let pl = GameDatabase.allPlants.first(where: { $0.id == id }) {
            let payload = ShopDetailPayload.from(plant: pl)
            pflanzHinzufuegen(shopItem: payload, isFree: true)
        }
    }

    // MARK: - Leben System
    func pflanzeGestorben(_ habit: HabitModel) {
        withAnimation(.spring) {
            let damage = aktivesWetter == .sturm ? 2 : 1
            leben = max(0, leben - damage)
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
                
                // Jedes Deko-Kauf spawnt ein eigenes Unkraut mit eigenen Kosten
                spawnWeed(
                    removalCost: shopItem.price * GameConstants.weedRemovalCostMultiplier,
                    source: .decoration
                )
                
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
        coinsGutschreiben(amount: amount, beschreibung: " \(reason)")
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

    func logPurchase(shopItem: ShopDetailPayload, isFree: Bool = false) {
        if !isFree && shopItem.price > 0 {
            let desc = "\(NSLocalizedString("shop.buy.success", comment: "")) \(shopItem.titleKey)"
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
        // --- Screen Time Auto-Processing ---
        let screenTimeLastProcessed = UserDefaults.standard.double(forKey: "screenTimeLastProcessedDate")
        let heute = Calendar.current.startOfDay(for: Date())
        let letztesProcessedTag = Calendar.current.startOfDay(for: Date(timeIntervalSince1970: screenTimeLastProcessed))
        
        if heute > letztesProcessedTag {
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "screenTimeLastProcessedDate")
            
            let screenTimeLimitExceeded = SharedUserDefaults.suite.bool(forKey: "screenTimeLimitExceededToday")
            if screenTimeLimitExceeded {
                // Bad habit log
                if let badHabit = pflanzen.first(where: { $0.id == "bad_habit_screen_time" || $0.plantID == "trash.junk_mail_abo" }) {
                    let execution = BadHabitExecution(date: Date(), coinsLost: 0, triggers: [String(localized: "screenTime.reason.exceeded", defaultValue: "Tageslimit überschritten")])
                    badHabitExecutions[badHabit.id, default: []].append(execution)
                } else {
                    let bad = HabitModel(
                        id: "bad_habit_screen_time",
                        name: String(localized: "trash.junk_mail_abo.name", defaultValue: "Zuviel Bildschirmzeit"),
                        symbolName: "hourglass.bottomhalf.filled",
                        symbolColor: "red",
                        habitCategory: .health,
                        symbolism: String(localized: "bad_habit.screen_time.desc", defaultValue: "Rückfall"),
                        habitName: String(localized: "trash.junk_mail_abo.name", defaultValue: "Zuviel Bildschirmzeit"),
                        maxLevel: 10,
                        xpPerCompletion: 0,
                        waterNeedPerDay: 0,
                        decayDays: 0,
                        plantID: "trash.junk_mail_abo",
                        isNegative: true
                    )
                    pflanzen.append(bad)
                    let execution = BadHabitExecution(date: Date(), coinsLost: 0, triggers: [String(localized: "screenTime.reason.exceeded", defaultValue: "Tageslimit überschritten")])
                    badHabitExecutions[bad.id, default: []].append(execution)
                }
            } else {
                // Auto-water the tracker (using Aloe Vera / Bildschirmzeit)
                if let tracker = pflanzen.first(where: { $0.habitName == "habit.bildschirmzeit" }) {
                    tracker.istBewässert = true
                    tracker.letzteBewaesserung = Date()
                    tracker.wateringDates.append(Date())
                    tracker.streak += 1
                    tracker.currentXP += tracker.xpPerCompletion
                    tracker.missedCycles = 0
                    xpHinzufuegen(amount: tracker.xpPerCompletion)
                    
                    let timeString = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short)
                    let noteText = "\(timeString) - \(String(localized: "note.auto.screentime_success", defaultValue: "Bildschirmzeit eingehalten"))"
                    tracker.notizen.insert(noteText, at: 0)
                }
            }
            // Reset the limit for the new day
            SharedUserDefaults.suite.set(false, forKey: "screenTimeLimitExceededToday")
        }
        
        for pflanze in pflanzen {
            let isProtected = activePowerUps.contains(where: { $0.powerUpId == "powerup.zeitkapsel" && $0.targetPlantId == pflanze.id && $0.isActive })
            if pflanze.streakAbgelaufen && !isProtected {
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
        
        // Unkraut Ausbreitung (ältestes Unkraut zählt)
        if isWeedActive, let spawnDate = weedSpawnDate {
            let daysActive = Calendar.current.dateComponents([.day], from: spawnDate, to: Date()).day ?? 0
            if daysActive >= GameConstants.weedSpreadDays {
                // Infiziert gesunde Pflanzen (sie kränkeln / Health sinkt künstlich)
                for pflanze in pflanzen {
                    pflanze.missedCycles = min(2, pflanze.missedCycles + 1)
                }
            }
        }
        
        objectWillChange.send() // UI-Update erzwingen
        savePlants()
    }

    var isDailySpinAvailable: Bool {
        if pendingDailySpin { return true }
        if let lastSpin = lastSpinTimestamp {
            return !Calendar.current.isDateInToday(lastSpin)
        }
        return true
    }

    // MARK: Daily Spin Check
    func checkDailySpin() {
        // Gratis-Spin bereitstellen
        pendingDailySpin = true
        
        // Rad öffnen
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
            habitCategory: dbPlant.habitCategory,
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
            neue.individualSchwierigkeit = "fortgeschritten"
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
        if powerUp.id == PowerUpWeedSupport.zauberstabID {
            applyZauberstabPowerUp(powerUp)
            return
        }

        // Sofortige Ausführung für Herz-Auffüller
        if powerUp.id == "powerup.herz_auffueller" {
            if leben < 5 {
                leben += 1
                FeedbackManager.shared.playSuccess()
                saveStats()
            }
            return
        }

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
        mult *= aktivesWetter.xpMultiplikator
        
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

        // 5. Comeback-Wachstumsschub (nach überstandener Unkraut-Krise)
        if isComebackBoostActive {
            mult *= GameConstants.comebackXPMultiplier
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
        for aktiv in activePowerUps where aktiv.isActive && (aktiv.targetPlantId == nil || aktiv.targetPlantId == pflanze.id) {
            if let base = GameDatabase.allPowerUps.first(where: { $0.id == aktiv.powerUpId }), base.id.contains("coin") {
                mult *= base.effectMultiplier
            }
        }
        
        // 3. Pro-User Coin-Bonus (+25%)
        if isProUser {
            mult *= GameConstants.proCoinBonus
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
                Task { @MainActor in
                    self.ladeTagesWetter()
                }
            }
        }
    }

    var hatZeitkapsel: Bool {
        activePowerUps.contains { $0.isActive && $0.powerUpId == "powerup.zeitkapsel" }
    }


    func addCustomPlant(name: String, habit: String, icon: String, color: String, category: HabitCategory, isNegative: Bool = false) {
        guard seeds >= 10 else { return }
        seeds -= 10
        saveStats()
        
        createAndAddCustomPlant(name: name, habit: habit, icon: icon, color: color, category: category, isNegative: isNegative)
    }
    
    // Non-billed version for Onboarding
    func addCustomPlantFromOnboarding(name: String, habit: String, icon: String, color: String, category: HabitCategory, reminderTime: Date? = nil) {
        createAndAddCustomPlant(name: name, habit: habit, icon: icon, color: color, category: category, reminderTime: reminderTime, isNegative: false)
    }
    
    // Backwards compatibility for older onboarding code calling a German-named API
    func pflanzeHinzufuegenCustom(name: String, habit: String, icon: String, color: String, category: HabitCategory = .fitness, reminderTime: Date? = nil) {
        addCustomPlantFromOnboarding(name: name, habit: habit, icon: icon, color: color, category: category, reminderTime: reminderTime)
    }
    
    private func createAndAddCustomPlant(name: String, habit: String, icon: String, color: String, category: HabitCategory, reminderTime: Date? = nil, isNegative: Bool = false) {
        let newCustomID = "custom_\(UUID().uuidString)"
        
        if isNegative {
            let customDecoration = DecorationItem(
                id: "trash.\(newCustomID)",
                objectNameKey: name,
                objectDescriptionKey: "Eigene schlechte Angewohnheit",
                habitNameKey: name,
                habitDescriptionKey: habit,
                sfSymbol: icon,
                price: 0,
                category: .deko,
                minGartenLevel: 1
            )
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                placedDecorations.append(customDecoration)
                if let encoded = try? JSONEncoder().encode(placedDecorations) {
                    SharedUserDefaults.suite.set(encoded, forKey: "placedDecorations")
                    SharedUserDefaults.suite.synchronize()
                }
            }
        } else {
            let customPlant = HabitModel(
                id: UUID().uuidString,
                name: name,
                symbolName: icon,
                symbolColor: color,
                habitCategory: category,
                symbolism: "plant.create.custom_symbolism",
                habitName: habit,
                maxLevel: 10,
                xpPerCompletion: 100,
                waterNeedPerDay: 1,
                decayDays: 2,
                plantID: newCustomID,
                reminderTime: reminderTime,
                isNegative: isNegative
            )
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                pflanzen.append(customPlant)
                savePlants()
                NotificationManager.shared.scheduleAll(for: pflanzen)
            }
        }
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

    // MARK: Timer setzen (neues System)
    func timerScheduleSetzen(pflanze: HabitModel, schedule: ReminderSchedule) {
        pflanze.reminderSchedule = schedule
        // Legacy-Felder synchron halten für Rückwärtskompatibilität
        pflanze.reminderTime = schedule.weekdays.first(where: { $0.isEnabled })?.time
        self.objectWillChange.send()
        savePlants()
        NotificationManager.shared.scheduleAll(for: pflanzen)
    }

    // MARK: Timer setzen
    func timerSetzen(pflanze: HabitModel, datum: Date, customMessage: String? = nil) {
        let weekdays = (1...7).map { day in
            WeekdayReminder(weekday: day, time: datum, customMessage: customMessage, isEnabled: true)
        }
        let schedule = ReminderSchedule(weekdays: weekdays)
        pflanze.reminderSchedule = schedule
        pflanze.reminderTime = datum
        pflanze.customReminderMessage = customMessage
        self.objectWillChange.send()
        savePlants()
        // Wir planen alles neu, damit der Timer berücksichtigt wird.
        NotificationManager.shared.scheduleAll(for: pflanzen)
    }

    // MARK: Timer entfernen
    func timerEntfernen(pflanze: HabitModel) {
        pflanze.reminderTime = nil
        pflanze.reminderSchedule = nil
        self.objectWillChange.send()
        savePlants()
        NotificationManager.shared.cancelAll(for: pflanze)
        NotificationManager.shared.scheduleAll(for: pflanzen)
    }

    func saveActivePowerUps() {
        guard !isLoading else { return }
        if let encoded = try? JSONEncoder().encode(activePowerUps) {
            SharedUserDefaults.suite.set(encoded, forKey: "active_powerups_garden")
            SharedUserDefaults.suite.synchronize()
        }
    }

    private func loadActivePowerUps() {
        if let data = SharedUserDefaults.suite.data(forKey: "active_powerups_garden"),
           let decoded = try? JSONDecoder().decode([ActivePowerUp].self, from: data) {
            activePowerUps = decoded
        }
    }

    func saveDecorations() {
        guard !isMock else { return }
        guard !isLoading else { return }
        if let encoded = try? JSONEncoder().encode(placedDecorations) {
            SharedUserDefaults.suite.set(encoded, forKey: "garden_decorations")
            SharedUserDefaults.suite.synchronize()
        }
    }

    private func loadDecorations() {
        if let data = SharedUserDefaults.suite.data(forKey: "garden_decorations"),
           let decoded = try? JSONDecoder().decode([DecorationItem].self, from: data) {
            placedDecorations = decoded
        }
    }

    // MARK: - Unkraut

    func spawnWeed(removalCost: Int, source: WeedSource) {
        if source != .decoration && blocksNewWeedSpawns { return }

        if isComebackBoostActive {
            comebackBoostExpiresAt = nil
        }

        if weedCrisis.startedAt == nil {
            weedCrisis.startedAt = Date()
        }
        if source == .decoration {
            weedCrisis.decorationSpawnsDuringCrisis += 1
        }

        let patch = WeedPatch(removalCost: 500, source: source)
        activeWeeds.append(patch)
        weedCrisis.peakWeedCount = max(weedCrisis.peakWeedCount, activeWeeds.count)
        saveStats()
    }

    private func advanceWeedRemovalProgress() {
        guard let index = activeWeeds.firstIndex(where: { !$0.isCleared }) else { return }
        activeWeeds[index].habitsCompleted += 1
        if activeWeeds[index].isCleared {
            _ = withAnimation {
                activeWeeds.remove(at: index)
            }
            handleWeedQueueEmptied(clearedByHabits: true)
        }
        saveStats()
    }

    @discardableResult
    func removeFrontWeedWithCoins() -> Bool {
        guard let front = activeWeeds.first, coins >= front.removalCost else { return false }
        coinsAbziehen(
            amount: front.removalCost,
            beschreibung: NSLocalizedString("weed_popup_pay", comment: "")
        )
        _ = withAnimation {
            activeWeeds.removeFirst()
        }
        handleWeedQueueEmptied(clearedByHabits: false)
        saveStats()
        return true
    }

    private func handleWeedQueueEmptied(clearedByHabits: Bool, allowComeback: Bool = true) {
        if clearedByHabits {
            weedCrisis.weedsClearedByHabits += 1
        } else {
            weedCrisis.weedsClearedByCoins += 1
        }

        guard activeWeeds.isEmpty else { return }

        var preservedLastGranted = weedCrisis.lastComebackGrantedAt
        if allowComeback && ComebackBonusLogic.isEligible(crisis: weedCrisis) {
            grantComebackBoost()
            preservedLastGranted = Date()
        }
        weedCrisis = WeedCrisisState(lastComebackGrantedAt: preservedLastGranted)
    }

    private func applyZauberstabPowerUp(_ powerUp: PowerUpItem) {
        clearAllWeedsForShield(allowComeback: false)
        activateGardenPowerUp(powerUp, durationHours: GameConstants.zauberstabDurationHours)
        FeedbackManager.shared.playSuccess()
    }

    private func activateGardenPowerUp(_ powerUp: PowerUpItem, durationHours: Double) {
        activePowerUps.removeAll { !$0.isActive }
        let active = ActivePowerUp(
            id: UUID(),
            powerUpId: powerUp.id,
            appliedAt: Date(),
            durationHours: durationHours,
            targetPlantId: nil
        )
        withAnimation {
            activePowerUps.append(active)
        }
        saveStats()
    }

    private func clearFrontWeedForShield(allowComeback: Bool) {
        guard !activeWeeds.isEmpty else { return }
        _ = withAnimation {
            activeWeeds.removeFirst()
        }
        handleWeedQueueEmptied(clearedByHabits: true, allowComeback: allowComeback)
        saveStats()
    }

    private func clearAllWeedsForShield(allowComeback: Bool) {
        guard !activeWeeds.isEmpty else { return }
        withAnimation {
            activeWeeds.removeAll()
        }
        handleWeedQueueEmptied(clearedByHabits: false, allowComeback: allowComeback)
        saveStats()
    }

    /// Schutzschild-Ritual mit bereits aktivem Gartenschutz/Zauberstab (ohne Inventar-Verbrauch).
    func completeShieldRitualUsingActiveProtection() {
        if hasActivePowerUp(powerUpId: PowerUpWeedSupport.zauberstabID) {
            clearAllWeedsForShield(allowComeback: false)
        } else {
            clearFrontWeedForShield(allowComeback: false)
        }
        FeedbackManager.shared.playSuccess()
    }

    /// Nach Schutzschild-Ritual: Unkraut entfernen + Power-Up aktivieren.
    @discardableResult
    func applyWeedPowerUpAfterRitual(item: ShopDetailPayload) -> Bool {
        guard let powerUp = GameDatabase.allPowerUps.first(where: { $0.id == item.id }),
              PowerUpWeedSupport.isWeedPowerUp(item.id) else { return false }
        guard !hasActivePowerUp(powerUpId: item.id) else { return false }

        switch powerUp.id {
        case PowerUpWeedSupport.zauberstabID:
            clearAllWeedsForShield(allowComeback: false)
            activateGardenPowerUp(powerUp, durationHours: GameConstants.zauberstabDurationHours)
        case PowerUpWeedSupport.gartenschutzID:
            clearFrontWeedForShield(allowComeback: false)
            activateGardenPowerUp(powerUp, durationHours: powerUp.durationHours ?? 24)
        default:
            return false
        }

        itemVerbrauchen(shopItem: item)
        FeedbackManager.shared.playSuccess()
        return true
    }

    private func grantComebackBoost() {
        comebackBoostExpiresAt = Date().addingTimeInterval(
            GameConstants.comebackBoostDurationHours * 3600
        )
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            zeigeComebackBoostOverlay = true
        }
    }

    func refreshComebackBoostIfExpired() {
        guard let expires = comebackBoostExpiresAt, Date() >= expires else { return }
        comebackBoostExpiresAt = nil
    }

    private func loadWeedsFromStorage() {
        if let data = SharedUserDefaults.suite.data(forKey: "active_weeds"),
           let decoded = try? JSONDecoder().decode([WeedPatch].self, from: data) {
            activeWeeds = decoded.filter { !$0.isCleared }
        } else {
            activeWeeds = []
        }
    }

    func saveStats() {
        guard !isMock else { return }
        guard !isLoading else { return }
        SharedUserDefaults.suite.set(coins, forKey: "stats_coins")
        SharedUserDefaults.suite.set(gesamtXP, forKey: "stats_gesamt_xp")
        SharedUserDefaults.suite.set(leben, forKey: "stats_leben")
        SharedUserDefaults.suite.set(gluecksradDrehungen, forKey: "stats_gluecksrad_drehungen")
        SharedUserDefaults.suite.set(gesamtGekaufteItemsCount, forKey: "stats_gesamt_gekaufte_items_count")
        SharedUserDefaults.suite.set(gesamtGegossen, forKey: "stats_gesamt_gegossen")
        SharedUserDefaults.suite.set(tageAktiv, forKey: "stats_tage_aktiv")
        SharedUserDefaults.suite.set(gesamtVerdient, forKey: "stats_gesamt_verdient")
        SharedUserDefaults.suite.set(gesamtAusgegeben, forKey: "stats_gesamt_ausgegeben")
        SharedUserDefaults.suite.set(completed90DayChallenges, forKey: "stats_completed_90day_challenges")
        
        if let spinDate = lastSpinTimestamp {
            SharedUserDefaults.suite.set(spinDate.timeIntervalSince1970, forKey: "last_spin_timestamp_double")
        } else {
            SharedUserDefaults.suite.removeObject(forKey: "last_spin_timestamp_double")
        }
        
        SharedUserDefaults.suite.set(pendingDailySpin, forKey: "pending_daily_spin")
        if let encoded = try? JSONEncoder().encode(activeWeeds) {
            SharedUserDefaults.suite.set(encoded, forKey: "active_weeds")
            if activeWeeds.isEmpty {
                SharedUserDefaults.suite.removeObject(forKey: "is_weed_active")
            }
        } else {
            SharedUserDefaults.suite.removeObject(forKey: "active_weeds")
            SharedUserDefaults.suite.removeObject(forKey: "is_weed_active")
        }
        if let crisisData = try? JSONEncoder().encode(weedCrisis) {
            SharedUserDefaults.suite.set(crisisData, forKey: "weed_crisis_state")
        }
        if let expires = comebackBoostExpiresAt {
            SharedUserDefaults.suite.set(expires.timeIntervalSince1970, forKey: "comeback_boost_expires_at")
        } else {
            SharedUserDefaults.suite.removeObject(forKey: "comeback_boost_expires_at")
        }
        SharedUserDefaults.suite.set(seeds, forKey: "stats_seeds")
        
        if let skillData = try? JSONEncoder().encode(skillXP) {
            SharedUserDefaults.suite.set(skillData, forKey: "stats_skill_xp")
        }
        
        SharedUserDefaults.suite.synchronize()
        updateWidgetData()
    }
    
    func saveFocusSessions() {
        guard !isMock else { return }
        guard !isLoading else { return }
        if let encoded = try? JSONEncoder().encode(focusSessions) {
            SharedUserDefaults.suite.set(encoded, forKey: "stats_focus_sessions")
            SharedUserDefaults.suite.synchronize()
        }
    }

    private func loadStats() {
        isLoading = true
        defer { isLoading = false }
        
        coins = SharedUserDefaults.suite.object(forKey: "stats_coins") != nil ? SharedUserDefaults.suite.integer(forKey: "stats_coins") : GameConstants.startCoins
        gesamtXP = SharedUserDefaults.suite.integer(forKey: "stats_gesamt_xp")
        leben = SharedUserDefaults.suite.object(forKey: "stats_leben") != nil ? SharedUserDefaults.suite.integer(forKey: "stats_leben") : 5
        gluecksradDrehungen = SharedUserDefaults.suite.integer(forKey: "stats_gluecksrad_drehungen")
        gesamtGekaufteItemsCount = SharedUserDefaults.suite.integer(forKey: "stats_gesamt_gekaufte_items_count")
        gesamtGegossen = SharedUserDefaults.suite.integer(forKey: "stats_gesamt_gegossen")
        tageAktiv = SharedUserDefaults.suite.integer(forKey: "stats_tage_aktiv")
        gesamtVerdient = SharedUserDefaults.suite.integer(forKey: "stats_gesamt_verdient")
        gesamtAusgegeben = SharedUserDefaults.suite.integer(forKey: "stats_gesamt_ausgegeben")
        completed90DayChallenges = SharedUserDefaults.suite.integer(forKey: "stats_completed_90day_challenges")
        
        let spinDouble = SharedUserDefaults.suite.double(forKey: "last_spin_timestamp_double")
        if spinDouble > 0 {
            lastSpinTimestamp = Date(timeIntervalSince1970: spinDouble)
        } else {
            // Check fallback for old users
            lastSpinTimestamp = SharedUserDefaults.suite.object(forKey: "last_spin_timestamp") as? Date
        }
        
        pendingDailySpin = SharedUserDefaults.suite.bool(forKey: "pending_daily_spin")
        loadWeedsFromStorage()
        if let crisisData = SharedUserDefaults.suite.data(forKey: "weed_crisis_state"),
           let decodedCrisis = try? JSONDecoder().decode(WeedCrisisState.self, from: crisisData) {
            weedCrisis = decodedCrisis
        }
        let comebackExpiry = SharedUserDefaults.suite.double(forKey: "comeback_boost_expires_at")
        if comebackExpiry > 0 {
            comebackBoostExpiresAt = Date(timeIntervalSince1970: comebackExpiry)
        }
        refreshComebackBoostIfExpired()
        seeds = SharedUserDefaults.suite.integer(forKey: "stats_seeds")
        
        if let skillData = SharedUserDefaults.suite.data(forKey: "stats_skill_xp"),
           let decodedSkillXP = try? JSONDecoder().decode([String: Int].self, from: skillData) {
            skillXP = decodedSkillXP
        } else if skillXP.isEmpty {
            // Migration: Initialisiere aus vorhandenen Pflanzen
            migrateSkillXP()
        }
        
        if let focusData = SharedUserDefaults.suite.data(forKey: "stats_focus_sessions"),
           let decodedFocus = try? JSONDecoder().decode([FocusSessionLog].self, from: focusData) {
            focusSessions = decodedFocus
        }
    }
    
    private func migrateSkillXP() {
        var newXP: [String: Int] = [:]
        for pflanze in pflanzen {
            if let skill = SkillHelper.getSkill(for: pflanze) {
                let count = pflanze.wateringDates.count
                newXP[skill.rawValue, default: 0] += count * 10
            }
        }
        if !newXP.isEmpty {
            self.skillXP = newXP
            saveStats()
        }
    }

    func savePlants() {
        guard !isMock else { return }
        guard !isLoading else { return }
        if let encoded = try? JSONEncoder().encode(pflanzen) {
            SharedUserDefaults.suite.set(encoded, forKey: "garden_plants")
            SharedUserDefaults.suite.synchronize()
        }
        updateWidgetData()
    }

    func updateWidgetData() {
        guard !isMock else { return }
        let totalStreak = SharedUserDefaults.suite.integer(forKey: "streak_last_shown")
        let timestamps = SharedUserDefaults.suite.array(forKey: "streak_completed_dates") as? [TimeInterval] ?? []
        let dates = Set(timestamps.map { Date(timeIntervalSince1970: $0) })
        
        GroovyWidgetDataProvider.write(
            habits: pflanzen,
            totalStreak: totalStreak,
            gems: coins,
            streakCompletedDates: dates
        )
    }

    private func loadPlants() {
        isLoading = true
        defer { isLoading = false }
        
        if let data = SharedUserDefaults.suite.data(forKey: "garden_plants"),
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
            
            // Delete legacy custom screen time tracker if it exists
            if pflanzen.contains(where: { $0.id == "screen_time_tracker" }) {
                pflanzen.removeAll { $0.id == "screen_time_tracker" }
                savePlants()
            }
        } else {
            pflanzen = []
        }
    }

    func saveTransactions() {
        guard !isMock else { return }
        guard !isLoading else { return }
        if let encoded = try? JSONEncoder().encode(transactions) {
            SharedUserDefaults.suite.set(encoded, forKey: "garden_transactions")
            SharedUserDefaults.suite.synchronize()
        }
    }

    private func loadTransactions() {
        isLoading = true
        defer { isLoading = false }
        
        if let data = SharedUserDefaults.suite.data(forKey: "garden_transactions"),
           let decoded = try? JSONDecoder().decode([CoinTransaction].self, from: data) {
            transactions = decoded
        }
    }

    func saveInventory() {
        guard !isMock else { return }
        guard !isLoading else { return }
        if let encoded = try? JSONEncoder().encode(gekaufteItems) {
            SharedUserDefaults.suite.set(encoded, forKey: "garden_inventory")
            SharedUserDefaults.suite.synchronize()
        }
    }

    private func loadInventory() {
        isLoading = true
        defer { isLoading = false }
        
        if let data = SharedUserDefaults.suite.data(forKey: "garden_inventory"),
           let decoded = try? JSONDecoder().decode([ShopDetailPayload].self, from: data) {
            gekaufteItems = decoded
        }
    }

    func trackBadHabit(id: String, penaltyCoins: Int, triggers: [String]? = nil) {
        let execution = BadHabitExecution(date: Date(), coinsLost: penaltyCoins, triggers: triggers)
        badHabitExecutions[id, default: []].append(execution)
        
        // Automatisch eine Notiz mit den Auslösern speichern
        if let triggers = triggers, !triggers.isEmpty {
            let triggerList = triggers.joined(separator: ", ")
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            let dateStr = dateFormatter.string(from: Date())
            let noteText = "\(dateStr) – \(triggerList)"
            addBadHabitNote(id: id, text: noteText)
        }
        
        // Unkraut spawnen (Bestrafung für Rückfall)
        withAnimation {
            if let decoration = GameDatabase.allDecorations.first(where: { $0.id == id }) {
                spawnWeed(removalCost: decoration.price * GameConstants.weedRemovalCostMultiplier, source: .decoration)
            } else {
                spawnWeed(removalCost: 50, source: .decoration)
            }
        }
    }

    // MARK: - Bad Habit Notes
    @Published var badHabitNotes: [String: [String]] = [:] {
        didSet { saveBadHabitNotes() }
    }

    func addBadHabitNote(id: String, text: String) {
        badHabitNotes[id, default: []].append(text)
    }

    func updateBadHabitNote(id: String, index: Int, text: String) {
        guard var notes = badHabitNotes[id], index < notes.count else { return }
        notes[index] = text
        badHabitNotes[id] = notes
    }

    func deleteBadHabitNote(id: String, index: Int) {
        guard var notes = badHabitNotes[id], index < notes.count else { return }
        notes.remove(at: index)
        badHabitNotes[id] = notes
    }

    private func saveBadHabitNotes() {
        guard !isLoading else { return }
        if let encoded = try? JSONEncoder().encode(badHabitNotes) {
            SharedUserDefaults.suite.set(encoded, forKey: "badHabitNotes")
            SharedUserDefaults.suite.synchronize()
        }
    }

    private func loadBadHabitNotes() {
        if let data = SharedUserDefaults.suite.data(forKey: "badHabitNotes"),
           let decoded = try? JSONDecoder().decode([String: [String]].self, from: data) {
            badHabitNotes = decoded
        }
    }

    private func saveBadHabits() {
        guard !isMock else { return }
        guard !isLoading else { return }
        if let encoded = try? JSONEncoder().encode(badHabitExecutions) {
            SharedUserDefaults.suite.set(encoded, forKey: "badHabitExecutions")
            SharedUserDefaults.suite.synchronize()
        }
    }

    private func loadBadHabits() {
        isLoading = true
        defer { isLoading = false }
        
        if let saved = SharedUserDefaults.suite.data(forKey: "badHabitExecutions"),
           let decoded = try? JSONDecoder().decode([String: [BadHabitExecution]].self, from: saved) {
            self.badHabitExecutions = decoded
        }
    }
    
    private func saveCustomTriggers() {
        guard !isMock else { return }
        guard !isLoading else { return }
        if let encoded = try? JSONEncoder().encode(savedCustomTriggers) {
            SharedUserDefaults.suite.set(encoded, forKey: "savedCustomTriggers")
            SharedUserDefaults.suite.synchronize()
        }
    }
    
    private func loadCustomTriggers() {
        if let saved = SharedUserDefaults.suite.data(forKey: "savedCustomTriggers"),
           let decoded = try? JSONDecoder().decode([String].self, from: saved) {
            self.savedCustomTriggers = decoded
        }
    }

    private func updateTageAktiv() {
        isLoading = true
        defer { isLoading = false }
        
        let lastActiveKey = "last_active_date"
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastActive = SharedUserDefaults.suite.object(forKey: lastActiveKey) as? Date {
            let lastActiveDay = Calendar.current.startOfDay(for: lastActive)
            if lastActiveDay < today {
                tageAktiv += 1
                SharedUserDefaults.suite.set(today, forKey: lastActiveKey)
                SharedUserDefaults.suite.synchronize()
                saveStats()
            }
        } else {
            // Erstmaliger Start
            tageAktiv = 1
            SharedUserDefaults.suite.set(today, forKey: lastActiveKey)
            SharedUserDefaults.suite.synchronize()
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

            badHabitExecutions.removeAll()
            badHabitNotes.removeAll()
            skillXP.removeAll()
            
            lastSpinTimestamp = nil
            activeWeeds.removeAll()
            weedCrisis = WeedCrisisState()
            comebackBoostExpiresAt = nil
            zeigeComebackBoostOverlay = false
            
            let keys = [
                "garden_plants", "stats_coins", "stats_gesamt_xp", "stats_gesamt_streak",
                "stats_best_streak", "stats_gesamt_gekaufte_items_count",
                "stats_gesamt_gegossen", "stats_tage_aktiv", "stats_gesamt_verdient",
                "stats_gesamt_ausgegeben", "coin_transactions", "garden_transactions",
                "garden_inventory", "active_powerups_garden", "garden_decorations",
                "last_active_date", "last_spin_timestamp", "is_weed_active",
                "daily_quests_completed_since_weed", "active_weeds",
                "weed_removal_cost", "weed_spawn_date", "weed_crisis_state",
                "comeback_boost_expires_at", "abgeholtePassLevel",
                "stats_gluecksrad_drehungen", "daily_spin_last_shown_day_string",
                "badHabitExecutions", "badHabitNotes", "stats_skill_xp", "savedCustomTriggers"
            ]
            keys.forEach { SharedUserDefaults.suite.removeObject(forKey: $0) }
            
            // Set today as last active immediately after reset
            let today = Calendar.current.startOfDay(for: Date())
            SharedUserDefaults.suite.set(today, forKey: "last_active_date")
            
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
        
        let now = Date()
        var changed = false
        
        for pflanze in pflanzen {
            let hours = pflanze.hoursSinceThirstStarted
            
            // 72h window: 0-36 (OK), 36-72 (Warning), >72 (Death)
            var verpasst = 0
            if hours >= 72 {
                verpasst = 2
            } else if hours >= 36 {
                verpasst = 1
            }
            
            // Wächter-Turm (Sturmfest) Rettung vor dem sicheren Tod
            if verpasst >= 2 {
                if let tower = activePowerUps.first(where: { $0.powerUpId == "powerup.sturmfest" && $0.targetPlantId == pflanze.id && $0.isActive }) {
                    pflanze.letzteBewaesserung = now
                    verpasst = 0
                    activePowerUps.removeAll { $0.id == tower.id }
                    changed = true
                } else if pflanze.lastNotifiedCycle < 2 && !pflanze.isDead {
                    // Pflanze stirbt jetzt. Hat der Benutzer Wunder-Wasser?
                    let hasWunderWasser = gekaufteItems.contains(where: { $0.id == "powerup.wunder_wasser" })
                    if hasWunderWasser {
                        plantToRescue = pflanze
                        return // Logik unterbrechen, restliche Pflanzen warten auf den nächsten Lauf
                    } else {
                        // Pflanze stirbt final
                        pflanze.isDead = true
                        pflanze.missedCycles = 2
                        pflanze.lastNotifiedCycle = 2
                        pflanzeGestorben(pflanze)
                        
                        withAnimation {
                            spawnWeed(
                                removalCost: GameConstants.weedRemovalCostPlantDeath,
                                source: .plantDeath
                            )
                        }
                        changed = true
                    }
                }
            }
            
            if pflanze.missedCycles != verpasst {
                pflanze.missedCycles = verpasst
                changed = true
            }

            // Warnung (verpasst == 1)
            if verpasst == 1 && pflanze.lastNotifiedCycle < 1 {
                pflanze.lastNotifiedCycle = 1
                changed = true
            }
            
            // Reset Notification Cycle if watered
            if verpasst == 0 && pflanze.lastNotifiedCycle > 0 {
                pflanze.lastNotifiedCycle = 0
                changed = true
            }
        }
        
        if changed {
            savePlants()
            saveStats()
        }
    }

    func checkUngegossenePflanzen() {
        // Diese Funktion wird nun durch pruefePflanzenStatus ersetzt, 
        // die das neue 72h-Timer-System nutzt.
        pruefePflanzenStatus()
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

    // MARK: - Live Activity Management (Moved to FocusTimer)
    
    // MARK: - Screen Time Integration
    func checkScreenTimeExceeded() {
        let sharedDefaults = UserDefaults(suiteName: "group.com.jannik.grovy")
        guard sharedDefaults?.bool(forKey: "didExceedScreenTime") == true else { return }
        
        // Clear the flag immediately so we don't trigger twice
        sharedDefaults?.set(false, forKey: "didExceedScreenTime")
        sharedDefaults?.synchronize()
        
        let reason = sharedDefaults?.string(forKey: "screenTimeExceededReason") ?? "Bildschirmzeit-Limit überschritten"
        let habitID = "trash.junk_mail_abo" // DecorationItem ID für "Zu viel Bildschirmzeit"
        
        // Kaufe die schlechte Gewohnheit, falls noch nicht vorhanden
        let alreadyOwned = gekaufteItems.contains(where: { $0.id == habitID })
                        || placedDecorations.contains(where: { $0.id == habitID })
        
        if !alreadyOwned {
            if let decoration = GameDatabase.allDecorations.first(where: { $0.id == habitID }) {
                let shopItem = ShopDetailPayload.from(decoration: decoration)
                itemHinzufuegen(shopItem: shopItem, isFree: true)
            }
        }
        
        // Gewohnheit abgehakt: trackBadHabit, der Grund (z.B. meistgenutzte App) wird als Trigger gesetzt
        trackBadHabit(id: habitID, penaltyCoins: 0, triggers: [reason])
    }
}
