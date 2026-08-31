import SwiftUI
import Charts
import HealthKit

// MARK: - BodyDataFactoryView

struct BodyDataFactoryView: View {
    @ObservedObject var pflanze: HabitModel
    let type: BodyTrackingType

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var gardenStore: GardenStore
    @StateObject private var hm = HealthManager.shared

    @State private var timeRange: BodyDataTimeRange = .m
    @State private var selectedMeasurement: BodyMeasurementCategory = {
        let raw = UserDefaults.standard.string(forKey: "lastSelectedBodyMeasure") ?? BodyMeasurementCategory.brust.rawValue
        return BodyMeasurementCategory(rawValue: raw) ?? .brust
    }()
    @State private var showAddSheet = false
    @State private var inputValue: String = ""
    @State private var healthWeightData: [DailyProgressEntry] = []
    @State private var isLoadingHealth = false
    @State private var selectedDate: Date? = nil
    
    @State private var showTargetSheet = false
    @State private var targetInput = ""
    @State private var targetDateInput = Date()
    @State private var isManualEntriesExpanded = false

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Zeitbereich Picker
                Picker("", selection: $timeRange) {
                    ForEach(BodyDataTimeRange.allCases) { r in
                        Text(r.localizedName).tag(r)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)
                .onChange(of: timeRange) { _, _ in
                    if type == .weight { fetchHealthWeight() }
                }

                // Körperumfänge Picker
                if type == .measurements {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(BodyMeasurementCategory.allCases) { cat in
                                Item3DPillButton(
                                    farbe: selectedMeasurement == cat ? Color.pink : Color(UIColor.secondarySystemGroupedBackground),
                                    sekundaerFarbe: selectedMeasurement == cat ? Color(red: 0.8, green: 0.0, blue: 0.35) : Color(UIColor.tertiarySystemGroupedBackground),
                                    groesse: 36,
                                    isPermanentlyPressed: selectedMeasurement == cat,
                                    aktion: { selectedMeasurement = cat }
                                ) {
                                    Text(cat.localizedName)
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundStyle(selectedMeasurement == cat ? .white : .primary)
                                        .lineLimit(1)
                                        .fixedSize(horizontal: true, vertical: false)
                                        .padding(.horizontal, 10)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .onChange(of: selectedMeasurement) { _, newValue in
                            UserDefaults.standard.set(newValue.rawValue, forKey: "lastSelectedBodyMeasure")
                        }
                    }
                    
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(Color.pink)
                        Text(selectedMeasurement.infoText)
                            .font(.system(size: 13, design: .rounded))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }

                // Stats Header – zeigt Durchschnitt
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(localized: "body.tracking.average", defaultValue: "DURCHSCHNITT"))
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .kerning(1.2)

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        let avg = currentAverage
                        if avg > 0 {
                            Text(String(format: "%.1f", avg))
                                .font(.system(size: 42, weight: .black, design: .rounded))
                                .foregroundStyle(.pink)
                            Text(unit)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(.pink.opacity(0.7))
                        } else {
                            Text(String(localized: "body.tracking.no_data", defaultValue: "Keine Daten"))
                                .font(.system(size: 32, weight: .black, design: .rounded))
                                .foregroundStyle(Color(UIColor.systemGray3))
                        }
                    }

                    Text(dateRangeLabel)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                // Chart
                if filteredData.isEmpty {
                    emptyStateView
                } else {
                    chartView
                }
                
                // Ziel (bei Gewicht & Körperumfängen)
                targetSection
                    .padding(.top, 16)
                
