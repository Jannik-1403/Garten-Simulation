import SwiftUI
import Combine

struct DailyHealthScoreCard: View {
    @StateObject private var vm = DailyFeedbackViewModel()
    @EnvironmentObject var gardenStore: GardenStore
    @State private var showDetailSheet: Bool = false
    @State private var showCalendarSheet: Bool = false

    var body: some View {
        VStack(spacing: 12) {
            // Date Header
            HStack {
                Button {
                    showCalendarSheet = true
                } label: {
                    Text(dateLabel(for: vm.targetDate))
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(.primary)
                }
                Spacer()
            }

            // MARK: Kopfzeile (Score)
            Button {
                showDetailSheet = true
            } label: {
                VStack(spacing: 0) {
                    HStack(spacing: 16) {
                        MiniChunkyProgressRing(
                            progress: Double(vm.dailyScore),
                            goal: 100,
                            color: vm.dailyScore >= 80 ? Color(.systemGreen) : (vm.dailyScore >= 50 ? Color(.systemOrange) : Color(.systemRed))
                        )
                            .frame(width: 56, height: 56)
    
                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(localized: "fitness.score.title", defaultValue: "Tages-Score"))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                }
                .clipped()
            }
            .buttonStyle(PillButtonStyle(
                farbe: .white,
                sekundaerFarbe: Color(white: 0.85),
                cornerRadius: 16,
                shadowDepth: 6
            ))
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 30)
                .onEnded { value in
                    if value.translation.width > 30 {
                        vm.targetDate = Calendar.current.date(byAdding: .day, value: -1, to: vm.targetDate) ?? vm.targetDate
                        vm.reevaluate()
                    } else if value.translation.width < -30 {
                        if !Calendar.current.isDateInToday(vm.targetDate) {
                            vm.targetDate = Calendar.current.date(byAdding: .day, value: 1, to: vm.targetDate) ?? vm.targetDate
                            vm.reevaluate()
                        }
                    }
                }
        )
        .fullScreenCover(isPresented: $showDetailSheet) {
            DailyFeedbackDetailView(vm: vm)
        }
        .sheet(isPresented: $showCalendarSheet) {
            HistoryCalendarSheet(vm: vm)
                .environmentObject(gardenStore)
        }
        .onAppear {
            vm.activeHabits = gardenStore.sichtbarePflanzen
            vm.reevaluate()
        }
        .onReceive(gardenStore.objectWillChange) { _ in
            DispatchQueue.main.async {
                vm.activeHabits = gardenStore.sichtbarePflanzen
                vm.reevaluate()
            }
        }
    }
    
    func dateLabel(for date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return String(localized: "history.today", defaultValue: "Heute")
        } else if Calendar.current.isDateInYesterday(date) {
            return String(localized: "history.yesterday", defaultValue: "Gestern")
        } else {
            let formatter = DateFormatter()
            formatter.locale = Locale.autoupdatingCurrent
            formatter.setLocalizedDateFormatFromTemplate("EEE d.M.")
            return formatter.string(from: date)
        }
    }
}

// MARK: - DailyFeedbackDetailView

struct DailyFeedbackDetailView: View {
    @ObservedObject var vm: DailyFeedbackViewModel
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var gardenStore: GardenStore
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if vm.issueFeedbacks.isEmpty {
                        // Alles perfekt
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color(.systemGreen))
                            Text(String(localized: "fitness.score.perfect", defaultValue: "Perfekt! Alle deine Werte liegen im optimalen Bereich. Weiter so!"))
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                                .lineSpacing(4)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white)
                                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.black.opacity(0.15), lineWidth: 1))
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(white: 0.85))
                                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.black.opacity(0.1), lineWidth: 1))
                                .offset(y: 6)
                        )
                        .padding(.bottom, 6)
                    } else {
                        // Begründungen für Warnungen/Kritische Punkte (jetzt alle)
                        VStack(spacing: 24) {
                            ForEach(vm.issueFeedbacks) { feedback in
                                CategoryIssueRow(feedback: feedback)
                                if feedback.id != vm.issueFeedbacks.last?.id {
                                    Divider()
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white)
                                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.black.opacity(0.15), lineWidth: 1))
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(white: 0.85))
                                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.black.opacity(0.1), lineWidth: 1))
                                .offset(y: 6)
                        )
                        .padding(.bottom, 6)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(String(localized: "fitness.score.detail.title", defaultValue: "Tages-Analyse"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
}

// MARK: - MiniChunkyProgressRing

struct MiniChunkyProgressRing: View {
    var progress: Double
    var goal: Double
    var color: Color = .orange
    var fontSize: CGFloat = 16
    
    var percent: Double {
        if goal <= 0 { return 0 }
        return min(1.0, progress / goal)
    }
    
    var body: some View {
        ZStack {
            // Background Shadow
            Circle()
                .stroke(color.opacity(0.15), lineWidth: 8)
                .offset(y: 2)
            
            // Background Track
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 8)
            
            // Foreground Progress Shadow
            Circle()
                .trim(from: 0.0, to: percent)
                .stroke(color.opacity(0.5), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(Angle(degrees: -90))
                .offset(y: 2)
            
            // Foreground Progress
            Circle()
                .trim(from: 0.0, to: percent)
                .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(Angle(degrees: -90))
                
            VStack(spacing: 0) {
                Text("\(Int(progress))")
                    .font(.system(size: fontSize, weight: .black, design: .rounded))
                    .foregroundColor(color)
            }
        }
    }
}

// MARK: - CategoryIssueRow

private struct CategoryIssueRow: View {
    let feedback: CategoryFeedback

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Text(categoryName)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(feedback.summaryText)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(.secondaryLabel))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
            }
            
            Text(feedback.detailText)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
                
            if let progress = feedback.progress, let goal = feedback.goal, goal > 0 {
                ProgressView(value: min(progress, goal), total: goal)
                    .progressViewStyle(LinearProgressViewStyle(tint: progress >= goal ? Color(.systemGreen) : Color.accentColor))
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var categoryName: String {
         switch feedback.category {
        case .water:     return String(localized: "tagesanalyseHeaderWasser",     defaultValue: "Wasseranalyse")
        case .sleep:     return String(localized: "tagesanalyseHeaderSchlaf",     defaultValue: "Schlafanalyse")
        case .strength:  return String(localized: "tagesanalyseHeaderKraft",  defaultValue: "Kraftanalyse")
        case .running:   return String(localized: "tagesanalyseHeaderSchritte",   defaultValue: "Schrittanalyse")
        case .nutrition: return String(localized: "tagesanalyseHeaderErnaehrung", defaultValue: "Ernährungsanalyse")
        case .gratitude: return String(localized: "tagesanalyseHeaderDankbarkeit", defaultValue: "Dankbarkeits-Check")
        case .cleaning:  return String(localized: "tagesanalyseHeaderCleaning",   defaultValue: "Aufräumen")
        }
    }
}

