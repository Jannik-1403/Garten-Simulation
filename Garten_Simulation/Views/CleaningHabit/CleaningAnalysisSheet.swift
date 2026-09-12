import SwiftUI
import Charts

enum CleaningChartTimeRange: String, CaseIterable, Identifiable {
    case w    = "body.timerange.w"
    case m    = "body.timerange.m"
    case sixM = "body.timerange.sixm"
    case j    = "body.timerange.j"
    
    var id: String { rawValue }
    var localizedName: String {
        switch self {
        case .w: return String(localized: "body.timerange.w", defaultValue: "W")
        case .m: return String(localized: "body.timerange.m", defaultValue: "M")
        case .sixM: return String(localized: "body.timerange.sixm", defaultValue: "6 M.")
        case .j: return String(localized: "body.timerange.j", defaultValue: "J")
        }
    }
}

struct CleaningLogEntry: Identifiable {
    let id = UUID()
    let timestamp: Date
    let progress: Double // Always 1 for each completion
}

struct CleaningAnalysisSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var manager: CleaningManager
    var task: CleaningTask
    
    @State private var showingDeleteAlert = false
    @State private var frequencyDays: Int
    @State private var timeRange: CleaningChartTimeRange = .sixM
    @State private var selectedDate: Date? = nil
    @State private var periodOffset: Int = 0
    
    init(manager: CleaningManager, task: CleaningTask) {
        self.manager = manager
        self.task = task
        _frequencyDays = State(initialValue: task.frequencyDays)
    }
    
    var taskColor: Color { AppColors.color(for: task.colorHex) }
    
    private var chartTitle: String {
        String(localized: String.LocalizationValue(task.nameKey))
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                Color.appHintergrund.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Header
                        HStack(spacing: 6) {
                            Circle()
                                .fill(taskColor)
                                .frame(width: 10, height: 10)
                            Text(chartTitle)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(taskColor)
                        }
                        .padding(.horizontal)
                        .padding(.top, 16)
                        
                        // Zeitbereich Picker
                        Picker("", selection: $timeRange) {
                            ForEach(CleaningChartTimeRange.allCases) { r in
                                Text(r.localizedName).tag(r)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        .onChange(of: timeRange) { _, _ in
                            periodOffset = 0
                            selectedDate = nil
                        }
                        
                        // Stats Header
                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(localized: "cleaning.stat.completions", defaultValue: "MAL ERLEDIGT").uppercased())
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                                .kerning(1.2)

                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                if let selectedDate, let selectedEntry = findSelectedEntry(for: selectedDate) {
                                    Text("\(Int(selectedEntry.progress))")
                                        .font(.system(size: 42, weight: .black, design: .rounded))
                                        .foregroundStyle(taskColor)
                                    Text(String(localized: "cleaning.stat.times", defaultValue: "Mal"))
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundStyle(taskColor.opacity(0.7))
                                } else {
                                    let total = currentTotal
                                    if total > 0 {
                                        Text("\(total)")
                                            .font(.system(size: 42, weight: .black, design: .rounded))
                                            .foregroundStyle(taskColor)
                                        Text(String(localized: "cleaning.stat.times", defaultValue: "Mal"))
                                            .font(.system(size: 20, weight: .bold, design: .rounded))
                                            .foregroundStyle(taskColor.opacity(0.7))
                                    } else {
                                        Text("0")
                                            .font(.system(size: 42, weight: .black, design: .rounded))
                                            .foregroundStyle(Color(UIColor.systemGray3))
                                    }
                                }
                            }

                            if let selectedDate, let selectedEntry = findSelectedEntry(for: selectedDate) {
                                Text(selectedEntry.timestamp.formatted(.dateTime.day().month().year().locale(SettingsStore.shared.appLocale)))
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.secondary)
                            } else {
                                Text(dateRangeLabel)
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Chart
                        if filteredData.isEmpty {
                            emptyStateView
                        } else {
                            chartView
                        }
                        
                        // Edit Interval
                        VStack(alignment: .leading, spacing: 16) {
                            Text(String(localized: "cleaning.edit.interval", defaultValue: "Intervall ändern"))
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Stepper(value: $frequencyDays, in: 1...90) {
                                Text("\(frequencyDays) \(frequencyDays == 1 ? String(localized: "cleaning.add.day.singular", defaultValue: "Tag") : String(localized: "cleaning.add.days", defaultValue: "Tage"))")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
                            .onChange(of: frequencyDays) { _, newValue in
                                var updated = task
                                updated.frequencyDays = newValue
                                manager.updateTask(updated)
                            }
                        }
                        .padding(20)
                        .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
                        .padding(.horizontal)
                        .padding(.top, 16)
                        
                        // Delete Button (item3D-Style)
                        Item3DButton(
                            farbe: .red,
                            sekundaerFarbe: Color(red: 0.7, green: 0, blue: 0),
                            groesse: 56,
                            isRectangular: true,
                            aktion: {
                                showingDeleteAlert = true
                            }
                        ) {
                            HStack {
                                Image(systemName: "trash")
                                    .font(.system(size: 20, weight: .bold))
                                Text(String(localized: "common.delete", defaultValue: "Löschen"))
                                    .font(.system(size: 18, weight: .black, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal)
                        .padding(.top, 24)
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "common.close", defaultValue: "Schließen")) {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                }
            }
            .alert(String(localized: "cleaning.delete.title", defaultValue: "Aufgabe löschen?"), isPresented: $showingDeleteAlert) {
                Button(String(localized: "common.cancel", defaultValue: "Abbrechen"), role: .cancel) { }
                Button(String(localized: "common.delete", defaultValue: "Löschen"), role: .destructive) {
                    manager.deleteTask(task)
                    dismiss()
                }
            }
        }
    }
    
    // MARK: - Chart View
    
    private var visibleDomain: TimeInterval {
        switch timeRange {
        case .w: return 3600 * 24 * 7 // 1 Week
        case .m: return 3600 * 24 * 31 // ~1 Month
        case .sixM: return 3600 * 24 * 30 * 6 // 6 Months
        case .j: return 3600 * 24 * 365 // 1 Year
        }
    }
    
    private var chartXDomain: ClosedRange<Date> {
        let minDate = scrollData.first?.timestamp ?? Date().addingTimeInterval(-visibleDomain)
        let maxDate: Date
        let now = Date()
        let cal = Calendar.current
        
        switch timeRange {
        case .w:
            maxDate = cal.dateInterval(of: .weekOfYear, for: now)?.end.addingTimeInterval(-1) ?? now
        case .m:
            maxDate = cal.dateInterval(of: .month, for: now)?.end.addingTimeInterval(-1) ?? now
        case .sixM, .j:
            maxDate = cal.dateInterval(of: .year, for: now)?.end.addingTimeInterval(-1) ?? now
        }
        
        let start = min(minDate, maxDate.addingTimeInterval(-visibleDomain))
        return start...maxDate
    }
    
    @ViewBuilder
    private var chartView: some View {
        Chart {
            ForEach(scrollData, id: \.timestamp) { entry in
                BarMark(
                    x: .value("x", entry.timestamp),
                    y: .value("y", entry.progress)
                )
                .foregroundStyle(taskColor)
                .cornerRadius(4)
            }
            
            if let selectedDate, let selectedEntry = findSelectedEntry(for: selectedDate) {
                RuleMark(x: .value("Selected", selectedEntry.timestamp))
                    .foregroundStyle(Color(UIColor.systemGray4))
                    .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                    .annotation(position: .top, overflowResolution: .init(x: .fit, y: .disabled)) {
                        VStack(spacing: 2) {
                            Text("\(Int(selectedEntry.progress))")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(taskColor)
                            Text(selectedEntry.timestamp.formatted(.dateTime.day().month().year().locale(SettingsStore.shared.appLocale)))
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(UIColor.tertiarySystemGroupedBackground))
                                .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                        }
                    }
            }
        }
        .chartXSelection(value: $selectedDate)
        .chartScrollableAxes(.horizontal)
        .chartXScale(domain: chartXDomain)
        .chartXVisibleDomain(length: visibleDomain)
        .chartScrollPosition(initialX: Date())
        .chartXAxis {
            let component: Calendar.Component = (timeRange == .sixM || timeRange == .j) ? .month : .day
            let count = (timeRange == .w ? 1 : (timeRange == .m ? 7 : 1))
            
            AxisMarks(values: .stride(by: component, count: count)) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4, 4]))
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        let locale = SettingsStore.shared.appLocale
                        if timeRange == .w {
                            Text(date.formatted(.dateTime.weekday(.short).locale(locale)))
                        } else if timeRange == .m {
                            Text(date.formatted(.dateTime.day().locale(locale)))
                        } else if timeRange == .sixM {
                            Text(date.formatted(.dateTime.month(.abbreviated).locale(locale)))
                        } else {
                            Text(date.formatted(.dateTime.month(.narrow).locale(locale)))
                        }
                    }
                }
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(UIColor.systemGray2))
            }
        }
        .chartYAxis {
            AxisMarks(position: .trailing) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4, 4]))
                AxisValueLabel {
                    if let v = value.as(Double.self) {
                        Text(verbatim: String(format: "%.0f", v))
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color(UIColor.systemGray2))
                    }
                }
            }
        }
        .frame(height: 250)
        .padding(.horizontal)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 40))
                .foregroundColor(.secondary.opacity(0.5))
            Text(String(localized: "cleaning.chart.empty", defaultValue: "Noch keine Daten vorhanden"))
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150)
    }
    
    // MARK: - Logic
    
    private var allData: [CleaningLogEntry] {
        manager.logs.filter { $0.taskId == task.id }.map { CleaningLogEntry(timestamp: $0.timestamp, progress: 1) }.sorted { $0.timestamp < $1.timestamp }
    }
    
    private var scrollData: [CleaningLogEntry] {
        let rawData = allData
        if timeRange == .sixM || timeRange == .j {
            return aggregateByMonth(rawData)
        } else if timeRange == .m {
            return aggregateByWeek(rawData)
        } else {
            return aggregateByDay(rawData)
        }
    }
    
    private var filteredData: [CleaningLogEntry] {
        let range = dateRangeForOffset(periodOffset)
        let rawData = allData.filter { $0.timestamp >= range.start && $0.timestamp <= range.end }
        if timeRange == .sixM || timeRange == .j {
            return aggregateByMonth(rawData)
        } else if timeRange == .m {
            return aggregateByWeek(rawData)
        } else {
            return aggregateByDay(rawData)
        }
    }
    
    private func aggregateByDay(_ data: [CleaningLogEntry]) -> [CleaningLogEntry] {
        guard !data.isEmpty else { return [] }
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: data) { entry -> Date in
            calendar.startOfDay(for: entry.timestamp)
        }
        return grouped.map { (dayStart, entries) in
            CleaningLogEntry(timestamp: dayStart, progress: Double(entries.count))
        }.sorted { $0.timestamp < $1.timestamp }
    }

    private func aggregateByWeek(_ data: [CleaningLogEntry]) -> [CleaningLogEntry] {
        guard !data.isEmpty else { return [] }
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Monday
        
        let grouped = Dictionary(grouping: data) { entry -> Date in
            let comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: entry.timestamp)
            return calendar.date(from: comps) ?? entry.timestamp
        }
        return grouped.map { (weekStart, entries) in
            CleaningLogEntry(timestamp: weekStart, progress: Double(entries.count))
        }.sorted { $0.timestamp < $1.timestamp }
    }

    private func aggregateByMonth(_ data: [CleaningLogEntry]) -> [CleaningLogEntry] {
        guard !data.isEmpty else { return [] }
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: data) { entry -> Date in
            let comps = calendar.dateComponents([.year, .month], from: entry.timestamp)
            return calendar.date(from: comps) ?? entry.timestamp
        }
        return grouped.map { (monthStart, entries) in
            CleaningLogEntry(timestamp: monthStart, progress: Double(entries.count))
        }.sorted { $0.timestamp < $1.timestamp }
    }
    
    private var currentTotal: Int {
        let range = dateRangeForOffset(periodOffset)
        let rawData = allData.filter { $0.timestamp >= range.start && $0.timestamp <= range.end }
        return rawData.count
    }
    
    private func findSelectedEntry(for date: Date) -> CleaningLogEntry? {
        let entries = filteredData
        guard !entries.isEmpty else { return nil }
        return entries.min(by: { abs($0.timestamp.timeIntervalSince(date)) < abs($1.timestamp.timeIntervalSince(date)) })
    }
    
    private func dateRangeForOffset(_ offset: Int) -> (start: Date, end: Date) {
        let cal: Calendar = {
            var c = Calendar.current
            c.firstWeekday = 2 // Montag
            return c
        }()
        let now = Date()
        var start: Date
        var end: Date

        switch timeRange {
        case .w:
            if let currentInterval = cal.dateInterval(of: .weekOfYear, for: now) {
                let baseStart = currentInterval.start
                start = cal.date(byAdding: .weekOfYear, value: offset, to: baseStart) ?? baseStart
                end = cal.date(byAdding: .weekOfYear, value: 1, to: start)?.addingTimeInterval(-1) ?? start
            } else {
                start = now; end = now
            }
        case .m:
            if let currentInterval = cal.dateInterval(of: .month, for: now) {
                let baseStart = currentInterval.start
                start = cal.date(byAdding: .month, value: offset, to: baseStart) ?? baseStart
                end = cal.date(byAdding: .month, value: 1, to: start)?.addingTimeInterval(-1) ?? start
            } else {
                start = now; end = now
            }
        case .sixM:
            if let monthStart = cal.dateInterval(of: .month, for: now)?.start {
                start = cal.date(byAdding: .month, value: -5, to: monthStart) ?? now
                end = cal.dateInterval(of: .month, for: now)?.end.addingTimeInterval(-1) ?? now
            } else {
                start = now; end = now
            }
        case .j:
            if let currentInterval = cal.dateInterval(of: .year, for: now) {
                let baseStart = currentInterval.start
                start = cal.date(byAdding: .year, value: offset, to: baseStart) ?? baseStart
                end = cal.date(byAdding: .year, value: 1, to: start)?.addingTimeInterval(-1) ?? start
            } else {
                start = now; end = now
            }
        }
        return (start, end)
    }

    private var dateRangeLabel: String {
        let locale = SettingsStore.shared.appLocale
        let formatter = DateFormatter()
        formatter.locale = locale
        let range = dateRangeForOffset(periodOffset)

        if periodOffset == 0 {
            switch timeRange {
            case .w:    return String(localized: "body.tracking.this_week", defaultValue: "Diese Woche")
            case .m:    return String(localized: "body.tracking.this_month", defaultValue: "Dieser Monat")
            case .sixM: return String(localized: "body.tracking.six_months", defaultValue: "6 Monate")
            case .j:    return String(localized: "body.tracking.this_year", defaultValue: "Dieses Jahr")
            }
        }

        switch timeRange {
        case .w:
            let startStr = range.start.formatted(.dateTime.day().month().locale(locale))
            let endStr = range.end.formatted(.dateTime.day().month().year().locale(locale))
            return "\(startStr) – \(endStr)"
        case .m:
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: range.start)
        case .sixM:
            return String(localized: "body.tracking.six_months", defaultValue: "6 Monate")
        case .j:
            formatter.dateFormat = "yyyy"
            return formatter.string(from: range.start)
        }
    }
}
