import SwiftUI
import WidgetKit
import AppIntents

// MARK: - AppIntent für den Style (optional, für Konsistenz)
struct SelectHabitStyleIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Hintergrund wählen"
    static var description = IntentDescription("Wähle den Hintergrund für das Gewohnheiten-Widget.")
    
    @Parameter(title: "Stil", default: .colorful)
    var style: WidgetBackgroundStyle
}

// MARK: - Timeline Provider
struct HabitsTimelineProvider: AppIntentTimelineProvider {
    typealias Intent = SelectHabitStyleIntent
    typealias Entry = GroovyStreakEntry
    
    private func loadWidgetData() -> WidgetAppData? {
        guard let defaults = UserDefaults(suiteName: "group.com.jannik.grovy"),
              let raw = defaults.data(forKey: "groovyWidgetData"),
              let data = try? JSONDecoder().decode(WidgetAppData.self, from: raw)
        else { return nil }
        return data
    }

    func placeholder(in context: Context) -> GroovyStreakEntry {
        GroovyStreakEntry(date: .now, appData: nil, waterPeriod: .today, backgroundStyle: .colorful)
    }
    
    func snapshot(for intent: SelectHabitStyleIntent, in context: Context) async -> GroovyStreakEntry {
        GroovyStreakEntry(date: .now, appData: loadWidgetData(), waterPeriod: .today, backgroundStyle: intent.style)
    }
    
    func timeline(for intent: SelectHabitStyleIntent, in context: Context) async -> Timeline<GroovyStreakEntry> {
        let entry = GroovyStreakEntry(date: .now, appData: loadWidgetData(), waterPeriod: .today, backgroundStyle: intent.style)
        // Refresh every 15 mins to keep it up to date, but the AppIntent will reload it immediately anyway
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 15, to: .now)!
        return Timeline(entries: [entry], policy: .after(nextRefresh))
    }
}

// MARK: - Widget View
struct GroovyHabitsWidgetView: View {
    let entry: GroovyStreakEntry
    
    // Wir zeigen maximal 3 unbewässerte an
    var openHabits: [WidgetPlantData] {
        guard let appData = entry.appData else { return [] }
        return appData.plants.filter { !$0.isWateredToday }.prefix(2).map { $0 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if openHabits.isEmpty {
                // Leer-Zustand (Alles geschafft)
                VStack(spacing: 8) {
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(Color.green)
                    Text("Gute Arbeit!")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(DuoStyle.contentColor(for: entry.backgroundStyle).opacity(0.8))
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                // Header (nur wenn noch was offen ist)
                VStack(alignment: .leading, spacing: 2) {
                    Text("OFFENE GEWOHNHEITEN")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundStyle(DuoStyle.contentColor(for: entry.backgroundStyle).opacity(0.8))
                        .tracking(1)
                }
                
                // Liste der Habits
                VStack(spacing: 10) {
                    ForEach(openHabits, id: \.id) { plant in
                        HStack(spacing: 10) {
                            // Kleines Icon / Indikator (Fallback)
                            Circle()
                                .fill(Color.orange.opacity(0.2))
                                .frame(width: 24, height: 24)
                                .overlay {
                                    Image(systemName: "drop.fill")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.orange)
                                }
                            
                            VStack(alignment: .leading, spacing: 1) {
                                Text(plant.name)
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundStyle(DuoStyle.contentColor(for: entry.backgroundStyle))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                                
                                HStack(spacing: 2) {
                                    Image(systemName: "flame.fill")
                                        .font(.system(size: 8))
                                        .foregroundColor(.orange)
                                    Text("\(plant.streak) Tage")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundStyle(DuoStyle.contentColor(for: entry.backgroundStyle).opacity(0.6))
                                }
                            }
                            
                            Spacer()
                            
                            // INTERACTIVE BUTTON - Sehr großer Hit-Bereich und angepasste Farben!
                            let toggleColor: Color = (entry.backgroundStyle == .dark) ? .white : .black
                            
                            Button(intent: WaterPlantIntent(plant: PlantEntity(id: plant.id, name: plant.name, symbolName: "leaf.fill"))) {
                                Image(systemName: "circle")
                                    .font(.system(size: 26, weight: .regular))
                                    .foregroundColor(toggleColor)
                                    .frame(width: 44, height: 44)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .containerBackground(for: .widget) {
            DuoStyle.backgroundView(for: entry.backgroundStyle, defaultGradient: DuoStyle.orangeGradient)
        }
    }
}

// MARK: - Widget Configuration
struct GroovyHabitsWidget: Widget {
    let kind = "GroovyHabitsWidget"
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectHabitStyleIntent.self, provider: HabitsTimelineProvider()) { entry in
            GroovyHabitsWidgetView(entry: entry)
        }
        .configurationDisplayName("Offene Gewohnheiten")
        .description("Hake deine offenen Gewohnheiten direkt vom Homescreen ab!")
        .supportedFamilies([.systemMedium]) // Medium ist perfekt für eine kleine Liste
    }
}
