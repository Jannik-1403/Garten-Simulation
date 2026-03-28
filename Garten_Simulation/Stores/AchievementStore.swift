import SwiftUI
import Combine

@MainActor
class AchievementStore: ObservableObject {
    @Published var alleErfolge: [ErfolgModel] = []
    
    private var gardenStore: GardenStore?
    private var cancellables = Set<AnyCancellable>()
    
    init(gardenStore: GardenStore) {
        self.gardenStore = gardenStore
        self.alleErfolge = ErfolgModel.platzhalterErfolge // Load base templates
        
        // Initial Refresh
        refreshProgress()
        
        // Observe GardenStore for changes to update progress
        gardenStore.$gesamtXP
            .sink { [weak self] _ in self?.refreshProgress() }
            .store(in: &cancellables)
            
        gardenStore.$coins
            .sink { [weak self] _ in self?.refreshProgress() }
            .store(in: &cancellables)
            
        gardenStore.$pflanzen
            .sink { [weak self] _ in self?.refreshProgress() }
            .store(in: &cancellables)

        gardenStore.$gesamtStreak
            .sink { [weak self] _ in self?.refreshProgress() }
            .store(in: &cancellables)
    }
    
    func refreshProgress() {
        guard let garden = gardenStore else { return }
        
        var updated = [ErfolgModel]()
        
        for base in ErfolgModel.platzhalterErfolge {
            var aktuellValue = 0
            
            switch base.kategorie {
            case .streak:
                aktuellValue = garden.gesamtStreak
            case .coins:
                aktuellValue = garden.gesamtVerdient
            case .seltenheit:
                // Historically used for plant count in the template
                aktuellValue = garden.pflanzen.count
            case .gewohnheit:
                // Since we don't have a history for "Early Bird" yet, we keep it at 0
                aktuellValue = 0 
            }
            
            // Check if it's unlocked now
            let freigeschaltetAm = (aktuellValue >= base.ziel) ? (base.freigeschaltetAm ?? Date()) : nil
            
            let model = ErfolgModel(
                id: base.id,
                titel: base.titel,
                beschreibung: base.beschreibung,
                icon: base.icon,
                farbe: base.farbe,
                kategorie: base.kategorie,
                ziel: base.ziel,
                aktuell: aktuellValue,
                freigeschaltetAm: freigeschaltetAm
            )
            updated.append(model)
        }
        
        self.alleErfolge = updated
    }
    
    var freigeschalteteErfolge: [ErfolgModel] {
        alleErfolge.filter { $0.istFreigeschaltet }
    }
}
