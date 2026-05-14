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
