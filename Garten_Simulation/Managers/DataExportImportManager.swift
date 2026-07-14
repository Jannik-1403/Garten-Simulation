import Foundation
import SwiftUI
import SwiftData
import Combine
import UniformTypeIdentifiers

// MARK: - Save Data Structure

struct GartenSaveFile: Codable {
    let version: Int                        // aktuell: 1
    let exportDatum: Date
    let coins: Int
    let gesamtStreak: Int?                   // Note: Optional if older versions didn't have it
    let gesamtXP: Int
    let pflanzen: [PflanzenSaveData]
    let gekauftePflanzenIDs: [String]
    let gekaufteItemIDs: [String]
    let erfolge: [ErfolgSaveData]
    let einstellungen: EinstellungenSaveData
    
    // Progressive achievements support
    let achievementTiers: [String: Int]?
    let achievementUnlockDatesV2: [String: TimeInterval]?
    
    // New fields in V2 (Version is still 1, but these are newly added as optional for backward compatibility)
    let leben: Int?
    let gestorbenePflanzenLog: [String]?
    let gluecksradDrehungen: Int?
    let seeds: Int?
    let gesamtVerdient: Int?
    let gesamtAusgegeben: Int?
    let gesamtGegossen: Int?
    let tageAktiv: Int?
    let skillXP: [String: Int]?
    let completed90DayChallenges: Int?
    let focusSessions: [FocusSessionLog]?
    let placedDecorations: [DecorationItem]?
    let badHabitExecutions: [String: [BadHabitExecution]]?
    let savedCustomTriggers: [String]?
    let badHabitNotes: [String: [String]]?
    let transactions: [CoinTransaction]?
    let assessmentData: AssessmentSaveData?
    let customRoutines: [RoutineUIData]?
    
    // V3 Extensions
    let streakCompletedDates: [Date]?
    let streakBestStreak: Int?
    let streakGoal: Int?
    let streakFreezes: Int?
    let streakFrozenDates: [Date]?
    let streakLastShown: Int?
    
    let screenTimeAdultFilterEnabled: Bool?
    let isScreenTimeScheduleActive: Bool?
    let screenTimeDaySchedulesData: Data?
}

struct AssessmentSaveData: Codable {
    let financeResult: AssessmentResult?
    let mentalResult: MentalAssessmentResult?
    let growthResult: GrowthAssessmentResult?
    let healthResult: HealthAssessmentResult?
    let fitnessResult: FitnessAssessmentResult?
    let lifestyleResult: LifestyleAssessmentResult?
}

struct PflanzenSaveData: Codable {
    let id: UUID
    let plantID: String                     // Referenz auf GameDatabase
    let xp: Int
    let streak: Int
    let letzteBewaesserung: Date?
    let customName: String?
    let gekauftAm: Date?
    let istBewässert: Bool?
    let missedCycles: Int?
    let lastNotifiedCycle: Int?
    let totalMlGegossen: Double?
    let lebenBereitsAbgezogen: Bool?
    let isDead: Bool?
    let isNegative: Bool?
    let wiederbelebtAm: Date?
    let strafTage: Int?
    let notizen: [String]?
    let timerDatum: Date?
    let reminderTime: Date?
    let customReminderMessage: String?
    let reminderSchedule: ReminderSchedule?
    let individualSchwierigkeit: String?
    let pfadAktiviertAm: Date?
    let pfadCheckedDates: [Date]?
    let linkedHealthMetric: HealthMetricType?
    let healthTarget: Double?
    let allowManualTrackingForHealth: Bool?
    let customTrackerName: String?
    let customTrackerTarget: Double?
    let customTrackerProgress: Double?
    let isRoutineOnly: Bool?
    let isGenericFocus: Bool?
    let challengeJokers: Int?
    let xpHistory: [String: Int]?
    let totalCoinsEarned: Int?
    let wateringDates: [Date]?
}

struct ErfolgSaveData: Codable {
    let id: String
    let freigeschaltet: Bool
    let freigeschaltetAm: Date?
}

struct EinstellungenSaveData: Codable {
    let sprache: String                     // "de" / "en"
    let benachrichtigungenAktiv: Bool
    