#Preview {
    DailyHealthScoreCard()
        .padding()
        .background(Color(.systemGroupedBackground))
}

// MARK: - History Calendar Sheet

struct HistoryCalendarSheet: View {
    @ObservedObject var vm: DailyFeedbackViewModel
    @EnvironmentObject var gardenStore: GardenStore
    @Environment(\.dismiss) var dismiss
    @State private var selectedMonth = Date()
    
    var daysOfWeek: [String] {
        let symbols = Calendar.current.shortWeekdaySymbols
        let firstWeekdayIndex = Calendar.current.firstWeekday - 1
        return Array(symbols[firstWeekdayIndex...] + symbols[0..<firstWeekdayIndex])
    }
    
    var installDate: Date {
        var earliest: Date = Date()
        for plant in gardenStore.sichtbarePflanzen {
            if let firstWatering = plant.wateringDates.min(), firstWatering < earliest {
                earliest = firstWatering
            }
            if let firstHistory = plant.intradayProgressHistory.min(by: { $0.timestamp < $1.timestamp })?.timestamp, firstHistory < earliest {
                earliest = firstHistory
            }
        }
        return Calendar.current.startOfDay(for: earliest)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Month Selector
                HStack {
                    Button(action: { selectedMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth)! }) {
                        Image(systemName: "chevron.left")
                    }
                    Spacer()
                    Text(selectedMonth.formatted(.dateTime.month(.wide).year()))
                        .font(.headline)
                    Spacer()
                    Button(action: {
                        let next = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth)!
                        if next <= Date() { selectedMonth = next }
                    }) {
                        Image(systemName: "chevron.right")
                    }
                    .disabled(Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth)! > Date())
                }
                .padding()
                
                // Days Header
                HStack {
                    ForEach(daysOfWeek, id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal)
                
                // Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 16) {
                    let dates = daysInMonth(for: selectedMonth)
                    if let first = dates.first {
                        let weekday = Calendar.current.component(.weekday, from: first)
                        let firstWeekday = Calendar.current.firstWeekday
                        let diff = weekday - firstWeekday
                        let emptyCount = diff < 0 ? diff + 7 : diff
                        ForEach(0..<emptyCount, id: \.self) { _ in
                            Spacer()
                        }
                    }
                    
                    ForEach(dates, id: \.self) { date in
                        let isFuture = Calendar.current.startOfDay(for: date) > Calendar.current.startOfDay(for: Date())
                        let isBeforeInstall = Calendar.current.startOfDay(for: date) < installDate
                        let isDisabled = isFuture || isBeforeInstall
                        let isSelected = Calendar.current.isDate(date, inSameDayAs: vm.targetDate)
                        
                        Button {
                            if !isDisabled {
                                vm.targetDate = date
                                vm.reevaluate()
                                dismiss()
                            }
                        } label: {
                            VStack(spacing: 4) {
                                Text("\(Calendar.current.component(.day, from: date))")
                                    .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                                    .foregroundColor(isSelected ? .blue : (isDisabled ? .gray : .primary))
                                
                                if !isDisabled {
                                    if hasStreak(on: date) {
                                        Text("🔥").font(.system(size: 10))
                                    } else {
                                        Text("❌").font(.system(size: 10))
                                    }
                                } else {
                                    Text(" ").font(.system(size: 10)) // Placeholder
                                }
                            }
                            .frame(width: 40, height: 40)
                        }
                        .disabled(isDisabled)
                    }
                }
                .padding()
                Spacer()
            }
            .navigationTitle(String(localized: "history.pick_date", defaultValue: "Datum auswählen"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "common.close", defaultValue: "Schließen")) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    func daysInMonth(for date: Date) -> [Date] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: date) else { return [] }
        var dates = [Date]()
        var current = monthInterval.start
        while current < monthInterval.end {
            dates.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }
        return dates
    }
    
    func hasStreak(on date: Date) -> Bool {
        let start = Calendar.current.startOfDay(for: date)
        for plant in gardenStore.sichtbarePflanzen {
            if plant.wateringDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: start) }) {
                return true
            }
            if plant.intradayProgressHistory.contains(where: { Calendar.current.isDate($0.timestamp, inSameDayAs: start) && $0.progress > 0 }) {
                return true
            }
        }
        if Calendar.current.isDateInToday(date) {
            for plant in gardenStore.sichtbarePflanzen {
                if plant.isCompleted || plant.customTrackerProgress > 0 || plant.sliderProgress > 0 { return true }
            }
        }
        return false
    }
}
