import WidgetKit
import SwiftUI


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
        .configurationDisplayName(String(localized: "widget_water_title", defaultValue: "Wasser", locale: widgetLocale))
        .description(String(localized: "widget_water_description", defaultValue: "Dein getrunkenes Wasser.", locale: widgetLocale))
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
        .configurationDisplayName(String(localized: "widget_streak_title", defaultValue: "Streak", locale: widgetLocale))
        .description(String(localized: "widget_streak_description", defaultValue: "Dein aktueller Streak.", locale: widgetLocale))
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
        .configurationDisplayName(String(localized: "widget_verlauf_week_title", defaultValue: "Wochenverlauf", locale: widgetLocale))
        .description(String(localized: "widget_verlauf_week_description", defaultValue: "Die letzten 7 Tage im Überblick.", locale: widgetLocale))
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
        .configurationDisplayName(String(localized: "widget_verlauf_month_title", defaultValue: "Monatsverlauf", locale: widgetLocale))
        .description(String(localized: "widget_verlauf_month_description", defaultValue: "Dein gesamter Monat auf einen Blick.", locale: widgetLocale))
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
        .configurationDisplayName(String(localized: "widget_lock_streak_title", defaultValue: "Streak (Pro)", locale: widgetLocale))
        .description(String(localized: "widget_lock_streak_desc", defaultValue: "Dein aktueller Streak auf dem Sperrbildschirm.", locale: widgetLocale))
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
        .configurationDisplayName(String(localized: "widget_interactive_routine_title", defaultValue: "Routine (Pro)", locale: widgetLocale))
        .description(String(localized: "widget_interactive_routine_desc", defaultValue: "Erledige deine Routinen direkt vom Homescreen.", locale: widgetLocale))
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
