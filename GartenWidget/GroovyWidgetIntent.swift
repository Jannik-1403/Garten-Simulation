import AppIntents
import WidgetKit
import Foundation


private var widgetLocale: Locale {
    let supported = ["pt", "nl", "zh-Hans", "ko", "ja", "tr", "es", "fr", "en", "ru", "pl", "it", "hi", "zh-Hant", "pt-BR", "de"]
    
    for lang in Locale.preferredLanguages {
        let identifier = Locale(identifier: lang).language.languageCode?.identifier ?? lang
        if supported.contains(identifier) || supported.contains(lang) {
            return Locale(identifier: lang)
        }
    }
    
    return Locale(identifier: "en")
}


// PlantEntity and PlantQuery are defined in PlantEntity.swift

// MARK: - Neu: Hintergrund-Stil
enum WidgetBackgroundStyle: String, AppEnum {
    case light, dark

    static var typeDisplayRepresentation: TypeDisplayRepresentation = TypeDisplayRepresentation(name: LocalizedStringResource("widget_style_type", defaultValue: "Hintergrund-Stil"))
    static var caseDisplayRepresentations: [WidgetBackgroundStyle: DisplayRepresentation] = [
        .light: DisplayRepresentation(title: LocalizedStringResource("widget_style_light", defaultValue: "Hell (Weiß)")),
        .dark: DisplayRepresentation(title: LocalizedStringResource("widget_style_dark", defaultValue: "Dunkel (Schwarz)"))
    ]
}

// MARK: - Neu: Wasser-Widget Auswahl

struct SelectWaterPeriodIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = LocalizedStringResource("widget_intent_water_title", defaultValue: "Wasser-Widget anpassen")
    static var description = IntentDescription(LocalizedStringResource("widget_intent_water_desc", defaultValue: "Hintergrund wählen."))


    @Parameter(title: LocalizedStringResource("widget_style_type", defaultValue: "Hintergrund"), default: .dark)
    var style: WidgetBackgroundStyle

    init() {}
}

// MARK: - Neu: Streak & Verlauf Intents

struct SelectStreakIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = LocalizedStringResource("widget_intent_streak_title", defaultValue: "Streak-Widget anpassen")
    
    @Parameter(title: LocalizedStringResource("widget_style_type", defaultValue: "Hintergrund"), default: .dark)
    var style: WidgetBackgroundStyle

    init() {}
}

struct SelectHistoryIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = LocalizedStringResource("widget_intent_history_title", defaultValue: "Verlauf-Widget anpassen")
    
    @Parameter(title: LocalizedStringResource("widget_style_type", defaultValue: "Hintergrund"), default: .dark)
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
    var lastCompletedDate: Date?
}

struct RoutineEntity: AppEntity {
    var id: String
    var titleKey: String
    var icon: String

    static var typeDisplayRepresentation: TypeDisplayRepresentation = TypeDisplayRepresentation(name: LocalizedStringResource("widget_routine_type", defaultValue: "Routine"))
    static var defaultQuery = RoutineEntityQuery()

    /// Platzhalter-ID, wenn der Nutzer noch keine Routine angelegt hat.
    static let emptyID = "empty"
    static var unavailable: RoutineEntity {
        RoutineEntity(id: emptyID, titleKey: "widget_routine_unavailable", icon: "⚠️")
    }

    var displayRepresentation: DisplayRepresentation {
        if id == Self.emptyID {
            return DisplayRepresentation(title: LocalizedStringResource("widget_routine_unavailable", defaultValue: "Keine Routine verfügbar"))
        }
        return DisplayRepresentation(title: "\(String(localized: String.LocalizationValue(titleKey), locale: widgetLocale))")
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
            return [.unavailable]
        }
        do {
            let routines = try JSONDecoder().decode([WidgetRoutineUIData].self, from: data)
            if routines.isEmpty {
                return [.unavailable]
            }
            return routines.map { RoutineEntity(id: $0.id.uuidString, titleKey: $0.titleKey, icon: $0.icon) }
        } catch {
            return [.unavailable]
        }
    }
}

struct SelectRoutineIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = LocalizedStringResource("widget_intent_routine_title", defaultValue: "Routine-Widget anpassen")
    static var description = IntentDescription(LocalizedStringResource("widget_intent_routine_desc", defaultValue: "Wähle eine Routine und den Hintergrund."))

    @Parameter(title: LocalizedStringResource("widget_routine_type", defaultValue: "Routine"))
    var routine: RoutineEntity?

    @Parameter(title: LocalizedStringResource("widget_style_type", defaultValue: "Hintergrund"), default: .dark)
    var style: WidgetBackgroundStyle

    init() {}
}

