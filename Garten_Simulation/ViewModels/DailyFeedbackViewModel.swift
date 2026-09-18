 import Foundation
import Combine
import SwiftUI

// MARK: - DailyFeedbackViewModel

@MainActor
class DailyFeedbackViewModel: ObservableObject {

    @Published var categoryFeedbacks: [CategoryFeedback] = []
    @Published var issueFeedbacks: [CategoryFeedback] = []
    @Published var dailyScore: Int = 100
    @Published var headerText: String = ""
    @Published var primaryKey: FeedbackKey = .feedbackPositiv1

    @Published var activeHabits: [HabitModel] = []

    private var cancellables = Set<AnyCancellable>()

    init() {
        let hm = HealthManager.shared
        let wgm = WaterGoalManager.shared
        let cm = CleaningManager.shared

        Publishers.MergeMany(
            hm.$todaysWater.map { _ in () }.eraseToAnyPublisher(),
            hm.$waterHistory7Days.map { _ in () }.eraseToAnyPublisher(),
            hm.$todaysSleep.map { _ in () }.eraseToAnyPublisher(),
            hm.$lastStrengthWorkoutDate.map { _ in () }.eraseToAnyPublisher(),
            hm.$todaysRunning.map { _ in () }.eraseToAnyPublisher(),
            hm.$todaysEnergy.map { _ in () }.eraseToAnyPublisher(),
            hm.$todaysProtein.map { _ in () }.eraseToAnyPublisher(),
            hm.$todaysFiber.map { _ in () }.eraseToAnyPublisher(),
            wgm.$currentGoal.map { _ in () }.eraseToAnyPublisher(),
            cm.$logs.map { _ in () }.eraseToAnyPublisher(),
            cm.$tasks.map { _ in () }.eraseToAnyPublisher()
        )
        .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
        .sink { [weak self] in self?.reevaluate() }
        .store(in: &cancellables)

        reevaluate()
    }