    let isHapticEnabled: Bool?
    let isAnalyticsEnabled: Bool?
    let showHabitInsteadOfName: Bool?
    let onboardingAbgeschlossen: Bool?
    let appTourPromptShown: Bool?
    let appTourAbgeschlossen: Bool?
    let routineOnboardingAbgeschlossen: Bool?
    let ausgewaehltesZiel: String?
    let habitStartStunde: Int?
    let ritualReihenfolgeIDs: [String]?
    let igelCustomizationData: Data?
    let erinnerungsZeitInternal: Double?
}

// MARK: - Errors

enum DataExportError: LocalizedError {
    case ungueligesFormat
    case neuereVersion
    case importFehlgeschlagen(String)
    
    var errorDescription: String? {
        switch self {
        case .ungueligesFormat:
            return NSLocalizedString("backup_fehler_format", comment: "")
        case .neuereVersion:
            return NSLocalizedString("backup_fehler_version", comment: "")
        case .importFehlgeschlagen(let msg):
            return msg
        }
    }
}

// MARK: - Manager

@MainActor
final class DataExportImportManager: ObservableObject {
    static let shared = DataExportImportManager()
    
    @Published var isLoading = false
    
    private init() {}
    
    /// Exports the current game state as a .gartensave file and returns the temporary URL.
    func exportieren(
        gardenStore: GardenStore,
        shopStore: ShopStore,
        achievementStore: AchievementStore,
        settingsStore: SettingsStore,
        streakStore: StreakStore,
        assessmentStore: AssessmentStore
    ) throws -> URL {
        isLoading = true
        defer { isLoading = false }
        
        var customRoutines: [RoutineUIData]? = nil
        if let customRoutinesData = SharedUserDefaults.suite.data(forKey: "customRoutinesData") {
            customRoutines = try? JSONDecoder().decode([RoutineUIData].self, from: customRoutinesData)
        }
        
        let saveFile = GartenSaveFile(
            version: 1,
            exportDatum: Date(),
            coins: gardenStore.coins,
            gesamtStreak: streakStore.currentStreak,
            gesamtXP: gardenStore.gesamtXP,
            pflanzen: gardenStore.pflanzen.map { habit in
                PflanzenSaveData(
                    id: UUID(uuidString: habit.id) ?? UUID(),
                    plantID: habit.plantID,
                    xp: habit.currentXP,
                    streak: habit.streak,
                    letzteBewaesserung: habit.letzteBewaesserung,
                    customName: habit.habitName,
                    gekauftAm: habit.gekauftAm,
                    istBewässert: habit.istBewässert,
                    missedCycles: habit.missedCycles,
                    lastNotifiedCycle: habit.lastNotifiedCycle,
                    totalMlGegossen: habit.totalMlGegossen,
                    lebenBereitsAbgezogen: habit.lebenBereitsAbgezogen,
                    isDead: habit.isDead,
                    isNegative: habit.isNegative,
                    wiederbelebtAm: habit.wiederbelebtAm,
                    strafTage: habit.strafTage,
                    notizen: habit.notizen,
                    timerDatum: habit.timerDatum,
                    reminderTime: habit.reminderTime,
                    customReminderMessage: habit.customReminderMessage,
                    reminderSchedule: habit.reminderSchedule,
                    individualSchwierigkeit: habit.individualSchwierigkeit,
                    pfadAktiviertAm: habit.pfadAktiviertAm,
                    pfadCheckedDates: habit.pfadCheckedDates,
                    linkedHealthMetric: habit.linkedHealthMetric,
                    healthTarget: habit.healthTarget,
                    allowManualTrackingForHealth: habit.allowManualTrackingForHealth,
                    customTrackerName: habit.customTrackerName,
                    customTrackerTarget: habit.customTrackerTarget,
                    customTrackerProgress: habit.customTrackerProgress,
                    isRoutineOnly: habit.isRoutineOnly,
                    isGenericFocus: habit.isGenericFocus,
                    challengeJokers: habit.challengeJokers,
                    xpHistory: habit.xpHistory,
                    totalCoinsEarned: habit.totalCoinsEarned,
                    wateringDates: habit.wateringDates
                )
            },
            gekauftePflanzenIDs: Array(shopStore.purchasedIDs).filter { $0.starts(with: "plant.") },
            gekaufteItemIDs: Array(shopStore.purchasedIDs).filter { !$0.starts(with: "plant.") },
            erfolge: achievementStore.alleErfolge.map { erfog in
                ErfolgSaveData(
                    id: erfog.id,
                    freigeschaltet: erfog.istFreigeschaltet,
                    freigeschaltetAm: erfog.freigeschaltetAm
                )
            },
            einstellungen: EinstellungenSaveData(
                sprache: settingsStore.appLanguage,
                benachrichtigungenAktiv: settingsStore.isNotificationsEnabled,
                isHapticEnabled: settingsStore.isHapticEnabled,
                isAnalyticsEnabled: settingsStore.isAnalyticsEnabled,
                showHabitInsteadOfName: settingsStore.showHabitInsteadOfName,
                onboardingAbgeschlossen: settingsStore.onboardingAbgeschlossen,
                appTourPromptShown: settingsStore.appTourPromptShown,
                appTourAbgeschlossen: settingsStore.appTourAbgeschlossen,
                routineOnboardingAbgeschlossen: settingsStore.routineOnboardingAbgeschlossen,
                ausgewaehltesZiel: settingsStore.ausgewaehltesZiel,
                habitStartStunde: settingsStore.habitStartStunde,
                ritualReihenfolgeIDs: settingsStore.ritualReihenfolgeIDs,
                igelCustomizationData: try? JSONEncoder().encode(settingsStore.igelCustomization),
                erinnerungsZeitInternal: UserDefaults.standard.object(forKey: "erinnerungsZeit") as? Double
            ),
            achievementTiers: achievementStore.achievementTiers,
            achievementUnlockDatesV2: SharedUserDefaults.suite.dictionary(forKey: "achievement_unlock_dates_v2") as? [String: TimeInterval],
            leben: gardenStore.leben,
            gestorbenePflanzenLog: gardenStore.gestorbenePflanzenLog,
            gluecksradDrehungen: gardenStore.gluecksradDrehungen,
            seeds: gardenStore.seeds,
            gesamtVerdient: gardenStore.gesamtVerdient,
            gesamtAusgegeben: gardenStore.gesamtAusgegeben,
            gesamtGegossen: gardenStore.gesamtGegossen,
            tageAktiv: gardenStore.tageAktiv,
            skillXP: gardenStore.skillXP,
            completed90DayChallenges: gardenStore.completed90DayChallenges,
            focusSessions: gardenStore.focusSessions,
            placedDecorations: gardenStore.placedDecorations,
            badHabitExecutions: gardenStore.badHabitExecutions,
            savedCustomTriggers: gardenStore.savedCustomTriggers,
            badHabitNotes: gardenStore.badHabitNotes,
            transactions: gardenStore.transactions,
            assessmentData: AssessmentSaveData(
                financeResult: assessmentStore.financeResult,
                mentalResult: assessmentStore.mentalResult,
                growthResult: assessmentStore.growthResult,
                healthResult: assessmentStore.healthResult,
                fitnessResult: assessmentStore.fitnessResult,
                lifestyleResult: assessmentStore.lifestyleResult
            ),
            customRoutines: customRoutines,
            streakCompletedDates: Array(streakStore.completedDates),
            streakBestStreak: streakStore.bestStreak,
            streakGoal: streakStore.streakGoal,
            streakFreezes: streakStore.streakFreezes,
            streakFrozenDates: Array(streakStore.frozenDates),
            streakLastShown: streakStore.lastShownStreak,
            screenTimeAdultFilterEnabled: UserDefaults.standard.bool(forKey: "screenTimeAdultFilterEnabled"),
            isScreenTimeScheduleActive: UserDefaults.standard.bool(forKey: "isScreenTimeScheduleActive"),
            screenTimeDaySchedulesData: UserDefaults.standard.data(forKey: "screenTimeDaySchedulesData")
        )
        
        // Serialize
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        
        let data = try encoder.encode(saveFile)
        
        // Write to temp file
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: Date())
        let fileName = "Grovy_Backup_\(dateString).gartensave"
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        // Check if file already exists if needed, or just overwrite
        if FileManager.default.fileExists(atPath: tempURL.path) {
            try FileManager.default.removeItem(at: tempURL)
        }
        
