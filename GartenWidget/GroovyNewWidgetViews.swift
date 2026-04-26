import SwiftUI
import WidgetKit

private let mlPerWatering: Int = 300

// MARK: - Igel-Assets
private let igelAssets: [String] = [
    "Igel-Backen", "Igel-Code", "Igel-Duschen", "Igel-Essen", "Igel-Fischen",
    "Igel-Foto", "Igel-Golf", "Igel-Kochen", "Igel-König", "Igel-Lesen",
    "Igel-Malen", "Igel-Meditieren", "Igel-Musik", "Igel-Schach", "Igel-Schlafen",
    "Igel-Sport", "Igel-Surfen", "Igel-Welttraum", "Igel-wandern"
]
private func igelForToday() -> String {
    let day = Calendar.current.ordinality(of: .day, in: .era, for: .now) ?? 0
    return igelAssets[day % igelAssets.count]
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
        Link(destination: URL(string: "grovy://water")!) {
            VStack(spacing: 2) {
                Image("Drop water")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 42, height: 42)
                    .padding(.bottom, 2)
                
                Text(displayAmount)
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(DuoStyle.contentColor(for: entry.backgroundStyle))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)

                Text(NSLocalizedString("widget_water_alltime", comment: "").uppercased())
                    .font(.system(size: 10, weight: .black))
                    .foregroundStyle(DuoStyle.contentColor(for: entry.backgroundStyle).opacity(0.7))
                    .tracking(1.2)
                
                Spacer().frame(height: 4)
                
                Text(String(format: NSLocalizedString("widget_water_times", comment: ""), count))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(DuoStyle.contentColor(for: entry.backgroundStyle).opacity(0.6))
            }
            .padding(12)
        }
    }
}

// MARK: - SMALL: Streak-Widget (Duolingo Stil)

struct StreakSmallWidgetView: View {
    let entry: GroovyStreakEntry

    var streak: Int { entry.appData?.totalStreak ?? 0 }

    var body: some View {
        Link(destination: URL(string: "grovy://streak")!) {
            VStack(spacing: 2) {
                Image(igelForToday())
                    .resizable()
                    .scaledToFit()
                    .frame(height: 62)
                    .padding(.top, 4)
                
                HStack(spacing: 4) {
                    Image("streak")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                    
                    Text("\(streak)")
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundStyle(DuoStyle.contentColor(for: entry.backgroundStyle))
                }
                
                Text(NSLocalizedString("widget_streak_days", comment: "").uppercased())
                    .font(.system(size: 10, weight: .black))
                    .foregroundStyle(DuoStyle.contentColor(for: entry.backgroundStyle).opacity(0.7))
                    .tracking(1.2)
            }
            .padding(10)
        }
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
        Link(destination: URL(string: "grovy://streak")!) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 1) {
                        Text(NSLocalizedString("widget_verlauf_week_title", comment: "").uppercased())
                            .font(.system(size: 11, weight: .black))
                            .foregroundStyle(DuoStyle.contentColor(for: entry.backgroundStyle).opacity(0.8))
                            .tracking(1)
                        Text(String(format: NSLocalizedString("widget_streak_current", comment: ""), streak))
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(DuoStyle.contentColor(for: entry.backgroundStyle))
                    }
                    Spacer()
                    HStack(spacing: 5) {
                        Image("streak")
                            .resizable()
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
                                    .shadow(color: .black.opacity(day.completed ? 0.12 : 0), radius: 2, y: 2)
                                
                                if day.completed {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 16, weight: .black))
                                        .foregroundStyle(Color.orange)
                                } else {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 16, weight: .black))
                                        .foregroundStyle(DuoStyle.contentColor(for: entry.backgroundStyle).opacity(0.5))
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
        }
    }
}

// MARK: - LARGE: Monats-Historie (Aktueller Monat, Orange)

struct VerlaufLargeWidgetView: View {
    let entry: GroovyStreakEntry
    var streak: Int { entry.appData?.totalStreak ?? 0 }

    var currentMonthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
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
        Link(destination: URL(string: "grovy://streak")!) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 1) {
                        Text(currentMonthName)
                            .font(.system(size: 12, weight: .black))
                            .foregroundStyle(DuoStyle.contentColor(for: entry.backgroundStyle).opacity(0.8))
                            .tracking(1)
                        Text(NSLocalizedString("widget_verlauf_month_title", comment: ""))
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(DuoStyle.contentColor(for: entry.backgroundStyle))
                    }
                    Spacer()
                    HStack(spacing: 6) {
                        Image("streak")
                            .resizable()
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
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(DuoStyle.blockFill(for: entry.backgroundStyle, completed: day.completed))
                                    .shadow(color: .black.opacity(day.completed ? 0.12 : 0), radius: 2, y: 2)
                                
                                if day.completed {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 10, weight: .black))
                                        .foregroundStyle(Color.orange)
                                }
                            }
                            .aspectRatio(1, contentMode: .fit)
                        } else {
                            Color.clear.aspectRatio(1, contentMode: .fit)
                        }
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(18)
        }
    }
}
