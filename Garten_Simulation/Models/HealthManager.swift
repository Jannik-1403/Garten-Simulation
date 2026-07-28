import Foundation
import HealthKit
import Combine

class HealthManager: ObservableObject {
    static let shared = HealthManager()
    
    let healthStore = HKHealthStore()
    
    @Published var isAuthorized: Bool = false
    
    // Live Daten für das UI (Heute)
    @Published var todaysSteps: Double = 0
    @Published var todaysWater: Double = 0
    @Published var todaysSleep: Double = 0
    @Published var todaysMindfulness: Double = 0
    @Published var todaysRunning: Double = 0
    @Published var todaysStrengthTraining: Double = 0
    
    private init() {
        checkAuthorizationStatus()
        if isAuthorized {
            fetchAllTodaysData()
        }
    }
    
    func checkAuthorizationStatus() {
        guard HKHealthStore.isHealthDataAvailable() else {
            isAuthorized = false
            return
        }
        
        // Da wir nur lesen wollen, reicht es oft, den Status zu checken, aber HealthKit hat keinen expliziten
        // "isAuthorizedForReading" check. Wir nehmen an, wenn der User den Flow gemacht hat, ist er berechtigt.
        // Ein sicherer Weg ist, UserDefaults zu nutzen, um zu wissen, ob der Prompt schon gezeigt wurde.
        let hasRequested = UserDefaults.standard.bool(forKey: "HealthKitAuthRequested")
        if hasRequested {
            isAuthorized = true
        }
    }
    
