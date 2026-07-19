import SwiftUI

// MARK: - HabitVerlaufView
// 90-day heatmap showing watering history for a single habit.
// Falls back to xpHistory for existing habits that pre-date wateringDates.
struct HabitVerlaufView: View {
    @ObservedObject var pflanze: HabitModel
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var iapStore: IAPStore
    @State private var showPaywall: Bool = false

    private let calendar = Calendar.current
    private let cellSize: CGFloat = 28
    private let cellSpacing: CGFloat = 5

    // The last 90 days, oldest first
    private var days: [Date] {
        let today = calendar.startOfDay(for: Date())
        return (0..<90).compactMap { i in
            calendar.date(byAdding: .day, value: -(89 - i), to: today)
        }
    }

    // Weeks: group 'days' into slices of 7 (Mon..Sun columns)
    private var weeks: [[Date?]] {
        guard let first = days.first else { return [] }
        // Find the weekday of the first day (1=Sun, 2=Mon …)
        let weekdayOffset = (calendar.component(.weekday, from: first) + 5) % 7 // 0=Mon
        var all: [Date?] = Array(repeating: nil, count: weekdayOffset) + days.map { Optional($0) }
        // Pad end so it divides by 7
        while all.count % 7 != 0 { all.append(nil) }
        return stride(from: 0, to: all.count, by: 7).map { Array(all[$0..<min($0+7, all.count)]) }
    }

