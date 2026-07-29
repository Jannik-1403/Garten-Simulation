import SwiftUI
import Charts

// MARK: - HealthChartView

struct HealthChartView: View {
    let data: [(Date, Double)]
    let metric: HealthMetricType
    var target: Double?
    var hourlyAverageData: [(Date, Double)] = []
    var onEditTarget: (() -> Void)? = nil

    // MARK: Computed

    private var chartTitle: String {
        switch metric {
        case .steps:            return String(localized: "health.chart.title.steps.plain",        defaultValue: "Schritte")
        case .water:            return String(localized: "health.chart.title.water.plain",         defaultValue: "Wasser")
        case .sleep:            return String(localized: "health.chart.title.sleep.plain",         defaultValue: "Schlaf")
        case .mindfulness:      return String(localized: "health.chart.title.mindfulness.plain",   defaultValue: "Achtsamkeit")
        case .running:          return String(localized: "health.chart.title.running.plain",       defaultValue: "Laufen")
        case .strengthTraining: return String(localized: "health.chart.title.strength.plain",      defaultValue: "Krafttraining")
        }
    }

    private var unitString: String {
        switch metric {
        case .steps: return String(localized: "health.unit.steps", defaultValue: "Schritte")
        case .water: return String(localized: "health.unit.water",  defaultValue: "ml")
        default:     return String(localized: "health.unit.hours",  defaultValue: "Std")
        }
    }

    private var todayTotal: Double { cumulativeData().last?.1 ?? 0 }
    private var avgNow: Double     { hourlyAverageData.last?.1 ?? 0 }
    private var dayStart: Date     { Calendar.current.startOfDay(for: Date()) }

    private var rightAxisDate: Date {
        let cal = Calendar.current
        let now = Date()
        return cal.date(bySettingHour: cal.component(.hour, from: now),
                        minute: 0, second: 0, of: now) ?? now
    }

