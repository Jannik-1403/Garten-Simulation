import Foundation
import Combine
import SwiftUI

// MARK: - DailyFeedbackViewModel

@MainActor
class DailyFeedbackViewModel: ObservableObject {

    @Published var feedbackText: String = ""
    @Published var currentKey: FeedbackKey = .feedbackPositiv1

    private var cancellables = Set<AnyCancellable>()

    init() {
        // Neu auswerten, wenn sich relevante HealthKit-Werte ändern
        let hm = HealthManager.shared
        let wgm = WaterGoalManager.shared

        Publishers.CombineLatest4(
            hm.$waterHistory7Days,
            hm.$stepsHistory7Days,
            hm.$lastStrengthWorkoutDate,
            wgm.$currentGoal
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _, _, _, _ in
            self?.reevaluate()
        }
        .store(in: &cancellables)

        hm.$todaysEnergy
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.reevaluate() }
            .store(in: &cancellables)

        reevaluate()
    }

    func reevaluate() {
        let hm = HealthManager.shared
        let wgm = WaterGoalManager.shared
        let nim = NutrientIndexManager.shared
        let store = FeedbackStore.shared

        // Schlechtesten Nährstoff bestimmen (< 70% des Bedarfs, mind. 1 Tracking-Tag)
        // Wir nutzen currentValue/targetDGE aus dem NutrientIndexManager für heute.
        // "3 von 7 Tracking-Tagen" würde historische Nährstoff-Daten brauchen – da diese
        // im NutrientIndexManager nicht als History vorliegen, vereinfachen wir:
        // Nur feuern wenn score < 70 UND energyToday > 0.
        let allNutrients = nim.vitamins + nim.minerals + [nim.fiber]
        let worstNutrient: (name: String, daysBelow: Int)? = allNutrients
            .filter { $0.isEnabled && $0.targetDGE > 0 && $0.score < 70 }
            .sorted { $0.score < $1.score }
            .first
            .map { ($0.name, 3) } // Konservativ: 3 Tage als Standardwert, da keine History

        let result = FeedbackScoringEngine.evaluate(
            waterHistory: hm.waterHistory7Days,
            waterGoal: wgm.currentGoal,
            stepsHistory: hm.stepsHistory7Days,
            lastStrengthDate: hm.lastStrengthWorkoutDate,
            hasWorkoutHistory: hm.hasAnyWorkoutHistory,
            energyToday: hm.todaysEnergy,
            worstNutrient: worstNutrient,
            userFactors: { store.factor(forKey: $0) }
        )

        feedbackText = result.formattedText
        currentKey = result.key
    }
}
