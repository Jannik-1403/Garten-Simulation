import SwiftUI

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
    @EnvironmentObject var gardenStore: GardenStore
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedMode: StreakMode = .week
    @State private var currentMonth: Date = Date()
    @State private var showFreezeDetail = false
    private let calendar = Calendar.current
    
    @State var selectedPlant: HabitModel? = nil
    var isBadHabitMode: Bool = false
    
    init(selectedPlant: HabitModel? = nil, isBadHabitMode: Bool = false) {
        _selectedPlant = State(initialValue: selectedPlant)
        self.isBadHabitMode = isBadHabitMode
    }
    
    var body: some View {
        ZStack {
            // Background - Same as Shop
            Color.appHintergrund.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // 2. Weekly & Monthly Progress Section
                    // 2. Weekly & Monthly Progress Section
                    VStack(spacing: 16) {
                        LottieView(name: GameConstants.streakLottieURL)
                            .frame(width: 140, height: 140)
                            .shadow(color: .orangePrimary.opacity(0.3), radius: 30)
                        
                        VStack(spacing: 0) {
                            Text("\(selectedPlant?.streak ?? streakStore.currentStreak)")
                                .font(.system(size: 80, weight: .heavy, design: .rounded))
                                .foregroundStyle(.orange)
                        }
                    }
                    .padding(.top, 40)
                    .opacity(selectedMode != .year ? 1.0 : 0.0)
                    .frame(height: selectedMode != .year ? nil : 0)
                    .clipped()
                    .animation(.spring(), value: selectedMode)
                    
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
                                YearlyCalendarView(calendar: calendar, streakStore: streakStore, settings: settings, selectedPlant: selectedPlant)
                                    .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .move(edge: .top).combined(with: .opacity)))
                            }
                        }
                    }
                    .padding(24)
                    .liquidGlass(opacity: 0.05)
                    .padding(.horizontal, 24)
                    .animation(.spring(), value: selectedMode)
                    
                    if !isBadHabitMode {
                        streakFreezeCard
                            .padding(.horizontal, 24)
                            .padding(.bottom, 40)
                    }
                    
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $showFreezeDetail) {
            StreakFreezeDetailSheet()
                .environmentObject(streakStore)
                .environmentObject(gardenStore)
                .environmentObject(settings)
                .presentationDetents([.medium])
                .presentationCornerRadius(32)
        }
        .navigationTitle(selectedPlant == nil
            ? settings.localizedString(for: "streak.view.title")
            : (isBadHabitMode ? selectedPlant!.name : (settings.showHabitInsteadOfName ? settings.localizedString(for: selectedPlant!.displayedHabitName) : settings.localizedString(for: selectedPlant!.name))))
        .navigationBarTitleDisplayMode(.inline)
        .standardNavigationX()
        .toolbar {
            if !isBadHabitMode {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button(action: {
                            withAnimation {
                                selectedPlant = nil
                            }
                        }) {
                            HStack {
                                Text(settings.localizedString(for: "Alle") == "Alle" ? "Alle" : settings.localizedString(for: "Alle"))
                                if selectedPlant == nil {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        
                        ForEach(gardenStore.pflanzen) { pflanze in
                            Button(action: {
                                withAnimation {
                                    selectedPlant = pflanze
                                }
                            }) {
                                HStack {
                                    Text(settings.showHabitInsteadOfName ? settings.localizedString(for: pflanze.displayedHabitName) : settings.localizedString(for: pflanze.name))
                                    if selectedPlant?.id == pflanze.id {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.primary)
                            .padding(8)
                    }
                }
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
                            let completedAmount = isWeekdayCompletedAmount(index)
                            if isCompleted {
                                if isBadHabitMode {
                                    Text("\(completedAmount)")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white)
                                } else {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                        .frame(width: 40, height: 40)
                    }
                        .buttonStyle(Streak3DButtonStyle(color: isWeekdayFrozen(index) ? .blue : (isWeekdayCompleted(index) ? .orange : Color.primary.opacity(0.1)), isCircle: true))
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
                                let isCompleted = isDateCompleted(date)
                                let completedAmount = dateCompletedAmount(date)
                                let isFrozen = isDateFrozen(date)
                                Button(action: {}) {
                                    if isBadHabitMode && isCompleted {
                                        Text("\(completedAmount)")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundStyle(.white)
                                            .frame(width: 32, height: 32)
                                    } else {
                                        Text("\(calendar.component(.day, from: date))")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundStyle(isCompleted ? .white : .secondary)
                                            .frame(width: 32, height: 32)
                                    }
                                }
                                .buttonStyle(Streak3DButtonStyle(color: isFrozen ? .blue : (isCompleted ? .orange : Color.primary.opacity(0.05)), isCircle: true))
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
        return isDateCompleted(dateToCheck)
    }
    
    private func isWeekdayCompletedAmount(_ index: Int) -> Int {
        let today = calendar.startOfDay(for: Date())
        let weekdayOfToday = calendar.component(.weekday, from: today)
        let currentDayInOurMapping = (weekdayOfToday + 5) % 7
        let daysToSubtract = currentDayInOurMapping - index
        guard let dateToCheck = calendar.date(byAdding: .day, value: -daysToSubtract, to: today) else { return 0 }
        return dateCompletedAmount(dateToCheck)
    }

    private func isWeekdayFrozen(_ index: Int) -> Bool {
        let today = calendar.startOfDay(for: Date())
        let weekdayOfToday = calendar.component(.weekday, from: today)
        let currentDayInOurMapping = (weekdayOfToday + 5) % 7
        let daysToSubtract = currentDayInOurMapping - index
        guard let dateToCheck = calendar.date(byAdding: .day, value: -daysToSubtract, to: today) else { return false }
        return isDateFrozen(dateToCheck)
    }

    private func isDateCompleted(_ date: Date) -> Bool {
        if let selectedPlant = selectedPlant {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let key = formatter.string(from: date)
            return (selectedPlant.xpHistory[key] ?? 0) > 0
        } else {
            return streakStore.isDateCompleted(date)
        }
    }

    private func dateCompletedAmount(_ date: Date) -> Int {
        if let selectedPlant = selectedPlant {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let key = formatter.string(from: date)
            return selectedPlant.xpHistory[key] ?? 0
        } else {
            return streakStore.isDateCompleted(date) ? 1 : 0
        }
    }

    private func isDateFrozen(_ date: Date) -> Bool {
        return streakStore.isDateFrozen(date)
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
    
    // MARK: - Streak Freeze Card (Screenshot 1)
    private var streakFreezeCard: some View {
        DuolingoCard(action: { showFreezeDetail = true }) {
            VStack(spacing: 16) {
                ZStack {
                    Image("Streak_Eis")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                }
                .padding(.top, 8)
                
                VStack(spacing: 4) {
                    Text(settings.localizedString(for: "streak.freeze.title"))
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    
                    Text(String(format: settings.localizedString(for: "streak.freeze.unit"), streakStore.streakFreezes))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.blue)
                }
                .padding(.bottom, 8)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Streak Freeze Detail Sheet (Screenshot 2)
struct StreakFreezeDetailSheet: View {
    @EnvironmentObject var streakStore: StreakStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 32) {
            // Icon(s)
            HStack(spacing: -20) {
                ForEach(0..<max(1, streakStore.streakFreezes), id: \.self) { _ in
                    ZStack {
                        Image("Streak_Eis")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                    }
                    .scaleEffect(streakStore.streakFreezes > 1 ? 0.9 : 1.0)
                }
            }
            .padding(.top, 20)
            
            VStack(spacing: 12) {
                Text(settings.localizedString(for: "streak.freeze.description"))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                let countText: Text = {
                    let fullString = String(format: settings.localizedString(for: "streak.freeze.count_format"), streakStore.streakFreezes)
                    let highlight = "\(streakStore.streakFreezes) \(settings.localizedString(for: "common.of") == "common.of" ? "von" : settings.localizedString(for: "common.of")) 2 \(settings.localizedString(for: "common.in_stock") == "common.in_stock" ? "auf Vorrat" : settings.localizedString(for: "common.in_stock"))"
                    
                    // Simple approach: split the string and color the dynamic part
                    // Or just recreate it manually for better control
                    return Text(settings.localizedString(for: "common.you_have") == "common.you_have" ? "Du hast " : settings.localizedString(for: "common.you_have"))
                        .foregroundColor(.primary)
                        + Text(highlight)
                        .foregroundColor(.blue)
                        + Text(".")
                        .foregroundColor(.primary)
                }()
                
                countText
                    .font(.system(size: 18, weight: .bold, design: .rounded))
            }
            
            Spacer()
            
            if streakStore.streakFreezes >= 2 {
                Item3DButton(
                    farbe: .blauPrimary,
                    sekundaerFarbe: .blauPrimary.darker(),
                    groesse: 60,
                    isRectangular: true,
                    aktion: { dismiss() }
                ) {
                    Text(settings.localizedString(for: "streak.freeze.understand"))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                }
            } else {
                Item3DButton(
                    farbe: .blauPrimary,
                    sekundaerFarbe: .blauPrimary.darker(),
                    groesse: 60,
                    isRectangular: true,
                    isDisabled: gardenStore.coins < 100,
                    aktion: buyStreakFreeze
                ) {
                    HStack(spacing: 8) {
                        Text(settings.localizedString(for: "streak.freeze.buy").replacingOccurrences(of: "(100 Coins)", with: ""))
                            .font(.system(size: 18, weight: .bold))
                        
                        HStack(spacing: 4) {
                            Image("coin")
                                .resizable()
                                .frame(width: 24, height: 24)
                            Text("100")
                                .font(.system(size: 18, weight: .bold))
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(32)
    }
    
    private func buyStreakFreeze() {
        guard gardenStore.coins >= 100 && streakStore.streakFreezes < 2 else { return }
        
        withAnimation(.spring()) {
            gardenStore.coins -= 100
            streakStore.streakFreezes += 1
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            if streakStore.streakFreezes >= 2 {
                // optional: auto dismiss or keep showing the "understand" state
            }
        }
    }
}

// MARK: - Yearly Calendar View
struct YearlyCalendarView: View {
    let calendar: Calendar
    let streakStore: StreakStore
    let settings: SettingsStore
    let selectedPlant: HabitModel?
    
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
                            let isCompleted = isDateCompleted(date)
                            let isFrozen = isDateFrozen(date)
                            Circle()
                                .fill(isFrozen ? Color.blue : (isCompleted ? Color.orange : Color.gray.opacity(0.1)))
                                .frame(width: 6, height: 6)
                        }
                    } else {
                        Color.clear.frame(width: 6, height: 6)
                    }
                }
            }
        }
    }
    
    private func isDateCompleted(_ date: Date) -> Bool {
        if let selectedPlant = selectedPlant {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let key = formatter.string(from: date)
            return (selectedPlant.xpHistory[key] ?? 0) > 0
        } else {
            return streakStore.isDateCompleted(date)
        }
    }
    
    private func isDateFrozen(_ date: Date) -> Bool {
        return streakStore.isDateFrozen(date)
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
