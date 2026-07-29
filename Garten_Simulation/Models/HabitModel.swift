import SwiftUI
import Combine

// MARK: - Reminder Schedule Types

struct TimerEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var time: Date
    var customMessage: String?
    var repeatMode: ReminderRepeatMode
    var activeWeekdays: Set<Int> // 1=Mo, 7=So
    var isEnabled: Bool
    var eventIdentifier: String? // for calendar sync
    
    func isExpired(startDate: Date) -> Bool {
        switch repeatMode {
        case .forever:
            return false
        case .once:
            return Date().timeIntervalSince(startDate) > 7 * 24 * 3600
        case .month:
            return Date().timeIntervalSince(startDate) > 30 * 24 * 3600
        case .year:
            return Date().timeIntervalSince(startDate) > 365 * 24 * 3600
        }
    }
}

struct WeekdayReminder: Codable, Identifiable, Equatable {
    var id: Int { weekday }
    var weekday: Int              // 1=Mo, 2=Di, 3=Mi, 4=Do, 5=Fr, 6=Sa, 7=So
    var time: Date                // Nur Stunde:Minute relevant
    var customMessage: String?    // Individueller Benachrichtigungstext pro Tag
    var isEnabled: Bool = true
    var repeatMode: ReminderRepeatMode = .forever // NEU
    
    /// Konvertiert unseren Wochentag (Mo=1...So=7) zu Apples DateComponents.weekday (So=1...Sa=7)
    var appleWeekday: Int {
        weekday == 7 ? 1 : weekday + 1  // So(7)→1, Mo(1)→2, Di(2)→3, ...
    }
    
    enum CodingKeys: String, CodingKey {
        case weekday, time, customMessage, isEnabled, repeatMode
    }
    
    init(weekday: Int, time: Date, customMessage: String? = nil, isEnabled: Bool = true, repeatMode: ReminderRepeatMode = .forever) {
        self.weekday = weekday
        self.time = time
        self.customMessage = customMessage
        self.isEnabled = isEnabled
        self.repeatMode = repeatMode
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        weekday = try container.decode(Int.self, forKey: .weekday)
        time = try container.decode(Date.self, forKey: .time)
        customMessage = try container.decodeIfPresent(String.self, forKey: .customMessage)
        isEnabled = try container.decodeIfPresent(Bool.self, forKey: .isEnabled) ?? true
        repeatMode = try container.decodeIfPresent(ReminderRepeatMode.self, forKey: .repeatMode) ?? .forever
    }
    
    func isExpired(startDate: Date) -> Bool {
        switch repeatMode {
        case .forever:
            return false
        case .once:
            return Date().timeIntervalSince(startDate) > 7 * 24 * 3600
        case .month:
            return Date().timeIntervalSince(startDate) > 30 * 24 * 3600
        case .year:
            return Date().timeIntervalSince(startDate) > 365 * 24 * 3600
        }
    }
}

enum ReminderRepeatMode: String, Codable, CaseIterable {
    case once    = "once"     // Einmalig
    case month   = "month"    // 1 Monat
    case year    = "year"     // 1 Jahr
    case forever = "forever"  // Unbegrenzt (Standard)
    
    var localizationKey: String {
        switch self {
        case .once:    return "timer.repeat.once"
        case .month:   return "timer.repeat.month"
        case .year:    return "timer.repeat.year"
        case .forever: return "timer.repeat.forever"
        }
    }
    
    var sfSymbol: String {
        switch self {
        case .once:    return "1.circle"
        case .month:   return "calendar"
        case .year:    return "calendar.badge.clock"
        case .forever: return "infinity"
        }
    }
}

struct ReminderSchedule: Codable, Equatable {
    var entries: [TimerEntry] = []
    var startDate: Date = Date()            // Wann der Timer begonnen hat
    
    private enum CodingKeys: String, CodingKey {
        case entries, weekdays, startDate, repeatMode
    }
    
    init(entries: [TimerEntry], startDate: Date = Date()) {
        self.entries = entries
        self.startDate = startDate
    }
    
