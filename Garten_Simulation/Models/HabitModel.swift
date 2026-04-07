import SwiftUI
import Combine

// MARK: - HabitModel (plain class — kein SwiftData benötigt)
class HabitModel: Identifiable, ObservableObject, Codable {
    let id: String
    var name: String
    var symbolName: String          // SF Symbol Name z.B. "leaf.fill"
    var symbolColor: String         // z.B. "green"
    var habitCategories: [HabitCategory]
    var symbolism: String
    var habitName: String
    var plantID: String // Link zur GameDatabase
    
    @Published var currentXP: Int
    @Published var streak: Int
    var letzteBewaesserung: Date?
    var gekauftAm: Date
    @Published var istBewässert: Bool  // heute schon gegossen?
    @Published var missedCycles: Int   // Wie viele 24h-Fenster verpasst?
    @Published var lastNotifiedCycle: Int // Welcher Zyklus wurde bereits "bestraft" (Herz-Abzug)?
    @Published var totalMlGegossen: Double = 0
    
    // Wiederbelebungs-System
    @Published var wiederbelebtAm: Date? = nil
    var strafTage: Int = 3
    
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

    var isDead: Bool {
        missedCycles >= 2
    }

    var isPenaltyActive: Bool {
        if let start = wiederbelebtAm {
            let tage = Calendar.current.dateComponents([.day], from: start, to: Date()).day ?? 0
            return tage < strafTage
        }
        return false
    }

    var ringFortschritt: Double {
        seltenheit.fortschritt(aktuelleXP: currentXP)
    }

    var formattedVolume: String {
        let liter = totalMlGegossen / 1000
        if liter < 1 {
            return String(format: "%.0f ml", totalMlGegossen)
        } else {
            return String(format: "%.1f Liter", liter)
        }
    }

    var timerIconName: String {
        let h = remainingHoursInCycle
        if h > 16 { return "Timer full" }
        if h > 8  { return "Timer half" }
        return "Timer empty"
    }

    var hoursSinceWatering: Double {
        guard let letzte = letzteBewaesserung else { return 0 }
        return Date().timeIntervalSince(letzte) / 3600.0
    }

    var remainingHoursInCycle: Int {
        let totalHours = hoursSinceWatering
        let currentCycleHours = totalHours.truncatingRemainder(dividingBy: 24.0)
        return max(0, Int(ceil(24.0 - currentCycleHours)))
    }

    var drynessSaturation: Double {
        if isDead { return 0.0 }
        // 0h: 1.0 -> 48h: 0.0
        let s = 1.0 - (hoursSinceWatering / 48.0)
        // Clamp between 0.2 and 1.0 so it's never fully black before death, or keep it 0.0 for dead.
        return max(0.0, min(1.0, s))
    }

    // MARK: - Init

    init(
        id: String = UUID().uuidString,
        name: String,
        symbolName: String,
        symbolColor: String = "green",
        habitCategories: [HabitCategory] = [.lifestyle],
        symbolism: String = "",
        habitName: String = "",
        maxLevel: Int = 10,
        xpPerCompletion: Int = 100,
        waterNeedPerDay: Int = 1,
        decayDays: Int = 3,
        missedCycles: Int = 0,
        lastNotifiedCycle: Int = 0,
        plantID: String? = nil
    ) {
        self.id = id
        self.name = name
        self.symbolName = symbolName
        self.symbolColor = symbolColor
        self.habitCategories = habitCategories
        self.symbolism = symbolism
        self.habitName = habitName.isEmpty ? (habitCategories.first?.localizationKey ?? "category.lifestyle") : habitName
        self.maxLevel = maxLevel
        self.xpPerCompletion = xpPerCompletion
        self.waterNeedPerDay = waterNeedPerDay
        self.decayDays = decayDays
        self.missedCycles = missedCycles
        self.lastNotifiedCycle = lastNotifiedCycle
        self.wiederbelebtAm = nil
        self.strafTage = 3
        
        // Fallback für plantID falls nicht übergeben
        if let pid = plantID {
            self.plantID = pid
        } else {
            // Heuristik: plant.NAME.name -> plant.NAME
            self.plantID = name.replacingOccurrences(of: ".name", with: "")
        }
        
        self.currentXP = 0
        self.streak = 0
        self.letzteBewaesserung = nil
        self.gekauftAm = Date()
        self.istBewässert = false
    }

    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case id, name, symbolName, symbolColor, habitCategories, habitCategory, symbolism, habitName
        case currentXP, streak, letzteBewaesserung, gekauftAm, istBewässert
        case maxLevel, xpPerCompletion, waterNeedPerDay, decayDays, missedCycles, lastNotifiedCycle
        case notiz, notizen, timerDatum, xpHistory, totalCoinsEarned, totalMlGegossen, plantID
        case wiederbelebtAm, strafTage
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        symbolName = try container.decode(String.self, forKey: .symbolName)
        symbolColor = try container.decode(String.self, forKey: .symbolColor)
        
