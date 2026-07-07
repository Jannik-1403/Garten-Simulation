import AppIntents
import WidgetKit
import Foundation

// PlantEntity and PlantQuery are defined in PlantEntity.swift

// MARK: - Neu: Hintergrund-Stil
enum WidgetBackgroundStyle: String, AppEnum {
    case colorful, light, dark

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Hintergrund-Stil"
    static var caseDisplayRepresentations: [WidgetBackgroundStyle: DisplayRepresentation] = [
        .colorful: "Farbig (Gradient)",
        .light: "Hell (Weiß)",
        .dark: "Dunkel (Schwarz)"
    ]
}

// MARK: - Neu: Wasser-Widget Auswahl

enum WaterPeriod: String, AppEnum {
    case today, week, month, allTime

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Zeitraum"
    static var caseDisplayRepresentations: [WaterPeriod: DisplayRepresentation] = [
        .today:   "Heute",
        .week:    "Diese Woche",
        .month:   "Dieser Monat",
        .allTime: "Gesamt"
    ]
}

struct SelectWaterPeriodIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Wasser-Widget anpassen"
    static var description = IntentDescription("Zeitraum und Hintergrund wählen.")

    @Parameter(title: "Zeitraum", default: .week)
    var period: WaterPeriod

    @Parameter(title: "Hintergrund", default: .colorful)
    var style: WidgetBackgroundStyle

    init() {}
}

// MARK: - Neu: Streak & Verlauf Intents

struct SelectStreakIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Streak-Widget anpassen"
    
    @Parameter(title: "Hintergrund", default: .colorful)
    var style: WidgetBackgroundStyle

    init() {}
}

struct SelectHistoryIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Verlauf-Widget anpassen"
    
    @Parameter(title: "Hintergrund", default: .colorful)
    var style: WidgetBackgroundStyle

    init() {}
}

// MARK: - Neu: Routine Auswahl

enum WidgetRoutineFilterType: String, Codable {
    case morning
    case afternoon
    case evening
    case custom
}

struct WidgetRoutineUIData: Identifiable, Codable {
    var id: UUID
    var titleKey: String
    var icon: String
    var colorHex: String
    var filterType: WidgetRoutineFilterType
    var assignedHabitIDs: [String]?
}

struct RoutineEntity: AppEntity {
    var id: String
    var titleKey: String
    var icon: String

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Routine"
    static var defaultQuery = RoutineEntityQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(icon) \(String(localized: String.LocalizationValue(titleKey)))")
    }
}

struct RoutineEntityQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [RoutineEntity] {
        let all = fetchAllRoutines()
        return all.filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [RoutineEntity] {
        return fetchAllRoutines()
    }
    
    private func fetchAllRoutines() -> [RoutineEntity] {
        guard let data = SharedUserDefaults.suite.data(forKey: "customRoutinesData") else {
            return [RoutineEntity(id: "empty", titleKey: "Keine Routine zur Verfügung", icon: "⚠️")]
        }
        do {
            let routines = try JSONDecoder().decode([WidgetRoutineUIData].self, from: data)
            if routines.isEmpty {
                return [RoutineEntity(id: "empty", titleKey: "Keine Routine zur Verfügung", icon: "⚠️")]
            }
            return routines.map { RoutineEntity(id: $0.id.uuidString, titleKey: $0.titleKey, icon: $0.icon) }
        } catch {
            return [RoutineEntity(id: "empty", titleKey: "Keine Routine zur Verfügung", icon: "⚠️")]
        }
    }
}

struct SelectRoutineIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Routine-Widget anpassen"
    static var description = IntentDescription("Wähle eine Routine und den Hintergrund.")

    @Parameter(title: "Routine")
    var routine: RoutineEntity?

    @Parameter(title: "Hintergrund", default: .dark)
    var style: WidgetBackgroundStyle

    init() {}
}