    init(weekdays: [WeekdayReminder], startDate: Date = Date()) {
        self.startDate = startDate
        self.entries = []
        let globalRepeatMode = ReminderRepeatMode.forever
        for wd in weekdays {
            let entry = TimerEntry(
                time: wd.time,
                customMessage: wd.customMessage,
                repeatMode: wd.repeatMode == .forever ? globalRepeatMode : wd.repeatMode,
                activeWeekdays: [wd.weekday],
                isEnabled: wd.isEnabled
            )
            self.entries.append(entry)
        }
    }

    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        startDate = try container.decodeIfPresent(Date.self, forKey: .startDate) ?? Date()
        
        if let decodedEntries = try container.decodeIfPresent([TimerEntry].self, forKey: .entries) {
            self.entries = decodedEntries
        } else {
            // MIGRATION: Convert old weekdays array to TimerEntry
            self.entries = []
            if let decodedWeekdays = try container.decodeIfPresent([WeekdayReminder].self, forKey: .weekdays) {
                var globalRepeatMode = ReminderRepeatMode.forever
                if let oldRepeatMode = try container.decodeIfPresent(ReminderRepeatMode.self, forKey: .repeatMode) {
                    globalRepeatMode = oldRepeatMode
                }
                for wd in decodedWeekdays {
                    let entry = TimerEntry(
                        time: wd.time,
                        customMessage: wd.customMessage,
                        repeatMode: wd.repeatMode == .forever ? globalRepeatMode : wd.repeatMode,
                        activeWeekdays: [wd.weekday],
                        isEnabled: wd.isEnabled
                    )
                    self.entries.append(entry)
                }
            }
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(entries, forKey: .entries)
        try container.encode(startDate, forKey: .startDate)
    }
    
    /// Erstellt einen Standard-Schedule mit gleicher Zeit an allen Tagen
    static func defaultSchedule(time: Date, customMessage: String? = nil) -> ReminderSchedule {
        let entry = TimerEntry(
            time: time,
            customMessage: customMessage,
            repeatMode: .forever,
            activeWeekdays: Set(1...7),
            isEnabled: true
        )
        return ReminderSchedule(entries: [entry])
    }
    
    /// Prüft ob der Schedule abgelaufen ist
    var isExpired: Bool {
        let enabledEntries = entries.filter { $0.isEnabled }
        if enabledEntries.isEmpty { return true }
        return enabledEntries.allSatisfy { $0.isExpired(startDate: startDate) }
    }
    
    /// Gibt alle Einträge für den aktuellen Wochentag zurück (falls aktiviert und nicht abgelaufen)
    var todaysReminders: [TimerEntry] {
        let calendar = Calendar.current
        let appleWeekday = calendar.component(.weekday, from: Date()) // So=1...Sa=7
        let ourWeekday = appleWeekday == 1 ? 7 : appleWeekday - 1    // Mo=1...So=7
        
        return entries.filter { entry in
            entry.isEnabled && entry.activeWeekdays.contains(ourWeekday) && !entry.isExpired(startDate: startDate)
        }
    }
    
    /// Anzahl aktiver Tage
    var enabledDaysCount: Int {
        var uniqueDays = Set<Int>()
        for entry in entries where entry.isEnabled {
            uniqueDays.formUnion(entry.activeWeekdays)
        }
        return uniqueDays.count
    }
    
    /// MIGRATION/COMPATIBILITY: Berechnet virtuelle WeekdayReminder aus den neuen TimerEntry-Einträgen bzw. schreibt Änderungen in diese zurück.
    var weekdays: [WeekdayReminder] {
        get {
            var list: [WeekdayReminder] = []
            for entry in entries {
                for day in entry.activeWeekdays {
                    list.append(WeekdayReminder(
                        weekday: day,
                        time: entry.time,
                        customMessage: entry.customMessage,
                        isEnabled: entry.isEnabled,
                        repeatMode: entry.repeatMode
                    ))
                }
            }
            return list.sorted { $0.weekday < $1.weekday }
        }
        set {
            var tempEntries: [TimerEntry] = []
            for wd in newValue {
                if let idx = tempEntries.firstIndex(where: {
                    $0.time == wd.time &&
                    $0.customMessage == wd.customMessage &&
                    $0.repeatMode == wd.repeatMode &&
                    $0.isEnabled == wd.isEnabled
                }) {
                    tempEntries[idx].activeWeekdays.insert(wd.weekday)
                } else {
                    let entry = TimerEntry(
                        time: wd.time,
                        customMessage: wd.customMessage,
                        repeatMode: wd.repeatMode,
                        activeWeekdays: [wd.weekday],
                        isEnabled: wd.isEnabled
                    )
                    tempEntries.append(entry)
                }
            }
            self.entries = tempEntries
        }
    }

    
    /// MIGRATION/COMPATIBILITY: Gibt den heutigen WeekdayReminder zurück, falls vorhanden und aktiv
    var todaysReminder: WeekdayReminder? {
        let calendar = Calendar.current
        let appleWeekday = calendar.component(.weekday, from: Date()) // So=1...Sa=7
        let ourWeekday = appleWeekday == 1 ? 7 : appleWeekday - 1    // Mo=1...So=7
        
        return weekdays.first { wd in
            wd.weekday == ourWeekday && wd.isEnabled && !wd.isExpired(startDate: startDate)
        }
    }
}


