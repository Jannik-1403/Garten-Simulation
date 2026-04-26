import SwiftUI
import Combine

@MainActor
class AchievementStore: ObservableObject {
    @Published var alleErfolge: [Erfolg] = []
    
    private var gardenStore: GardenStore
    private var streakStore: StreakStore
    private var cancellables = Set<AnyCancellable>()
    private var unlockDates: [String: TimeInterval] = [:] {
        didSet {
            SharedUserDefaults.suite.set(unlockDates, forKey: "achievement_unlock_dates")
        }
    }
    
    init(gardenStore: GardenStore, streakStore: StreakStore) {
        self.gardenStore = gardenStore
        self.streakStore = streakStore
        self.unlockDates = SharedUserDefaults.suite.dictionary(forKey: "achievement_unlock_dates") as? [String: TimeInterval] ?? [:]
        
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
            
        refresh()
    }
    
    func refresh() {
        var updatedErfolge = [
            // STREAK
            Erfolg(id: "streak_7",
                   titelKey: "erfolg.erstewoche.name",
                   beschreibungKey: "erfolg.erstewoche.beschreibung",
                   sfSymbol: "flame.fill",
                   farbe: Color(hex: "#FF6B35"),
                   zielWert: 7,
                   aktuellerWert: streakStore.currentStreak,
                   kategorie: .streak,
                   imageName: "Erste Woche"),
            
            Erfolg(id: "streak_100",
                   titelKey: "erfolg.legende.name",
                   beschreibungKey: "erfolg.legende.beschreibung",
                   sfSymbol: "crown.fill",
                   farbe: Color(hex: "#FFD700"),
                   zielWert: 100,
                   aktuellerWert: streakStore.currentStreak,
                   kategorie: .streak,
                   imageName: "Legende"),
            
            Erfolg(id: "streak_365",
                   titelKey: "erfolg.jahresring.name",
                   beschreibungKey: "erfolg.jahresring.beschreibung",
                   sfSymbol: "sun.max.fill",
                   farbe: Color(hex: "#FF9500"),
                   zielWert: 365,
                   aktuellerWert: streakStore.currentStreak,
                   kategorie: .streak,
                   imageName: "Jahresring"),
            
            // GARTEN
            Erfolg(id: "giessen_100",
                   titelKey: "erfolg.wassermeister.name",
                   beschreibungKey: "erfolg.wassermeister.beschreibung",
                   sfSymbol: "drop.fill",
                   farbe: Color(hex: "#007AFF"),
                   zielWert: 100,
                   aktuellerWert: gardenStore.gesamtGegossen,
                   kategorie: .garten,
                   imageName: "Wassermann"),
            
            Erfolg(id: "xp_500",
                   titelKey: "erfolg.xpsammler.name",
                   beschreibungKey: "erfolg.xpsammler.beschreibung",
                   sfSymbol: "star.fill",
                   farbe: Color(hex: "#FF9F0A"),
                   zielWert: 500,
                   aktuellerWert: gardenStore.gesamtXP,
                   kategorie: .garten,
                   imageName: "XP-Sammler"),
            
            // SAMMLER
            Erfolg(id: "pflanzen_1",
                   titelKey: "erfolg.ersterpflanze.name",
                   beschreibungKey: "erfolg.ersterpflanze.beschreibung",
                   sfSymbol: "leaf.fill",
                   farbe: Color(hex: "#34C759"),
                   zielWert: 1,
                   aktuellerWert: gardenStore.pflanzen.count,
                   kategorie: .sammler,
                   imageName: "ErstePflanze"),
            
            Erfolg(id: "pflanzen_3",
                   titelKey: "erfolg.pflanzensammler.name",
                   beschreibungKey: "erfolg.pflanzensammler.beschreibung",
                   sfSymbol: "leaf.fill",
                   farbe: Color(hex: "#34C759"),
                   zielWert: 3,
                   aktuellerWert: gardenStore.pflanzen.count,
                   kategorie: .sammler,
                   imageName: "Pflanzensammler"),
            
            Erfolg(id: "pflanzen_10",
                   titelKey: "erfolg.gruenerDaumen.name",
                   beschreibungKey: "erfolg.gruenerDaumen.beschreibung",
                   sfSymbol: "leaf.fill",
                   farbe: Color(hex: "#248A3D"),
                   zielWert: 10,
                   aktuellerWert: gardenStore.pflanzen.count,
                   kategorie: .sammler,
                   imageName: "Grünerdaumen"),
            
            Erfolg(id: "pflanzen_20",
                   titelKey: "erfolg.gartenprofi.name",
                   beschreibungKey: "erfolg.gartenprofi.beschreibung",
                   sfSymbol: "diamond.fill",
                   farbe: Color(hex: "#1A9FE0"),
                   zielWert: 20,
                   aktuellerWert: gardenStore.pflanzen.count,
                   kategorie: .sammler,
                   imageName: "Gartenprofil"),
            
            // SHOP / COINS
            Erfolg(id: "coins_1",
                   titelKey: "erfolg.ersteMuenze.name",
                   beschreibungKey: "erfolg.ersteMuenze.beschreibung",
                   sfSymbol: "dollarsign.circle.fill",
                   farbe: Color(hex: "#FFD60A"),
                   zielWert: 1,
                   aktuellerWert: gardenStore.gesamtVerdient,
                   kategorie: .shop,
                   imageName: "ErsteMünze"),
            
            Erfolg(id: "coins_50",
                   titelKey: "erfolg.muenzmeister.name",
                   beschreibungKey: "erfolg.muenzmeister.beschreibung",
                   sfSymbol: "dollarsign.circle.fill",
                   farbe: Color(hex: "#FFD60A"),
                   zielWert: 50,
                   aktuellerWert: gardenStore.gesamtVerdient,
                   kategorie: .shop,
                   imageName: "Münzmeister"),
            
            Erfolg(id: "ersterkauf",
                   titelKey: "erfolg.ersterkauf.name",
                   beschreibungKey: "erfolg.ersterkauf.beschreibung",
                   sfSymbol: "cart.fill",
                   farbe: Color(hex: "#AF52DE"),
                   zielWert: 1,
                   aktuellerWert: gardenStore.gekauftePflanzenAnzahl,
                   kategorie: .shop,
                   imageName: "ErsterEinkauf"),
        ]
        
        // Apply persisted dates
        for i in 0..<updatedErfolge.count {
            let id = updatedErfolge[i].id
            if updatedErfolge[i].istFreigeschaltet {
                if let timestamp = unlockDates[id] {
                    updatedErfolge[i].freigeschaltetAm = Date(timeIntervalSince1970: timestamp)
                } else {
                    let now = Date()
                    unlockDates[id] = now.timeIntervalSince1970
                    updatedErfolge[i].freigeschaltetAm = now
                }
            }
        }
        
        self.alleErfolge = updatedErfolge
    }
}
