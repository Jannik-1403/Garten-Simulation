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
                        HStack(spacing: 8) {
                            ForEach(BodyMeasurementCategory.allCases) { cat in
                                Button {
                                    selectedMeasurement = cat
                                } label: {
                                    Text(cat.localizedName)
                                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(selectedMeasurement == cat ? Color.pink : Color(UIColor.systemGray5))
                                        )
                                        .foregroundStyle(selectedMeasurement == cat ? .white : .primary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                // Stats Header
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

                AreaMark(
                    x: .value("x", entry.timestamp),
                    yStart: .value("bottom", yMin),
                    yEnd: .value("y", entry.progress)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.pink.opacity(0.3), Color.pink.opacity(0.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                PointMark(
                    x: .value("x", entry.timestamp),
                    y: .value("y", entry.progress)
                )
                .foregroundStyle(Color.pink)
                .symbolSize(40)
            }
        }
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
        let range = dateRange

        let predicate = HKQuery.predicateForSamples(withStart: range.start, end: Date(), options: .strictStartDate)
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
}

// MARK: - Safe Array Subscript

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