// MARK: - HealthKit Metric Types
enum HealthMetricType: String, Codable, CaseIterable {
    case steps = "steps"
    case water = "water"
    case sleep = "sleep"
    case mindfulness = "mindfulness"
    case running = "running"
    case strengthTraining = "strengthTraining"
    
    var localizationKey: String {
        switch self {
        case .steps: return "health.metric.steps"
        case .water: return "health.metric.water"
        case .sleep: return "health.metric.sleep"
        case .mindfulness: return "health.metric.mindfulness"
        case .running: return "health.metric.running"
        case .strengthTraining: return "health.metric.strengthTraining"
        }
    }
}

// MARK: - HabitModel (plain class — kein SwiftData benötigt)
class HabitModel: Identifiable, ObservableObject, Codable {
    let id: String
    var name: String
    var symbolName: String          // SF Symbol Name z.B. "leaf.fill"
    var symbolColor: String         // z.B. "green"
    var habitCategory: HabitCategory
    var symbolism: String
    var habitName: String
    var plantID: String // Link zur GameDatabase
    
    var plantImageName: String {
        if let plant = GameDatabase.shared.plant(for: plantID), let asset = plant.assetName {
            return asset
        }
        return symbolName
    }
    
    var automaticHealthMetric: HealthMetricType? {
        let nameLower = habitName.lowercased()
        if nameLower.contains("joggen") || nameLower.contains("laufen") || nameLower.contains("running") || nameLower.contains("schritt") || nameLower.contains("spazieren") || nameLower.contains("walk") {
            return .steps
        } else if nameLower.contains("krafttraining") || nameLower.contains("fitness") || nameLower.contains("gym") || nameLower.contains("workout") {
            return .strengthTraining
        } else if nameLower.contains("trinken") || nameLower.contains("wasser") || nameLower.contains("water") {
            return .water
        } else if nameLower.contains("schlafen") || nameLower.contains("sleep") || nameLower.contains("ruhe") {
            return .sleep
        } else if nameLower.contains("meditieren") || nameLower.contains("mindfulness") || nameLower.contains("achtsamkeit") {
            return .mindfulness
        } else if nameLower.contains("schritte") || nameLower.contains("spazieren") || nameLower.contains("steps") {
            return .steps
        }
        return nil
    }
    
    @Published var currentXP: Int
    @Published var streak: Int
    var letzteBewaesserung: Date?
    var gekauftAm: Date
    @Published var istBewässert: Bool  // heute schon gegossen?
    @Published var missedCycles: Int   // Wie viele 24h-Fenster verpasst?
    @Published var lastNotifiedCycle: Int // Welcher Zyklus wurde bereits "bestraft" (Herz-Abzug)?
    @Published var totalMlGegossen: Double = 0
    @Published var lebenBereitsAbgezogen: Bool = false
    @Published var isDead: Bool = false
    @Published var isNegative: Bool = false
    
    // Wiederbelebungs-System
    @Published var wiederbelebtAm: Date? = nil
    var strafTage: Int = 3
    
    // Notizen & Timer & Todos
    @Published var notizen: [String] = []
    @Published var todos: [FocusGoal] = []
    var timerDatum: Date? = nil
    @Published var reminderTime: Date? = nil
    @Published var customReminderMessage: String? = nil
    @Published var reminderSchedule: ReminderSchedule? = nil  // Wochentag-basierter Timer
    @Published var individualSchwierigkeit: String? = nil // NEU: Individueller Pfad-Level
    @Published var pfadAktiviertAm: Date? = nil
    @Published var pfadCheckedDates: [Date] = []
    
