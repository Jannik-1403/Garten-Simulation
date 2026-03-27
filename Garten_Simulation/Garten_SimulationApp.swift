import SwiftData
import SwiftUI

@main
struct Garten_SimulationApp: App {
    private let modelContainer: ModelContainer = {
        do {
            return try ModelContainer(for: Schema([Gewohnheit.self, Pflanze.self]))
        } catch {
            fatalError("SwiftData ModelContainer: \(error)")
        }
    }()

    @StateObject private var shopStore = ShopStore()
    @StateObject private var settingsStore = SettingsStore()
    @StateObject private var progressStore = GardenProgressStore()
    @StateObject private var streakStore = StreakStore()

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(shopStore)
                .environmentObject(settingsStore)
                .environmentObject(progressStore)
                .environmentObject(streakStore)
        }
        .modelContainer(modelContainer)
    }
}