        // Migration für plantID (muss zuerst geladen werden für Kategorien-Sync)
        let decodedPlantID: String
        if let pid = try container.decodeIfPresent(String.self, forKey: .plantID) {
            decodedPlantID = pid
        } else {
            decodedPlantID = name.replacingOccurrences(of: ".name", with: "")
        }
        self.plantID = decodedPlantID

        // Migration für habitCategories
        if let cats = try container.decodeIfPresent([HabitCategory].self, forKey: .habitCategories) {
            habitCategories = cats
        } else if let single = try container.decodeIfPresent(HabitCategory.self, forKey: .habitCategory) {
            // Wenn möglich, echte Kategorien aus DB holen, sonst Fallback auf das gespeicherte
            if let dbPlant = GameDatabase.allPlants.first(where: { $0.id == decodedPlantID }) {
                habitCategories = dbPlant.habitCategories
            } else {
                habitCategories = [single]
            }
        } else {
            habitCategories = [.lifestyle]
        }
        
        symbolism = try container.decode(String.self, forKey: .symbolism)
        let savedHabitName = try container.decodeIfPresent(String.self, forKey: .habitName) ?? ""
        habitName = savedHabitName.isEmpty ? (habitCategories.first?.localizationKey ?? "category.lifestyle") : savedHabitName
        
        currentXP = try container.decode(Int.self, forKey: .currentXP)
        streak = try container.decode(Int.self, forKey: .streak)
        letzteBewaesserung = try container.decodeIfPresent(Date.self, forKey: .letzteBewaesserung)
        gekauftAm = try container.decode(Date.self, forKey: .gekauftAm)
        istBewässert = try container.decode(Bool.self, forKey: .istBewässert)
        
        maxLevel = try container.decode(Int.self, forKey: .maxLevel)
        xpPerCompletion = try container.decode(Int.self, forKey: .xpPerCompletion)
        waterNeedPerDay = try container.decode(Int.self, forKey: .waterNeedPerDay)
        decayDays = try container.decode(Int.self, forKey: .decayDays)
        missedCycles = try container.decodeIfPresent(Int.self, forKey: .missedCycles) ?? 0
        lastNotifiedCycle = try container.decodeIfPresent(Int.self, forKey: .lastNotifiedCycle) ?? 0
        
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
        totalMlGegossen = try container.decodeIfPresent(Double.self, forKey: .totalMlGegossen) ?? 0
        wiederbelebtAm = try container.decodeIfPresent(Date.self, forKey: .wiederbelebtAm)
        strafTage = try container.decodeIfPresent(Int.self, forKey: .strafTage) ?? 3
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(symbolName, forKey: .symbolName)
        try container.encode(symbolColor, forKey: .symbolColor)
        try container.encode(habitCategories, forKey: .habitCategories)
        try container.encode(symbolism, forKey: .symbolism)
        try container.encode(habitName, forKey: .habitName)
        
        try container.encode(currentXP, forKey: .currentXP)
        try container.encode(streak, forKey: .streak)
        try container.encode(letzteBewaesserung, forKey: .letzteBewaesserung)
        try container.encode(gekauftAm, forKey: .gekauftAm)
        try container.encode(istBewässert, forKey: .istBewässert)
        
        try container.encode(maxLevel, forKey: .maxLevel)
        try container.encode(xpPerCompletion, forKey: .xpPerCompletion)
        try container.encode(waterNeedPerDay, forKey: .waterNeedPerDay)
        try container.encode(decayDays, forKey: .decayDays)
        try container.encode(missedCycles, forKey: .missedCycles)
        try container.encode(lastNotifiedCycle, forKey: .lastNotifiedCycle)
        
        try container.encode(notizen, forKey: .notizen)
        try container.encodeIfPresent(timerDatum, forKey: .timerDatum)
        try container.encode(xpHistory, forKey: .xpHistory)
        try container.encode(totalCoinsEarned, forKey: .totalCoinsEarned)
        try container.encode(totalMlGegossen, forKey: .totalMlGegossen)
        try container.encode(plantID, forKey: .plantID)
        try container.encodeIfPresent(wiederbelebtAm, forKey: .wiederbelebtAm)
        try container.encode(strafTage, forKey: .strafTage)
    }
}

// MARK: - Equatable
extension HabitModel: Equatable {
    static func == (lhs: HabitModel, rhs: HabitModel) -> Bool {
        lhs.id == rhs.id
    }
}
