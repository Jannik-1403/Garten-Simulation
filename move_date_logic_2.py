import re

file_path = "Garten_Simulation/Views/GartenView.swift"
with open(file_path, "r") as f:
    content = f.read()

# 1. State Variable für showCalendarSheet
old_state = """    @State private var showingReward = false
    @State private var showingEnergy = false"""
new_state = """    @State private var showingReward = false
    @State private var showingEnergy = false
    @State private var showCalendarSheet = false"""
content = content.replace(old_state, new_state)

# 2. Date Helpers and UI
old_header = """    @ViewBuilder
    private var staticHeaderBar: some View {
        GartenStatsBar(
            streak: streakStore.currentStreak,
            coins: gardenStore.coins,
            leben: gardenStore.leben,
            onStreakTap: { zeigeStreakDetail = true },
            onCoinsTap: { zeigeCoinsDetail = true },
            onLebenTap: { zeigeLebenDetail = true }
        )
        .padding(.horizontal)
        .padding(.vertical, 8)
        .frame(maxWidth: 850)
        .background(.regularMaterial, ignoresSafeAreaEdges: .top)
    }"""

new_header = """    func defaultFormattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: settings.appLanguage)
        formatter.setLocalizedDateFormatFromTemplate("EEEE d. MMMM")
        return formatter.string(from: date).replacingOccurrences(of: ",", with: "")
    }

    @ViewBuilder
    func dateLabel(for date: Date) -> some View {
        let appLocale = Locale(identifier: settings.appLanguage)
        if Calendar.current.isDateInToday(date) {
            Text(String(localized: "history.today", defaultValue: "Heute", table: "Localizable", locale: appLocale))
        } else if Calendar.current.isDateInYesterday(date) {
            Text(String(localized: "history.yesterday", defaultValue: "Gestern", table: "Localizable", locale: appLocale))
        } else {
            Text(defaultFormattedDate(date))
        }
    }

    @ViewBuilder
    private var staticHeaderBar: some View {
        HStack {
            Button {
                showCalendarSheet = true
            } label: {
                dateLabel(for: dailyFeedbackVM.targetDate)
                    .font(.system(size: 15, weight: .bold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .foregroundColor(.primary)
            }
            Spacer()
            GartenStatsBar(
                streak: streakStore.currentStreak,
                coins: gardenStore.coins,
                leben: gardenStore.leben,
                onStreakTap: { zeigeStreakDetail = true },
                onCoinsTap: { zeigeCoinsDetail = true },
                onLebenTap: { zeigeLebenDetail = true }
            )
            .frame(maxWidth: 300)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .frame(maxWidth: 850)
        .background(.regularMaterial, ignoresSafeAreaEdges: .top)
    }"""
content = content.replace(old_header, new_header)

# 3. Add HistoryCalendarSheet
old_sheet = """        .sheet(isPresented: $zeigeStreakDetail) {
            StreakDetailView()
                .environment(\\.locale, Locale(identifier: settings.appLanguage))
        }"""
new_sheet = """        .sheet(isPresented: $zeigeStreakDetail) {
            StreakDetailView()
                .environment(\\.locale, Locale(identifier: settings.appLanguage))
        }
        .sheet(isPresented: $showCalendarSheet) {
            HistoryCalendarSheet(vm: dailyFeedbackVM)
                .environmentObject(gardenStore)
                .environment(\\.locale, Locale(identifier: settings.appLanguage))
        }"""
content = content.replace(old_sheet, new_sheet)

with open(file_path, "w") as f:
    f.write(content)
