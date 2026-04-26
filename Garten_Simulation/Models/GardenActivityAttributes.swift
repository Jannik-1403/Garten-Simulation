import ActivityKit
import Foundation

struct GardenActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var gegossenePflanzen: Int
        var gesamtPflanzen: Int
        var wetterIcon: String
        var wetterName: String
        var streakTage: Int
        var nachricht: String
        
        var fortschritt: Double {
            guard gesamtPflanzen > 0 else { return 1.0 }
            return Double(gegossenePflanzen) / Double(gesamtPflanzen)
        }
    }

    var gartenName: String
}
