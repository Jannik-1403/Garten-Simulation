import SwiftUI
import WidgetKit
import AppIntents

private let mlPerWatering: Int = 300

// MARK: - Igel-Assets
private let igelAssets: [String] = [
    "Igel-Backen", "Igel-Code", "Igel-Duschen", "Igel-Essen", "Igel-Fischen",
    "Igel-Foto", "Igel-Golf", "Igel-Kochen", "Igel-König", "Igel-Lesen",
    "Igel-Malen", "Igel-Meditieren", "Igel-Musik", "Igel-Schach", "Igel-Schlafen",
    "Igel-Sport", "Igel-Surfen", "Igel-Welttraum", "Igel-wandern", "Igel-Schlagzeug",
    "Igel-Schreiben", "Igel-Zelten", "Igel-rennen", "Igel-Skatboard", "Igel-Töpfern"
]

private func igelForToday() -> String {
    let day = Calendar.current.ordinality(of: .day, in: .era, for: .now) ?? 0
    return igelAssets[day % igelAssets.count]
}

// MARK: - PNG Image Helper
private var appBundle: Bundle {
    // Der zuverlässigste Weg, den "App Ordner" aus einem Widget zu finden:
    // Wir gehen vom Widget-Bundle (.../App.app/PlugIns/Widget.appex) zwei Ebenen hoch.
    let pluginURL = Bundle.main.bundleURL
    let appURL = pluginURL.deletingLastPathComponent().deletingLastPathComponent()
    if let bundle = Bundle(url: appURL) {
        return bundle
    }
    // Fallback auf Identifier
    if let bundle = Bundle(identifier: "com.jannik.grovy") ?? Bundle(identifier: "de.jannik.gartensimulation") {
        return bundle
    }
    return .main
}

@ViewBuilder
func PNGImage(_ name: String) -> some View {
    // Widgets müssen explizit auf das Bundle der Haupt-App verlinkt werden
    Group {
        if let uiImage = UIImage(named: name, in: appBundle, with: nil) ?? 
           UIImage(named: name.precomposedStringWithCanonicalMapping, in: appBundle, with: nil) ??
           UIImage(named: name.decomposedStringWithCanonicalMapping, in: appBundle, with: nil) ??
           UIImage(named: name.replacingOccurrences(of: " ", with: "_"), in: appBundle, with: nil) {
            Image(uiImage: uiImage)
                .renderingMode(.original)
                .resizable()
        } else {
            // Letzter Versuch: Direktes Laden über SwiftUI im Widget-Bundle
            Image(name)
                .renderingMode(.original)
                .resizable()
        }
    }
}

// MARK: - UI Constants für Duolingo-Stil
private extension Color {
    static func duoAdaptive(light: Color, dark: Color) -> Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}

enum DuoStyle {
    static let blueGradient = LinearGradient(
        colors: [
            .duoAdaptive(light: Color(red: 0.2, green: 0.6, blue: 1.0), dark: Color(red: 0.1, green: 0.35, blue: 0.7)),
            .duoAdaptive(light: Color(red: 0.1, green: 0.4, blue: 0.9), dark: Color(red: 0.05, green: 0.25, blue: 0.55))
        ],
        startPoint: .top, endPoint: .bottom
    )
    
    static let orangeGradient = LinearGradient(
        colors: [
            .duoAdaptive(light: Color(red: 1.0, green: 0.6, blue: 0.0), dark: Color(red: 0.85, green: 0.45, blue: 0.0)),
            .duoAdaptive(light: Color(red: 1.0, green: 0.4, blue: 0.0), dark: Color(red: 0.75, green: 0.3, blue: 0.0))
        ],
        startPoint: .top, endPoint: .bottom
    )
    
    static let greenGradient = LinearGradient(
        colors: [
            .duoAdaptive(light: Color(red: 0.4, green: 0.8, blue: 0.0), dark: Color(red: 0.25, green: 0.55, blue: 0.0)),
            .duoAdaptive(light: Color(red: 0.3, green: 0.7, blue: 0.0), dark: Color(red: 0.15, green: 0.45, blue: 0.0))
        ],
        startPoint: .top, endPoint: .bottom
    )

    static func contentColor(for style: WidgetBackgroundStyle) -> Color {
        switch style {
        case .light:    return .black
        case .dark:     return .white
        }
    }

    static func blockFill(for style: WidgetBackgroundStyle, completed: Bool) -> Color {
        switch style {
        case .light:
            return completed ? Color(white: 0.9) : Color(white: 0.8)
        case .dark:
            return completed ? Color(white: 0.25) : Color(white: 0.15)
        }
    }

