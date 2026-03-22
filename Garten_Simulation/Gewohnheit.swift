import SwiftData
import Foundation

@Model
class Gewohnheit {
    var name: String
    var emoji: String
    var streak: Int
    var gesundheit: Double
    var letzteAktion: Date?
    var istGesperrt: Bool
    
    init(name: String, emoji: String) {
        self.name = name
        self.emoji = emoji
        self.streak = 0
        self.gesundheit = 1.0
        self.letzteAktion = nil
        self.istGesperrt = false
    }
}
