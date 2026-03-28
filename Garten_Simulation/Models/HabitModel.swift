import SwiftUI
import Combine

// MARK: - HabitModel (plain class — kein SwiftData benötigt)
class HabitModel: Identifiable, ObservableObject {
    let id: String
    var name: String
    var bildName: String            // Asset-Name z.B. "bonsai_stufe1"
    @Published var currentXP: Int
    @Published var streak: Int
    var letzteBewaesserung: Date?
    var gekauftAm: Date
    @Published var istBewässert: Bool  // heute schon gegossen?

    // MARK: - Computed Properties

    var seltenheit: PflanzenSeltenheit {
        if currentXP >= GameConstants.xpFuerDiamant { return .diamant }
        if currentXP >= GameConstants.xpFuerGold    { return .gold }
        if currentXP >= GameConstants.xpFuerSilber  { return .silber }
        return .bronze
    }

    var timerLaeuftAb: Date? {
        guard let letzte = letzteBewaesserung else { return nil }
        return letzte.addingTimeInterval(GameConstants.streakTimerStunden * 3600)
    }

    var streakAbgelaufen: Bool {
        guard let ablauf = timerLaeuftAb else { return false }
        return Date() > ablauf
    }

    var ringFortschritt: Double {
        seltenheit.fortschritt(aktuelleXP: currentXP)
    }

    // MARK: - Init

    init(id: String, name: String, bildName: String) {
        self.id = id
        self.name = name
        self.bildName = bildName
        self.currentXP = 0
        self.streak = 0
        self.letzteBewaesserung = nil
        self.gekauftAm = Date()
        self.istBewässert = false
    }
}

// MARK: - Equatable
extension HabitModel: Equatable {
    static func == (lhs: HabitModel, rhs: HabitModel) -> Bool {
        lhs.id == rhs.id
    }
}
