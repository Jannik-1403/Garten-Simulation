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
}

struct PflanzenSaveData: Codable {
    let id: UUID
    let plantID: String                     // Referenz auf GameDatabase
    let xp: Int
    let streak: Int
    let letzteBewaesserung: Date?
    let customName: String?
}

struct ErfolgSaveData: Codable {
    let id: String
    let freigeschaltet: Bool
    let freigeschaltetAm: Date?
}

struct EinstellungenSaveData: Codable {
    let sprache: String                     // "de" / "en"
    let benachrichtigungenAktiv: Bool
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
        streakStore: StreakStore
    ) throws -> URL {
        isLoading = true
        defer { isLoading = false }
        
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
                    customName: habit.habitName
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
                benachrichtigungenAktiv: settingsStore.isNotificationsEnabled
            )
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
        let fileName = "GartenSimulation_Backup_\(dateString).gartensave"
        
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
        if let context = modelContext {
             // In current app, HabitModel is NOT @Model, so this might be empty
             // but we'll include it for future-proofing as requested.
        }
        
        // 2. Overwrite Stores
        gardenStore.coins = saveFile.coins
        gardenStore.gesamtXP = saveFile.gesamtXP
        if let importedStreak = saveFile.gesamtStreak {
            streakStore.currentStreak = importedStreak
        }
        
        // Pflanzen neu aufbauen
        gardenStore.pflanzen = saveFile.pflanzen.map { data in
            let plantID = data.plantID
            // Re-fetch default values from DB, then apply save data
            let dbPlant = GameDatabase.allPlants.first(where: { $0.id == plantID })
            
            let habit = HabitModel(
                id: data.id.uuidString,
                name: dbPlant?.name ?? settingsStore.localizedString(for: "common.plant_fallback"), // Or keep localized name if available
                symbolName: dbPlant?.symbolName ?? "leaf",
                symbolColor: dbPlant?.symbolColor ?? "green",
                habitCategories: dbPlant?.habitCategories ?? [.lifestyle],
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
            
            return habit
        }
        
        // Gekaufte IDs
        var allPurchased = Set<String>()
        saveFile.gekauftePflanzenIDs.forEach { allPurchased.insert($0) }
        saveFile.gekaufteItemIDs.forEach { allPurchased.insert($0) }
        shopStore.purchasedIDs = allPurchased
        
        // Erfolge syncen (über unlockDates in AchievementStore falls möglich)
        // Note: AchievementStore uses its own refresh() logic, so we need a way to set the unlock dates manually.
        // For now, we'll try to reach into the persistence layer or assume refresh() will handle it if we set UserDefaults.
        var newUnlockDates: [String: TimeInterval] = [:]
        for e in saveFile.erfolge {
            if e.freigeschaltet, let am = e.freigeschaltetAm {
                newUnlockDates[e.id] = am.timeIntervalSince1970
            }
        }
        SharedUserDefaults.suite.set(newUnlockDates, forKey: "achievement_unlock_dates")
        achievementStore.refresh()
        
        // Einstellungen
        settingsStore.appLanguage = saveFile.einstellungen.sprache
        settingsStore.isNotificationsEnabled = saveFile.einstellungen.benachrichtigungenAktiv
        
        // Persistence trigger
        gardenStore.savePlants()
        gardenStore.saveStats()
        
        try? modelContext?.save()
    }
}
