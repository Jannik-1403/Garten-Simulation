import SwiftUI
import Combine

enum TourStep: Int, CaseIterable {
    case coinsIntro = 0
    case livesIntro = 1
    case streakHeaderIntro = 2
    case dailyRingIntro = 3
    case intro = 4
    case focusTimer = 5
    case plantTodos = 6
    case plantNotes = 7
    case plantTimer = 8
    case plantHealth = 9
    case plantStreak = 10
    case plantPath = 11
    case badHabits = 12
    case todoPrompt = 13
    case todoIntro = 14
    case routinePrompt = 15
    case routineIntro = 16
    case shopPrompt = 17
    case shopIntro = 18
    case profilePrompt = 19
    case titles = 20
    case achievements = 21
    case streak = 22
    case inventory = 23
    case done = 24
}

class InteractiveTourManager: ObservableObject {
    @Published var isActive: Bool = false
    @Published var currentStep: TourStep = .coinsIntro
    @Published var anchors: [TourStep: CGRect] = [:]
    @Published var showTimerSheet: Bool = false
    @Published var showPlantDetail: HabitModel? = nil
    
    // Wir übergeben SettingsStore bei der Initialisierung nicht zwingend, 
    // sondern rufen es bei Beendigung auf, falls nötig, oder speichern den Status lokal in @AppStorage.
    // Aber es ist besser, den SettingsStore-Status direkt aus der View heraus zu setzen, 
    // oder wir haben eine `onComplete`-Closure.
    var onComplete: (() -> Void)? = nil
    
    func startTour() {
        withAnimation(.spring()) {
            currentStep = .coinsIntro
            isActive = true
        }
    }
    
    func nextStep() {
        if let next = TourStep(rawValue: currentStep.rawValue + 1) {
            withAnimation(.spring()) {
                currentStep = next
            }
            if next == .focusTimer {
                // Let the overlay handle programmatic navigation in the nextStep or onNext closure
            }
            if next == .done {
                endTour()
            }
        }
    }
    
    func endTour() {
        withAnimation(.spring()) {
            isActive = false
        }
        onComplete?()
    }
}