    // Apple Health Integration (Pro Version)
    @Published var linkedHealthMetric: HealthMetricType? = nil
    @Published var healthTarget: Double? = nil
    @Published var allowManualTrackingForHealth: Bool = false
    
    // Eigener Tracker (Manuell)
    @Published var customTrackerName: String? = nil
    @Published var customTrackerTarget: Double? = nil
    @Published var customTrackerProgress: Double = 0
    
    // Custom ToDos in Routines
    @Published var isRoutineOnly: Bool = false
    
    // Generic Focus Session (not tied to a specific plant)
    @Published var isGenericFocus: Bool = false
    
    // Slider Progress (0.0 to 1.0)
    @Published var sliderProgress: Double = 0.0
    @Published var intradayProgressHistory: [DailyProgressEntry] = []
    
    // 90-Tage Challenge Joker System
    @Published var challengeJokers: Int = 0
    let maxChallengeJokers: Int = 3
    
    /// Hat die Pflanze einen aktiven (nicht abgelaufenen) Erinnerungs-Schedule?
    var hasActiveReminder: Bool {
        guard let schedule = reminderSchedule else {
            return reminderTime != nil  // Legacy-Fallback
        }
        return !schedule.isExpired && schedule.enabledDaysCount > 0
    }
    
    /// Gibt den heutigen WeekdayReminder zurück (falls vorhanden und aktiv)
    var todaysReminder: WeekdayReminder? {
        guard let schedule = reminderSchedule, !schedule.isExpired else { return nil }
        return schedule.todaysReminder
    }
    
    /// Gibt den nächsten anstehenden WeekdayReminder zurück (heute oder in der Zukunft)
    var nextActiveReminder: WeekdayReminder? {
        guard let schedule = reminderSchedule, !schedule.isExpired else { return nil }
        
        let calendar = Calendar.current
        let appleWeekday = calendar.component(.weekday, from: Date()) // So=1...Sa=7
        let ourWeekday = appleWeekday == 1 ? 7 : appleWeekday - 1    // Mo=1...So=7
        
        // Zuerst heute prüfen
        if let today = schedule.weekdays.first(where: { $0.weekday == ourWeekday && $0.isEnabled }), !today.isExpired(startDate: schedule.startDate) {
            return today
        }
        
        // Danach die nächsten Tage in der Woche prüfen
        for offset in 1...7 {
            let nextDay = ((ourWeekday - 1 + offset) % 7) + 1
            if let next = schedule.weekdays.first(where: { $0.weekday == nextDay && $0.isEnabled }), !next.isExpired(startDate: schedule.startDate) {
                return next
            }
        }
        
        return nil
    }
    
    // XP Verlauf für die Wochenübersicht (Datum im Format "yyyy-MM-dd": XP an diesem Tag)
    @Published var xpHistory: [String: Int] = [:]
    
    // Gieß-Log: jeder Gießvorgang wird mit Zeitstempel gespeichert
    @Published var wateringDates: [Date] = []
    
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

    var displayedHabitName: String {
        if !habitName.isEmpty { return habitName }
        
        // 1. Suche den Standard-Gewohnheitsnamen in der Datenbank (z.B. habit.meditieren)
        if let dbPlant = GameDatabase.allPlants.first(where: { $0.id.lowercased() == plantID.lowercased() }) {
            // Höchste Priorität: Der Standard-Name der Gewohnheit
            if !dbPlant.habitName.isEmpty {
                return dbPlant.habitName
            }
            // Zweite Priorität: Die Kategorie (z.B. category.mental)
            return dbPlant.habitCategory.localizationKey
        }
        
        return "common.habit" 
    }

    /// Gibt den lokalisierten Gewohnheitsnamen zurück.
    /// Wenn `displayedHabitName` ein Lokalisierungsschlüssel ist
    /// (z.B. "habit.frueh_aufstehen"), wird dieser übersetzt. Sonst direkte Ausgabe.
    var localizedHabitName: String {
        let raw = displayedHabitName
        let translated = Bundle.main.localizedString(forKey: raw, value: nil, table: nil)
        return translated == raw ? raw : translated
    }

