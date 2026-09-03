import Foundation
import HealthKit
import Combine

struct NutrientItem: Identifiable, Codable {
    let id: UUID
    var name: String
    let hkTypeIdentifier: String
    var targetDGE: Double
    var unitString: String
    var currentValue: Double = 0.0
    var isEnabled: Bool = true
    
    var hkType: HKQuantityTypeIdentifier {
        HKQuantityTypeIdentifier(rawValue: hkTypeIdentifier)
    }
    
    var unit: HKUnit {
        HKUnit(from: unitString)
    }
    
    var score: Double {
        guard targetDGE > 0 else { return 0 }
        return min((currentValue / targetDGE) * 100.0, 100.0)
    }
}

class NutrientIndexManager: ObservableObject {
    static let shared = NutrientIndexManager()
    let healthStore = HKHealthStore()
    
    @Published var vitamins: [NutrientItem] = []
    @Published var minerals: [NutrientItem] = []
    @Published var fiber: NutrientItem
    
    private let defaultsKey = "NutrientIndexSettings"
    
    init() {
        // Init default fiber
        self.fiber = NutrientItem(id: UUID(), name: "Ballaststoffe", hkTypeIdentifier: HKQuantityTypeIdentifier.dietaryFiber.rawValue, targetDGE: 30.0, unitString: String(localized: "unit.g", defaultValue: "g"))
        
        loadSettings()
    }
    
    private func loadSettings() {
        let defVitamins = defaultVitamins()
        let defMinerals = defaultMinerals()
        let defFiber = defaultFiber()
        
        if let data = UserDefaults.standard.data(forKey: defaultsKey),
           let savedState = try? JSONDecoder().decode([String: [NutrientItem]].self, from: data) {
            
            var loadedVits = savedState["vitamins"] ?? defVitamins
            for i in loadedVits.indices {
                if let match = defVitamins.first(where: { $0.hkTypeIdentifier == loadedVits[i].hkTypeIdentifier }) {
                    loadedVits[i].name = match.name
                    loadedVits[i].unitString = match.unitString
                }
            }
            self.vitamins = loadedVits
            
            var loadedMins = savedState["minerals"] ?? defMinerals
            for i in loadedMins.indices {
                if let match = defMinerals.first(where: { $0.hkTypeIdentifier == loadedMins[i].hkTypeIdentifier }) {
                    loadedMins[i].name = match.name
                    loadedMins[i].unitString = match.unitString
                }
            }
            self.minerals = loadedMins
            
            var loadedFiber = savedState["fiber"]?.first ?? defFiber
            loadedFiber.name = defFiber.name
            loadedFiber.unitString = defFiber.unitString
            self.fiber = loadedFiber
            
        } else {
            self.vitamins = defVitamins
            self.minerals = defMinerals
            self.fiber = defFiber
        }
    }
    
