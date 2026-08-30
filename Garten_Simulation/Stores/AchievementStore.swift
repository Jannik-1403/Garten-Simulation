import SwiftUI
import Combine

struct AchievementConfig {
    let key: String
    let titleKey: String
    let baseDescriptionKey: String
    let sfSymbol: String
    let farbe: Color
    let kategorie: ErfolgKategorie
    let imageName: String
    let targets: [Int] // Size 5 for Bronze, Silber, Gold, Diamant, Master
}

@MainActor
class AchievementStore: ObservableObject {
    @Published var alleErfolge: [Erfolg] = []
    
    // Kept for backup/export manager compatibility
    @Published var achievementTiers: [String: Int] = [:]
    
    private var gardenStore: GardenStore
    private var streakStore: StreakStore
    private var cancellables = Set<AnyCancellable>()
    
    private let configs: [AchievementConfig] = [
        AchievementConfig(
            key: "pflanzen",
            titleKey: "erfolg.pflanzen.name",
            baseDescriptionKey: "erfolg.pflanzen.tier",
            sfSymbol: "leaf.fill",
            farbe: Color(hex: "#34C759"),
            kategorie: .sammler,
            imageName: "ErstePflanze",
            targets: [1, 3, 5, 10, 19]
        ),
        AchievementConfig(
            key: "streak",
            titleKey: "erfolg.streak.name",
            baseDescriptionKey: "erfolg.streak.tier",
            sfSymbol: "flame.fill",
            farbe: Color(hex: "#FF6B35"),
            kategorie: .streak,
            imageName: "Erste Woche",
            targets: [3, 7, 14, 30, 100]
        ),
        AchievementConfig(
            key: "giessen",
            titleKey: "erfolg.giessen.name",
            baseDescriptionKey: "erfolg.giessen.tier",
            sfSymbol: "drop.fill",
            farbe: Color(hex: "#007AFF"),
            kategorie: .garten,
            imageName: "Wassermann",
            targets: [5, 15, 50, 150, 1000]
        ),
        AchievementConfig(
            key: "xp",
            titleKey: "erfolg.xp.name",
            baseDescriptionKey: "erfolg.xp.tier",
            sfSymbol: "star.fill",
            farbe: Color(hex: "#FF9F0A"),
            kategorie: .garten,
            imageName: "XP-Sammler",
            targets: [100, 250, 500, 1000, 10000]
        ),
        AchievementConfig(
            key: "coins",
            titleKey: "erfolg.coins.name",
            baseDescriptionKey: "erfolg.coins.tier",
            sfSymbol: "dollarsign.circle.fill",
            farbe: Color(hex: "#FFD60A"),
            kategorie: .shop,
            imageName: "ErsteMünze",
            targets: [50, 150, 500, 1000, 10000]
        ),
        AchievementConfig(
            key: "kauf",
            titleKey: "erfolg.kauf.name",
            baseDescriptionKey: "erfolg.kauf.tier",
            sfSymbol: "cart.fill",
            farbe: Color(hex: "#AF52DE"),
            kategorie: .shop,
            imageName: "ErsterEinkauf",
            targets: [1, 3, 7, 15, 48]
        ),
        AchievementConfig(
            key: "challenge",
            titleKey: "erfolg.challenge.name",
            baseDescriptionKey: "erfolg.challenge.tier",
            sfSymbol: "star.circle.fill",
            farbe: Color(hex: "#FF2D55"),
            kategorie: .garten,
            imageName: "Meilenstein",
            targets: [1, 3, 5, 10, 25]
        )
    ]
    
    init(gardenStore: GardenStore, streakStore: StreakStore) {
        self.gardenStore = gardenStore
        self.streakStore = streakStore
        
        // Observe relevant changes in GardenStore to refresh achievements
        gardenStore.$gesamtXP
            .sink { [weak self] _ in self?.refresh() }
            .store(in: &cancellables)
            
        gardenStore.$coins
            .sink { [weak self] _ in self?.refresh() }
            .store(in: &cancellables)
            
        gardenStore.$gesamtGegossen
            .sink { [weak self] _ in self?.refresh() }
            .store(in: &cancellables)
            
        gardenStore.$tageAktiv
            .sink { [weak self] _ in self?.refresh() }
            .store(in: &cancellables)
            
        gardenStore.$pflanzen
            .sink { [weak self] _ in self?.refresh() }
            .store(in: &cancellables)
            
        streakStore.$currentStreak
            .sink { [weak self] _ in self?.refresh() }
            .store(in: &cancellables)
            
        gardenStore.$gesamtVerdient
            .sink { [weak self] _ in self?.refresh() }
            .store(in: &cancellables)
            
        gardenStore.$gesamtGekaufteItemsCount
            .sink { [weak self] _ in self?.refresh() }
            .store(in: &cancellables)
            
        gardenStore.$gekaufteItems
            .sink { [weak self] _ in self?.refresh() }
            .store(in: &cancellables)
            
        gardenStore.$placedDecorations
            .sink { [weak self] _ in self?.refresh() }
            .store(in: &cancellables)
            
        gardenStore.$completed90DayChallenges
            .sink { [weak self] _ in self?.refresh() }
            .store(in: &cancellables)
            
        refresh()
    }
    
