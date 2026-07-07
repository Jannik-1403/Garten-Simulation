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
        // Lock Screen (Pro)
        GroovyLockScreenStreakWidget()
        
        // Interactive (Pro)
        GroovyInteractiveHabitsWidget()
        
        // Live Activities:
        FocusTimerLiveActivity()
    }
}


// MARK: - Wasser-Widget (Small, konfigurierbar)
struct GroovyWaterWidget: Widget {
    let kind = "GroovyWaterWidget"
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectWaterPeriodIntent.self, provider: WaterTimelineProvider()) { entry in
            WaterWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    WaterBackgroundView(style: entry.backgroundStyle)
                }
        }
        .configurationDisplayName(String(localized: "widget_water_title", defaultValue: "Wasser"))
        .description(String(localized: "widget_water_description", defaultValue: "Dein getrunkenes Wasser."))
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
                    StreakBackgroundView(style: entry.backgroundStyle)
                }
        }
        .configurationDisplayName(String(localized: "widget_streak_title", defaultValue: "Streak"))
        .description(String(localized: "widget_streak_description", defaultValue: "Dein aktueller Streak."))
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
        .configurationDisplayName(String(localized: "widget_verlauf_week_title", defaultValue: "Wochenverlauf"))
        .description(String(localized: "widget_verlauf_week_description", defaultValue: "Die letzten 7 Tage im Überblick."))
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
        .configurationDisplayName(String(localized: "widget_verlauf_month_title", defaultValue: "Monatsverlauf"))
        .description(String(localized: "widget_verlauf_month_description", defaultValue: "Dein gesamter Monat auf einen Blick."))
        .supportedFamilies([.systemLarge])
    }
}

// MARK: - LOCK SCREEN: Streak Widget (Pro)
struct GroovyLockScreenStreakWidget: Widget {
    let kind = "GroovyLockScreenStreakWidget"
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectStreakIntent.self, provider: StreakSmallTimelineProvider()) { entry in
            LockScreenStreakWidgetView(entry: entry)
        }
        .configurationDisplayName(String(localized: "widget_lock_streak_title", defaultValue: "Streak (Pro)"))
        .description(String(localized: "widget_lock_streak_desc", defaultValue: "Dein aktueller Streak auf dem Sperrbildschirm."))
        .supportedFamilies([.accessoryCircular, .accessoryRectangular])
    }
}

// MARK: - INTERACTIVE HABITS WIDGET (Pro)
struct GroovyInteractiveHabitsWidget: Widget {
    let kind = "GroovyInteractiveHabitsWidget"
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectStreakIntent.self, provider: StreakSmallTimelineProvider()) { entry in
            InteractiveHabitsWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    DuoStyle.backgroundView(for: .colorful, defaultGradient: DuoStyle.blueGradient)
                }
        }
        .configurationDisplayName(String(localized: "widget_interactive_habits_title", defaultValue: "Pflanzen gießen (Pro)"))
        .description(String(localized: "widget_interactive_habits_desc", defaultValue: "Gieße deine Pflanzen direkt vom Homescreen."))
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
