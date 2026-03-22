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

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
        }
        .modelContainer(modelContainer)
    }
}
