import WidgetKit
import SwiftUI

@main
struct GroovyWidgetBundle: WidgetBundle {
    var body: some Widget {
        // Neue Widgets:
        GroovyWaterWidget()
        GroovyStreakWidget()
        GroovyVerlaufMediumWidget()
        GroovyVerlaufLargeWidget()
        
        // Live Activities:
        GardenLiveActivity()
    }
}


// MARK: - Wasser-Widget (Small, konfigurierbar)
struct GroovyWaterWidget: Widget {
    let kind = "GroovyWaterWidget"
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectWaterPeriodIntent.self, provider: WaterTimelineProvider()) { entry in
            WaterWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    DuoStyle.backgroundView(for: entry.backgroundStyle, defaultGradient: DuoStyle.blueGradient)
                }
        }
        .configurationDisplayName(NSLocalizedString("widget_water_title", comment: ""))
        .description(NSLocalizedString("widget_water_description", comment: ""))
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Streak-Widget (Small, nicht konfigurierbar)
struct GroovyStreakWidget: Widget {
    let kind = "GroovyStreakWidget"
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectStreakIntent.self, provider: StreakSmallTimelineProvider()) { entry in
            StreakSmallWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    DuoStyle.backgroundView(for: entry.backgroundStyle, defaultGradient: DuoStyle.orangeGradient)
                }
        }
        .configurationDisplayName(NSLocalizedString("widget_streak_title", comment: ""))
        .description(NSLocalizedString("widget_streak_description", comment: ""))
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Verlauf Medium (7 Tage)
struct GroovyVerlaufMediumWidget: Widget {
    let kind = "GroovyVerlaufMedium"
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectHistoryIntent.self, provider: VerlaufMediumTimelineProvider()) { entry in
            VerlaufMediumWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    DuoStyle.backgroundView(for: entry.backgroundStyle, defaultGradient: DuoStyle.orangeGradient)
                }
        }
        .configurationDisplayName(NSLocalizedString("widget_verlauf_week_title", comment: ""))
        .description(NSLocalizedString("widget_verlauf_week_description", comment: ""))
        .supportedFamilies([.systemMedium])
    }
}

// MARK: - Verlauf Large (Aktueller Monat)
struct GroovyVerlaufLargeWidget: Widget {
    let kind = "GroovyVerlaufLarge"
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectHistoryIntent.self, provider: VerlaufLargeTimelineProvider()) { entry in
            VerlaufLargeWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    DuoStyle.backgroundView(for: entry.backgroundStyle, defaultGradient: DuoStyle.orangeGradient)
                }
        }
        .configurationDisplayName(NSLocalizedString("widget_verlauf_month_title", comment: ""))
        .description(NSLocalizedString("widget_verlauf_month_description", comment: ""))
        .supportedFamilies([.systemLarge])
    }
}