    private func wasWatered(on date: Date) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let key = dateFormatter.string(from: date)
        // wateringDates is the primary source; xpHistory is the legacy fallback
        return pflanze.wateringDates.contains { calendar.isDate($0, inSameDayAs: date) }
            || (pflanze.xpHistory[key] ?? 0) > 0
    }

    private func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }

    private func isFuture(_ date: Date) -> Bool {
        date > calendar.startOfDay(for: Date())
    }

    private var wateredCount: Int {
        days.filter { wasWatered(on: $0) }.count
    }

    private var consistencyPct: Int {
        Int(Double(wateredCount) / 90.0 * 100)
    }

    private var weekdayLabels: [String] {
        ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]
    }

    private var consistencyAnalysis: (title: String, desc: String) {
        let recentDays = Array(days.suffix(84))
        var weeklyCounts: [Double] = []
        for i in 0..<12 {
            let weekSlice = recentDays[(i*7)..<((i+1)*7)]
            let count = weekSlice.filter { wasWatered(on: $0) }.count
            weeklyCounts.append(Double(count))
        }
        
        let count = Double(weeklyCounts.count)
        let mean = weeklyCounts.reduce(0, +) / count
        let variance = weeklyCounts.reduce(0) { $0 + pow($1 - mean, 2) } / count
        let stdDev = sqrt(variance)
        
        if wateredCount < 5 {
            return (String(localized: "verlauf.analysis.title.new", defaultValue: "Anfangsphase"), String(localized: "verlauf.analysis.desc.new", defaultValue: "Du hast gerade erst angefangen! Bleib dran, um bald erste Trends zu sehen."))
        }
        
        if stdDev > 2.0 {
            return (String(localized: "verlauf.analysis.title.fluctuating", defaultValue: "Starke Schwankungen"), String(localized: "verlauf.analysis.desc.fluctuating", defaultValue: "Deine Routine bei dieser Gewohnheit ist noch unregelmäßig. Versuche, sie an eine bereits bestehende Gewohnheit zu koppeln."))
        } else if mean >= 5.0 {
             return (String(localized: "verlauf.analysis.title.pro", defaultValue: "Eiserne Disziplin"), String(localized: "verlauf.analysis.desc.pro", defaultValue: "Wahnsinn! Du ziehst diese Gewohnheit extrem konstant durch. Das ist eine tief verankerte Routine."))
        } else if mean >= 2.0 {
             return (String(localized: "verlauf.analysis.title.stable", defaultValue: "Gute Basis"), String(localized: "verlauf.analysis.desc.stable", defaultValue: "Du bist stetig dabei, auch wenn du nicht jeden Tag perfekt bist. Das ist genau der richtige Weg!"))
        } else {
             return (String(localized: "verlauf.analysis.title.low", defaultValue: "Wieder reinkommen"), String(localized: "verlauf.analysis.desc.low", defaultValue: "Diese Gewohnheit ist in letzter Zeit etwas eingeschlafen. Setze dir ein kleines, machbares Ziel für morgen."))
        }
    }

    var body: some View {
        if pflanze.plantID.hasPrefix("custom_") || GameDatabase.shared.plant(for: pflanze.plantID) == nil {
            VStack(spacing: 20) {
                Spacer()
                
                Image(systemName: "clock.badge.exclamationmark")
                    .font(.system(size: 60))
                    .foregroundStyle(.secondary.opacity(0.3))
                
                Text(String(localized: "verlauf.custom_plant.message"))
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
        } else {
            ZStack {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // MARK: Stats Row
                        statsRow

                        // MARK: Analysis Card
                        analysisCard

                        // MARK: Heatmap
                        heatmapSection

                        // MARK: Legend
                        legendRow
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .blur(radius: iapStore.isProUser ? 0 : 8)
                    .disabled(!iapStore.isProUser)
                }
                
                if !iapStore.isProUser {
                    VStack(spacing: 16) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundStyle(Color.goldPrimary)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        
                        Stat3DTitleView(title: "PRO INSIGHTS", color: .goldPrimary)
                        
                        Text(String(localized: "paywall.feature.weekly_report.desc", defaultValue: "Lerne dich selbst besser kennen. Entdecke, wann du am produktivsten bist und feiere deinen Fortschritt."))
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Item3DButton(
                            farbe: .goldPrimary,
                            sekundaerFarbe: .goldPrimary.darker(),
                            groesse: 60,
                            shadowDepthFactor: 0.10,
                            isRectangular: true,
                            aktion: { showPaywall = true }
                        ) {
                            Text(String(localized: "focus.paywall.button", defaultValue: "Pro freischalten"))
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 20)
                        }
                        .padding(.top, 8)
                    }
                    .padding(24)
                    .background(Color(UIColor.systemBackground).opacity(0.8))
                    .cornerRadius(24)
                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                    .padding(.horizontal, 20)
                }
            }
            .fullScreenCover(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    // MARK: - Stats Row
    private var statsRow: some View {
        HStack(spacing: 0) {
            statCell(
                value: "\(wateredCount)",
                label: String(localized: "verlauf.stat.days"),
                color: .gruenPrimary
            )
            divider
            statCell(
                value: "\(pflanze.streak)",
                label: String(localized: "verlauf.stat.streak"),
                color: .orangePrimary
            )
            divider
            statCell(
                value: "\(consistencyPct)%",
                label: String(localized: "verlauf.stat.rate"),
                color: .blauPrimary
            )
        }
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
        )
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.black.opacity(0.06))
            .frame(width: 1, height: 40)
    }

    private func statCell(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 26, weight: .black, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Analysis Card
    private var analysisCard: some View {
        let analysis = consistencyAnalysis
        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.yellow)
                    .padding(8)
                    .background(Color.yellow.opacity(0.15))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(analysis.title)
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundColor(.primary)
                    Text(String(localized: "verlauf.analysis.subtitle", defaultValue: "Habit Analyse"))
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            Divider().padding(.vertical, 4)
            
            Text(analysis.desc)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(.primary.opacity(0.85))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
    }

    // MARK: - Heatmap Section
    private var heatmapSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(String(localized: "verlauf.title"))
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)

            if wateredCount == 0 {
                emptyState
            } else {
                heatmapGrid
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
        )
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "drop.fill")
                .font(.system(size: 36))
                .foregroundStyle(Color.blauPrimary.opacity(0.3))
            Text(String(localized: "verlauf.empty.title"))
                .font(.system(size: 15, weight: .bold, design: .rounded))
            Text(String(localized: "verlauf.empty.subtitle"))
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    private var heatmapGrid: some View {
        VStack(alignment: .leading, spacing: cellSpacing) {
            // Weekday header
            HStack(spacing: cellSpacing) {
                ForEach(weekdayLabels, id: \.self) { label in
                    Text(label)
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .frame(width: cellSize)
                        .multilineTextAlignment(.center)
                }
            }

            // Weeks
            ForEach(weeks.indices, id: \.self) { weekIdx in
                HStack(spacing: cellSpacing) {
                    ForEach(0..<7, id: \.self) { dayIdx in
                        if let date = weeks[weekIdx][safe: dayIdx] ?? nil {
                            dayCell(date: date)
                        } else {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: cellSize, height: cellSize)
                        }
                    }
                }
            }
        }
    }

    private func dayCell(date: Date) -> some View {
        let watered = wasWatered(on: date)
        let today = isToday(date)
        let future = isFuture(date)

        return ZStack {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(cellFill(watered: watered, today: today, future: future))
                .frame(width: cellSize, height: cellSize)
            if today {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(Color.blauPrimary, lineWidth: 2)
                    .frame(width: cellSize, height: cellSize)
            }
            if watered {
                Image(systemName: "drop.fill")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
    }

    private func cellFill(watered: Bool, today: Bool, future: Bool) -> Color {
        if future { return Color.black.opacity(0.04) }
        if watered { return Color.gruenPrimary }
        return Color.black.opacity(0.06)
    }

    // MARK: - Legend
    private var legendRow: some View {
        HStack(spacing: 16) {
            Spacer()
            legendItem(color: Color.gruenPrimary, label: "Gegossen")
            legendItem(color: Color.black.opacity(0.06), label: "Nicht gegossen")
        }
        .padding(.bottom, 8)
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(color)
                .frame(width: 14, height: 14)
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }
}

