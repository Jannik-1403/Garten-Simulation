import SwiftUI
import WidgetKit

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
        case .colorful: return .white
        case .light:    return .black
        case .dark:     return .white
        }
    }

    static func blockFill(for style: WidgetBackgroundStyle, completed: Bool) -> Color {
        switch style {
        case .colorful:
            return completed ? .white : .white.opacity(0.25)
        case .light:
            return completed ? Color(white: 0.9) : Color(white: 0.8)
        case .dark:
            return completed ? Color(white: 0.25) : Color(white: 0.15)
        }
    }

    @ViewBuilder
    static func backgroundView(for style: WidgetBackgroundStyle, defaultGradient: LinearGradient) -> some View {
        switch style {
        case .colorful:
            defaultGradient
        case .light:
            Color.white
        case .dark:
            Color.black
        }
    }
}

// MARK: - PREMIUM STREAK BACKGROUND
struct StreakBackgroundView: View {
    let style: WidgetBackgroundStyle
    
    var body: some View {
        ZStack {
            if style == .colorful {
                // 1. Dynamischer Verlauf (Bernstein zu Goldgelb)
                RadialGradient(
                    stops: [
                        .init(color: Color(red: 1.0, green: 0.95, blue: 0.4), location: 0.0), // Strahlendes Gold
                        .init(color: Color(red: 1.0, green: 0.6, blue: 0.0), location: 0.4),  // Sattes Orange
                        .init(color: Color(red: 0.6, green: 0.2, blue: 0.0), location: 1.0)   // Dunkles Bernstein
                    ],
                    center: UnitPoint(x: 0.85, y: 0.85), // Hinter dem Igel unten rechts
                    startRadius: 10,
                    endRadius: 220
                )
                
                // 2. Volumetrisches Licht (Strahlen)
                GeometryReader { geo in
                    ZStack {
                        ForEach(0..<6) { i in
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [.white.opacity(0.12), .clear],
                                        startPoint: .bottomTrailing,
                                        endPoint: .topLeading
                                    )
                                )
                                .frame(width: geo.size.width * 1.5, height: 30)
                                .rotationEffect(.degrees(Double(i) * 15 - 45), anchor: .bottomTrailing)
                                .offset(x: geo.size.width * 0.2, y: geo.size.height * 0.2)
                                .blur(radius: 15)
                        }
                    }
                }
                
                // 3. Partikel / Bokeh (Glühende Funken)
                Canvas { context, size in
                    for i in 0..<18 {
                        let seed = Double(i)
                        let x = (sin(seed * 123.45) * 0.5 + 0.5) * size.width
                        let y = (cos(seed * 678.90) * 0.5 + 0.5) * size.height
                        let s = (sin(seed * 99.9) * 0.5 + 0.5) * 4 + 2
                        
                        let rect = CGRect(x: x, y: y, width: s, height: s)
                        let color = Color.white.opacity((sin(seed) * 0.5 + 0.5) * 0.3 + 0.1)
                        
                        context.addFilter(.blur(radius: 0.5))
                        context.fill(Path(ellipseIn: rect), with: .color(color))
                    }
                }
            } else if style == .light {
                Color.white
            } else {
                Color.black
            }
            
            // 4. Beleuchteter Rahmen (Rim Light / Edge Highlight)
            RoundedRectangle(cornerRadius: 24) // Widget-Radius Annäherung
                .strokeBorder(
                    LinearGradient(
                        stops: [
                            .init(color: .white.opacity(0.7), location: 0.0),
                            .init(color: .white.opacity(0.1), location: 0.2),
                            .init(color: .clear, location: 0.5),
                            .init(color: .white.opacity(0.3), location: 1.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2.5
                )
                .blendMode(.overlay)
        }
    }
}

// MARK: - PREMIUM WATER BACKGROUND
struct WaterBackgroundView: View {
    let style: WidgetBackgroundStyle
    
