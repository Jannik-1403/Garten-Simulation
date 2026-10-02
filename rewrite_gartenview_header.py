import re

file_path = "Garten_Simulation/Views/GartenView.swift"
with open(file_path, "r") as f:
    content = f.read()

# 1. Update date formatter to explicitly build "Mon 28.9."
old_formatter = """    func defaultFormattedDate(_ date: Date) -> String {
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
    }"""

new_formatter = """    @ViewBuilder
    func dateLabel(for date: Date) -> some View {
        let appLocale = Locale(identifier: settings.appLanguage)
        
        let dayFmt = DateFormatter()
        dayFmt.locale = appLocale
        dayFmt.dateFormat = "EEE"
        
        let numFmt = DateFormatter()
        numFmt.locale = appLocale
        numFmt.dateFormat = "d.M."
        
        let dayStr = dayFmt.string(from: date).capitalized
        let numStr = numFmt.string(from: date)
        
        Text("\\(dayStr) \\(numStr)")
    }"""
content = content.replace(old_formatter, new_formatter)

# 2. Update staticHeaderBar layout
old_header = """    @ViewBuilder
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

new_header = """    @ViewBuilder
    private var staticHeaderBar: some View {
        HStack {
            dateLabel(for: dailyFeedbackVM.targetDate)
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundColor(.primary)
                .contentTransition(.numericText())
                .animation(.spring(), value: dailyFeedbackVM.targetDate)
            
            Spacer()
            
            GartenStatsBar(
                streak: streakStore.currentStreak,
                coins: gardenStore.coins,
                leben: gardenStore.leben,
                onStreakTap: { zeigeStreakDetail = true },
                onCoinsTap: { zeigeCoinsDetail = true },
                onLebenTap: { zeigeLebenDetail = true },
                onCalendarTap: { showCalendarSheet = true }
            )
        }
        .padding(.horizontal)
        .padding(.top, 16)
        .frame(maxWidth: 850)
        // Kein Hintergrund, nur das rohe UI wie auf dem Screenshot
    }"""
content = content.replace(old_header, new_header)

with open(file_path, "w") as f:
    f.write(content)
