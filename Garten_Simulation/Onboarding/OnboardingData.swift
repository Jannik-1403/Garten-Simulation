import SwiftUI
import Combine

struct CustomOnboardingPflanze: Identifiable, Codable {
    var id = UUID()
    var name: String
    var sfSymbol: String
    var farbe: String
    var habitCategory: HabitCategory = .lifestyle
}

class OnboardingData: ObservableObject {
    @Published var currentStep: Int = 1
    @Published var gewaehltesZiele: [OnboardingZiel] = []
    @Published var gewaehltePflanzenIDs: [String] = []
    @Published var tutorialMuenzen: Int = 0
    @Published var erinnerungsZeiten: [String: Date] = [:]
    @Published var globalXPMultiplier: Double = 1.0
}
