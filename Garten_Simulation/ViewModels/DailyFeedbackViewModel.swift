import Foundation
import Combine
import SwiftUI

// MARK: - DailyFeedbackViewModel

@MainActor
class DailyFeedbackViewModel: ObservableObject {

    @Published var categoryFeedbacks: [CategoryFeedback] = []
    @Published var headerText: String = ""

    /// Der wichtigste Key für FeedbackStore (schlechteste Kategorie)
    @Published var primaryKey: FeedbackKey = .feedbackPositiv1

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

        // Prüfen ob Nutzer eine Lauf-Pflanze hat (aus GardenStore via UserDefaults nicht direkt erreichbar)
        // Wir nutzen hasAnyWorkoutHistory als Proxy — Laufen-Routing erfolgt über hasRunningPlant
        // Die GardenStore-Pflanzen sind hier nicht direkt zugänglich; wir lesen aus dem separaten
        // UserDefaults-Key, den wir beim Auswertungsaufruf von außen übergeben könnten.
        // Vereinfachung: Wenn todaysRunning > 0, immer anzeigen. Sonst nur wenn explizit gesetzt.
        let hasRunningPlant = UserDefaults.standard.bool(forKey: "feedback_hasRunningPlant")

        // Protein-Ziel aus UserDefaults (wird von MacroCalculator/HealthManager gesetzt)
        let proteinGoal = UserDefaults.standard.double(forKey: "goal_protein")
        let fiberGoal = 30.0 // DGE-Empfehlung, NutrientIndexManager default

        let input = FeedbackScoringEngine.EvaluationInput(
            waterToday: hm.todaysWater,
            waterGoal: wgm.currentGoal,
            waterHistory7Days: hm.waterHistory7Days,
            sleepHoursToday: hm.todaysSleep,
            sleepGoalHours: 8.0,
            sleepRegularity: hm.sleepRegularityPercentage,
            strengthDaysAgo: strengthDaysAgo,
            hasStrengthHistory: hm.hasAnyWorkoutHistory,
            runningMinutesToday: hm.todaysRunning,
            hasRunningPlant: hasRunningPlant || hm.todaysRunning > 0,
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
        headerText = FeedbackScoringEngine.headerText(from: feedbacks)

        // Primären Key für FeedbackStore bestimmen (schlechteste Kategorie)
        if feedbacks.contains(where: { $0.status == .critical }) {
            primaryKey = .feedbackWasserKritisch
        } else if feedbacks.contains(where: { $0.status == .warning }) {
            primaryKey = .feedbackWasserLeicht
        } else {
            primaryKey = FeedbackKey.positiveKeys.randomElement() ?? .feedbackPositiv1
        }
    }
}