    func reevaluate() {
        let hm = HealthManager.shared
        let wgm = WaterGoalManager.shared
        let nim = NutrientIndexManager.shared
        let store = FeedbackStore.shared

        // Stärkstes Krafttraining in Tagen berechnen
        let strengthDaysAgo: Int?
        if let lastDate = hm.lastStrengthWorkoutDate {
            let days = Calendar.current.dateComponents([.day],
                from: Calendar.current.startOfDay(for: lastDate),
                to: Calendar.current.startOfDay(for: Date())).day ?? 999
            strengthDaysAgo = days
        } else {
            strengthDaysAgo = nil
        }

        // Schlechtesten Mineralstoff ermitteln
        let worstMineral = nim.minerals
            .filter { $0.isEnabled && $0.targetDGE > 0 }
            .min(by: { $0.score < $1.score })

        let hasWaterPlant = activeHabits.contains(where: { $0.effectiveHealthMetric == .water })
        let hasSleepPlant = activeHabits.contains(where: { $0.effectiveHealthMetric == .sleep })
        let hasStrengthPlant = activeHabits.contains(where: { $0.effectiveHealthMetric == .strengthTraining || $0.name.lowercased().contains("kraft") })
        let hasRunningPlant = activeHabits.contains(where: { $0.effectiveHealthMetric == .steps || $0.effectiveHealthMetric == .running || $0.name.lowercased().contains("laufen") || $0.name.lowercased().contains("joggen") || $0.name.lowercased().contains("schritt") })
        let hasNutritionPlant = activeHabits.contains(where: { plant in
            if plant.effectiveHealthMetric == .energy { return true }
            if plant.effectiveHealthMetric == .fiber { return true }
            let lowerName = plant.name.lowercased()
            if lowerName.contains("gemüse") { return true }
            if lowerName.contains("kochen") { return true }
            return false
        })

        // Protein-Ziel aus UserDefaults (wird von MacroCalculator/HealthManager gesetzt)
        let proteinGoal = UserDefaults.standard.double(forKey: "goal_protein")



        let strengthPlant = activeHabits.first(where: { $0.effectiveHealthMetric == .strengthTraining || $0.name.lowercased().contains("kraft") })
        let strengthGoalMinutes = strengthPlant?.healthTarget ?? 30.0
        
        let runningPlant = activeHabits.first(where: { $0.effectiveHealthMetric == .steps || $0.effectiveHealthMetric == .running })
        let stepsGoal = runningPlant?.healthTarget ?? 10000.0

        let fiberPlant = activeHabits.first(where: { $0.effectiveHealthMetric == .fiber })
        let fiberGoal = fiberPlant?.healthTarget ?? 30.0 // DGE-Empfehlung
        
        let gratitudePlant = activeHabits.first(where: { $0.habitName == "habit.dankbarkeit" })
        let hasGratitudePlant = gratitudePlant != nil
        let gratitudeTodayDone = gratitudePlant?.journalEntries.contains(where: { Calendar.current.isDateInToday($0.date) }) ?? false
        let gratitudeYesterdayEntry = gratitudePlant?.journalEntries.first(where: { Calendar.current.isDateInYesterday($0.date) })

        let energyPlant = activeHabits.first(where: { plant in
            if plant.effectiveHealthMetric == .energy { return true }
            let lowerName = plant.name.lowercased()
            if lowerName.contains("kochen") { return true }
            return false
        })
        let energyGoal = energyPlant?.healthTarget ?? UserDefaults.standard.double(forKey: "goal_energy")

        let cm = CleaningManager.shared
        var hasCleaningTaskToday = false
        var isCleaningTaskDone = true
        let activeCleaningTasks = cm.tasks.filter { $0.isActive }
        let todayStart = Calendar.current.startOfDay(for: Date())
        
        var nextCleaningDate: Date? = nil
        
        for task in activeCleaningTasks {
            let lastCompleted = cm.lastCompletedDate(for: task.id)
            let due = task.dueDate(lastCompleted: lastCompleted)
            
            if nextCleaningDate == nil || due < nextCleaningDate! {
                nextCleaningDate = due
            }

            let isDoneToday = lastCompleted != nil && Calendar.current.isDateInToday(lastCompleted!)
            
            if due <= todayStart || isDoneToday {
                hasCleaningTaskToday = true
                if !isDoneToday {
                    isCleaningTaskDone = false
                }
            }
        }
        if !hasCleaningTaskToday {
            isCleaningTaskDone = false
        }

        let hasSetGoals = UserDefaults.standard.bool(forKey: "has_set_nutrition_goals")
        let isGoalValid = hm.weightGoalType != 0 && hm.weightGoalTargetKg > 0 && hm.weightGoalDateInterval > 0
        let showNutrition = hasSetGoals && isGoalValid
        
        func getManualOrHealth(plant: HabitModel?, healthValue: Double, goal: Double) -> Double {
            if let p = plant, p.effectiveHealthMetric == nil {
                let todaysManualProgress = p.intradayProgressHistory
                    .filter { Calendar.current.isDateInToday($0.timestamp) }
                    .last?.progress ?? 0.0
                if todaysManualProgress > 0 {
                    return todaysManualProgress * goal
                }
            }
            return healthValue
        }
        
        let proteinPlant = activeHabits.first(where: { $0.effectiveHealthMetric == .protein })
        
        let effectiveStrength = getManualOrHealth(plant: strengthPlant, healthValue: hm.todaysStrengthTraining, goal: strengthGoalMinutes)
        let effectiveSteps = getManualOrHealth(plant: runningPlant, healthValue: hm.todaysSteps, goal: stepsGoal)
        let effectiveEnergy = getManualOrHealth(plant: energyPlant, healthValue: hm.todaysEnergy, goal: energyGoal > 0 ? energyGoal : 2000.0)
        let effectiveProtein = getManualOrHealth(plant: proteinPlant, healthValue: hm.todaysProtein, goal: proteinGoal > 0 ? proteinGoal : 120.0)
        let effectiveFiber = getManualOrHealth(plant: fiberPlant, healthValue: hm.todaysFiber, goal: fiberGoal)
        
        var effectiveStrengthDaysAgo = strengthDaysAgo
        if let p = strengthPlant, p.effectiveHealthMetric == nil {
            let todaysManualProgress = p.intradayProgressHistory
                .filter { Calendar.current.isDateInToday($0.timestamp) }
                .last?.progress ?? 0.0
            if todaysManualProgress > 0 {
                effectiveStrengthDaysAgo = 0
            }
        }
        
        let input = FeedbackScoringEngine.EvaluationInput(
            hasWaterPlant: hasWaterPlant,
            hasSleepPlant: hasSleepPlant,
            hasStrengthPlant: hasStrengthPlant,
            hasRunningPlant: hasRunningPlant,
            hasNutritionPlant: hasNutritionPlant,
            hasGratitudePlant: hasGratitudePlant,
            gratitudeTodayDone: gratitudeTodayDone,
            gratitudeYesterdayEntry: gratitudeYesterdayEntry,
            hasCleaningTaskToday: hasCleaningTaskToday,
            isCleaningTaskDone: isCleaningTaskDone,
            nextCleaningDate: nextCleaningDate,
            waterToday: hm.todaysWater,
            waterGoal: wgm.currentGoal,
            waterHistory7Days: hm.waterHistory7Days,
            sleepHoursToday: hm.todaysSleep,
            sleepGoalHours: UserDefaults.standard.double(forKey: "goal_sleep") > 0 ? UserDefaults.standard.double(forKey: "goal_sleep") : 8.0,
            sleepRegularity: hm.sleepRegularityPercentage,
            sleepAvgBedtimeString: hm.sleepAvgBedtimeString,
            sleepTargetWakeUpString: hm.sleepTargetWakeUpString,
            strengthDaysAgo: effectiveStrengthDaysAgo,
            hasStrengthHistory: hm.hasAnyWorkoutHistory,
            strengthTodayMinutes: effectiveStrength,
            strengthGoalMinutes: strengthGoalMinutes,
            stepsToday: effectiveSteps,
            stepsGoal: stepsGoal,
            energyToday: showNutrition ? effectiveEnergy : 0.0,
            energyGoal: energyGoal > 0 ? energyGoal : 2000.0,
            proteinToday: showNutrition ? effectiveProtein : 0.0,
            proteinGoal: proteinGoal > 0 ? proteinGoal : 120.0,
            fiberToday: effectiveFiber,
            fiberGoal: fiberGoal,
            worstMineralName: worstMineral?.name,
            worstMineralScore: worstMineral?.score ?? 100,
            userFactors: { store.factor(forKey: $0) }
        )

        let feedbacks = FeedbackScoringEngine.evaluateAll(input: input)
        categoryFeedbacks = feedbacks
        issueFeedbacks = feedbacks.filter { $0.status != CategoryStatus.unavailable }
        headerText = FeedbackScoringEngine.headerText(from: feedbacks)

        // Tages-Score berechnen (Präzise Berechnung auf Basis des tatsächlichen Fortschritts)
        let availableFeedbacks = feedbacks.filter { $0.status != CategoryStatus.unavailable }
        if availableFeedbacks.isEmpty {
            dailyScore = 0
        } else {
            let total = availableFeedbacks.reduce(0.0) { sum, fb in
                var scoreForCategory: Double = 0
                
                if fb.category == .strength {
                    // Krafttraining basiert auf Tagen (Status) um Ruhetage nicht abzustrafen
                    switch fb.status {
                    case .good: scoreForCategory = 100
                    case .warning: scoreForCategory = 50
                    case .critical: scoreForCategory = 0
                    case .unavailable: scoreForCategory = 0
                    }
                } else if fb.category == .cleaning || fb.category == .gratitude {
                    // Binäre Aufgaben: 100% wenn gut (erledigt), sonst 0%
                    scoreForCategory = fb.status == .good ? 100 : 0
                } else {
                    // Kontinuierliche Aufgaben: Nutze exakten prozentualen Fortschritt (max 100%)
                    let progress = fb.progress ?? 0
                    let goal = fb.goal ?? 0
                    let pct = goal > 0 ? (progress / goal) : 0
                    scoreForCategory = min(100.0, pct * 100.0)
                }
                
                return sum + scoreForCategory
            }
            dailyScore = Int(total / Double(availableFeedbacks.count))
        }

        // Primären Key für FeedbackStore bestimmen (schlechteste Kategorie)
        if feedbacks.contains(where: { $0.status == CategoryStatus.critical }) {
            primaryKey = .feedbackWasserKritisch
        } else if feedbacks.contains(where: { $0.status == CategoryStatus.warning }) {
            primaryKey = .feedbackWasserLeicht
        } else {
            primaryKey = FeedbackKey.positiveKeys.randomElement() ?? .feedbackPositiv1
        }
    }
}
