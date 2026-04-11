import SwiftUI
import DotLottie

enum StreakMode: String, CaseIterable, Identifiable {
    case week, month, year
    var id: String { self.rawValue }
    
    func label(settings: SettingsStore) -> String {
        switch self {
        case .week: return settings.localizedString(for: "streak.mode.week")
        case .month: return settings.localizedString(for: "streak.mode.month")
        case .year: return settings.localizedString(for: "streak.mode.year")
        }
    }
}

struct StreakView: View {
    @EnvironmentObject var streakStore: StreakStore
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedMode: StreakMode = .week
    @State private var currentMonth: Date = Date()
    private let calendar = Calendar.current
    
    var body: some View {
        ZStack {
            // Background - Clean and White
            Color.white.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // 2. Weekly & Monthly Progress Section
                    if selectedMode != .year {
                        VStack(spacing: 16) {
                            SafeDotLottieView(
                                url: "https://lottie.host/b8842b8d-669c-45fe-a8cb-92cbd20903dc/9KcW3VdzUV.lottie",
                                animationConfig: .init(autoplay: true, loop: true, speed: 0.7),
                                fixedSize: CGSize(width: 200, height: 200)
                            )
                            .shadow(color: .orange.opacity(0.15), radius: 30)
                            
                            VStack(spacing: 0) {
                                Text("\(streakStore.currentStreak)")
                                    .font(.system(size: 80, weight: .heavy, design: .rounded))
                                    .foregroundStyle(.orange)
                            }
                        }
                        .padding(.top, 40)
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    VStack(spacing: 24) {
                        // Segmented Picker
                        Picker("", selection: $selectedMode) {
                            ForEach(StreakMode.allCases) { mode in
                                Text(mode.label(settings: settings)).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 4)

                        // Header for Card
                        HStack {
                            Text(headerTitle)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            if selectedMode == .month {
                                // Month Navigation
                                HStack(spacing: 16) {
                                    Button(action: { changeMonth(by: -1) }) {
                                        Image(systemName: "chevron.left")
                                            .font(.system(size: 14, weight: .bold))
                                    }
                                    Button(action: { changeMonth(by: 1) }) {
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .bold))
                                    }
                                }
                                .foregroundStyle(.orange)
                            }
                        }
                        .padding(.horizontal, 4)
                        
                        Group {
                            switch selectedMode {
                            case .week:
                                weeklyProgressRow
                                    .transition(.opacity)
                            case .month:
                                monthlyCalendarGrid
                                    .transition(.asymmetric(insertion: .push(from: .bottom).combined(with: .opacity), removal: .push(from: .top).combined(with: .opacity)))
                            case .year:
                                YearlyCalendarView(calendar: calendar, streakStore: streakStore, settings: settings)
                                    .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .move(edge: .top).combined(with: .opacity)))
                            }
                        }
                    }
                    .padding(24)
                    .liquidGlass(opacity: 0.05)
                    .padding(.horizontal, 24)
                    .animation(.spring(), value: selectedMode)
                    
