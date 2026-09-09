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

        Publishers.MergeMany(
            hm.$todaysWater.map { _ in () }.eraseToAnyPublisher(),
            hm.$waterHistory7Days.map { _ in () }.eraseToAnyPublisher(),
            hm.$todaysSleep.map { _ in () }.eraseToAnyPublisher(),
            hm.$lastStrengthWorkoutDate.map { _ in () }.eraseToAnyPublisher(),
            hm.$todaysRunning.map { _ in () }.eraseToAnyPublisher(),
            hm.$todaysEnergy.map { _ in () }.eraseToAnyPublisher(),
            hm.$todaysProtein.map { _ in () }.eraseToAnyPublisher(),
            hm.$todaysFiber.map { _ in () }.eraseToAnyPublisher(),
            wgm.$currentGoal.map { _ in () }.eraseToAnyPublisher()
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

        let hasWaterPlant = activeHabits.contains { $0.automaticHealthMetric == HealthMetricType.water }
        let hasSleepPlant = activeHabits.contains { $0.automaticHealthMetric == HealthMetricType.sleep }
        let hasStrengthPlant = activeHabits.contains { $0.automaticHealthMetric == HealthMetricType.strengthTraining }
        let hasRunningPlant = activeHabits.contains { $0.automaticHealthMetric == HealthMetricType.steps } // In HabitModel ist Laufen als .steps gemappt
        let hasNutritionPlant = activeHabits.contains {
            $0.automaticHealthMetric == HealthMetricType.energy ||
            $0.automaticHealthMetric == HealthMetricType.fiber ||
            $0.habitName.lowercased().contains("gemüse") ||
            $0.habitName.lowercased().contains("kochen")
        }

        // Protein-Ziel aus UserDefaults (wird von MacroCalculator/HealthManager gesetzt)
        let proteinGoal = UserDefaults.standard.double(forKey: "goal_protein")
        let fiberGoal = 30.0 // DGE-Empfehlung, NutrientIndexManager default

        let input = FeedbackScoringEngine.EvaluationInput(
            hasWaterPlant: hasWaterPlant,
            hasSleepPlant: hasSleepPlant,
            hasStrengthPlant: hasStrengthPlant,
            hasRunningPlant: hasRunningPlant,
            hasNutritionPlant: hasNutritionPlant,
            waterToday: hm.todaysWater,
            waterGoal: wgm.currentGoal,
            waterHistory7Days: hm.waterHistory7Days,
            sleepHoursToday: hm.todaysSleep,
            sleepGoalHours: 8.0,
            sleepRegularity: hm.sleepRegularityPercentage,
            strengthDaysAgo: strengthDaysAgo,
            hasStrengthHistory: hm.hasAnyWorkoutHistory,
            runningMinutesToday: hm.todaysRunning,
            energyToday: hm.todaysEnergy,
            proteinToday: hm.todaysProtein,
            proteinGoal: proteinGoal > 0 ? proteinGoal : 120.0,
            fiberToday: hm.todaysFiber,
            fiberGoal: fiberGoal,
            worstMineralName: worstMineral?.name,
            worstMineralScore: worstMineral?.score ?? 100,
            userFactors: { store.factor(forKey: $0) }
        )

        let feedbacks = FeedbackScoringEngine.evaluateAll(input: input)
        categoryFeedbacks = feedbacks
        issueFeedbacks = feedbacks.filter { $0.status == CategoryStatus.warning || $0.status == CategoryStatus.critical }
        headerText = FeedbackScoringEngine.headerText(from: feedbacks)

        // Tages-Score berechnen (Good = 100, Warning = 50, Critical = 0)
        let availableFeedbacks = feedbacks.filter { $0.status != CategoryStatus.unavailable }
        if availableFeedbacks.isEmpty {
            dailyScore = 0
        } else {
            let total = availableFeedbacks.reduce(0) { sum, fb in
                switch fb.status {
                case .good: return sum + 100
                case .warning: return sum + 50
                case .critical: return sum + 0
                case .unavailable: return sum
                }
            }
            dailyScore = total / availableFeedbacks.count
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