    @ViewBuilder
    static func backgroundView(for style: WidgetBackgroundStyle, defaultGradient: LinearGradient) -> some View {
        switch style {
        case .light:
            Color.white
        case .dark:
            Color(red: 28/255, green: 28/255, blue: 30/255)
        }
    }
}

// MARK: - PREMIUM STREAK BACKGROUND
struct StreakBackgroundView: View {
    let style: WidgetBackgroundStyle
    
    var body: some View {
        ZStack {
            if style == .light {
                Color.white
            } else {
                Color(red: 28/255, green: 28/255, blue: 30/255)
            }
        }
    }
}

// MARK: - PREMIUM WATER BACKGROUND
struct WaterBackgroundView: View {
    let style: WidgetBackgroundStyle
    
    var body: some View {
        ZStack {
            if style == .light {
                Color.white
            } else {
                Color(red: 28/255, green: 28/255, blue: 30/255)
            }
            
            // 4. Rim Light
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(
                    LinearGradient(
                        colors: [.white.opacity(0.6), .clear, .white.opacity(0.2)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
                .blendMode(.screen)
        }
    }
}



// MARK: - SMALL: Wasser-Widget (Duolingo Stil)

struct WaterWidgetView: View {
    let entry: GroovyStreakEntry

    var count: Int {
        entry.appData?.totalWateringCount ?? 0
    }

    var ml: Int { count * mlPerWatering }

    var displayAmount: String {
        if ml >= 1000 {
            let liter = Double(ml) / 1000.0
            return String(format: "%.1fL", liter)
        }
        return "\(ml)ml"
    }

    var body: some View {
        VStack(spacing: 2) {
            PNGImage("Drop water")
                    .scaledToFit()
                    .frame(width: 42, height: 42)
                    .padding(.bottom, 2)
                
                Text(displayAmount)
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(DuoStyle.contentColor(for: entry.backgroundStyle))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)

                Text(String(localized: "widget_water_alltime", defaultValue: "GESAMT").uppercased())
                    .font(.system(size: 10, weight: .black))
                    .foregroundStyle(DuoStyle.contentColor(for: entry.backgroundStyle).opacity(0.7))
                    .tracking(1.2)
                
                Spacer().frame(height: 4)
                
                Text(String(format: String(localized: "widget_water_times", defaultValue: "%d mal"), count))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(DuoStyle.contentColor(for: entry.backgroundStyle).opacity(0.6))
        }
        .padding(12)
        .widgetURL(URL(string: "grovy://water"))
    }
}

// MARK: - SMALL: Streak-Widget (Duolingo Stil)

struct StreakSmallWidgetView: View {
    let entry: GroovyStreakEntry
    var streak: Int { entry.appData?.totalStreak ?? 0 }

    var body: some View {
        VStack(spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(streak)")
                    .font(.system(size: 38, weight: .black, design: .rounded))
                Text(String(localized: "widget_streak_days", defaultValue: "TAGE").uppercased())
                    .font(.system(size: 10, weight: .black))
                    .opacity(0.7)
            }
            .foregroundStyle(DuoStyle.contentColor(for: entry.backgroundStyle))
            
            PNGImage("streak")
                .scaledToFit()
                .frame(width: 65, height: 65)
            
            Spacer()
        }
        .padding(.top, 16)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .widgetURL(URL(string: "grovy://streak"))
    }
}






// MARK: - MEDIUM: Streak-Verlauf 7 Tage (Duolingo Stil)

struct VerlaufMediumWidgetView: View {
    let entry: GroovyStreakEntry
    var streak: Int { entry.appData?.totalStreak ?? 0 }

