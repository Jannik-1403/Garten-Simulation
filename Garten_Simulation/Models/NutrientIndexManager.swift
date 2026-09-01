import Foundation
import HealthKit
import Combine

struct NutrientItem: Identifiable, Codable {
    let id: UUID
    let name: String
    let hkTypeIdentifier: String
    var targetDGE: Double
    let unitString: String
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
    let healthStore = HKHealthStore()
    
    @Published var vitamins: [NutrientItem] = []
    @Published var minerals: [NutrientItem] = []
    @Published var fiber: NutrientItem
    
    private let defaultsKey = "NutrientIndexSettings"
    
    init() {
        // Init default fiber
        self.fiber = NutrientItem(id: UUID(), name: "Ballaststoffe", hkTypeIdentifier: HKQuantityTypeIdentifier.dietaryFiber.rawValue, targetDGE: 30.0, unitString: "g")
        
        loadSettings()
    }
    
    private func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: defaultsKey),
           let savedState = try? JSONDecoder().decode([String: [NutrientItem]].self, from: data) {
            
            self.vitamins = savedState["vitamins"] ?? defaultVitamins()
            self.minerals = savedState["minerals"] ?? defaultMinerals()
            self.fiber = savedState["fiber"]?.first ?? defaultFiber()
            
        } else {
            self.vitamins = defaultVitamins()
            self.minerals = defaultMinerals()
            self.fiber = defaultFiber()
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
            NutrientItem(id: UUID(), name: String(localized: "nutrient.vitamin_c", defaultValue: "Vitamin C"), hkTypeIdentifier: HKQuantityTypeIdentifier.dietaryVitaminC.rawValue, targetDGE: 110.0, unitString: "mg"),
            NutrientItem(id: UUID(), name: String(localized: "nutrient.vitamin_a", defaultValue: "Vitamin A"), hkTypeIdentifier: HKQuantityTypeIdentifier.dietaryVitaminA.rawValue, targetDGE: 1000.0, unitString: "mcg"),
            NutrientItem(id: UUID(), name: String(localized: "nutrient.folate", defaultValue: "Folsäure"), hkTypeIdentifier: HKQuantityTypeIdentifier.dietaryFolate.rawValue, targetDGE: 300.0, unitString: "mcg"),
            NutrientItem(id: UUID(), name: String(localized: "nutrient.vitamin_k", defaultValue: "Vitamin K"), hkTypeIdentifier: HKQuantityTypeIdentifier.dietaryVitaminK.rawValue, targetDGE: 70.0, unitString: "mcg")
        ]
    }
    
    private func defaultMinerals() -> [NutrientItem] {
        [
            NutrientItem(id: UUID(), name: String(localized: "nutrient.potassium", defaultValue: "Kalium"), hkTypeIdentifier: HKQuantityTypeIdentifier.dietaryPotassium.rawValue, targetDGE: 4000.0, unitString: "mg"),
            NutrientItem(id: UUID(), name: String(localized: "nutrient.magnesium", defaultValue: "Magnesium"), hkTypeIdentifier: HKQuantityTypeIdentifier.dietaryMagnesium.rawValue, targetDGE: 350.0, unitString: "mg"),
            NutrientItem(id: UUID(), name: String(localized: "nutrient.calcium", defaultValue: "Calcium"), hkTypeIdentifier: HKQuantityTypeIdentifier.dietaryCalcium.rawValue, targetDGE: 1000.0, unitString: "mg")
        ]
    }
    
    private func defaultFiber() -> NutrientItem {
        NutrientItem(id: UUID(), name: String(localized: "nutrient.fiber", defaultValue: "Ballaststoffe"), hkTypeIdentifier: HKQuantityTypeIdentifier.dietaryFiber.rawValue, targetDGE: 30.0, unitString: "g")
    }
    
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
                self.fetchTodaySum(for: &self.fiber, updateBlock: { updated in
                    self.fiber = updated
                })
                
                for i in self.vitamins.indices {
                    self.fetchTodaySum(for: &self.vitamins[i], updateBlock: { updated in
                        self.vitamins[i] = updated
                    })
                }
                
                for i in self.minerals.indices {
                    self.fetchTodaySum(for: &self.minerals[i], updateBlock: { updated in
                        self.minerals[i] = updated
                    })
                }
            }
        }
    }
    
    private func fetchTodaySum(for item: inout NutrientItem, updateBlock: @escaping (NutrientItem) -> Void) {
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
