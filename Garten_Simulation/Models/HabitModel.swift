import SwiftUI
import Combine

// MARK: - HabitModel (plain class — kein SwiftData benötigt)
class HabitModel: Identifiable, ObservableObject, Codable {
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
    
    // Notizen & Timer
    @Published var notizen: [String] = []
    var timerDatum: Date? = nil
    
    // XP Verlauf für die Wochenübersicht (Datum im Format "yyyy-MM-dd": XP an diesem Tag)
    @Published var xpHistory: [String: Int] = [:]
    
    // Lebenslange Einnahmen durch diese Pflanze
    @Published var totalCoinsEarned: Int = 0
    
    // Performance / Growth Parameters from Database
    var maxLevel: Int
    var xpPerCompletion: Int
    var waterNeedPerDay: Int
    var decayDays: Int

    var basePrice: Int {
        let basis = xpPerCompletion * 10
        let levelBonus = maxLevel > 10 ? 50 : 0
        return basis + levelBonus
    }

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

    var stufe: PflanzenStufe {
        PflanzenStufe.allCases.last { GameConstants.xpSchwelle(fuer: $0) <= self.currentXP } ?? .bronze1
    }

    var fortschrittZurNaechstenStufe: Double {
        guard let naechste = stufe.naechste else { return 1.0 }
        let aktuelleMin = GameConstants.xpSchwelle(fuer: stufe)
        let naechsteMin = GameConstants.xpSchwelle(fuer: naechste)
        return Double(currentXP - aktuelleMin) / Double(naechsteMin - aktuelleMin)
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

    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case id, name, symbolName, symbolColor, habitCategory, symbolism
        case currentXP, streak, letzteBewaesserung, gekauftAm, istBewässert
        case maxLevel, xpPerCompletion, waterNeedPerDay, decayDays
        case notiz, notizen, timerDatum, xpHistory, totalCoinsEarned
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        symbolName = try container.decode(String.self, forKey: .symbolName)
        symbolColor = try container.decode(String.self, forKey: .symbolColor)
        habitCategory = try container.decode(HabitCategory.self, forKey: .habitCategory)
        symbolism = try container.decode(String.self, forKey: .symbolism)
        
        currentXP = try container.decode(Int.self, forKey: .currentXP)
        streak = try container.decode(Int.self, forKey: .streak)
        letzteBewaesserung = try container.decodeIfPresent(Date.self, forKey: .letzteBewaesserung)
        gekauftAm = try container.decode(Date.self, forKey: .gekauftAm)
        istBewässert = try container.decode(Bool.self, forKey: .istBewässert)
        
        maxLevel = try container.decode(Int.self, forKey: .maxLevel)
        xpPerCompletion = try container.decode(Int.self, forKey: .xpPerCompletion)
        waterNeedPerDay = try container.decode(Int.self, forKey: .waterNeedPerDay)
        decayDays = try container.decode(Int.self, forKey: .decayDays)
        
        if let existingNotes = try container.decodeIfPresent([String].self, forKey: .notizen) {
            notizen = existingNotes
        } else if let oldNote = try container.decodeIfPresent(String.self, forKey: .notiz), !oldNote.isEmpty {
            notizen = [oldNote]
        } else {
            notizen = []
        }
        timerDatum = try container.decodeIfPresent(Date.self, forKey: .timerDatum)
        xpHistory = try container.decodeIfPresent([String: Int].self, forKey: .xpHistory) ?? [:]
        totalCoinsEarned = try container.decodeIfPresent(Int.self, forKey: .totalCoinsEarned) ?? 0
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(symbolName, forKey: .symbolName)
        try container.encode(symbolColor, forKey: .symbolColor)
        try container.encode(habitCategory, forKey: .habitCategory)
        try container.encode(symbolism, forKey: .symbolism)
        
        try container.encode(currentXP, forKey: .currentXP)
        try container.encode(streak, forKey: .streak)
        try container.encode(letzteBewaesserung, forKey: .letzteBewaesserung)
        try container.encode(gekauftAm, forKey: .gekauftAm)
        try container.encode(istBewässert, forKey: .istBewässert)
        
        try container.encode(maxLevel, forKey: .maxLevel)
        try container.encode(xpPerCompletion, forKey: .xpPerCompletion)
        try container.encode(waterNeedPerDay, forKey: .waterNeedPerDay)
        try container.encode(decayDays, forKey: .decayDays)
        
        try container.encode(notizen, forKey: .notizen)
        try container.encodeIfPresent(timerDatum, forKey: .timerDatum)
        try container.encode(xpHistory, forKey: .xpHistory)
        try container.encode(totalCoinsEarned, forKey: .totalCoinsEarned)
    }
}

// MARK: - Equatable
extension HabitModel: Equatable {
    static func == (lhs: HabitModel, rhs: HabitModel) -> Bool {
        lhs.id == rhs.id
    }
}
