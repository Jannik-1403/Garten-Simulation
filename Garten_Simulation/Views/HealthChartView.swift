import SwiftUI
import Charts

struct HealthChartView: View {
    let data: [(Date, Double)]
    let metric: HealthMetricType
    let target: Double?
    var hourlyAverageData: [(Date, Double)] = []

    // MARK: - Computed Properties

    private var chartTitle: String {
        switch metric {
        case .steps:           return String(localized: "health.chart.title.steps.plain",       defaultValue: "Schritte")
        case .water:           return String(localized: "health.chart.title.water.plain",        defaultValue: "Wasser")
        case .sleep:           return String(localized: "health.chart.title.sleep.plain",        defaultValue: "Schlaf")
        case .mindfulness:     return String(localized: "health.chart.title.mindfulness.plain",  defaultValue: "Achtsamkeit")
        case .running:         return String(localized: "health.chart.title.running.plain",      defaultValue: "Laufen")
        case .strengthTraining:return String(localized: "health.chart.title.strength.plain",     defaultValue: "Krafttraining")
        }
    }

    private var unitString: String {
        switch metric {
        case .steps:           return String(localized: "health.unit.steps", defaultValue: "Schritte")
        case .water:           return String(localized: "health.unit.water",  defaultValue: "ml")
        default:               return String(localized: "health.unit.hours",  defaultValue: "Std")
        }
    }

    private var totalToday: Double { cumulativeData().last?.1 ?? 0 }
    private var avgTotal: Double   { hourlyAverageData.last?.1 ?? 0 }

    /// Zeitpunkt rechts auf der X-Achse (aktuelle Stunde)
    private var rightAxisDate: Date {
        let cal = Calendar.current
        let now = Date()
        return cal.date(bySettingHour: cal.component(.hour, from: now),
                        minute: 0, second: 0, of: now) ?? now
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Title ──────────────────────────────────────────────
            Text(chartTitle)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(Color.orangePrimary)
                .padding(.bottom, 12)

            // ── Stats (untereinander, 2 Spalten) ──────────────────
            HStack(alignment: .top, spacing: 0) {
                // Heute
                statColumn(
                    dotColor: Color.orangePrimary,
                    label: String(localized: "health.chart.label.today", defaultValue: "Today"),
                    value: totalToday,
                    unit: unitString,
                    valueColor: Color.orangePrimary
                )

                Spacer()

                // Durchschnitt
                if avgTotal > 0 {
                    statColumn(
                        dotColor: Color(UIColor.systemGray3),
                        label: String(localized: "health.chart.label.average", defaultValue: "Average"),
                        value: avgTotal,
                        unit: unitString,
                        valueColor: Color(UIColor.systemGray2)
                    )
                }
            }
            .padding(.bottom, 16)

            // ── Chart ──────────────────────────────────────────────
            Chart {
                // Graue Durchschnittslinie
                if !hourlyAverageData.isEmpty {
                    ForEach(hourlyAverageData, id: \.0) { item in
                        LineMark(
                            x: .value("Uhrzeit", item.0),
                            y: .value("Durchschnitt", item.1),
                            series: .value("S", "avg")
                        )
                        .foregroundStyle(Color(UIColor.systemGray3))
                        .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                    }
                    // Grauer Endpunkt
                    if let last = hourlyAverageData.last {
                        PointMark(
                            x: .value("Uhrzeit", last.0),
                            y: .value("Durchschnitt", last.1)
                        )
                        .foregroundStyle(Color(UIColor.systemGray2))
                        .symbolSize(55)
                    }
                }

                // Orange heutige kumulative Linie
                ForEach(cumulativeData(), id: \.0) { item in
                    LineMark(
                        x: .value("Uhrzeit", item.0),
                        y: .value("Wert", item.1),
                        series: .value("S", "today")
                    )
                    .foregroundStyle(Color.orangePrimary)
                    .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                }

                // Oranger Endpunkt
                if let lastItem = cumulativeData().last {
                    PointMark(
                        x: .value("Uhrzeit", lastItem.0),
                        y: .value("Wert", lastItem.1)
                    )
                    .foregroundStyle(Color.orangePrimary)
                    .symbolSize(65)

                    // Vertikale gestrichelte Linie bei aktueller Zeit
                    RuleMark(x: .value("Jetzt", lastItem.0))
                        .foregroundStyle(Color(UIColor.systemGray4))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                }
            }
            .chartXAxis {
                // Nur links (00:00) und rechts (aktuelle Stunde)
                AxisMarks(values: [
                    Calendar.current.startOfDay(for: Date()),
                    rightAxisDate
                ]) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            Text(timeLabel(for: date))
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(UIColor.systemGray2))
                        }
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0))
                    }
                }
            }
            .chartYAxis(.hidden)
            .frame(height: 160)
        }
        .padding(20)
        .modifier(Item3DContainerModifier(
            farbe: Color(UIColor.systemBackground),
            sekundaerFarbe: Color(UIColor.systemGray5),
            shadowDepth: 6
        ))
    }

    // MARK: - Helpers

    @ViewBuilder
    private func statColumn(dotColor: Color, label: String, value: Double, unit: String, valueColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 5) {
                Circle().fill(dotColor).frame(width: 8, height: 8)
                Text(label)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(valueColor)
            }
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(formatNumber(value))
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(valueColor)
                Text(unit)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(valueColor.opacity(0.8))
            }
        }
    }

    private func formatNumber(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 0
        return f.string(from: NSNumber(value: value)) ?? "\(Int(value))"
    }

    private func timeLabel(for date: Date) -> String {
        let h = Calendar.current.component(.hour, from: date)
        let m = Calendar.current.component(.minute, from: date)
        return String(format: "%02d:%02d", h, m)
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