    /// Wie `name`, aber mit Lokalisierung falls der Wert ein Schlüssel ist.
    var localizedName: String {
        let translated = Bundle.main.localizedString(forKey: name, value: nil, table: nil)
        return translated == name ? name : translated
    }

    var color: Color {
        let colorString: String
        if let plant = GameDatabase.shared.plant(for: plantID) {
            colorString = plant.symbolColor
        } else {
            colorString = symbolColor
        }
        
        let lower = colorString.lowercased()
        if lower == "red" || lower == "rot" {
            // Ein helleres Rot, damit es nicht wie "Schlechte Gewohnheit" (rotPrimary) wirkt
            return Color(red: 1.0, green: 0.45, blue: 0.45)
        }
        
        return AppColors.color(for: colorString)
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
        // Find next 0:00:00 starting from today
        Calendar.current.nextDate(after: Date(), matching: DateComponents(hour: 0, minute: 0, second: 0), matchingPolicy: .nextTime)
    }

    var streakAbgelaufen: Bool {
        guard let letzte = letzteBewaesserung else { return false }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let letzteDay = calendar.startOfDay(for: letzte)
        
        let daysPassed = calendar.dateComponents([.day], from: letzteDay, to: today).day ?? 0
        return daysPassed > 1
    }


    var showWarning: Bool {
        (missedCycles == 1 && !isDead) || isDead
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
            let unit = NSLocalizedString("common.ml", comment: "")
            return String(format: "%.0f %@", totalMlGegossen, unit)
        } else {
            let unit = NSLocalizedString("common.liter", comment: "")
            return String(format: "%.1f %@", liter, unit)
        }
    }

    var timerIconName: String {
        let h = remainingHoursInCycle
        if h > 36 { return "Timer full" }
        if h > 0  { return "Timer half" }
        return "Timer empty"
    }

    var hoursSinceThirstStarted: Double {
        let reference = letzteBewaesserung ?? gekauftAm
        let calendar = Calendar.current
        // Der Countdown beginnt erst ab der nächsten Mitternacht nach der letzten Aktion
        guard let naechsteMitternacht = calendar.nextDate(after: reference, matching: DateComponents(hour: 0, minute: 0, second: 0), matchingPolicy: .nextTime) else {
            return 0
        }
        let diff = Date().timeIntervalSince(naechsteMitternacht) / 3600.0
        return max(0, diff)
    }

    var remainingHoursInCycle: Int {
        let maxHours: Double = 72.0
        let elapsed = hoursSinceThirstStarted
        let diff = maxHours - elapsed
        return max(0, Int(ceil(diff)))
    }

    var drynessSaturation: Double {
        if isDead { return 0.0 }
        // Optische Sättigung basiert weiterhin auf der Gesamtzeit seit dem Gießen
        let reference = letzteBewaesserung ?? gekauftAm
        let totalElapsed = Date().timeIntervalSince(reference) / 3600.0
        let s = 1.0 - (totalElapsed / 72.0)
        return max(0.0, min(1.0, s))
    }

    // MARK: - Init

    init(
        id: String = UUID().uuidString,
        name: String,
        symbolName: String,
        symbolColor: String = "green",
        habitCategory: HabitCategory = .lifestyle,
        symbolism: String = "",
        habitName: String = "",
        maxLevel: Int = 10,
        xpPerCompletion: Int = 100,
        waterNeedPerDay: Int = 1,
        decayDays: Int = 3,
        missedCycles: Int = 0,
        lastNotifiedCycle: Int = 0,
        plantID: String? = nil,
        reminderTime: Date? = nil,
        customReminderMessage: String? = nil,
        isNegative: Bool = false,
        isRoutineOnly: Bool = false,
        isGenericFocus: Bool = false
    ) {
        self.id = id
        self.name = name
        self.symbolName = symbolName
        self.symbolColor = symbolColor
        self.habitCategory = habitCategory
        self.symbolism = symbolism
        self.habitName = habitName.isEmpty ? (habitCategory.localizationKey) : habitName
        self.maxLevel = maxLevel
        self.xpPerCompletion = xpPerCompletion
        self.waterNeedPerDay = waterNeedPerDay
        self.decayDays = decayDays
        self.missedCycles = missedCycles
        self.lastNotifiedCycle = lastNotifiedCycle
        self.isNegative = isNegative
        self.isRoutineOnly = isRoutineOnly
        self.isGenericFocus = isGenericFocus
        self.challengeJokers = 0
        self.wiederbelebtAm = nil
        self.strafTage = 3
        self.reminderTime = reminderTime
        self.customReminderMessage = customReminderMessage
        self.pfadAktiviertAm = nil
        self.pfadCheckedDates = []
        self.linkedHealthMetric = nil
        self.healthTarget = nil        
        // Wenn reminderTime gesetzt → automatisch Schedule erstellen
        if let rt = reminderTime {
            self.reminderSchedule = ReminderSchedule.defaultSchedule(time: rt, customMessage: customReminderMessage)
        }
        
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
        self.isDead = false
        self.lebenBereitsAbgezogen = false
        self.sliderProgress = 0.0
        self.intradayProgressHistory = []
    }

    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case id, name, symbolName, symbolColor, habitCategory, habitCategories, symbolism, habitName
        case currentXP, streak, letzteBewaesserung, gekauftAm, istBewässert
        case maxLevel, xpPerCompletion, waterNeedPerDay, decayDays, missedCycles, lastNotifiedCycle
        case notiz, notizen, timerDatum, xpHistory, totalCoinsEarned, totalMlGegossen, plantID
        case wiederbelebtAm, strafTage, reminderTime, customReminderMessage, wateringDates
        case lebenBereitsAbgezogen, isDead, isNegative
        case reminderSchedule
        case pfadAktiviertAm, pfadCheckedDates
        case individualSchwierigkeit
        case linkedHealthMetric, healthTarget, allowManualTrackingForHealth
        case customTrackerName, customTrackerTarget, customTrackerProgress
        case isRoutineOnly
        case isGenericFocus
        case challengeJokers
        case todos
        case sliderProgress, intradayProgressHistory
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
            habitCategory = cats.first ?? .lifestyle
        } else if let single = try container.decodeIfPresent(HabitCategory.self, forKey: .habitCategory) {
            habitCategory = single
        } else {
            // Wenn möglich, echte Kategorien aus DB holen, sonst Fallback
            if let dbPlant = GameDatabase.allPlants.first(where: { $0.id == decodedPlantID }) {
                habitCategory = dbPlant.habitCategory
            } else {
                habitCategory = .lifestyle
            }
        }
        
        symbolism = try container.decode(String.self, forKey: .symbolism)
        let savedHabitName = try container.decodeIfPresent(String.self, forKey: .habitName) ?? ""
        habitName = savedHabitName.isEmpty ? (habitCategory.localizationKey) : savedHabitName
        
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
        
        todos = try container.decodeIfPresent([FocusGoal].self, forKey: .todos) ?? []
        timerDatum = try container.decodeIfPresent(Date.self, forKey: .timerDatum)
        xpHistory = try container.decodeIfPresent([String: Int].self, forKey: .xpHistory) ?? [:]
        totalCoinsEarned = try container.decodeIfPresent(Int.self, forKey: .totalCoinsEarned) ?? 0
        totalMlGegossen = try container.decodeIfPresent(Double.self, forKey: .totalMlGegossen) ?? 0
        wiederbelebtAm = try container.decodeIfPresent(Date.self, forKey: .wiederbelebtAm)
        strafTage = try container.decodeIfPresent(Int.self, forKey: .strafTage) ?? 3
        reminderTime = try container.decodeIfPresent(Date.self, forKey: .reminderTime)
        customReminderMessage = try container.decodeIfPresent(String.self, forKey: .customReminderMessage)
        wateringDates = try container.decodeIfPresent([Date].self, forKey: .wateringDates) ?? []
        lebenBereitsAbgezogen = try container.decodeIfPresent(Bool.self, forKey: .lebenBereitsAbgezogen) ?? false
        isDead = try container.decodeIfPresent(Bool.self, forKey: .isDead) ?? false
        isNegative = try container.decodeIfPresent(Bool.self, forKey: .isNegative) ?? false
        pfadAktiviertAm = try container.decodeIfPresent(Date.self, forKey: .pfadAktiviertAm)
        pfadCheckedDates = try container.decodeIfPresent([Date].self, forKey: .pfadCheckedDates) ?? []
        
        // Migration: reminderSchedule laden oder aus Legacy-Feldern erstellen
        if let schedule = try container.decodeIfPresent(ReminderSchedule.self, forKey: .reminderSchedule) {
            reminderSchedule = schedule
        } else if let legacyTime = reminderTime {
            // Automatische Migration: alter Timer → Schedule mit gleicher Zeit an allen Tagen
            reminderSchedule = ReminderSchedule.defaultSchedule(time: legacyTime, customMessage: customReminderMessage)
        }
        individualSchwierigkeit = try container.decodeIfPresent(String.self, forKey: .individualSchwierigkeit)
        linkedHealthMetric = try container.decodeIfPresent(HealthMetricType.self, forKey: .linkedHealthMetric)
        
        // MIGRATION: Fix old plants that saved .running for Joggen instead of .steps
        let nameLower = habitName.lowercased()
        if linkedHealthMetric == .running && (nameLower.contains("joggen") || nameLower.contains("laufen") || nameLower.contains("schritt") || nameLower.contains("spazieren")) {
            linkedHealthMetric = .steps
        }
        healthTarget = try container.decodeIfPresent(Double.self, forKey: .healthTarget)
        allowManualTrackingForHealth = try container.decodeIfPresent(Bool.self, forKey: .allowManualTrackingForHealth) ?? false
        customTrackerName = try container.decodeIfPresent(String.self, forKey: .customTrackerName)
        customTrackerTarget = try container.decodeIfPresent(Double.self, forKey: .customTrackerTarget)
        customTrackerProgress = try container.decodeIfPresent(Double.self, forKey: .customTrackerProgress) ?? 0
        isRoutineOnly = try container.decodeIfPresent(Bool.self, forKey: .isRoutineOnly) ?? false
        isGenericFocus = try container.decodeIfPresent(Bool.self, forKey: .isGenericFocus) ?? false
        challengeJokers = try container.decodeIfPresent(Int.self, forKey: .challengeJokers) ?? 0
        sliderProgress = try container.decodeIfPresent(Double.self, forKey: .sliderProgress) ?? 0.0
        intradayProgressHistory = try container.decodeIfPresent([DailyProgressEntry].self, forKey: .intradayProgressHistory) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(symbolName, forKey: .symbolName)
        try container.encode(symbolColor, forKey: .symbolColor)
        try container.encode(habitCategory, forKey: .habitCategory)
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
        try container.encodeIfPresent(reminderTime, forKey: .reminderTime)
        try container.encodeIfPresent(customReminderMessage, forKey: .customReminderMessage)
        try container.encode(wateringDates, forKey: .wateringDates)
        try container.encode(lebenBereitsAbgezogen, forKey: .lebenBereitsAbgezogen)
        try container.encode(isDead, forKey: .isDead)
        try container.encode(isNegative, forKey: .isNegative)
        try container.encodeIfPresent(reminderSchedule, forKey: .reminderSchedule)
        try container.encodeIfPresent(pfadAktiviertAm, forKey: .pfadAktiviertAm)
        try container.encode(pfadCheckedDates, forKey: .pfadCheckedDates)
        try container.encodeIfPresent(individualSchwierigkeit, forKey: .individualSchwierigkeit)
        try container.encodeIfPresent(linkedHealthMetric, forKey: .linkedHealthMetric)
        try container.encodeIfPresent(healthTarget, forKey: .healthTarget)
        try container.encode(allowManualTrackingForHealth, forKey: .allowManualTrackingForHealth)
        
        try container.encodeIfPresent(customTrackerName, forKey: .customTrackerName)
        try container.encodeIfPresent(customTrackerTarget, forKey: .customTrackerTarget)
        try container.encode(customTrackerProgress, forKey: .customTrackerProgress)
        try container.encode(isRoutineOnly, forKey: .isRoutineOnly)
        try container.encode(isGenericFocus, forKey: .isGenericFocus)
        try container.encode(challengeJokers, forKey: .challengeJokers)
        try container.encode(todos, forKey: .todos)
        try container.encode(sliderProgress, forKey: .sliderProgress)
        try container.encode(intradayProgressHistory, forKey: .intradayProgressHistory)
    }
}

// MARK: - Equatable
extension HabitModel: Equatable {
    static func == (lhs: HabitModel, rhs: HabitModel) -> Bool {
        lhs.id == rhs.id
    }
}