    func valueForAchievement(key: String) -> Int {
        switch key {
        case "pflanzen":
            return gardenStore.pflanzen.count
        case "streak":
            return streakStore.currentStreak
        case "giessen":
            return gardenStore.gesamtGegossen
        case "xp":
            return gardenStore.gesamtXP
        case "coins":
            return max(gardenStore.gesamtVerdient, gardenStore.coins)
        case "kauf":
            return gardenStore.totalItemsCount
        case "challenge":
            return gardenStore.completed90DayChallenges
        default:
            return 0
        }
    }
    
    // Obsolete in automatic progression mode, but kept for compilation safety
    func upgradeAchievement(key: String) {}
    
    func refresh() {
        var updatedErfolge: [Erfolg] = []
        var dates = SharedUserDefaults.suite.dictionary(forKey: "achievement_unlock_dates_v2") as? [String: TimeInterval] ?? [:]
        var datesChanged = false
        var computedTiers: [String: Int] = [:]
        
        for config in configs {
            let currentVal = valueForAchievement(key: config.key)
            
            // Determine active/completed tier dynamically
            var activeTier: ErfolgTier = .bronze
            var nextTarget = config.targets[0]
            var isMax = false
            var isFreigeschaltet = false
            
            if currentVal >= config.targets[4] { // Completed Master
                activeTier = .master
                nextTarget = config.targets[4]
                isMax = true
                isFreigeschaltet = true
                
                if dates["\(config.key)_tier_4"] == nil {
                    dates["\(config.key)_tier_4"] = Date().timeIntervalSince1970
                    datesChanged = true
                }
            } else if currentVal >= config.targets[3] { // Completed Diamant, working towards Master
                activeTier = .diamant
                nextTarget = config.targets[4]
                isFreigeschaltet = true
                
                if dates["\(config.key)_tier_3"] == nil {
                    dates["\(config.key)_tier_3"] = Date().timeIntervalSince1970
                    datesChanged = true
                }
            } else if currentVal >= config.targets[2] { // Completed Gold, working towards Diamant
                activeTier = .gold
                nextTarget = config.targets[3]
                isFreigeschaltet = true
                
                if dates["\(config.key)_tier_2"] == nil {
                    dates["\(config.key)_tier_2"] = Date().timeIntervalSince1970
                    datesChanged = true
                }
            } else if currentVal >= config.targets[1] { // Completed Silver, working towards Gold
                activeTier = .silber
                nextTarget = config.targets[2]
                isFreigeschaltet = true
                
                if dates["\(config.key)_tier_1"] == nil {
                    dates["\(config.key)_tier_1"] = Date().timeIntervalSince1970
                    datesChanged = true
                }
            } else if currentVal >= config.targets[0] { // Completed Bronze, working towards Silver
                activeTier = .bronze
                nextTarget = config.targets[1]
                isFreigeschaltet = true
                
                if dates["\(config.key)_tier_0"] == nil {
                    dates["\(config.key)_tier_0"] = Date().timeIntervalSince1970
                    datesChanged = true
                }
            } else {
                // Not even Bronze completed yet
                activeTier = .bronze
                nextTarget = config.targets[0]
                isFreigeschaltet = false
            }
            
            computedTiers[config.key] = isMax ? 5 : (isFreigeschaltet ? activeTier.rawValue + 1 : 0)
            
            // Unlocked Date extraction
            var freigeschaltetAm: Date? = nil
            if isMax {
                if let ts = dates["\(config.key)_tier_4"] {
                    freigeschaltetAm = Date(timeIntervalSince1970: ts)
                }
            } else {
                let completedTierIndex: Int
                if currentVal >= config.targets[3] { completedTierIndex = 3 }
                else if currentVal >= config.targets[2] { completedTierIndex = 2 }
                else if currentVal >= config.targets[1] { completedTierIndex = 1 }
                else if currentVal >= config.targets[0] { completedTierIndex = 0 }
                else { completedTierIndex = -1 }
                
                if completedTierIndex >= 0 {
                    if let ts = dates["\(config.key)_tier_\(completedTierIndex)"] {
                        freigeschaltetAm = Date(timeIntervalSince1970: ts)
                    }
                }
            }
            
            // Description index matches active target they are working towards
            let descIndex: Int
            if isMax { descIndex = 4 }
            else if currentVal >= config.targets[3] { descIndex = 4 }
            else if currentVal >= config.targets[2] { descIndex = 3 }
            else if currentVal >= config.targets[1] { descIndex = 2 }
            else if currentVal >= config.targets[0] { descIndex = 1 }
            else { descIndex = 0 }
            
            let descKey = "\(config.baseDescriptionKey)\(descIndex)"
            
            let e = Erfolg(
                id: config.key,
                titelKey: config.titleKey,
                beschreibungKey: descKey,
                sfSymbol: config.sfSymbol,
                farbe: config.farbe,
                zielWert: nextTarget,
                aktuellerWert: currentVal,
                kategorie: config.kategorie,
                imageName: config.imageName,
                tier: isMax ? .max : activeTier,
                freigeschaltet: isFreigeschaltet,
                freigeschaltetAm: freigeschaltetAm
            )
            updatedErfolge.append(e)
        }
        
        if datesChanged {
            SharedUserDefaults.suite.set(dates, forKey: "achievement_unlock_dates_v2")
        }
        
        self.achievementTiers = computedTiers
        self.alleErfolge = updatedErfolge
    }
    
    func reset() {
        SharedUserDefaults.suite.removeObject(forKey: "achievement_unlock_dates_v2")
        self.achievementTiers = [:]
        self.refresh()
    }
}