        try data.write(to: tempURL)
        
        return tempURL
    }
    
    func importieren(
        von url: URL,
        gardenStore: GardenStore,
        shopStore: ShopStore,
        achievementStore: AchievementStore,
        settingsStore: SettingsStore,
        streakStore: StreakStore,
        assessmentStore: AssessmentStore,
        modelContext: ModelContext? = nil
    ) throws {
        isLoading = true
        defer { isLoading = false }
        
        // Access security scoped resource if necessary (important for file pickers)
        let _ = url.startAccessingSecurityScopedResource()
        defer { url.stopAccessingSecurityScopedResource() }
        
        let data = try Data(contentsOf: url)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard let saveFile = try? decoder.decode(GartenSaveFile.self, from: data) else {
            throw DataExportError.ungueligesFormat
        }
        
        // Versionscheck
        if saveFile.version > 1 {
            throw DataExportError.neuereVersion
        }
        
        // 1. Reset all data
        // SwiftData deletion (optional if used)
        if modelContext != nil {
             // In current app, HabitModel is NOT @Model, so this might be empty
             // but we'll include it for future-proofing as requested.
        }
        
        // 2. Overwrite Stores
        gardenStore.coins = saveFile.coins
        gardenStore.gesamtXP = saveFile.gesamtXP
        if let importedStreak = saveFile.gesamtStreak {
            streakStore.currentStreak = importedStreak
        }
        
        if let completedDates = saveFile.streakCompletedDates {
            streakStore.completedDates = Set(completedDates)
        }
        if let bestStreak = saveFile.streakBestStreak { streakStore.bestStreak = bestStreak }
        if let streakGoal = saveFile.streakGoal { streakStore.streakGoal = streakGoal }
        if let streakFreezes = saveFile.streakFreezes { streakStore.streakFreezes = streakFreezes }
        if let frozenDates = saveFile.streakFrozenDates { streakStore.frozenDates = Set(frozenDates) }
        if let lastShown = saveFile.streakLastShown { streakStore.lastShownStreak = lastShown }
        streakStore.calculateStreak(shouldAnimate: false)
        
        if let leben = saveFile.leben { gardenStore.leben = leben }
        if let gestorbenePflanzenLog = saveFile.gestorbenePflanzenLog { gardenStore.gestorbenePflanzenLog = gestorbenePflanzenLog }
        if let gluecksradDrehungen = saveFile.gluecksradDrehungen { gardenStore.gluecksradDrehungen = gluecksradDrehungen }
        if let seeds = saveFile.seeds { gardenStore.seeds = seeds }
        if let gesamtVerdient = saveFile.gesamtVerdient { gardenStore.gesamtVerdient = gesamtVerdient }
        if let gesamtAusgegeben = saveFile.gesamtAusgegeben { gardenStore.gesamtAusgegeben = gesamtAusgegeben }
        if let gesamtGegossen = saveFile.gesamtGegossen { gardenStore.gesamtGegossen = gesamtGegossen }
        if let tageAktiv = saveFile.tageAktiv { gardenStore.tageAktiv = tageAktiv }
        if let skillXP = saveFile.skillXP { gardenStore.skillXP = skillXP }
        if let completed90DayChallenges = saveFile.completed90DayChallenges { gardenStore.completed90DayChallenges = completed90DayChallenges }
        if let focusSessions = saveFile.focusSessions { gardenStore.focusSessions = focusSessions }
        if let placedDecorations = saveFile.placedDecorations { gardenStore.placedDecorations = placedDecorations }
        if let badHabitExecutions = saveFile.badHabitExecutions { gardenStore.badHabitExecutions = badHabitExecutions }
        if let savedCustomTriggers = saveFile.savedCustomTriggers { gardenStore.savedCustomTriggers = savedCustomTriggers }
        if let badHabitNotes = saveFile.badHabitNotes { gardenStore.badHabitNotes = badHabitNotes }
        if let transactions = saveFile.transactions { gardenStore.transactions = transactions }
        
        if let assessmentData = saveFile.assessmentData {
            assessmentStore.financeResult = assessmentData.financeResult
            assessmentStore.mentalResult = assessmentData.mentalResult
            assessmentStore.growthResult = assessmentData.growthResult
            assessmentStore.healthResult = assessmentData.healthResult
            assessmentStore.fitnessResult = assessmentData.fitnessResult
            assessmentStore.lifestyleResult = assessmentData.lifestyleResult
        }
        
        if let customRoutines = saveFile.customRoutines {
            if let encoded = try? JSONEncoder().encode(customRoutines) {
                SharedUserDefaults.suite.set(encoded, forKey: "customRoutinesData")
            }
        }
        
        if let adultFilter = saveFile.screenTimeAdultFilterEnabled {
            UserDefaults.standard.set(adultFilter, forKey: "screenTimeAdultFilterEnabled")
        }
        if let stScheduleActive = saveFile.isScreenTimeScheduleActive {
            UserDefaults.standard.set(stScheduleActive, forKey: "isScreenTimeScheduleActive")
        }
        if let stSchedulesData = saveFile.screenTimeDaySchedulesData {
            UserDefaults.standard.set(stSchedulesData, forKey: "screenTimeDaySchedulesData")
        }
        
        // Pflanzen neu aufbauen
        gardenStore.pflanzen = saveFile.pflanzen.map { data in
            let plantID = data.plantID
            // Re-fetch default values from DB, then apply save data
            let dbPlant = GameDatabase.allPlants.first(where: { $0.id == plantID })
            
            let habit = HabitModel(
                id: data.id.uuidString,
                name: dbPlant?.name ?? String(localized: "common.plant_fallback"), // Or keep localized name if available
                symbolName: dbPlant?.symbolName ?? "leaf",
                symbolColor: dbPlant?.symbolColor ?? "green",
                habitCategory: dbPlant?.habitCategory ?? .lifestyle,
                symbolism: dbPlant?.symbolism ?? "",
                habitName: data.customName ?? "",
                maxLevel: dbPlant?.maxLevel ?? 10,
                xpPerCompletion: dbPlant?.xpPerCompletion ?? 100,
                waterNeedPerDay: dbPlant?.waterNeedPerDay ?? 1,
                decayDays: dbPlant?.decayDays ?? 3,
                plantID: plantID
            )
            
            habit.currentXP = data.xp
            habit.streak = data.streak
            habit.letzteBewaesserung = data.letzteBewaesserung
            
            if let gekauftAm = data.gekauftAm { habit.gekauftAm = gekauftAm }
            if let istBewässert = data.istBewässert { habit.istBewässert = istBewässert }
            if let missedCycles = data.missedCycles { habit.missedCycles = missedCycles }
            if let lastNotifiedCycle = data.lastNotifiedCycle { habit.lastNotifiedCycle = lastNotifiedCycle }
            if let totalMlGegossen = data.totalMlGegossen { habit.totalMlGegossen = totalMlGegossen }
            if let lebenBereitsAbgezogen = data.lebenBereitsAbgezogen { habit.lebenBereitsAbgezogen = lebenBereitsAbgezogen }
            if let isDead = data.isDead { habit.isDead = isDead }
            if let isNegative = data.isNegative { habit.isNegative = isNegative }
            if let wiederbelebtAm = data.wiederbelebtAm { habit.wiederbelebtAm = wiederbelebtAm }
            if let strafTage = data.strafTage { habit.strafTage = strafTage }
            if let notizen = data.notizen { habit.notizen = notizen }
            if let timerDatum = data.timerDatum { habit.timerDatum = timerDatum }
            if let reminderTime = data.reminderTime { habit.reminderTime = reminderTime }
            if let customReminderMessage = data.customReminderMessage { habit.customReminderMessage = customReminderMessage }
            if let reminderSchedule = data.reminderSchedule { habit.reminderSchedule = reminderSchedule }
            if let individualSchwierigkeit = data.individualSchwierigkeit { habit.individualSchwierigkeit = individualSchwierigkeit }
            if let pfadAktiviertAm = data.pfadAktiviertAm { habit.pfadAktiviertAm = pfadAktiviertAm }
            if let pfadCheckedDates = data.pfadCheckedDates { habit.pfadCheckedDates = pfadCheckedDates }
            if let linkedHealthMetric = data.linkedHealthMetric { habit.linkedHealthMetric = linkedHealthMetric }
            if let healthTarget = data.healthTarget { habit.healthTarget = healthTarget }
            if let allowManualTrackingForHealth = data.allowManualTrackingForHealth { habit.allowManualTrackingForHealth = allowManualTrackingForHealth }
            if let customTrackerName = data.customTrackerName { habit.customTrackerName = customTrackerName }
            if let customTrackerTarget = data.customTrackerTarget { habit.customTrackerTarget = customTrackerTarget }
            if let customTrackerProgress = data.customTrackerProgress { habit.customTrackerProgress = customTrackerProgress }
            if let isRoutineOnly = data.isRoutineOnly { habit.isRoutineOnly = isRoutineOnly }
            if let isGenericFocus = data.isGenericFocus { habit.isGenericFocus = isGenericFocus }
            if let challengeJokers = data.challengeJokers { habit.challengeJokers = challengeJokers }
            if let xpHistory = data.xpHistory { habit.xpHistory = xpHistory }
            if let totalCoinsEarned = data.totalCoinsEarned { habit.totalCoinsEarned = totalCoinsEarned }
            if let wateringDates = data.wateringDates { habit.wateringDates = wateringDates }
            
            return habit
        }
        
        // Gekaufte IDs
        var allPurchased = Set<String>()
        saveFile.gekauftePflanzenIDs.forEach { allPurchased.insert($0) }
        saveFile.gekaufteItemIDs.forEach { allPurchased.insert($0) }
        shopStore.purchasedIDs = allPurchased
        
        // Sync Achievements
        if let tiers = saveFile.achievementTiers, let dates = saveFile.achievementUnlockDatesV2 {
            SharedUserDefaults.suite.set(tiers, forKey: "achievement_tiers_v2")
            SharedUserDefaults.suite.set(dates, forKey: "achievement_unlock_dates_v2")
            SharedUserDefaults.suite.set(true, forKey: "did_migrate_achievements_v2")
            achievementStore.achievementTiers = tiers
        } else {
            // Force re-migration on next refresh
            SharedUserDefaults.suite.set(false, forKey: "did_migrate_achievements_v2")
            var newUnlockDates: [String: TimeInterval] = [:]
            for e in saveFile.erfolge {
                if e.freigeschaltet, let am = e.freigeschaltetAm {
                    newUnlockDates[e.id] = am.timeIntervalSince1970
                }
            }
            SharedUserDefaults.suite.set(newUnlockDates, forKey: "achievement_unlock_dates")
        }
        achievementStore.refresh()
        
        // Einstellungen
        settingsStore.appLanguage = saveFile.einstellungen.sprache
        settingsStore.isNotificationsEnabled = saveFile.einstellungen.benachrichtigungenAktiv
        
        if let isHapticEnabled = saveFile.einstellungen.isHapticEnabled { settingsStore.isHapticEnabled = isHapticEnabled }
        if let isAnalyticsEnabled = saveFile.einstellungen.isAnalyticsEnabled { settingsStore.isAnalyticsEnabled = isAnalyticsEnabled }
        if let showHabitInsteadOfName = saveFile.einstellungen.showHabitInsteadOfName { settingsStore.showHabitInsteadOfName = showHabitInsteadOfName }
        if let onboardingAbgeschlossen = saveFile.einstellungen.onboardingAbgeschlossen { settingsStore.onboardingAbgeschlossen = onboardingAbgeschlossen }
        if let appTourPromptShown = saveFile.einstellungen.appTourPromptShown { settingsStore.appTourPromptShown = appTourPromptShown }
        if let appTourAbgeschlossen = saveFile.einstellungen.appTourAbgeschlossen { settingsStore.appTourAbgeschlossen = appTourAbgeschlossen }
        if let routineOnboardingAbgeschlossen = saveFile.einstellungen.routineOnboardingAbgeschlossen { settingsStore.routineOnboardingAbgeschlossen = routineOnboardingAbgeschlossen }
        if let ausgewaehltesZiel = saveFile.einstellungen.ausgewaehltesZiel { settingsStore.ausgewaehltesZiel = ausgewaehltesZiel }
        if let habitStartStunde = saveFile.einstellungen.habitStartStunde { settingsStore.habitStartStunde = habitStartStunde }
        if let ritualReihenfolgeIDs = saveFile.einstellungen.ritualReihenfolgeIDs { settingsStore.ritualReihenfolgeIDs = ritualReihenfolgeIDs }
        
        if let igelData = saveFile.einstellungen.igelCustomizationData,
           let igel = try? JSONDecoder().decode(IgelCustomization.self, from: igelData) {
            settingsStore.igelCustomization = igel
        }
        
        if let erinnerungsZeitInternal = saveFile.einstellungen.erinnerungsZeitInternal {
            UserDefaults.standard.set(erinnerungsZeitInternal, forKey: "erinnerungsZeit")
        }
        
        // Persistence trigger
        gardenStore.savePlants()
        gardenStore.saveStats()
        
        try? modelContext?.save()
    }
}
