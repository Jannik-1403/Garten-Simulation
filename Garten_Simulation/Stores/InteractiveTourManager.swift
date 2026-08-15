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
    case badHabits = 10
    case todoPrompt = 11
    case todoIntro = 12
    case routinePrompt = 13
    case routineIntro = 14
    case shopPrompt = 15
    case shopIntro = 16
    case profilePrompt = 17
    case titles = 18
    case achievements = 19
    case streak = 20
    case inventory = 21
    case done = 22
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
