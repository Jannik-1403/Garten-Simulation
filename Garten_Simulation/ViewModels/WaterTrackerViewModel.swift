import Foundation
import HealthKit
import Combine

class WaterTrackerViewModel: ObservableObject {
    @Published var todaysEntries: [WaterEntry] = []
    @Published var isAddingAmount: Bool = false
    @Published var isLoading: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        fetchTodaysEntries()
        
        // Refresh when HealthManager water changes
        HealthManager.shared.$todaysWater
            .dropFirst()
            .sink { [weak self] _ in
                self?.fetchTodaysEntries()
            }
            .store(in: &cancellables)
    }
    
    func fetchTodaysEntries() {
        guard let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater) else { return }
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: waterType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { [weak self] _, samples, _ in
            guard let samples = samples as? [HKQuantitySample] else { return }
            
            let bundleName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "Garten_Simulation"
            
            let entries = samples.map { sample -> WaterEntry in
                let amount = sample.quantity.doubleValue(for: HKUnit.literUnit(with: .milli))
                let source = sample.sourceRevision.source.name
                let isManual = (source == bundleName)
                return WaterEntry(amountMl: amount, date: sample.startDate, source: source, isManualAppEntry: isManual)
            }
            
            DispatchQueue.main.async {
                self?.todaysEntries = entries
            }
        }
        
        HealthManager.shared.healthStore.execute(query)
    }
    
    func addWater(ml: Double) {
        isLoading = true
        HealthManager.shared.saveWater(ml: ml) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isLoading = false
            }
        }
    }
    
    func deleteEntry(_ entry: WaterEntry) {
        // Implement deletion from HealthKit if needed, but for simplicity we might just leave it out, 
        // or we can add a delete method to HealthManager.
    }
}
