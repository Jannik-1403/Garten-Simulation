import SwiftUI
import Combine

// MARK: - HabitModel (plain class — kein SwiftData benötigt)
class HabitModel: Identifiable, ObservableObject {
    let id: String
    var name: String
    var symbolName: String          // SF Symbol Name z.B. "leaf.fill"
    var symbolColor: String         // z.B. "green"
    var habitCategory: HabitCategory
    var symbolism: String
    
    @Published var currentXP: Int
    @Published var streak: Int
    var letzteBewaesserung: Date?
    var gekauftAm: Date
    @Published var istBewässert: Bool  // heute schon gegossen?
    
    // Performance / Growth Parameters from Database
    var maxLevel: Int
    var xpPerCompletion: Int
    var waterNeedPerDay: Int
    var decayDays: Int

    // MARK: - Computed Properties
    
    var color: Color {
        // Here we can use the same logic as GameDatabase helper
        switch symbolColor {
        case "green":   return .green
        case "mint":    return .mint
        case "teal":    return .teal
        case "cyan":    return .cyan
        case "yellow":  return .yellow
        case "orange":  return .orange
        case "red":     return .red
        case "pink":    return .pink
        case "purple":  return .purple
        case "blue":    return .blue
        case "indigo":  return .indigo
        case "brown":   return .brown
        case "gray":    return .gray
        default:        return .green
        }
    }

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

    init(
        id: String = UUID().uuidString,
        name: String,
        symbolName: String,
        symbolColor: String = "green",
        habitCategory: HabitCategory = .lifestyle,
        symbolism: String = "",
        maxLevel: Int = 10,
        xpPerCompletion: Int = 10,
        waterNeedPerDay: Int = 1,
        decayDays: Int = 3
    ) {
        self.id = id
        self.name = name
        self.symbolName = symbolName
        self.symbolColor = symbolColor
        self.habitCategory = habitCategory
        self.symbolism = symbolism
        self.maxLevel = maxLevel
        self.xpPerCompletion = xpPerCompletion
        self.waterNeedPerDay = waterNeedPerDay
        self.decayDays = decayDays
        
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
