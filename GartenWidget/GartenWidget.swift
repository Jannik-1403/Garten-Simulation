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
    let kind = "GroovyWaterWidgetV3"
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectWaterPeriodIntent.self, provider: WaterTimelineProvider()) { entry in
            WaterWidgetView(entry: entry)
                .environment(\.locale, Locale(identifier: SharedUserDefaults.suite.string(forKey: "appLanguage") ?? "de"))
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
    let kind = "GroovyStreakWidgetV3"
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectStreakIntent.self, provider: StreakSmallTimelineProvider()) { entry in
            StreakSmallWidgetView(entry: entry)
                .environment(\.locale, Locale(identifier: SharedUserDefaults.suite.string(forKey: "appLanguage") ?? "de"))
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
    let kind = "GroovyVerlaufMediumV3"
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectHistoryIntent.self, provider: VerlaufMediumTimelineProvider()) { entry in
            VerlaufMediumWidgetView(entry: entry)
                .environment(\.locale, Locale(identifier: SharedUserDefaults.suite.string(forKey: "appLanguage") ?? "de"))
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
    let kind = "GroovyVerlaufLargeV3"
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectHistoryIntent.self, provider: VerlaufLargeTimelineProvider()) { entry in
            VerlaufLargeWidgetView(entry: entry)
                .environment(\.locale, Locale(identifier: SharedUserDefaults.suite.string(forKey: "appLanguage") ?? "de"))
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
    let kind = "GroovyLockScreenStreakWidgetV3"
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectStreakIntent.self, provider: StreakSmallTimelineProvider()) { entry in
            LockScreenStreakWidgetView(entry: entry)
                .environment(\.locale, Locale(identifier: SharedUserDefaults.suite.string(forKey: "appLanguage") ?? "de"))
        }
        .configurationDisplayName(String(localized: "widget_lock_streak_title", defaultValue: "Streak (Pro)"))
        .description(String(localized: "widget_lock_streak_desc", defaultValue: "Dein aktueller Streak auf dem Sperrbildschirm."))
        .supportedFamilies([.accessoryCircular, .accessoryRectangular])
    }
}

// MARK: - INTERACTIVE ROUTINE WIDGET (Pro)
struct GroovyInteractiveHabitsWidget: Widget {
    let kind = "GroovyInteractiveHabitsWidgetV3"
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectRoutineIntent.self, provider: RoutineTimelineProvider()) { entry in
            InteractiveHabitsWidgetView(entry: entry)
                .environment(\.locale, Locale(identifier: SharedUserDefaults.suite.string(forKey: "appLanguage") ?? "de"))
                .containerBackground(for: .widget) {
                    DuoStyle.backgroundView(for: entry.style, defaultGradient: DuoStyle.blueGradient)
                }
        }
        .configurationDisplayName(String(localized: "widget_interactive_routine_title", defaultValue: "Routine (Pro)"))
        .description(String(localized: "widget_interactive_routine_desc", defaultValue: "Erledige deine Routinen direkt vom Homescreen."))
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
