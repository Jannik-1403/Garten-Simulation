import ActivityKit
import Foundation

public struct GardenActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var gegossenePflanzen: Int
        public var gesamtPflanzen: Int
        public var wetterIcon: String
        public var wetterName: String
        public var streakTage: Int
        public var nachricht: String

        public init(gegossenePflanzen: Int, gesamtPflanzen: Int, wetterIcon: String, wetterName: String, streakTage: Int, nachricht: String) {
            self.gegossenePflanzen = gegossenePflanzen
            self.gesamtPflanzen = gesamtPflanzen
            self.wetterIcon = wetterIcon
            self.wetterName = wetterName
            self.streakTage = streakTage
            self.nachricht = nachricht
        }
        
        public var fortschritt: Double {
            guard gesamtPflanzen > 0 else { return 1.0 }
            return Double(gegossenePflanzen) / Double(gesamtPflanzen)
        }
    }

    public var gartenName: String

    public init(gartenName: String) {
        self.gartenName = gartenName
    }
}