    func saveSettings() {
        let state: [String: [NutrientItem]] = [
            "vitamins": vitamins,
            "minerals": minerals,
            "fiber": [fiber]
        ]
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
        objectWillChange.send()
    }
    
    
    private func defaultVitamins() -> [NutrientItem] {
        [
            NutrientItem(id: UUID(), name: String(localized: "nutrient.vitamin_c", defaultValue: "Vitamin C"), hkTypeIdentifier: HKQuantityTypeIdentifier.dietaryVitaminC.rawValue, targetDGE: 110.0, unitString: String(localized: "unit.mg", defaultValue: "mg")),
            NutrientItem(id: UUID(), name: String(localized: "nutrient.vitamin_a", defaultValue: "Vitamin A"), hkTypeIdentifier: HKQuantityTypeIdentifier.dietaryVitaminA.rawValue, targetDGE: 1000.0, unitString: String(localized: "unit.mcg", defaultValue: "µg")),
            NutrientItem(id: UUID(), name: String(localized: "nutrient.folate", defaultValue: "Folsäure"), hkTypeIdentifier: HKQuantityTypeIdentifier.dietaryFolate.rawValue, targetDGE: 300.0, unitString: String(localized: "unit.mcg", defaultValue: "µg")),
            NutrientItem(id: UUID(), name: String(localized: "nutrient.vitamin_k", defaultValue: "Vitamin K"), hkTypeIdentifier: HKQuantityTypeIdentifier.dietaryVitaminK.rawValue, targetDGE: 70.0, unitString: String(localized: "unit.mcg", defaultValue: "µg")),
            NutrientItem(id: UUID(), name: String(localized: "nutrient.vitamin_b1", defaultValue: "Vitamin B1 (Thiamin)"), hkTypeIdentifier: HKQuantityTypeIdentifier.dietaryThiamin.rawValue, targetDGE: 1.2, unitString: String(localized: "unit.mg", defaultValue: "mg")),
            NutrientItem(id: UUID(), name: String(localized: "nutrient.vitamin_b2", defaultValue: "Vitamin B2 (Riboflavin)"), hkTypeIdentifier: HKQuantityTypeIdentifier.dietaryRiboflavin.rawValue, targetDGE: 1.4, unitString: String(localized: "unit.mg", defaultValue: "mg")),
            NutrientItem(id: UUID(), name: String(localized: "nutrient.vitamin_b3", defaultValue: "Vitamin B3 (Niacin)"), hkTypeIdentifier: HKQuantityTypeIdentifier.dietaryNiacin.rawValue, targetDGE: 15.0, unitString: String(localized: "unit.mg", defaultValue: "mg")),
            NutrientItem(id: UUID(), name: String(localized: "nutrient.vitamin_b5", defaultValue: "Vitamin B5 (Pantothensäure)"), hkTypeIdentifier: HKQuantityTypeIdentifier.dietaryPantothenicAcid.rawValue, targetDGE: 5.0, unitString: String(localized: "unit.mg", defaultValue: "mg")),
            NutrientItem(id: UUID(), name: String(localized: "nutrient.vitamin_b6", defaultValue: "Vitamin B6"), hkTypeIdentifier: HKQuantityTypeIdentifier.dietaryVitaminB6.rawValue, targetDGE: 1.6, unitString: String(localized: "unit.mg", defaultValue: "mg")),
            NutrientItem(id: UUID(), name: String(localized: "nutrient.vitamin_b7", defaultValue: "Vitamin B7 (Biotin)"), hkTypeIdentifier: HKQuantityTypeIdentifier.dietaryBiotin.rawValue, targetDGE: 40.0, unitString: String(localized: "unit.mcg", defaultValue: "µg")),
            NutrientItem(id: UUID(), name: String(localized: "nutrient.vitamin_b12", defaultValue: "Vitamin B12"), hkTypeIdentifier: HKQuantityTypeIdentifier.dietaryVitaminB12.rawValue, targetDGE: 4.0, unitString: String(localized: "unit.mcg", defaultValue: "µg")),
            NutrientItem(id: UUID(), name: String(localized: "nutrient.vitamin_d", defaultValue: "Vitamin D"), hkTypeIdentifier: HKQuantityTypeIdentifier.dietaryVitaminD.rawValue, targetDGE: 20.0, unitString: String(localized: "unit.mcg", defaultValue: "µg")),
            NutrientItem(id: UUID(), name: String(localized: "nutrient.vitamin_e", defaultValue: "Vitamin E"), hkTypeIdentifier: HKQuantityTypeIdentifier.dietaryVitaminE.rawValue, targetDGE: 14.0, unitString: String(localized: "unit.mg", defaultValue: "mg"))
        ]
    }
    
    private func defaultMinerals() -> [NutrientItem] {
        [
            NutrientItem(id: UUID(), name: String(localized: "nutrient.potassium", defaultValue: "Kalium"), hkTypeIdentifier: HKQuantityTypeIdentifier.dietaryPotassium.rawValue, targetDGE: 4000.0, unitString: String(localized: "unit.mg", defaultValue: "mg")),
            NutrientItem(id: UUID(), name: String(localized: "nutrient.magnesium", defaultValue: "Magnesium"), hkTypeIdentifier: HKQuantityTypeIdentifier.dietaryMagnesium.rawValue, targetDGE: 350.0, unitString: String(localized: "unit.mg", defaultValue: "mg")),
            NutrientItem(id: UUID(), name: String(localized: "nutrient.calcium", defaultValue: "Calcium"), hkTypeIdentifier: HKQuantityTypeIdentifier.dietaryCalcium.rawValue, targetDGE: 1000.0, unitString: String(localized: "unit.mg", defaultValue: "mg")),
            NutrientItem(id: UUID(), name: String(localized: "nutrient.chloride", defaultValue: "Chlorid"), hkTypeIdentifier: HKQuantityTypeIdentifier.dietaryChloride.rawValue, targetDGE: 2300.0, unitString: String(localized: "unit.mg", defaultValue: "mg")),
            NutrientItem(id: UUID(), name: String(localized: "nutrient.copper", defaultValue: "Kupfer"), hkTypeIdentifier: HKQuantityTypeIdentifier.dietaryCopper.rawValue, targetDGE: 1.5, unitString: String(localized: "unit.mg", defaultValue: "mg")),
            NutrientItem(id: UUID(), name: String(localized: "nutrient.iodine", defaultValue: "Jod"), hkTypeIdentifier: HKQuantityTypeIdentifier.dietaryIodine.rawValue, targetDGE: 200.0, unitString: String(localized: "unit.mcg", defaultValue: "µg")),
            NutrientItem(id: UUID(), name: String(localized: "nutrient.iron", defaultValue: "Eisen"), hkTypeIdentifier: HKQuantityTypeIdentifier.dietaryIron.rawValue, targetDGE: 15.0, unitString: String(localized: "unit.mg", defaultValue: "mg")),
            NutrientItem(id: UUID(), name: String(localized: "nutrient.manganese", defaultValue: "Mangan"), hkTypeIdentifier: HKQuantityTypeIdentifier.dietaryManganese.rawValue, targetDGE: 3.0, unitString: String(localized: "unit.mg", defaultValue: "mg")),
            NutrientItem(id: UUID(), name: String(localized: "nutrient.molybdenum", defaultValue: "Molybdän"), hkTypeIdentifier: HKQuantityTypeIdentifier.dietaryMolybdenum.rawValue, targetDGE: 65.0, unitString: String(localized: "unit.mcg", defaultValue: "µg")),
            NutrientItem(id: UUID(), name: String(localized: "nutrient.phosphorus", defaultValue: "Phosphor"), hkTypeIdentifier: HKQuantityTypeIdentifier.dietaryPhosphorus.rawValue, targetDGE: 700.0, unitString: String(localized: "unit.mg", defaultValue: "mg")),
            NutrientItem(id: UUID(), name: String(localized: "nutrient.selenium", defaultValue: "Selen"), hkTypeIdentifier: HKQuantityTypeIdentifier.dietarySelenium.rawValue, targetDGE: 70.0, unitString: String(localized: "unit.mcg", defaultValue: "µg")),
            NutrientItem(id: UUID(), name: String(localized: "nutrient.sodium", defaultValue: "Natrium"), hkTypeIdentifier: HKQuantityTypeIdentifier.dietarySodium.rawValue, targetDGE: 1500.0, unitString: String(localized: "unit.mg", defaultValue: "mg")),
            NutrientItem(id: UUID(), name: String(localized: "nutrient.zinc", defaultValue: "Zink"), hkTypeIdentifier: HKQuantityTypeIdentifier.dietaryZinc.rawValue, targetDGE: 14.0, unitString: String(localized: "unit.mg", defaultValue: "mg")),
            NutrientItem(id: UUID(), name: String(localized: "nutrient.chromium", defaultValue: "Chrom"), hkTypeIdentifier: HKQuantityTypeIdentifier.dietaryChromium.rawValue, targetDGE: 40.0, unitString: String(localized: "unit.mcg", defaultValue: "µg"))
        ]
    }
    
