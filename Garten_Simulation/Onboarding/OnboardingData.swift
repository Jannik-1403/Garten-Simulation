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
    @Published var customZiel: String = ""
    @Published var gewaehltePflanzenIDs: [String] = []
    @Published var tutorialMuenzen: Int = 0
    @Published var erinnerungsZeiten: [String: Date] = [:]
    @Published var globalXPMultiplier: Double = 1.0
    /// Maps synthetic "custom.<UUID>" IDs → user-entered habit name for custom habits
    @Published var customHabitNames: [String: String] = [:]
    /// Maps custom IDs → selected icon asset/symbol name
    @Published var customHabitIcons: [String: String] = [:]
    /// Maps custom IDs → selected color name string
    @Published var customHabitColors: [String: String] = [:]
    /// Maps custom IDs → selected HabitCategory
    @Published var customHabitCategories: [String: HabitCategory] = [:]
}