    func disconnect() {
        isAuthorized = false
        UserDefaults.standard.set(false, forKey: "HealthKitAuthRequested")
    }
    
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit ist auf diesem Gerät nicht verfügbar.")
            return
        }
        
        guard let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount),
              let water = HKObjectType.quantityType(forIdentifier: .dietaryWater),
              let sleep = HKObjectType.categoryType(forIdentifier: .sleepAnalysis),
              let mindfulness = HKObjectType.categoryType(forIdentifier: .mindfulSession) else {
            return
        }
        
        let workout = HKObjectType.workoutType()
        
        let typesToRead: Set<HKObjectType> = [stepCount, water, sleep, mindfulness, workout]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.isAuthorized = true
                    UserDefaults.standard.set(true, forKey: "HealthKitAuthRequested")
                    self?.fetchAllTodaysData()
                } else {
                    print("HealthKit Auth Fehlgeschlagen: \(String(describing: error))")
                    self?.isAuthorized = false
                }
            }
        }
    }
    
    func fetchAllTodaysData() {
        fetchSteps()
        fetchWater()
        fetchSleep()
        fetchMindfulness()
        fetchWorkout(activityType: .running)
        fetchWorkout(activityType: .traditionalStrengthTraining)
    }
    
    func fetchSteps() {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                return
            }
            let steps = sum.doubleValue(for: HKUnit.count())
            DispatchQueue.main.async {
                self.todaysSteps = steps
            }
        }
        
        healthStore.execute(query)
    }
    
    func fetchWater() {
        guard let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater) else { return }
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: waterType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                return
            }
            let ml = sum.doubleValue(for: HKUnit.literUnit(with: .milli))
            DispatchQueue.main.async {
                self.todaysWater = ml
            }
        }
        
        healthStore.execute(query)
    }
    
    func fetchSleep() {
        guard let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else { return }
        
        let calendar = Calendar.current
        let today = Date()
        // Wir suchen nach Schlaf von gestern Abend bis heute
        guard let start = calendar.date(byAdding: .hour, value: -24, to: today) else { return }
        
        let predicate = HKQuery.predicateForSamples(withStart: start, end: today, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: 100, sortDescriptors: [sortDescriptor]) { _, samples, error in
            guard let samples = samples as? [HKCategorySample] else { return }
            
            // Nur 'asleep' samples (asleepCore, asleepDeep, asleepREM etc.)
            let asleepSamples = samples.filter { $0.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue ||
                                                 $0.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue ||
                                                 $0.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue ||
                                                 $0.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue }
            
            let totalSleepSeconds = asleepSamples.reduce(0.0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
            let totalSleepHours = totalSleepSeconds / 3600.0
            
            DispatchQueue.main.async {
                self.todaysSleep = totalSleepHours
            }
        }
        
        healthStore.execute(query)
    }
    
    func fetchMindfulness() {
        guard let mindfulnessType = HKCategoryType.categoryType(forIdentifier: .mindfulSession) else { return }
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: mindfulnessType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            guard let samples = samples as? [HKCategorySample] else { return }
            
            let totalSeconds = samples.reduce(0.0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
            let totalMinutes = totalSeconds / 60.0
            
            DispatchQueue.main.async {
                self.todaysMindfulness = totalMinutes
            }
        }
        
        healthStore.execute(query)
    }
    
    func fetchWorkout(activityType: HKWorkoutActivityType) {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        let workoutPredicate = HKQuery.predicateForWorkouts(with: activityType)
        let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, workoutPredicate])
        
        let query = HKSampleQuery(sampleType: HKObjectType.workoutType(), predicate: combinedPredicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            guard let workouts = samples as? [HKWorkout] else { return }
            
            let totalSeconds = workouts.reduce(0.0) { $0 + $1.duration }
            let totalMinutes = totalSeconds / 60.0
            
            DispatchQueue.main.async {
                if activityType == .running {
                    self.todaysRunning = totalMinutes
                } else if activityType == .traditionalStrengthTraining {
                    self.todaysStrengthTraining = totalMinutes
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    /// Holt den aktuellen Wert für die übergebene Metrik für heute
    func fetchValue(for metric: HealthMetricType, completion: @escaping (Double) -> Void) {
        switch metric {
        case .steps:
            fetchSteps()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { completion(self.todaysSteps) }
        case .water:
            fetchWater()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { completion(self.todaysWater) }
        case .sleep:
            fetchSleep()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { completion(self.todaysSleep) }
        case .mindfulness:
            fetchMindfulness()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { completion(self.todaysMindfulness) }
        case .running:
            fetchWorkout(activityType: .running)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { completion(self.todaysRunning) }
        case .strengthTraining:
            fetchWorkout(activityType: .traditionalStrengthTraining)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { completion(self.todaysStrengthTraining) }
        }
    }
}
extension HealthManager {
    /// Holt historische Daten (pro Stunde) für den heutigen Tag
    func fetchHourlyData(for metric: HealthMetricType, completion: @escaping ([(Date, Double)]) -> Void) {
        guard isAuthorized else {
            DispatchQueue.main.async { completion([]) }
            return
        }
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        var hourlyData: [(Date, Double)] = []
        
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: Date())
        for h in 0...currentHour {
            if let date = calendar.date(bySettingHour: h, minute: 0, second: 0, of: startOfDay) {
                hourlyData.append((date, 0.0))
            }
        }
        
        switch metric {
        case .steps, .water:
            let isSteps = (metric == .steps)
            guard let quantityType = isSteps ? HKQuantityType.quantityType(forIdentifier: .stepCount) : HKQuantityType.quantityType(forIdentifier: .dietaryWater) else {
                DispatchQueue.main.async { completion([]) }
                return
            }
            let unit = isSteps ? HKUnit.count() : HKUnit.literUnit(with: .milli)
            var interval = DateComponents()
            interval.hour = 1
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
            
            let query = HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .cumulativeSum, anchorDate: startOfDay, intervalComponents: interval)
            query.initialResultsHandler = { _, results, _ in
                var resultsDict: [Date: Double] = [:]
                results?.enumerateStatistics(from: startOfDay, to: Date()) { statistics, _ in
                    if let sum = statistics.sumQuantity() {
                        resultsDict[statistics.startDate] = sum.doubleValue(for: unit)
                    }
                }
                
                var finalData: [(Date, Double)] = []
                for h in 0...currentHour {
                    if let date = calendar.date(bySettingHour: h, minute: 0, second: 0, of: startOfDay) {
                        finalData.append((date, resultsDict[date] ?? 0.0))
                    }
                }
                DispatchQueue.main.async { completion(finalData) }
            }
            healthStore.execute(query)
            
        case .running, .strengthTraining:
            let activityType: HKWorkoutActivityType = (metric == .running) ? .running : .traditionalStrengthTraining
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
            let workoutPredicate = HKQuery.predicateForWorkouts(with: activityType)
            let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, workoutPredicate])
            
            let query = HKSampleQuery(sampleType: HKObjectType.workoutType(), predicate: combinedPredicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
                guard let workouts = samples as? [HKWorkout] else {
                    DispatchQueue.main.async { completion(hourlyData) }
                    return
                }
                
                var resultsDict: [Int: Double] = [:]
                for workout in workouts {
                    let hour = calendar.component(.hour, from: workout.startDate)
                    let minutes = workout.duration / 60.0
                    resultsDict[hour, default: 0.0] += minutes
                }
                
                var finalData: [(Date, Double)] = []
                for h in 0...currentHour {
                    if let date = calendar.date(bySettingHour: h, minute: 0, second: 0, of: startOfDay) {
                        finalData.append((date, resultsDict[h] ?? 0.0))
                    }
                }
                DispatchQueue.main.async { completion(finalData) }
            }
            healthStore.execute(query)
            
        case .mindfulness:
            guard let mindfulnessType = HKCategoryType.categoryType(forIdentifier: .mindfulSession) else {
                DispatchQueue.main.async { completion([]) }
                return
            }
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
            let query = HKSampleQuery(sampleType: mindfulnessType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
                guard let samples = samples as? [HKCategorySample] else {
                    DispatchQueue.main.async { completion(hourlyData) }
                    return
                }
                var resultsDict: [Int: Double] = [:]
                for sample in samples {
                    let hour = calendar.component(.hour, from: sample.startDate)
                    let minutes = sample.endDate.timeIntervalSince(sample.startDate) / 60.0
                    resultsDict[hour, default: 0.0] += minutes
                }
                var finalData: [(Date, Double)] = []
                for h in 0...currentHour {
                    if let date = calendar.date(bySettingHour: h, minute: 0, second: 0, of: startOfDay) {
                        finalData.append((date, resultsDict[h] ?? 0.0))
                    }
                }
                DispatchQueue.main.async { completion(finalData) }
            }
            healthStore.execute(query)
            
        case .sleep:
            guard let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else {
                DispatchQueue.main.async { completion([]) }
                return
            }
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
            let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
                guard let samples = samples as? [HKCategorySample] else {
                    DispatchQueue.main.async { completion(hourlyData) }
                    return
                }
                let asleepSamples = samples.filter { $0.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue ||
                                                     $0.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue ||
                                                     $0.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue ||
                                                     $0.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue }
                var resultsDict: [Int: Double] = [:]
                for sample in asleepSamples {
                    let hour = calendar.component(.hour, from: sample.startDate)
                    let hours = sample.endDate.timeIntervalSince(sample.startDate) / 3600.0
                    resultsDict[hour, default: 0.0] += hours
                }
                var finalData: [(Date, Double)] = []
                for h in 0...currentHour {
                    if let date = calendar.date(bySettingHour: h, minute: 0, second: 0, of: startOfDay) {
                        finalData.append((date, resultsDict[h] ?? 0.0))
                    }
                }
                DispatchQueue.main.async { completion(finalData) }
            }
            healthStore.execute(query)
        }
    }
}
