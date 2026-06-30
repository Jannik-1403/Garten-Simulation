import Foundation
import HealthKit
import Combine
import SwiftUI

enum HealthKitType: String, Codable, CaseIterable {
    case steps = "steps"
    case water = "water"
    case sleep = "sleep"
    
    var displayName: String {
        switch self {
        case .steps: return String(localized: "health.type.steps", defaultValue: "Schritte")
        case .water: return String(localized: "health.type.water", defaultValue: "Wasser (ml)")
        case .sleep: return String(localized: "health.type.sleep", defaultValue: "Schlaf (Stunden)")
        }
    }
    
    var iconName: String {
        switch self {
        case .steps: return "figure.walk"
        case .water: return "drop.fill"
        case .sleep: return "bed.double.fill"
        }
    }
}

class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    
    let healthStore = HKHealthStore()
    @Published var isAuthorized = false
    
    private init() {}
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }
        
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount),
              let waterType = HKObjectType.quantityType(forIdentifier: .dietaryWater),
              let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion(false)
            return
        }
        
        let readTypes: Set<HKObjectType> = [stepType, waterType, sleepType]
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            DispatchQueue.main.async {
                self.isAuthorized = success
                completion(success)
            }
        }
    }
    
    func fetchTodayValue(for type: HealthKitType, completion: @escaping (Double) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(0)
            return
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let now = Date()
        let predicate = HKQuery.predicateForSamples(withStart: today, end: now, options: .strictStartDate)
        
        switch type {
        case .steps:
            guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
            let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
                let sum = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                DispatchQueue.main.async { completion(sum) }
            }
            healthStore.execute(query)
            
        case .water:
            guard let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater) else { return }
            let query = HKStatisticsQuery(quantityType: waterType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
                let sum = result?.sumQuantity()?.doubleValue(for: HKUnit.literUnit(with: .milli)) ?? 0
                DispatchQueue.main.async { completion(sum) }
            }
            healthStore.execute(query)
            
        case .sleep:
            guard let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else { return }
            
            // Für Schlaf nehmen wir gestern 18:00 Uhr bis jetzt, da Schlaf über Mitternacht geht
            let yesterday6PM = calendar.date(byAdding: .hour, value: -6, to: today) ?? today
            let sleepPredicate = HKQuery.predicateForSamples(withStart: yesterday6PM, end: now, options: .strictStartDate)
            
            let query = HKSampleQuery(sampleType: sleepType, predicate: sleepPredicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
                guard let sleepSamples = samples as? [HKCategorySample] else {
                    DispatchQueue.main.async { completion(0) }
                    return
                }
                
                var totalSleepHours = 0.0
                for sample in sleepSamples {
                    if sample.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue ||
                       sample.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue ||
                       sample.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue ||
                       sample.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue {
                        totalSleepHours += sample.endDate.timeIntervalSince(sample.startDate) / 3600.0
                    }
                }
                DispatchQueue.main.async { completion(totalSleepHours) }
            }
            healthStore.execute(query)
        }
    }
}
