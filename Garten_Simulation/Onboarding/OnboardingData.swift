import SwiftUI
import Combine

struct CustomOnboardingPflanze: Identifiable, Codable {
    var id = UUID()
    var name: String
    var sfSymbol: String
    var farbe: String
}

class OnboardingData: ObservableObject {
    @Published var currentStep: Int = 1
    @Published var gewaehltesZiel: OnboardingZiel? = nil
    @Published var gewaehltePflanzenIDs: [String] = []
    @Published var customPflanzen: [CustomOnboardingPflanze] = []
    @Published var zielFehlt: Bool = false
    @Published var tutorialMuenzen: Int = 0
    @Published var erinnerungsZeiten: [String: Date] = [:]
    @Published var globalXPMultiplier: Double = 1.0
}
