import SwiftUI
import SwiftData

@main
struct Garten_SimulationApp: App {
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
        }
        .modelContainer(for: Gewohnheit.self)
    }
}