    private func defaultFiber() -> NutrientItem {
        NutrientItem(id: UUID(), name: String(localized: "nutrient.fiber", defaultValue: "Ballaststoffe"), hkTypeIdentifier: HKQuantityTypeIdentifier.dietaryFiber.rawValue, targetDGE: 30.0, unitString: String(localized: "unit.g", defaultValue: "g"))
    }
    
    // NEU: Checks, ob Kategorien aktiv sind
    var hasActiveVitamins: Bool { vitamins.contains { $0.isEnabled } }
    var hasActiveMinerals: Bool { minerals.contains { $0.isEnabled } }
    var hasActiveFiber: Bool { fiber.isEnabled }
    
    // Berechnete Scores (0 - 100)
    var vitaminScore: Double {
        let active = vitamins.filter { $0.isEnabled }
        guard !active.isEmpty else { return 0 }
        return active.reduce(0.0) { $0 + $1.score } / Double(active.count)
    }
    
    var mineralScore: Double {
        let active = minerals.filter { $0.isEnabled }
        guard !active.isEmpty else { return 0 }
        return active.reduce(0.0) { $0 + $1.score } / Double(active.count)
    }
    
    var fiberScore: Double {
        fiber.isEnabled ? fiber.score : 0.0
    }
    
    // Gesamtindex (Durchschnitt der 3 Hauptbereiche)
    var totalScore: Int {
        var scores: [Double] = []
        if vitamins.contains(where: { $0.isEnabled }) { scores.append(vitaminScore) }
        if minerals.contains(where: { $0.isEnabled }) { scores.append(mineralScore) }
        if fiber.isEnabled { scores.append(fiberScore) }
        
        guard !scores.isEmpty else { return 0 }
        let total = scores.reduce(0.0, +) / Double(scores.count)
        return Int(total.rounded())
    }
    
    // Daten abfragen
    func fetchAllNutrients() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        var typesToRead: Set<HKObjectType> = []
        for v in vitamins { if let t = HKObjectType.quantityType(forIdentifier: v.hkType) { typesToRead.insert(t) } }
        for m in minerals { if let t = HKObjectType.quantityType(forIdentifier: m.hkType) { typesToRead.insert(t) } }
        if let f = HKObjectType.quantityType(forIdentifier: fiber.hkType) { typesToRead.insert(f) }
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, _ in
            if success {
                self.fetchTodaySum(for: self.fiber, updateBlock: { updated in
                    self.fiber = updated
                })
                
                for i in self.vitamins.indices {
                    self.fetchTodaySum(for: self.vitamins[i], updateBlock: { updated in
                        self.vitamins[i] = updated
                    })
                }
                
                for i in self.minerals.indices {
                    self.fetchTodaySum(for: self.minerals[i], updateBlock: { updated in
                        self.minerals[i] = updated
                    })
                }
            }
        }
    }
    
    private func fetchTodaySum(for item: NutrientItem, updateBlock: @escaping (NutrientItem) -> Void) {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: item.hkType) else { return }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else { return }
            let value = sum.doubleValue(for: item.unit)
            
            var mutableItem = item
            DispatchQueue.main.async {
                mutableItem.currentValue = value
                updateBlock(mutableItem)
            }
        }
        healthStore.execute(query)
    }
}