    var last7Days: [(date: Date, label: String, completed: Bool)] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        let completedDatesSet = Set((entry.appData?.completedStreakDates ?? []).map { cal.startOfDay(for: $0) })
        let weekdaySymbols = cal.shortWeekdaySymbols
        return (0..<7).reversed().map { offset in
            let date = cal.date(byAdding: .day, value: -offset, to: today)!
            let weekdayIndex = cal.component(.weekday, from: date) - 1
            let label = String(weekdaySymbols[weekdayIndex].prefix(2))
            return (date: date, label: label, completed: completedDatesSet.contains(date))
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {


            HStack(spacing: 0) {
                ForEach(last7Days, id: \.date) { day in
                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(DuoStyle.blockFill(for: entry.backgroundStyle, completed: day.completed))
                                .frame(width: 36, height: 36)
                            
                            if day.completed {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(Color.orange)
                            }
                        }
                        Text(day.label)
                            .font(.system(size: 10, weight: .black))
                            .foregroundStyle(DuoStyle.contentColor(for: entry.backgroundStyle).opacity(0.8))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(16)
        .widgetURL(URL(string: "grovy://streak"))
    }
}

// MARK: - LARGE: Monats-Historie (Aktueller Monat, Orange)

struct VerlaufLargeWidgetView: View {
    let entry: GroovyStreakEntry
    var streak: Int { entry.appData?.totalStreak ?? 0 }

    var currentMonthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        formatter.locale = .current
        return formatter.string(from: Date()).uppercased()
    }

    var gridDays: [(date: Date?, completed: Bool)] {
        let cal = Calendar.current
        let now = Date()
        let completedDatesSet = Set((entry.appData?.completedStreakDates ?? []).map { cal.startOfDay(for: $0) })
        
        guard let monthRange = cal.range(of: .day, in: .month, for: now),
              let startOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: now)) else { return [] }
        
        let daysInMonth = monthRange.count
        let weekdayOfFirst = cal.component(.weekday, from: startOfMonth)
        
        let paddingCount = (weekdayOfFirst + 5) % 7
        
        var result: [(date: Date?, completed: Bool)] = Array(repeating: (nil, false), count: paddingCount)
        
        for day in 1...daysInMonth {
            if let date = cal.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                result.append((date: date, completed: completedDatesSet.contains(cal.startOfDay(for: date))))
            }
        }
        return result
    }

    var weekdayHeaders: [String] {
        let cal = Calendar.current
        var symbols = cal.shortWeekdaySymbols
        symbols = Array(symbols[1...]) + [symbols[0]]
        return symbols.map { String($0.prefix(2)) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text(currentMonthName)
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(DuoStyle.contentColor(for: entry.backgroundStyle).opacity(0.8))
                        .tracking(1)
                    Text(String(localized: "widget_verlauf_month_title", defaultValue: "Monatsverlauf"))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(DuoStyle.contentColor(for: entry.backgroundStyle))
                }
                Spacer()
                HStack(spacing: 6) {
                    PNGImage("streak")
                        .scaledToFit()
                        .frame(width: 26, height: 26)
                    
                    Text("\(streak)")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(DuoStyle.contentColor(for: entry.backgroundStyle))
                }
            }

            HStack(spacing: 0) {
                ForEach(weekdayHeaders, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 11, weight: .black))
                        .foregroundStyle(DuoStyle.contentColor(for: entry.backgroundStyle).opacity(0.6))
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 6) {
                ForEach(Array(gridDays.enumerated()), id: \.offset) { _, day in
                    if let _ = day.date {
                        ZStack {
                            Circle()
                                .fill(DuoStyle.blockFill(for: entry.backgroundStyle, completed: day.completed))
                            
                            if day.completed {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(Color.orange)
                            }
                        }
                        .aspectRatio(1, contentMode: .fit)
                    } else {
                        Color.clear.aspectRatio(1, contentMode: .fit)
                    }
                }
            }
        }
        .padding(18)
        .widgetURL(URL(string: "grovy://streak"))
    }
}


// MARK: - LOCK SCREEN: Streak Widget
struct LockScreenStreakWidgetView: View {
    let entry: GroovyStreakEntry
    var streak: Int { entry.appData?.totalStreak ?? 0 }
    
    var isPro: Bool {
        SharedUserDefaults.suite.bool(forKey: "isProUser_active") || SharedUserDefaults.suite.bool(forKey: "debug_isProUser")
    }

    var body: some View {
        ZStack {
            if #available(iOSApplicationExtension 16.0, *) {
                AccessoryWidgetBackground()
            }
            if isPro {
                VStack(spacing: 0) {
                    PNGImage("streak")
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    Text("\(streak)")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                }
            } else {
                VStack(spacing: 2) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color(red: 1.0, green: 0.84, blue: 0.0))
                    Text("PRO")
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(Color(red: 1.0, green: 0.84, blue: 0.0))
                }
            }
        }
        .widgetURL(URL(string: isPro ? "grovy://streak" : "grovy://pro"))
    }
}

// MARK: - INTERACTIVE ROUTINE WIDGET (Pro)
struct InteractiveHabitsWidgetView: View {
    let entry: GroovyRoutineEntry
    
    var isPro: Bool {
        SharedUserDefaults.suite.bool(forKey: "isProUser_active") || SharedUserDefaults.suite.bool(forKey: "debug_isProUser")
    }
    
