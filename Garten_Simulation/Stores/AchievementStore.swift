import SwiftUI
import Combine

@MainActor
class AchievementStore: ObservableObject {
    @Published var alleErfolge: [Erfolg] = []
    
    private var gardenStore: GardenStore
    private var cancellables = Set<AnyCancellable>()
    
    init(gardenStore: GardenStore) {
        self.gardenStore = gardenStore
        
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
            
        gardenStore.$gesamtStreak
            .sink { [weak self] _ in self?.refresh() }
            .store(in: &cancellables)
            
        gardenStore.$gesamtVerdient
            .sink { [weak self] _ in self?.refresh() }
            .store(in: &cancellables)
            
        refresh()
    }
    
    func refresh() {
        self.alleErfolge = [
            // STREAK
            Erfolg(id: "streak_7",
                   titelKey: "erfolg.erstewoche.name",
                   beschreibungKey: "erfolg.erstewoche.beschreibung",
                   sfSymbol: "flame.fill",
                   farbe: Color(hex: "#FF6B35"),
                   zielWert: 7,
                   aktuellerWert: gardenStore.gesamtStreak,
                   kategorie: .streak),
            
            Erfolg(id: "streak_30",
                   titelKey: "erfolg.monatsstreaker.name",
                   beschreibungKey: "erfolg.monatsstreaker.beschreibung",
                   sfSymbol: "flame.fill",
                   farbe: Color(hex: "#FF3B00"),
                   zielWert: 30,
                   aktuellerWert: gardenStore.gesamtStreak,
                   kategorie: .streak),
            
            Erfolg(id: "streak_100",
                   titelKey: "erfolg.legende.name",
                   beschreibungKey: "erfolg.legende.beschreibung",
                   sfSymbol: "crown.fill",
                   farbe: Color(hex: "#FFD700"),
                   zielWert: 100,
                   aktuellerWert: gardenStore.gesamtStreak,
                   kategorie: .streak),
            
            Erfolg(id: "streak_365",
                   titelKey: "erfolg.jahresring.name",
                   beschreibungKey: "erfolg.jahresring.beschreibung",
                   sfSymbol: "sun.max.fill",
                   farbe: Color(hex: "#FF9500"),
                   zielWert: 365,
                   aktuellerWert: gardenStore.gesamtStreak,
                   kategorie: .streak),
            
            // GARTEN
            Erfolg(id: "giessen_1",
                   titelKey: "erfolg.erstergaertner.name",
                   beschreibungKey: "erfolg.erstergaertner.beschreibung",
                   sfSymbol: "drop.fill",
                   farbe: Color(hex: "#34C0EB"),
                   zielWert: 1,
                   aktuellerWert: gardenStore.gesamtGegossen,
                   kategorie: .garten),
            
            Erfolg(id: "giessen_100",
                   titelKey: "erfolg.wassermeister.name",
                   beschreibungKey: "erfolg.wassermeister.beschreibung",
                   sfSymbol: "drop.fill",
                   farbe: Color(hex: "#007AFF"),
                   zielWert: 100,
                   aktuellerWert: gardenStore.gesamtGegossen,
                   kategorie: .garten),
            
            Erfolg(id: "xp_5", // Use small value for "First XP"
                   titelKey: "erfolg.erstexp.name",
                   beschreibungKey: "erfolg.erstexp.beschreibung",
                   sfSymbol: "star.fill",
                   farbe: Color(hex: "#FFCC00"),
                   zielWert: 5,
                   aktuellerWert: gardenStore.gesamtXP,
                   kategorie: .garten),
            
            Erfolg(id: "xp_500",
                   titelKey: "erfolg.xpsammler.name",
                   beschreibungKey: "erfolg.xpsammler.beschreibung",
                   sfSymbol: "star.fill",
                   farbe: Color(hex: "#FF9F0A"),
                   zielWert: 500,
                   aktuellerWert: gardenStore.gesamtXP,
                   kategorie: .garten),
            
            // SAMMLER
            Erfolg(id: "pflanzen_1",
                   titelKey: "erfolg.ersterpflanze.name",
                   beschreibungKey: "erfolg.ersterpflanze.beschreibung",
                   sfSymbol: "leaf.fill",
                   farbe: Color(hex: "#34C759"),
                   zielWert: 1,
                   aktuellerWert: gardenStore.pflanzen.count,
                   kategorie: .sammler),
            
            Erfolg(id: "pflanzen_3",
                   titelKey: "erfolg.pflanzensammler.name",
                   beschreibungKey: "erfolg.pflanzensammler.beschreibung",
                   sfSymbol: "leaf.fill",
                   farbe: Color(hex: "#34C759"),
                   zielWert: 3,
                   aktuellerWert: gardenStore.pflanzen.count,
                   kategorie: .sammler),
            
            Erfolg(id: "pflanzen_10",
                   titelKey: "erfolg.gruenerDaumen.name",
                   beschreibungKey: "erfolg.gruenerDaumen.beschreibung",
                   sfSymbol: "leaf.fill",
                   farbe: Color(hex: "#248A3D"),
                   zielWert: 10,
                   aktuellerWert: gardenStore.pflanzen.count,
                   kategorie: .sammler),
            
            Erfolg(id: "pflanzen_20",
                   titelKey: "erfolg.gartenprofi.name",
                   beschreibungKey: "erfolg.gartenprofi.beschreibung",
                   sfSymbol: "diamond.fill",
                   farbe: Color(hex: "#1A9FE0"),
                   zielWert: 20,
                   aktuellerWert: gardenStore.pflanzen.count,
                   kategorie: .sammler),
            
            // SHOP / COINS
            Erfolg(id: "coins_1",
                   titelKey: "erfolg.ersteMuenze.name",
                   beschreibungKey: "erfolg.ersteMuenze.beschreibung",
                   sfSymbol: "dollarsign.circle.fill",
                   farbe: Color(hex: "#FFD60A"),
                   zielWert: 1,
                   aktuellerWert: gardenStore.gesamtVerdient,
                   kategorie: .shop),
            
            Erfolg(id: "coins_50",
                   titelKey: "erfolg.muenzmeister.name",
                   beschreibungKey: "erfolg.muenzmeister.beschreibung",
                   sfSymbol: "dollarsign.circle.fill",
                   farbe: Color(hex: "#FFD60A"),
                   zielWert: 50,
                   aktuellerWert: gardenStore.gesamtVerdient,
                   kategorie: .shop),
            
            Erfolg(id: "coins_500",
                   titelKey: "erfolg.reichtumssammler.name",
                   beschreibungKey: "erfolg.reichtumssammler.beschreibung",
                   sfSymbol: "dollarsign.circle.fill",
                   farbe: Color(hex: "#FFD60A"),
                   zielWert: 500,
                   aktuellerWert: gardenStore.gesamtVerdient,
                   kategorie: .shop),
            
            Erfolg(id: "ersterkauf",
                   titelKey: "erfolg.ersterkauf.name",
                   beschreibungKey: "erfolg.ersterkauf.beschreibung",
                   sfSymbol: "cart.fill",
                   farbe: Color(hex: "#AF52DE"),
                   zielWert: 1,
                   aktuellerWert: gardenStore.gekauftePflanzenAnzahl,
                   kategorie: .shop),
        ]
    }
}
