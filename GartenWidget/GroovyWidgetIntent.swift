import AppIntents
import WidgetKit
import Foundation

// MARK: - Plant Entity für die Auswahl
struct PlantEntity: AppEntity {
    let id: String
    let name: String
    let imageAsset: String

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Pflanze"
    static var defaultQuery = PlantQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

struct PlantQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [PlantEntity] {
        return try await allEntities().filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [PlantEntity] {
        return try await allEntities()
    }

    private func allEntities() async throws -> [PlantEntity] {
        let appGroupID = "group.com.jannik.grovy"
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = defaults.data(forKey: "groovyWidgetData"),
              let appData = try? JSONDecoder().decode(WidgetAppData.self, from: data) else {
            return []
        }
        return appData.plants.map { PlantEntity(id: $0.id, name: $0.name, imageAsset: $0.imageName) }
    }
}

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