    var routinePlants: [WidgetPlantData] {
        guard let appData = entry.appData, let routine = entry.routine else { return [] }
        guard let data = SharedUserDefaults.suite.data(forKey: "customRoutinesData"),
              let routines = try? JSONDecoder().decode([WidgetRoutineUIData].self, from: data),
              let fullRoutine = routines.first(where: { $0.id.uuidString == routine.id }) else {
            return []
        }
        
        let allPlants = appData.plants
        let assigned = fullRoutine.assignedHabitIDs ?? []
        let matched = allPlants.filter { assigned.contains($0.id) }
        
        return matched.sorted { p1, p2 in
            let idx1 = assigned.firstIndex(of: p1.id) ?? Int.max
            let idx2 = assigned.firstIndex(of: p2.id) ?? Int.max
            return idx1 < idx2
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if isPro {
                if let routineEntity = entry.routine {
                    HStack(spacing: 6) {
                        Text(String(localized: String.LocalizationValue(routineEntity.titleKey)))
                            .font(.system(size: 14, weight: .black, design: .rounded))
                    }
                    .foregroundStyle(DuoStyle.contentColor(for: entry.style))
                    .padding(.bottom, 2)
                    
                    let plants = routinePlants
                    if plants.isEmpty {
                        VStack {
                            Spacer()
                            Text(String(localized: "widget_routine_empty", defaultValue: "Keine Aufgaben."))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(DuoStyle.contentColor(for: entry.style).opacity(0.8))
                                .frame(maxWidth: .infinity, alignment: .center)
                            Spacer()
                        }
                    } else {
                        // Taskito-Style Timeline
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(Array(plants.prefix(4).enumerated()), id: \.element.id) { index, plant in
                                let isLast = index == min(plants.count - 1, 3)
                                HStack(alignment: .top, spacing: 10) {
                                    // Timeline Line and Dot
                                    VStack(spacing: 0) {
                                        ZStack {
                                            Circle()
                                                .strokeBorder(DuoStyle.contentColor(for: entry.style).opacity(plant.isWateredToday ? 0.3 : 1.0), lineWidth: 2)
                                                .frame(width: 14, height: 14)
                                                .background(Circle().fill(plant.isWateredToday ? DuoStyle.contentColor(for: entry.style).opacity(0.3) : Color.clear))
                                            
                                            if plant.isWateredToday {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 8, weight: .black))
                                                    .foregroundStyle(DuoStyle.contentColor(for: entry.style))
                                            }
                                        }
                                        
                                        if !isLast {
                                            Rectangle()
                                                .fill(DuoStyle.contentColor(for: entry.style).opacity(0.2))
                                                .frame(width: 2)
                                                .frame(maxHeight: .infinity)
                                        }
                                    }
                                    .frame(width: 14)
                                    
                                    // Content
                                    HStack {
                                        Text(plant.name)
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundStyle(DuoStyle.contentColor(for: entry.style).opacity(plant.isWateredToday ? 0.5 : 1.0))
                                            .strikethrough(plant.isWateredToday)
                                            .lineLimit(1)
                                        
                                        Spacer()
                                        
                                        if !plant.isWateredToday {
                                            Button(intent: WaterPlantIntent(plant: PlantEntity(id: plant.id, name: plant.name, symbolName: plant.imageName))) {
                                                Image(systemName: "circle")
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundStyle(DuoStyle.contentColor(for: entry.style).opacity(0.3))
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .padding(.bottom, isLast ? 0 : 10)
                                }
                                .padding(.top, index == 0 ? 2 : 0)
                            }
                        }
                    }
                } else {
                    VStack(spacing: 8) {
                        Spacer()
                        Image(systemName: "list.bullet.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(DuoStyle.contentColor(for: entry.style).opacity(0.8))
                        Text(String(localized: "widget_routine_not_selected", defaultValue: "Routine auswählen (Widget bearbeiten)"))
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(DuoStyle.contentColor(for: entry.style).opacity(0.8))
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(Color(red: 1.0, green: 0.84, blue: 0.0))
                    
                    Text("PRO")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(Color(red: 1.0, green: 0.84, blue: 0.0))
                    
                    Text(String(localized: "widget_pro_required", defaultValue: "Pro-Version erforderlich"))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(DuoStyle.contentColor(for: entry.style).opacity(0.7))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding(14)
        .widgetURL(URL(string: isPro ? "grovy://routines" : "grovy://pro"))
    }
}
