import WidgetKit
import Foundation

// MARK: - Shared Loader
private func loadWidgetData() -> WidgetAppData? {
    guard let defaults = UserDefaults(suiteName: "group.com.jannik.grovy"),
          let raw = defaults.data(forKey: "groovyWidgetData"),
          let data = try? JSONDecoder().decode(WidgetAppData.self, from: raw)
    else { return nil }
    return data
}

private func nextRefresh() -> Date {
    Calendar.current.date(byAdding: .minute, value: 15, to: .now)!
}

// MARK: - Neu: Wasser + Streak-Widgets

// Entry für Wasser + Streak-Widgets
struct GroovyStreakEntry: TimelineEntry {
    let date: Date
    let appData: WidgetAppData?
    let waterPeriod: WaterPeriod   // nur für Wasser-Widget relevant
    let backgroundStyle: WidgetBackgroundStyle
}

// MARK: - Wasser-Widget Provider (Small)
struct WaterTimelineProvider: AppIntentTimelineProvider {
    typealias Intent = SelectWaterPeriodIntent
    typealias Entry = GroovyStreakEntry

    func placeholder(in context: Context) -> GroovyStreakEntry {
        GroovyStreakEntry(date: .now, appData: nil, waterPeriod: .week, backgroundStyle: .colorful)
    }
    func snapshot(for intent: SelectWaterPeriodIntent, in context: Context) async -> GroovyStreakEntry {
        GroovyStreakEntry(date: .now, appData: loadWidgetData(), waterPeriod: intent.period, backgroundStyle: intent.style)
    }
    func timeline(for intent: SelectWaterPeriodIntent, in context: Context) async -> Timeline<GroovyStreakEntry> {
        let entry = GroovyStreakEntry(date: .now, appData: loadWidgetData(), waterPeriod: intent.period, backgroundStyle: intent.style)
        return Timeline(entries: [entry], policy: .after(nextRefresh()))
    }
}

// MARK: - Streak-Widget Provider (Small)
struct StreakSmallTimelineProvider: AppIntentTimelineProvider {
    typealias Intent = SelectStreakIntent
    typealias Entry = GroovyStreakEntry

    func placeholder(in context: Context) -> GroovyStreakEntry {
        GroovyStreakEntry(date: .now, appData: nil, waterPeriod: .today, backgroundStyle: .colorful)
    }
    func snapshot(for intent: SelectStreakIntent, in context: Context) async -> GroovyStreakEntry {
        GroovyStreakEntry(date: .now, appData: loadWidgetData(), waterPeriod: .today, backgroundStyle: intent.style)
    }
    func timeline(for intent: SelectStreakIntent, in context: Context) async -> Timeline<GroovyStreakEntry> {
        let entry = GroovyStreakEntry(date: .now, appData: loadWidgetData(), waterPeriod: .today, backgroundStyle: intent.style)
        return Timeline(entries: [entry], policy: .after(nextRefresh()))
    }
}

// MARK: - Verlauf Medium Provider (7 Tage)
struct VerlaufMediumTimelineProvider: AppIntentTimelineProvider {
    typealias Intent = SelectHistoryIntent
    typealias Entry = GroovyStreakEntry

    func placeholder(in context: Context) -> GroovyStreakEntry {
        GroovyStreakEntry(date: .now, appData: nil, waterPeriod: .week, backgroundStyle: .colorful)
    }
    func snapshot(for intent: SelectHistoryIntent, in context: Context) async -> GroovyStreakEntry {
        GroovyStreakEntry(date: .now, appData: loadWidgetData(), waterPeriod: .week, backgroundStyle: intent.style)
    }
    func timeline(for intent: SelectHistoryIntent, in context: Context) async -> Timeline<GroovyStreakEntry> {
        let entry = GroovyStreakEntry(date: .now, appData: loadWidgetData(), waterPeriod: .week, backgroundStyle: intent.style)
        return Timeline(entries: [entry], policy: .after(nextRefresh()))
    }
}

// MARK: - Verlauf Large Provider (Aktueller Monat)
struct VerlaufLargeTimelineProvider: AppIntentTimelineProvider {
    typealias Intent = SelectHistoryIntent
    typealias Entry = GroovyStreakEntry

    func placeholder(in context: Context) -> GroovyStreakEntry {
        GroovyStreakEntry(date: .now, appData: nil, waterPeriod: .month, backgroundStyle: .colorful)
    }
    func snapshot(for intent: SelectHistoryIntent, in context: Context) async -> GroovyStreakEntry {
        GroovyStreakEntry(date: .now, appData: loadWidgetData(), waterPeriod: .month, backgroundStyle: intent.style)
    }
    func timeline(for intent: SelectHistoryIntent, in context: Context) async -> Timeline<GroovyStreakEntry> {
        let entry = GroovyStreakEntry(date: .now, appData: loadWidgetData(), waterPeriod: .month, backgroundStyle: intent.style)
        return Timeline(entries: [entry], policy: .after(nextRefresh()))
    }
}