                    Spacer()
                }
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.secondary)
                }
            }
            ToolbarItem(placement: .principal) {
                Text(settings.localizedString(for: "streak.view.title"))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var headerTitle: String {
        switch selectedMode {
        case .week:
            return settings.localizedString(for: "streak.view.weekly_overview")
        case .month:
            return monthYearString(from: currentMonth)
        case .year:
            let year = calendar.component(.year, from: currentMonth)
            return String(format: settings.localizedString(for: "streak.view.year_format"), year)
        }
    }
    
    // MARK: - Weekly Progress
    private var weeklyProgressRow: some View {
        HStack(spacing: 10) {
            let weekdays = localizedWeekdays
            ForEach(0..<7, id: \.self) { index in
                VStack(spacing: 12) {
                    Text(weekdays[index])
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.secondary)
                    
                    Button(action: {}) {
                        ZStack {
                            let isCompleted = isWeekdayCompleted(index)
                            if isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .frame(width: 40, height: 40)
                    }
                    .buttonStyle(Streak3DButtonStyle(color: isWeekdayCompleted(index) ? .orange : Color.primary.opacity(0.1), isCircle: true))
                    .disabled(true)
                }
            }
        }
    }
    
    // MARK: - Monthly Calendar Grid
    private var monthlyCalendarGrid: some View {
        VStack(spacing: 15) {
            // Day Labels
            HStack(spacing: 0) {
                let days = localizedWeekdays
                ForEach(days, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            let days = generateDaysInMonth(for: currentMonth)
            let rows = days.chunked(into: 7)
            
            VStack(spacing: 10) {
                ForEach(rows.indices, id: \.self) { rowIndex in
                    HStack(spacing: 10) {
                        ForEach(rows[rowIndex], id: \.self) { date in
                            if let date = date {
                                let isCompleted = streakStore.isDateCompleted(date)
                                Button(action: {}) {
                                    Text("\(calendar.component(.day, from: date))")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(isCompleted ? .white : .secondary)
                                        .frame(width: 32, height: 32)
                                }
                                .buttonStyle(Streak3DButtonStyle(color: isCompleted ? .orange : Color.primary.opacity(0.05), isCircle: true))
                                .disabled(true)
                                .frame(maxWidth: .infinity)
                            } else {
                                Color.clear.frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func isWeekdayCompleted(_ index: Int) -> Bool {
        let today = calendar.startOfDay(for: Date())
        let weekdayOfToday = calendar.component(.weekday, from: today)
        let currentDayInOurMapping = (weekdayOfToday + 5) % 7
        let daysToSubtract = currentDayInOurMapping - index
        guard let dateToCheck = calendar.date(byAdding: .day, value: -daysToSubtract, to: today) else { return false }
        return streakStore.isDateCompleted(dateToCheck)
    }

    private var localizedWeekdays: [String] {
        let weekdayString = settings.localizedString(for: "streak.weekdays.short")
        let symbols = weekdayString.components(separatedBy: ",")
        if symbols.count == 7 {
            return symbols
        }
        
        // Fallback
        return ["M", "D", "M", "D", "F", "S", "S"]
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        let localeId: String
        switch settings.appLanguage {
        case "de": localeId = "de_DE"
        case "es": localeId = "es_ES"
        default:   localeId = "en_US"
        }
        formatter.locale = Locale(identifier: localeId)
        formatter.dateFormat = settings.localizedString(for: "streak.format.month_year")
        return formatter.string(from: date)
    }
    
    private func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) {
            withAnimation { currentMonth = newMonth }
        }
    }
    
    private func generateDaysInMonth(for date: Date) -> [Date?] {
        let range = calendar.range(of: .day, in: .month, for: date)!
        let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        var weekday = calendar.component(.weekday, from: firstOfMonth) - 2 // Adjust for Monday start
        if weekday < 0 { weekday = 6 }
        
        var days: [Date?] = Array(repeating: nil, count: weekday)
        for day in 1...range.count {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(date)
            }
        }
        while days.count % 7 != 0 { days.append(nil) }
        return days
    }
}

// MARK: - Yearly Calendar View
struct YearlyCalendarView: View {
    let calendar: Calendar
    let streakStore: StreakStore
    let settings: SettingsStore
    
    var body: some View {
        let year = calendar.component(.year, from: Date())
        let columns = [
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10)
        ]
        
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(1...12, id: \.self) { month in
                VStack(spacing: 8) {
                    Text(monthName(for: month))
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                    
                    miniMonthGrid(for: month, in: year)
                }
                .padding(8)
                .background(Color.primary.opacity(0.03))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
    
    @ViewBuilder
    private func miniMonthGrid(for month: Int, in year: Int) -> some View {
        let components = DateComponents(year: year, month: month, day: 1)
        if let firstDayOfMonth = calendar.date(from: components) {
            let daysInMonth = calendar.range(of: .day, in: .month, for: firstDayOfMonth)!.count
            let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth) - 2 // Monday start
            let adjustedFirstWeekday = firstWeekday < 0 ? 6 : firstWeekday
            
            let totalCells = adjustedFirstWeekday + daysInMonth
            let columns = Array(repeating: GridItem(.fixed(6), spacing: 2), count: 7)
            
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(0..<totalCells, id: \.self) { index in
                    if index >= adjustedFirstWeekday {
                        let day = index - adjustedFirstWeekday + 1
                        let dateComponents = DateComponents(year: year, month: month, day: day)
                        if let date = calendar.date(from: dateComponents) {
                            Circle()
                                .fill(streakStore.isDateCompleted(date) ? Color.orange : Color.gray.opacity(0.1))
                                .frame(width: 6, height: 6)
                        }
                    } else {
                        Color.clear.frame(width: 6, height: 6)
                    }
                }
            }
        }
    }
    
    private func monthName(for month: Int) -> String {
        return settings.localizedString(for: "month.\(month)")
    }
}

// MARK: - 3D Button Style
struct Streak3DButtonStyle: ButtonStyle {
    var color: Color
    var isSmall: Bool = false
    var isCircle: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        let shadowDepth: CGFloat = isSmall ? 2 : 4
        
        configuration.label
            .padding(.horizontal, isCircle ? 0 : (isSmall ? 12 : 20))
            .padding(.vertical, isCircle ? 0 : (isSmall ? 6 : 12))
            .background(
                Group {
                    if isCircle {
                        Circle()
                            .fill(color)
                            .shadow(color: color.darker(), radius: 0, y: pressed ? 0 : shadowDepth)
                    } else {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(color)
                            .shadow(color: color.darker(), radius: 0, y: pressed ? 0 : shadowDepth)
                    }
                }
            )
            .offset(y: pressed ? shadowDepth : 0)
            .animation(.interactiveSpring(), value: pressed)
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

#Preview {
    NavigationStack {
        StreakView()
            .environmentObject(StreakStore())
    }
}