    // MARK: Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Title
            HStack(spacing: 6) {
                Circle()
                    .fill(Color.orangePrimary)
                    .frame(width: 10, height: 10)
                Text(chartTitle)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.orangePrimary)
            }
            .padding(.bottom, 14)

            // Stats Row
            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 1) {
                    statLabel(dotColor: Color.orangePrimary,
                              text: String(localized: "health.chart.label.today", defaultValue: "Today"))
                    Text(formatNumber(todayTotal))
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(Color.orangePrimary)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                    Text(unitString)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.orangePrimary.opacity(0.7))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 1) {
                    statLabel(dotColor: Color(UIColor.systemGray3),
                              text: String(localized: "health.chart.label.average", defaultValue: "Average"))
                    if avgNow > 0 {
                        Text(formatNumber(avgNow))
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundStyle(Color(UIColor.systemGray2))
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                        Text(unitString)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(Color(UIColor.systemGray3))
                    } else {
                        Text(String(localized: "health.chart.average.unavailable", defaultValue: "k.A."))
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundStyle(Color(UIColor.systemGray3))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.bottom, 14)

            // Chart
            Chart {
                // Gruene gestrichelte Ziellinie
                if let t = target {
                    RuleMark(y: .value("Ziel", t))
                        .foregroundStyle(Color.gruenPrimary.opacity(0.6))
                        .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                }

                // Graue Oe-Linie
                if !hourlyAverageData.isEmpty {
                    ForEach(hourlyAverageData, id: \.0) { pt in
                        LineMark(
                            x: .value("Uhrzeit", pt.0),
                            y: .value("Avg", pt.1),
                            series: .value("s", "avg")
                        )
                        .foregroundStyle(Color(UIColor.systemGray3))
                        .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                        .interpolationMethod(.catmullRom)
                    }
                    if let last = hourlyAverageData.last {
                        PointMark(x: .value("Uhrzeit", last.0), y: .value("Avg", last.1))
                            .foregroundStyle(Color(UIColor.systemGray2))
                            .symbolSize(55)
                    }
                }

                // Orange heutige Linie (kumulativ)
                ForEach(cumulativeData(), id: \.0) { pt in
                    LineMark(
                        x: .value("Uhrzeit", pt.0),
                        y: .value("Schritte", pt.1),
                        series: .value("s", "today")
                    )
                    .foregroundStyle(Color.orangePrimary)
                    .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                    .interpolationMethod(.catmullRom)
                }

                // Oranger Endpunkt + vertikale Zeit-Linie
                if let last = cumulativeData().last {
                    PointMark(x: .value("Uhrzeit", last.0), y: .value("Schritte", last.1))
                        .foregroundStyle(Color.orangePrimary)
                        .symbolSize(60)

                    RuleMark(x: .value("Jetzt", last.0))
                        .foregroundStyle(Color(UIColor.systemGray4))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [3, 4]))
                }
            }
            .chartXAxis {
                AxisMarks(values: [dayStart, rightAxisDate]) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            Text(timeLabel(for: date))
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color(UIColor.systemGray2))
                        }
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3))
                    }
                }
            }
            .chartYAxis(.hidden)
            .frame(height: 160)

            // Ziel-Zeile (tappbar)
            Divider().padding(.vertical, 10)

            Button {
                onEditTarget?()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "flag.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.gruenPrimary)
                    Text(String(localized: "health.chart.label.target", defaultValue: "Tagesziel"))
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)
                    Spacer()
                    if let t = target {
                        Text(formatNumber(t) + " " + unitString)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                    } else {
                        Text(String(localized: "health.chart.target.set", defaultValue: "Ziel festlegen"))
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.gruenPrimary)
                    }
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color(UIColor.systemGray3))
                }
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .modifier(Item3DContainerModifier(
            farbe: Color(UIColor.systemBackground),
            sekundaerFarbe: Color(UIColor.systemGray5),
            shadowDepth: 6
        ))
    }

    // MARK: Helpers

    @ViewBuilder
    private func statLabel(dotColor: Color, text: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(dotColor).frame(width: 7, height: 7)
            Text(text)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(dotColor)
        }
    }

    private func timeLabel(for date: Date) -> String {
        let cal = Calendar.current
        let h = cal.component(.hour, from: date)
        let m = cal.component(.minute, from: date)
        return String(format: "%02d:%02d", h, m)
    }

    private func formatNumber(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 0
        f.usesGroupingSeparator = true
        return f.string(from: NSNumber(value: value)) ?? "\(Int(value))"
    }

    private func cumulativeData() -> [(Date, Double)] {
        var result: [(Date, Double)] = []
        var sum: Double = 0
        for item in data {
            sum += item.1
            result.append((item.0, sum))
        }
        return result
    }
}

struct HealthTargetEditSheet: View {
    @Binding var target: Double?
    let unitString: String
    @Environment(\.dismiss) private var dismiss
    @State private var inputText: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "flag.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(Color.gruenPrimary)

                    Text(String(localized: "health.target.edit.title", defaultValue: "Tagesziel festlegen"))
                        .font(.system(size: 22, weight: .bold, design: .rounded))

                    Text(String(localized: "health.target.edit.subtitle", defaultValue: "Das Ziel wird als Linie im Diagramm angezeigt."))
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 16)

                // Input
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "health.target.edit.label", defaultValue: "Ziel-Wert"))
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)

                    HStack {
                        TextField("0", text: $inputText)
                            .keyboardType(.numberPad)
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(Color.gruenPrimary)
                            .multilineTextAlignment(.leading)

                        Text(unitString)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    .padding(16)
                    .background(Color(UIColor.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 24)

                Spacer()

                // Buttons
                VStack(spacing: 12) {
                    Button {
                        if let val = Double(inputText.replacingOccurrences(of: ",", with: ".")
                                                      .replacingOccurrences(of: ".", with: "")
                                                      .trimmingCharacters(in: .whitespaces)) {
                            target = val
                        } else if let val = Double(inputText) {
                            target = val
                        }
                        dismiss()
                    } label: {
                        Text(String(localized: "common.save", defaultValue: "Speichern"))
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(16)
                            .background(Color.gruenPrimary, in: RoundedRectangle(cornerRadius: 14))
                            .foregroundStyle(.white)
                    }

                    Button {
                        dismiss()
                    } label: {
                        Text(String(localized: "common.cancel", defaultValue: "Abbrechen"))
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .onAppear {
            if let t = target {
                inputText = String(Int(t))
            }
        }
    }
}