    var body: some View {
        ZStack {
            if style == .colorful {
                // 1. Tiefsee-Verlauf (Cyan zu Marineblau)
                RadialGradient(
                    stops: [
                        .init(color: Color(red: 0.4, green: 0.9, blue: 1.0), location: 0.0), // Helles Türkis/Cyan
                        .init(color: Color(red: 0.1, green: 0.5, blue: 0.9), location: 0.5), // Sattes Blau
                        .init(color: Color(red: 0.0, green: 0.2, blue: 0.5), location: 1.0)  // Dunkles Navy
                    ],
                    center: .center,
                    startRadius: 5,
                    endRadius: 200
                )
                
                // 2. Unterwasser-Lichtstrahlen
                GeometryReader { geo in
                    ZStack {
                        ForEach(0..<4) { i in
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [.white.opacity(0.1), .clear],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: geo.size.width * 1.2, height: 40)
                                .rotationEffect(.degrees(Double(i) * 20 - 30))
                                .offset(y: -20)
                                .blur(radius: 25)
                        }
                    }
                }
                
                // 3. Blasen (Water Bubbles)
                Canvas { context, size in
                    for i in 0..<12 {
                        let seed = Double(i)
                        let x = (sin(seed * 432.1) * 0.5 + 0.5) * size.width
                        let y = (cos(seed * 123.4) * 0.5 + 0.5) * size.height
                        let s = (sin(seed * 77.7) * 0.5 + 0.5) * 8 + 4
                        
                        let rect = CGRect(x: x, y: y, width: s, height: s)
                        let color = Color.white.opacity(0.15)
                        
                        context.stroke(Path(ellipseIn: rect), with: .color(color), lineWidth: 1)
                        context.addFilter(.blur(radius: 0.5))
                    }
                }
            } else if style == .light {
                Color.white
            } else {
                Color.black
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
        ZStack(alignment: .bottomTrailing) {
            // Text pushed to the absolute top left
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(streak)")
                        .font(.system(size: 38, weight: .black, design: .rounded))
                    
                    Text(String(localized: "widget_streak_days", defaultValue: "TAGE").uppercased())
                        .font(.system(size: 12, weight: .black))
                        .opacity(0.7)
                }
                .foregroundStyle(DuoStyle.contentColor(for: entry.backgroundStyle))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.top, 2)
                .padding(.leading, 10)
                
            PNGImage("Igel-Streak")
                .scaledToFit()
                .frame(width: 160, height: 160)
                .offset(x: 35, y: 30)
        }
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
            HStack {
                    VStack(alignment: .leading, spacing: 1) {
                        Text(String(localized: "widget_verlauf_week_title", defaultValue: "WOCHENVERLAUF").uppercased())
                            .font(.system(size: 11, weight: .black))
                            .foregroundStyle(DuoStyle.contentColor(for: entry.backgroundStyle).opacity(0.8))
                            .tracking(1)
                        Text(String(format: String(localized: "widget_streak_current", defaultValue: "Aktuell: %d"), streak))
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(DuoStyle.contentColor(for: entry.backgroundStyle))
                    }
                    Spacer()
                    HStack(spacing: 5) {
                        PNGImage("streak")
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        
                        Text("\(streak)")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundStyle(DuoStyle.contentColor(for: entry.backgroundStyle))
                    }
                }

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
        
        // Montag-basiertes Padding (Mo=0, ..., So=6)
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

    var body: some View {
        ZStack {
            if #available(iOSApplicationExtension 16.0, *) {
                AccessoryWidgetBackground()
            }
            VStack(spacing: 0) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 16, weight: .bold))
                Text("\(streak)")
                    .font(.system(size: 18, weight: .black, design: .rounded))
            }
        }
        .widgetURL(URL(string: "grovy://streak"))
    }
}

// MARK: - LOCK SCREEN: Timer Widget
struct LockScreenTimerWidgetView: View {
    let entry: GroovyStreakEntry

    var body: some View {
        ZStack {
            if #available(iOSApplicationExtension 16.0, *) {
                AccessoryWidgetBackground()
            }
            Image(systemName: "timer")
                .font(.system(size: 30, weight: .bold))
        }
        .widgetURL(URL(string: "grovy://timer"))
    }
}
