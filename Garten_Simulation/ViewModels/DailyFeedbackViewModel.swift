import Foundation
import Combine
import SwiftUI
import WidgetKit

// MARK: - DailyFeedbackViewModel

@MainActor
class DailyFeedbackViewModel: ObservableObject {

    @Published var categoryFeedbacks: [CategoryFeedback] = []
    @Published var issueFeedbacks: [CategoryFeedback] = []
    @Published var dailyScore: Int = 100
    @Published var headerText: String = ""
    @Published var primaryKey: FeedbackKey = .feedbackPositiv1
    @Published var targetDate: Date = Date()
    @Published var isSwipingToPast: Bool = false

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
            cm.$tasks.map { _ in () }.eraseToAnyPublisher(),
            cm.$logs.map { _ in () }.eraseToAnyPublisher()
        )
        .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
        .sink { [weak self] in self?.reevaluate() }
        .store(in: &cancellables)

        reevaluate()
    }

    /// `true`, sobald die View echte Habits übergeben hat. Verhindert, dass der Init-Durchlauf
    /// (mit leeren Habits) einen falschen Score ins Widget schreibt.
    private var hasReceivedHabits = false

    func reevaluate() {
        if !activeHabits.isEmpty { hasReceivedHabits = true }

        let evaluation = Self.evaluate(targetDate: targetDate, activeHabits: activeHabits)
        let feedbacks = evaluation.feedbacks

        categoryFeedbacks = feedbacks
        issueFeedbacks = feedbacks.filter { $0.status != CategoryStatus.unavailable }
        headerText = FeedbackScoringEngine.headerText(from: feedbacks)
        dailyScore = evaluation.dailyScore

        // Widget NUR mit dem heutigen Score füttern – vergangene Tage (TabView-Pages, Kalender)
        // dürfen den Sperrbildschirm-Score nicht überschreiben.
        if hasReceivedHabits && Calendar.current.isDateInToday(targetDate) {
            Self.publishWidgetScore(evaluation.dailyScore)
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
