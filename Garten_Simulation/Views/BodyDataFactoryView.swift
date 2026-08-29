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
    @State private var selectedMeasurement: BodyMeasurementCategory = .bizeps
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
                        Text(r.rawValue).tag(r)
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
                        HStack(spacing: 10) {
                            ForEach(BodyMeasurementCategory.allCases) { cat in
                                Item3DButton(
                                    farbe: selectedMeasurement == cat ? Color.pink : Color(UIColor.secondarySystemGroupedBackground),
                                    sekundaerFarbe: selectedMeasurement == cat ? Color(red: 0.8, green: 0.0, blue: 0.35) : Color(UIColor.tertiarySystemGroupedBackground),
                                    groesse: 48,
                                    isRectangular: true,
                                    isPermanentlyPressed: selectedMeasurement == cat,
                                    aktion: { selectedMeasurement = cat }
                                ) {
                                    Text(cat.localizedName)
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                        .foregroundStyle(selectedMeasurement == cat ? .white : .primary)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.center)
                                        .frame(width: 64)
                                        .padding(.horizontal, 4)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                    }
                }

                // Stats Header – zeigt aktuellen (letzten) Wert
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(localized: "body.tracking.current", defaultValue: "AKTUELL"))
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .kerning(1.2)

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        let latest = allData.last?.progress ?? 0
                        if latest > 0 {
                            Text(String(format: "%.1f", latest))
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

                    if let lastEntry = allData.last {
                        Text(lastEntry.timestamp.formatted(.dateTime.day().month().year().hour().minute()))
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
            .navigationTitle(String(localized: "body.tracking.add_entry", defaultValue: "Eintrag hinzufügen"))
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
        type == .weight ? "kg" : "cm"
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
        return allData.filter { $0.timestamp >= range.start && $0.timestamp <= range.end }
    }

    private var currentAverage: Double {
        let data = filteredData
        guard !data.isEmpty else { return 0 }
        return data.reduce(0) { $0 + $1.progress } / Double(data.count)
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
            // Mo, Di, Mi, Do, Fr, Sa, So
            let weekday = cal.component(.weekday, from: date)
            let symbols = ["So", "Mo", "Di", "Mi", "Do", "Fr", "Sa"]
            return symbols[safe: weekday - 1] ?? ""
        case .m:
            // Tag des Monats
            let day = cal.component(.day, from: date)
            return "\(day)."
        case .sixM:
            // Monat kurz: Jan, Feb...
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            return formatter.string(from: date)
        case .j:
            // Erster Buchstabe des Monats: J, F, M, A, M, J, J, A, S, O, N, D
            let month = cal.component(.month, from: date)
            let letters = ["J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D"]
            return letters[safe: month - 1] ?? ""
        }
    }

    // MARK: - Eintrag hinzufügen

    private func addEntry(_ value: Double) {
        let entry = DailyProgressEntry(timestamp: Date(), progress: value)
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
                
                // Realismus-Check & Fortschritt
                if let targetVal = currentTarget, let targetDate = currentTargetDate, let current = currentValue {
                    let diff = targetVal - current
                    let weeks = max(1.0, targetDate.timeIntervalSince(Date()) / (7.0 * 24.0 * 3600.0))
                    let changePerWeek = abs(diff) / weeks
                    
                    let limitMax = type == .weight ? 1.0 : 0.5
                    let limitMin = type == .weight ? 0.3 : 0.1
                    
                    let actionText = type == .weight ? (diff < 0 ? String(localized: "body.tracking.action.lose") : String(localized: "body.tracking.action.gain")) : (diff < 0 ? String(localized: "body.tracking.action.reduce") : String(localized: "body.tracking.action.build"))
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Divider()
                        
                        // 1. Ziel-Analyse (Schwierigkeit)
                        HStack(alignment: .top, spacing: 12) {
                            if changePerWeek > limitMax {
                                Image(systemName: "exclamationmark.triangle.fill").font(.system(size: 18)).foregroundStyle(.orange)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(String(localized: "body.tracking.unrealistic_goal")).font(.system(size: 14, weight: .bold, design: .rounded)).foregroundStyle(.orange)
                                    let suggestedWeeks = Int(ceil(abs(diff) / limitMax))
                                    Text(String(format: String(localized: "body.tracking.unrealistic_desc_adaptive"), changePerWeek, unit, actionText, suggestedWeeks))
                                        .font(.system(size: 12, design: .rounded)).foregroundStyle(.secondary)
                                }
                            } else if changePerWeek >= limitMin {
                                Image(systemName: "checkmark.circle.fill").font(.system(size: 18)).foregroundStyle(.green)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(String(localized: "body.tracking.realistic_goal")).font(.system(size: 14, weight: .bold, design: .rounded)).foregroundStyle(.green)
                                    Text(String(format: String(localized: "body.tracking.realistic_desc", defaultValue: "Um dein Ziel zu erreichen, musst du ca. %.2f %@ pro Woche %@. Das entspricht einer gesunden und realistischen Rate."), changePerWeek, unit, actionText))
                                        .font(.system(size: 12, design: .rounded)).foregroundStyle(.secondary)
                                }
                            } else {
                                Image(systemName: "info.circle.fill").font(.system(size: 18)).foregroundStyle(.blue)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(String(localized: "body.tracking.easy_goal")).font(.system(size: 14, weight: .bold, design: .rounded)).foregroundStyle(.blue)
                                    let suggestedWeeks = Int(ceil(abs(diff) / limitMax))
                                    Text(String(format: String(localized: "body.tracking.easy_desc_adaptive"), changePerWeek, unit, actionText, suggestedWeeks))
                                        .font(.system(size: 12, design: .rounded)).foregroundStyle(.secondary)
                                }
                            }
                        }
                        
                        // 2. Fortschritts-Analyse (Historisch)
                        progressAnalysisView(currentValue: current, diff: diff, requiredChangePerWeek: diff / weeks, limitMax: limitMax)
                    }
                    .padding(.top, 8)
                }
            }
            .item3DContainer(farbe: Color(UIColor.secondarySystemGroupedBackground), sekundaerFarbe: Color(UIColor.tertiarySystemGroupedBackground), shadowDepth: 4)
            .padding(.horizontal)
        }
    }

    private func progressAnalysisView(currentValue: Double, diff: Double, requiredChangePerWeek: Double, limitMax: Double) -> some View {
        let entries = allData
        // Mindestens 1 Tag alt, max. 21 Tage – damit auch tägliche Einträge auswertbar sind
        let candidates = entries.dropLast().filter {
            let days = (entries.last?.timestamp ?? Date()).timeIntervalSince($0.timestamp) / (24 * 3600)
            return days >= 1 && days <= 21
        }
        
        let currentEntry = entries.last ?? DailyProgressEntry(timestamp: Date(), progress: 0)
        let bestOldEntry = candidates.min { a, b in
            let daysA = currentEntry.timestamp.timeIntervalSince(a.timestamp) / (24 * 3600)
            let daysB = currentEntry.timestamp.timeIntervalSince(b.timestamp) / (24 * 3600)
            return abs(7 - daysA) < abs(7 - daysB)
        }
        
        let daysDiff = bestOldEntry.map { currentEntry.timestamp.timeIntervalSince($0.timestamp) / (24 * 3600) } ?? 0
        // Absolute tatsächliche Änderung (nicht wöchentlich hochgerechnet)
        let absoluteChange = bestOldEntry.map { currentEntry.progress - $0.progress } ?? 0.0
        let absChange = abs(absoluteChange)
        
        // Für Richtungscheck weiterhin Wochenrate verwenden
        let actualChangePerWeek = (daysDiff > 0 && bestOldEntry != nil)
            ? absoluteChange / (daysDiff / 7.0)
            : 0.0
        let absRequired = abs(requiredChangePerWeek)
        
        let isGoalGain = diff > 0
        let isActualGain = actualChangePerWeek > 0
        
        enum ProgressState { case wrongWayGain, wrongWayLose, tooFast, tooSlow, onTrack }
        let state: ProgressState
        if isGoalGain != isActualGain && absChange > 0.05 {
            state = isGoalGain ? .wrongWayGain : .wrongWayLose
        } else if abs(actualChangePerWeek) > limitMax * 1.5 {
            state = .tooFast
        } else if abs(actualChangePerWeek) < absRequired * 0.5 {
            state = .tooSlow
        } else {
            state = .onTrack
        }
        
        let stateColor: Color
        let mainText: String
        let tipText: String
        
        switch state {
        case .wrongWayGain:
            stateColor = .red
            mainText = String(format: String(localized: "body.tracking.progress.wrong_way_gain", defaultValue: "Du hast %1$.2f %2$@ verloren, aber dein Ziel ist es, zuzunehmen."), absChange, unit)
            tipText = String(localized: "body.tracking.progress.tip_wrong_gain", defaultValue: "Erhöhe deine tägliche Kalorienzufuhr und achte auf ausreichend Protein.")
        case .wrongWayLose:
            stateColor = .red
            mainText = String(format: String(localized: "body.tracking.progress.wrong_way_lose", defaultValue: "Du hast %1$.2f %2$@ zugenommen, aber dein Ziel ist es, abzunehmen."), absChange, unit)
            tipText = String(localized: "body.tracking.progress.tip_wrong_lose", defaultValue: "Achte auf dein Kaloriendefizit und kontrolliere deine Ernährung.")
        case .tooFast:
            stateColor = .orange
            mainText = String(format: String(localized: "body.tracking.progress.too_fast", defaultValue: "Du hast %1$.2f %2$@ verändert – das ist etwas schnell."), absChange, unit)
            tipText = String(localized: "body.tracking.progress.tip_too_fast", defaultValue: "Sehr schnelle Veränderungen können ungesund sein. Halte ein moderates Tempo.")
        case .tooSlow:
            stateColor = .blue
            mainText = String(format: String(localized: "body.tracking.progress.too_slow", defaultValue: "Du hast %1$.2f %2$@ verändert – du musst etwas mehr Gas geben."), absChange, unit)
            tipText = String(localized: "body.tracking.progress.tip_too_slow", defaultValue: "Passe deine Routine an, um dein Ziel im gewählten Zeitraum zu erreichen.")
        case .onTrack:
            stateColor = .green
            mainText = String(format: String(localized: "body.tracking.progress.on_track", defaultValue: "Super! Du hast %1$.2f %2$@ in die richtige Richtung verändert."), absChange, unit)
            tipText = String(localized: "body.tracking.progress.tip_on_track", defaultValue: "Genau so weiter machen!")
        }
        
        return VStack(alignment: .leading, spacing: 6) {
            Text(String(localized: "body.tracking.progress_title", defaultValue: "Dein Fortschritt"))
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            
            if let oldEntry = bestOldEntry {
                let sinceLabel: String = {
                    let days = currentEntry.timestamp.timeIntervalSince(oldEntry.timestamp) / (24 * 3600)
                    if days < 1.5 {
                        return String(localized: "body.tracking.since_yesterday", defaultValue: "seit gestern")
                    } else if days < 2.5 {
                        return String(localized: "body.tracking.since_2days", defaultValue: "seit vorgestern")
                    } else {
                        let formatted = oldEntry.timestamp.formatted(.dateTime.day().month())
                        return String(format: String(localized: "body.tracking.since_date", defaultValue: "seit %@"), formatted)
                    }
                }()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(mainText + " (\(sinceLabel))")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(stateColor)
                    
                    Text(tipText)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            } else {
                Text(String(localized: "body.tracking.progress_nodata", defaultValue: "Gib noch einen weiteren Datenpunkt ein, um deinen Fortschritt zu analysieren."))
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(.secondary)
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
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
