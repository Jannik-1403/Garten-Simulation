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
        let hasRequestedV2 = UserDefaults.standard.bool(forKey: "HealthKitAuthRequested_v2")
        
        if hasRequested {
            isAuthorized = true
            
            // Wenn der User schon V1 hat, aber die neuen Permissions (Gewicht etc.) noch nicht
            if !hasRequestedV2 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.requestAuthorization()
                }
            }
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
              let mindfulness = HKObjectType.categoryType(forIdentifier: .mindfulSession),
              let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass),
              let waist = HKObjectType.quantityType(forIdentifier: .waistCircumference) else {
            return
        }
        
        let workout = HKObjectType.workoutType()
        
        let typesToRead: Set<HKObjectType> = [stepCount, water, sleep, mindfulness, workout, bodyMass, waist]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.isAuthorized = true
                    UserDefaults.standard.set(true, forKey: "HealthKitAuthRequested")
                    UserDefaults.standard.set(true, forKey: "HealthKitAuthRequested_v2")
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
    
    /// Holt den Durchschnitt der letzten 7 Tage für eine Metrik.
    /// Gibt nil zurück, wenn noch keine 3 Tage Daten vorhanden.
    func fetchWeeklyAverage(for metric: HealthMetricType, completion: @escaping (Double?) -> Void) {
        guard isAuthorized else {
            DispatchQueue.main.async { completion(nil) }
            return
        }
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount),
              let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater) else {
            DispatchQueue.main.async { completion(nil) }
            return
        }
        
        let calendar = Calendar.current
        guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: calendar.startOfDay(for: Date())) else {
            DispatchQueue.main.async { completion(nil) }
            return
        }
        let today = calendar.startOfDay(for: Date())
        
        var intervalComponents = DateComponents()
        intervalComponents.day = 1
        
        func handleStats(_ results: HKStatisticsCollection?, unit: HKUnit) {
            var dailyValues: [Double] = []
            results?.enumerateStatistics(from: sevenDaysAgo, to: today) { stats, _ in
                if let sum = stats.sumQuantity() {
                    let val = sum.doubleValue(for: unit)
                    if val > 0 { dailyValues.append(val) }
                }
            }
            let average: Double? = dailyValues.count >= 3 ? dailyValues.reduce(0, +) / Double(dailyValues.count) : nil
            DispatchQueue.main.async { completion(average) }
        }
        
        switch metric {
        case .steps:
            let pred = HKQuery.predicateForSamples(withStart: sevenDaysAgo, end: today, options: .strictStartDate)
            let q = HKStatisticsCollectionQuery(quantityType: stepType, quantitySamplePredicate: pred, options: .cumulativeSum, anchorDate: sevenDaysAgo, intervalComponents: intervalComponents)
            q.initialResultsHandler = { _, r, _ in handleStats(r, unit: .count()) }
            self.healthStore.execute(q)
        case .water:
            let pred = HKQuery.predicateForSamples(withStart: sevenDaysAgo, end: today, options: .strictStartDate)
            let q = HKStatisticsCollectionQuery(quantityType: waterType, quantitySamplePredicate: pred, options: .cumulativeSum, anchorDate: sevenDaysAgo, intervalComponents: intervalComponents)
            q.initialResultsHandler = { _, r, _ in handleStats(r, unit: .literUnit(with: .milli)) }
            self.healthStore.execute(q)
        default:
            DispatchQueue.main.async { completion(nil) }
        }
    }
    
    /// Berechnet pro Stunde den kumulativen Durchschnitt der letzten 7 Tage.
    /// Ergibt eine Linie, die zeigt: "Um X Uhr hatte ich durchschnittlich Y Schritte gesamt."
    func fetchHourlyWeeklyAverage(for metric: HealthMetricType, completion: @escaping ([(Date, Double)]) -> Void) {
        guard isAuthorized else {
            DispatchQueue.main.async { completion([]) }
            return
        }
        guard metric == .steps || metric == .water else {
            DispatchQueue.main.async { completion([]) }
            return
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: today) else {
            DispatchQueue.main.async { completion([]) }
            return
        }
        
        let isSteps = (metric == .steps)
        guard let quantityType = isSteps
            ? HKQuantityType.quantityType(forIdentifier: .stepCount)
            : HKQuantityType.quantityType(forIdentifier: .dietaryWater) else {
            DispatchQueue.main.async { completion([]) }
            return
        }
        let unit = isSteps ? HKUnit.count() : HKUnit.literUnit(with: .milli)
        
        var intervalComponents = DateComponents()
        intervalComponents.hour = 1
        
        let predicate = HKQuery.predicateForSamples(withStart: sevenDaysAgo, end: today, options: .strictStartDate)
        let query = HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: sevenDaysAgo,
            intervalComponents: intervalComponents
        )
        
        query.initialResultsHandler = { _, results, _ in
            // hourlyTotals[dayIndex][hour] = wert
            var hourlyByDay: [Int: [Int: Double]] = [:]
            
            results?.enumerateStatistics(from: sevenDaysAgo, to: today) { statistics, _ in
                guard let sum = statistics.sumQuantity() else { return }
                let val = sum.doubleValue(for: unit)
                if val <= 0 { return }
                
                let dayIndex = calendar.dateComponents([.day], from: sevenDaysAgo, to: statistics.startDate).day ?? 0
                let hour = calendar.component(.hour, from: statistics.startDate)
                
                if hourlyByDay[dayIndex] == nil { hourlyByDay[dayIndex] = [:] }
                hourlyByDay[dayIndex]![hour, default: 0] += val
            }
            
            guard !hourlyByDay.isEmpty else {
                DispatchQueue.main.async { completion([]) }
                return
            }
            
            // Für jede Stunde des heutigen Tages: kumulativer Durchschnitt über alle Tage mit Daten
            let currentHour = calendar.component(.hour, from: Date())
            var result: [(Date, Double)] = []
            
            for h in 0...currentHour {
                guard let date = calendar.date(bySettingHour: h, minute: 0, second: 0, of: today) else { continue }
                
                var cumulativePerDay: [Double] = []
                for (_, dayData) in hourlyByDay {
                    let cumSum = (0...h).reduce(0.0) { $0 + (dayData[$1] ?? 0) }
                    if cumSum > 0 { cumulativePerDay.append(cumSum) }
                }
                
                if !cumulativePerDay.isEmpty {
                    let avg = cumulativePerDay.reduce(0, +) / Double(cumulativePerDay.count)
                    result.append((date, avg))
                }
            }
            
            DispatchQueue.main.async { completion(result) }
        }
        
        self.healthStore.execute(query)
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