                // Manuelle Einträge zum Löschen
                manualEntriesSection
                    .padding(.top, 24)
            }
            .padding(.bottom, 40)
        }
        .navigationTitle(type == .weight
            ? String(localized: "body.tracking.weight", defaultValue: "Gewicht")
            : String(localized: "body.tracking.measurements", defaultValue: "Körperumfänge"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    inputValue = ""
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.primary)
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            addEntrySheet
        }
        .sheet(isPresented: $showTargetSheet) {
            editTargetSheet
        }
        .onAppear {
            if type == .weight { fetchHealthWeight() }
        }
    }

    // MARK: - Chart View

    @ViewBuilder
    private var chartView: some View {
        Chart {
            ForEach(filteredData, id: \.timestamp) { entry in
                LineMark(
                    x: .value("x", entry.timestamp),
                    y: .value("y", entry.progress)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(Color.pink)
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))

                PointMark(
                    x: .value("x", entry.timestamp),
                    y: .value("y", entry.progress)
                )
                .foregroundStyle(Color.pink)
                .symbolSize(40)
            }
            
            if let selectedDate, let selectedEntry = findSelectedEntry(for: selectedDate) {
                RuleMark(x: .value("Selected", selectedEntry.timestamp))
                    .foregroundStyle(Color(UIColor.systemGray4))
                    .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                    .annotation(
                        position: .top, spacing: 0,
                        overflowResolution: .init(x: .fit(to: .chart), y: .disabled)
                    ) {
                        VStack(spacing: 4) {
                            Text(String(format: "%.1f", selectedEntry.progress))
                                .font(.system(size: 16, weight: .black, design: .rounded))
                                .foregroundStyle(Color.pink)
                            Text(selectedEntry.timestamp.formatted(.dateTime.day().month().year()))
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color(UIColor.secondarySystemGroupedBackground))
                                .shadow(color: .black.opacity(0.1), radius: 3, y: 2)
                        )
                    }
            }
        }
        .chartXSelection(value: $selectedDate)
        .chartXAxis {
            AxisMarks(values: xAxisValues) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4, 4]))
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(xAxisLabel(for: date))
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color(UIColor.systemGray2))
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .trailing) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4, 4]))
                AxisValueLabel {
                    if let v = value.as(Double.self) {
                        Text(String(format: "%.0f", v))
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color(UIColor.systemGray2))
                    }
                }
            }
        }
        .chartYScale(domain: yMin...yMax)
        .chartXScale(domain: dateRange.start...dateRange.end)
        .frame(height: 250)
        .padding(.horizontal)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48))
                .foregroundStyle(Color.pink.opacity(0.4))
            Text(String(localized: "body.tracking.no_data", defaultValue: "Keine Daten"))
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
            Text(String(localized: "body.tracking.add_first_entry", defaultValue: "Tippe auf + um deinen ersten Eintrag hinzuzufügen."))
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 250)
    }

    // MARK: - Add Entry Sheet

    private var addEntrySheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Wert-Eingabe
                VStack(spacing: 8) {
                    TextField("0", text: $inputValue)
                        .font(.system(size: 56, weight: .black, design: .rounded))
                        .multilineTextAlignment(.center)
                        .keyboardType(.decimalPad)
                        .foregroundStyle(.pink)

                    Text(unit)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 32)
                
                // Info / Empfehlung
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.pink)
                    
                    Text(type == .weight
                         ? String(localized: "body.tracking.tip.weight", defaultValue: "Tipp: Für beste Ergebnisse empfehlen wir, das Gewicht jeden Morgen zur selben Zeit, nüchtern und ohne vorher etwas zu essen, zu tracken.")
                         : String(localized: "body.tracking.tip.measurements", defaultValue: "Tipp: Körperumfänge verändern sich langsam. Wir empfehlen, sie nur einmal im Monat zu messen, um echte Fortschritte zu sehen."))
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(16)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .padding(.horizontal, 24)

                if type == .measurements {
                    Picker("", selection: $selectedMeasurement) {
                        ForEach(BodyMeasurementCategory.allCases) { cat in
                            Text(cat.localizedName).tag(cat)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Spacer()
            }
            .navigationTitle(String(localized: "common.new", defaultValue: "Neu"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(String(localized: "button.cancel", defaultValue: "Abbrechen")) {
                        showAddSheet = false
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "common.save", defaultValue: "Speichern")) {
                        let val = Double(inputValue.replacingOccurrences(of: ",", with: ".")) ?? 0
                        if val > 0 { addEntry(val) }
                        showAddSheet = false
                    }
                    .bold()
                    .disabled(inputValue.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }

    private var dateRange: (start: Date, end: Date) {
        let cal = Calendar.current
        let now = Date()
        var start: Date
        var end: Date
        
        switch timeRange {
        case .t:
            start = cal.startOfDay(for: now)
            end = cal.date(byAdding: .day, value: 1, to: start)?.addingTimeInterval(-1) ?? now
        case .w:
            // Configure week to start on Monday
            var calendar = Calendar.current
            calendar.firstWeekday = 2 // Monday
            if let interval = calendar.dateInterval(of: .weekOfYear, for: now) {
                start = interval.start
                end = interval.end.addingTimeInterval(-1)
            } else {
                start = now; end = now
            }
        case .m:
            if let interval = cal.dateInterval(of: .month, for: now) {
                start = interval.start
                end = interval.end.addingTimeInterval(-1)
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
            if let interval = cal.dateInterval(of: .year, for: now) {
                start = interval.start
                end = interval.end.addingTimeInterval(-1)
            } else {
                start = now; end = now
            }
        }
        return (start, end)
    }

    // MARK: - HealthKit Fetch (Gewicht)

    private func fetchHealthWeight() {
        guard type == .weight, hm.isAuthorized else { return }
        guard let bodyMassType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else { return }

        isLoadingHealth = true
        // Fetch 1 year of data so local filtering works when timeRange changes
        let start = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date(), options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

        let query = HKSampleQuery(sampleType: bodyMassType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, samples, _ in
            guard let samples = samples as? [HKQuantitySample] else {
                DispatchQueue.main.async { self.isLoadingHealth = false }
                return
            }
            let entries = samples.map { s in
                DailyProgressEntry(timestamp: s.startDate, progress: s.quantity.doubleValue(for: .gramUnit(with: .kilo)))
            }
            DispatchQueue.main.async {
                self.healthWeightData = entries
                self.isLoadingHealth = false
            }
        }
        HealthManager.shared.healthStore.execute(query)
    }

    // MARK: - Logic

    private var unit: String {
        type == .weight ? String(localized: "body.tracking.unit.kg", defaultValue: "kg") : String(localized: "body.tracking.unit.cm", defaultValue: "cm")
    }

    private var allData: [DailyProgressEntry] {
        if type == .weight {
            // Kombination: Apple Health + manuelle Einträge
            let combined = healthWeightData + pflanze.manualWeightEntries
            return combined.sorted { $0.timestamp < $1.timestamp }
        } else {
            return pflanze.bodyMeasurements[selectedMeasurement.rawValue] ?? []
        }
    }

    private var filteredData: [DailyProgressEntry] {
        let range = dateRange
        let rawData = allData.filter { $0.timestamp >= range.start && $0.timestamp <= range.end }
        
        if timeRange == .sixM || timeRange == .j {
            return aggregateByWeek(rawData)
        }
        
        return rawData
    }
    
    private func aggregateByWeek(_ data: [DailyProgressEntry]) -> [DailyProgressEntry] {
        guard !data.isEmpty else { return [] }
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Monday
        
        let grouped = Dictionary(grouping: data) { entry -> Date in
            let comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: entry.timestamp)
            return calendar.date(from: comps) ?? entry.timestamp
        }
        
        return grouped.map { (weekStart, entries) in
            let avgProgress = entries.reduce(0) { $0 + $1.progress } / Double(entries.count)
            return DailyProgressEntry(timestamp: weekStart, progress: avgProgress)
        }.sorted { $0.timestamp < $1.timestamp }
    }

    private var currentAverage: Double {
        let range = dateRange
        let rawData = allData.filter { $0.timestamp >= range.start && $0.timestamp <= range.end }
        guard !rawData.isEmpty else { return 0 }
        return rawData.reduce(0) { $0 + $1.progress } / Double(rawData.count)
    }

    private var yMin: Double {
        let vals = filteredData.map { $0.progress }
        return max(0, (vals.min() ?? 0) - 5)
    }

    private var yMax: Double {
        let vals = filteredData.map { $0.progress }
        return (vals.max() ?? 100) + 5
    }

    private var dateRangeLabel: String {
        switch timeRange {
        case .t:    return String(localized: "body.tracking.today", defaultValue: "Heute")
        case .w:    return String(localized: "body.tracking.this_week", defaultValue: "Diese Woche")
        case .m:    return String(localized: "body.tracking.this_month", defaultValue: "Dieser Monat")
        case .sixM: return String(localized: "body.tracking.six_months", defaultValue: "6 Monate")
        case .j:    return String(localized: "body.tracking.this_year", defaultValue: "Dieses Jahr")
        }
    }

    // MARK: - X-Achse Dynamisch

    private var xAxisValues: [Date] {
        let cal = Calendar.current
        let start = dateRange.start
        
        switch timeRange {
        case .t:
            // 0:00, 6:00, 12:00, 18:00
            return [0, 6, 12, 18].compactMap {
                cal.date(bySettingHour: $0, minute: 0, second: 0, of: start)
            }
        case .w:
            // 7 Tage der aktuellen Woche (Montag bis Sonntag)
            return (0..<7).compactMap { i in
                cal.date(byAdding: .day, value: i, to: start)
            }
        case .m:
            // 1., 8., 15., 22., 29. des aktuellen Monats
            return [1, 8, 15, 22, 29].compactMap { day in
                var comps = cal.dateComponents([.year, .month], from: start)
                comps.day = day
                return cal.date(from: comps)
            }
        case .sixM:
            // Die 6 Monate von start
            return (0..<6).compactMap { i in
                cal.date(byAdding: .month, value: i, to: start)
            }
        case .j:
            // Alle 12 Monate des aktuellen Jahres
            return (0..<12).compactMap { i in
                cal.date(byAdding: .month, value: i, to: start)
            }
        }
    }

    private func xAxisLabel(for date: Date) -> String {
        let cal = Calendar.current
        switch timeRange {
        case .t:
            let h = cal.component(.hour, from: date)
            return "\(h):00"
        case .w:
            let formatter = DateFormatter()
            formatter.locale = SettingsStore.shared.appLocale
            let weekday = cal.component(.weekday, from: date)
            return formatter.shortWeekdaySymbols[weekday - 1]
        case .m:
            let day = cal.component(.day, from: date)
            return String(localized: "body.tracking.chart.day", defaultValue: "\(day).")
        case .sixM:
            let formatter = DateFormatter()
            formatter.locale = SettingsStore.shared.appLocale
            formatter.dateFormat = "MMM"
            return formatter.string(from: date)
        case .j:
            let formatter = DateFormatter()
            formatter.locale = SettingsStore.shared.appLocale
            let month = cal.component(.month, from: date)
            return formatter.veryShortMonthSymbols[month - 1]
        }
    }

    // MARK: - Eintrag hinzufügen

    private func addEntry(_ value: Double) {
        let timestamp = selectedDate ?? Date()
        let entry = DailyProgressEntry(timestamp: timestamp, progress: value)
        if type == .weight {
            pflanze.manualWeightEntries.append(entry)
        } else {
            var measures = pflanze.bodyMeasurements[selectedMeasurement.rawValue] ?? []
            measures.append(entry)
            pflanze.bodyMeasurements[selectedMeasurement.rawValue] = measures
        }
        gardenStore.savePlants()
    }

    // MARK: - Safe Array Subscript

    private func findSelectedEntry(for date: Date) -> DailyProgressEntry? {
        let entries = filteredData
        guard !entries.isEmpty else { return nil }
        // Finde den Eintrag, der am nächsten am selektierten Datum liegt
        return entries.min(by: { abs($0.timestamp.timeIntervalSince(date)) < abs($1.timestamp.timeIntervalSince(date)) })
    }

    // MARK: - Target Weight & Manual Entries UI
    
    private var currentValue: Double? {
        allData.last?.progress
    }

    private var currentTarget: Double? {
        if type == .weight {
            return pflanze.targetWeight
        } else {
            return pflanze.targetMeasurements[selectedMeasurement.rawValue]
        }
    }

    private var currentTargetDate: Date? {
        if type == .weight {
            return pflanze.targetWeightDate
        } else {
            return pflanze.targetMeasurementsDates[selectedMeasurement.rawValue]
        }
    }

    private var targetSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(String(localized: "body.tracking.target_title", defaultValue: "Ziel"))
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center) {
                    if let targetVal = currentTarget {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(String(format: "%.1f", targetVal)) \(unit)")
                                .font(.system(size: 24, weight: .black, design: .rounded))
                                .foregroundStyle(.pink)
                            
                            if let date = currentTargetDate {
                                Text(String(localized: "body.tracking.until", defaultValue: "bis zum ") + date.formatted(.dateTime.day().month().year()))
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } else {
                        Text(type == .weight 
                             ? String(localized: "body.tracking.no_target_weight", defaultValue: "Kein Zielgewicht festgelegt")
                             : String(localized: "body.tracking.no_target_measurement", defaultValue: "Kein Zielwert festgelegt"))
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Item3DButton(
                        farbe: .red,
                        sekundaerFarbe: Color(red: 0.8, green: 0.1, blue: 0.1),
                        groesse: 38,
                        isRectangular: true,
                        aktion: {
                            targetInput = currentTarget.map { String(format: "%.1f", $0) } ?? ""
                            targetDateInput = currentTargetDate ?? Calendar.current.date(byAdding: .month, value: 3, to: Date())!
                            showTargetSheet = true
                        }
                    ) {
                        Text(String(localized: "body.tracking.button.target", defaultValue: "Ziel"))
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                    }
                }
                
                // Wochentrend Statusbericht (Moving Averages)
                weeklyStatusReportView
                    .padding(.top, 8)
            }
            .item3DContainer(farbe: Color(UIColor.secondarySystemGroupedBackground), sekundaerFarbe: Color(UIColor.tertiarySystemGroupedBackground), shadowDepth: 4)
            .padding(.horizontal)
        }
    }

    @ViewBuilder
    private var weeklyStatusReportView: some View {
        let entries = allData
        let calendar: Calendar = {
            var cal = Calendar.current
            cal.firstWeekday = 2 // Montag
            return cal
        }()
        let now = Date()
        
        let currentWeekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        let previousWeekStart = calendar.date(byAdding: .weekOfYear, value: -1, to: currentWeekStart) ?? now
        
        let currentWeekData = entries.filter { $0.timestamp >= currentWeekStart }
        let previousWeekData = entries.filter { $0.timestamp >= previousWeekStart && $0.timestamp < currentWeekStart }
        
        let currentAvg = currentWeekData.isEmpty ? nil : currentWeekData.reduce(0) { $0 + $1.progress } / Double(currentWeekData.count)
        let previousAvg = previousWeekData.isEmpty ? nil : previousWeekData.reduce(0) { $0 + $1.progress } / Double(previousWeekData.count)
        
        VStack(alignment: .leading, spacing: 16) {
            Divider()
            
            Text(String(localized: "body.tracking.weekly_trend", defaultValue: "Dein Wochentrend (Ø zu Ø)"))
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            
            if let current = currentAvg, let previous = previousAvg {
                let delta = current - previous
                
                // Wir ermitteln, ob der User zunehmen oder abnehmen will
                let isGoalGain = (currentTarget ?? (entries.last?.progress ?? 0)) >= (entries.last?.progress ?? 0)
                let status = getWeeklyStatus(delta: delta, isGoalGain: isGoalGain, type: type)
                
                HStack(alignment: .center, spacing: 16) {
                    VStack(alignment: .center, spacing: 4) {
                        Text(String(localized: "body.tracking.last_week", defaultValue: "Letzte Woche"))
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                        Text(String(format: "%.1f", previous))
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundStyle(.primary)
                    }
                    
                    Image(systemName: "arrow.right")
                        .foregroundStyle(.secondary)
                        .font(.system(size: 14, weight: .bold))
                    
                    VStack(alignment: .center, spacing: 4) {
                        Text(String(localized: "body.tracking.this_week", defaultValue: "Diese Woche"))
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                        Text(String(format: "%.1f", current))
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundStyle(status.color)
                    }
                    
                    Spacer()
                    
                    Text(delta > 0 ? String(format: "+%.1f", delta) : String(format: "%.1f", delta))
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(status.color)
                }
                .padding(12)
                .background(Color(UIColor.tertiarySystemGroupedBackground))
                .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(status.title)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(status.color)
                    
                    Text(status.desc)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 4)
                
            } else {
                Text(String(localized: "body.tracking.need_more_data", defaultValue: "Wir brauchen mehr Daten. Trage dein Gewicht regelmäßig ein, um hier deinen biologisch korrekten Wochentrend (Ø zu Ø) zu sehen."))
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var manualEntriesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation(.easeInOut) {
                    isManualEntriesExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(String(localized: "body.tracking.manual_entries", defaultValue: "Manuelle Einträge"))
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isManualEntriesExpanded ? 90 : 0))
                }
                .padding(.horizontal)
            }
            .buttonStyle(.plain)
            
            if isManualEntriesExpanded {
                let entries = type == .weight ? pflanze.manualWeightEntries : (pflanze.bodyMeasurements[selectedMeasurement.rawValue] ?? [])
                
                if entries.isEmpty {
                    Text(String(localized: "body.tracking.no_manual_entries", defaultValue: "Keine manuellen Einträge"))
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(.secondary)
                        .padding(.all, 16)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .item3DContainer(farbe: Color(UIColor.secondarySystemGroupedBackground), sekundaerFarbe: Color(UIColor.tertiarySystemGroupedBackground), shadowDepth: 4)
                        .padding(.horizontal)
                } else {
                    VStack(spacing: 8) {
                        ForEach(entries.sorted { $0.timestamp > $1.timestamp }, id: \.timestamp) { entry in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(String(format: "%.1f", entry.progress)) \(unit)")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                    Text(entry.timestamp.formatted(.dateTime.day().month().year().hour().minute()))
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Button {
                                    deleteEntry(entry)
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundStyle(.red)
                                        .font(.system(size: 14))
                                        .padding(8)
                                        .background(Color.red.opacity(0.1))
                                        .clipShape(Circle())
                                }
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                        }
                    }
                    .item3DContainer(farbe: Color(UIColor.secondarySystemGroupedBackground), sekundaerFarbe: Color(UIColor.tertiarySystemGroupedBackground), shadowDepth: 4)
                    .padding(.horizontal)
                }
            }
        }
    }

    private func deleteEntry(_ entry: DailyProgressEntry) {
        if type == .weight {
            pflanze.manualWeightEntries.removeAll { $0.timestamp == entry.timestamp }
        } else {
            var measures = pflanze.bodyMeasurements[selectedMeasurement.rawValue] ?? []
            measures.removeAll { $0.timestamp == entry.timestamp }
            pflanze.bodyMeasurements[selectedMeasurement.rawValue] = measures
        }
        gardenStore.savePlants()
    }

    private var editTargetSheet: some View {
        NavigationStack {
            Form {
                Section(header: Text(type == .weight 
                                     ? String(localized: "body.tracking.target_weight_title", defaultValue: "Zielgewicht")
                                     : String(localized: "body.tracking.target_measurement_title", defaultValue: "Zielwert"))) {
                    HStack {
                        TextField("0", text: $targetInput)
                            .keyboardType(.decimalPad)
                        Text(unit)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section(header: Text(String(localized: "body.tracking.target_date_title", defaultValue: "Zieldatum"))) {
                    DatePicker(
                        String(localized: "body.tracking.target_date", defaultValue: "Erreichen bis"),
                        selection: $targetDateInput,
                        in: Date()...,
                        displayedComponents: .date
                    )
                }
                
                if currentTarget != nil {
                    Section {
                        Button(role: .destructive) {
                            if type == .weight {
                                pflanze.targetWeight = nil
                                pflanze.targetWeightDate = nil
                            } else {
                                pflanze.targetMeasurements.removeValue(forKey: selectedMeasurement.rawValue)
                                pflanze.targetMeasurementsDates.removeValue(forKey: selectedMeasurement.rawValue)
                            }
                            gardenStore.savePlants()
                            showTargetSheet = false
                        } label: {
                            Text(String(localized: "body.tracking.delete_target", defaultValue: "Ziel löschen"))
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
            }
            .navigationTitle(String(localized: "body.tracking.target_title", defaultValue: "Ziel"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(String(localized: "button.cancel", defaultValue: "Abbrechen")) {
                        showTargetSheet = false
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "common.save", defaultValue: "Speichern")) {
                        let w = Double(targetInput.replacingOccurrences(of: ",", with: ".")) ?? 0
                        if w > 0 {
                            if type == .weight {
                                pflanze.targetWeight = w
                                pflanze.targetWeightDate = targetDateInput
                            } else {
                                pflanze.targetMeasurements[selectedMeasurement.rawValue] = w
                                pflanze.targetMeasurementsDates[selectedMeasurement.rawValue] = targetDateInput
                            }
                            gardenStore.savePlants()
                        }
                        showTargetSheet = false
                    }
                    .bold()
                    .disabled(targetInput.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    private func getWeeklyStatus(delta: Double, isGoalGain: Bool, type: BodyTrackingType) -> (color: Color, title: String, desc: String) {
        let stateColor: Color
        let stateTitle: String
        let stateDesc: String
        
        // Bulking Logic (Muskelaufbau)
        if isGoalGain || type != .weight {
            if delta < 0.0 {
                stateColor = .red
                stateTitle = String(localized: "body.tracking.status.bulking.deficit.title", defaultValue: "🔴 Defizit-Warnung")
                stateDesc = String(localized: "body.tracking.status.bulking.deficit.desc", defaultValue: "Du verbrennst mehr, als du isst. Kalorien sofort um 300 kcal hoch.")
            } else if delta <= 0.2 {
                stateColor = .yellow
                stateTitle = String(localized: "body.tracking.status.bulking.stagnation.title", defaultValue: "🟡 Stagnation")
                stateDesc = String(localized: "body.tracking.status.bulking.stagnation.desc", defaultValue: "Zu wenig Treibstoff. Erhöhe deine täglichen Kalorien ab morgen um 200 kcal.")
            } else if delta <= 0.5 {
                stateColor = .green
                stateTitle = String(localized: "body.tracking.status.bulking.perfect.title", defaultValue: "🟢 Perfektes Tempo")
                stateDesc = String(localized: "body.tracking.status.bulking.perfect.desc", defaultValue: "Aufbau läuft sauber. Makros beibehalten. Training progressiv im Gym steigern.")
            } else {
                stateColor = .red
                stateTitle = String(localized: "body.tracking.status.bulking.fat.title", defaultValue: "🔴 Fett-Warnung")
                stateDesc = String(localized: "body.tracking.status.bulking.fat.desc", defaultValue: "Gewichtszunahme zu aggressiv. Du baust unnötig Fett auf. Kalorien um 200 kcal senken.")
            }
        } else {
            // Cutting Logic (Fettabbau) - Invertiert
            if delta > 0.0 {
                stateColor = .red
                stateTitle = String(localized: "body.tracking.status.cutting.gain.title", defaultValue: "🔴 Zunahme-Warnung")
                stateDesc = String(localized: "body.tracking.status.cutting.gain.desc", defaultValue: "Du nimmst zu statt ab. Reduziere deine täglichen Kalorien um 300 kcal.")
            } else if delta > -0.2 {
                stateColor = .yellow
                stateTitle = String(localized: "body.tracking.status.cutting.stagnation.title", defaultValue: "🟡 Stagnation")
                stateDesc = String(localized: "body.tracking.status.cutting.stagnation.desc", defaultValue: "Dein Gewichtsverlust stagniert. Senke deine Kalorien um 200 kcal oder erhöhe Cardio.")
            } else if delta >= -0.7 {
                stateColor = .green
                stateTitle = String(localized: "body.tracking.status.cutting.perfect.title", defaultValue: "🟢 Perfektes Tempo")
                stateDesc = String(localized: "body.tracking.status.cutting.perfect.desc", defaultValue: "Fettabbau läuft sauber. Makros beibehalten. Training intensiv fortführen.")
            } else {
                stateColor = .orange
                stateTitle = String(localized: "body.tracking.status.cutting.muscleloss.title", defaultValue: "🟠 Muskelverlust-Warnung")
                stateDesc = String(localized: "body.tracking.status.cutting.muscleloss.desc", defaultValue: "Gewichtsverlust zu aggressiv. Du verbrennst wertvolle Muskeln. Kalorien um 200 kcal erhöhen.")
            }
        }
        
        return (stateColor, stateTitle, stateDesc)
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
