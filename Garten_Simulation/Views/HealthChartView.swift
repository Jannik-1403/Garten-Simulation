import SwiftUI
import Charts

struct HealthChartView: View {
    let data: [(Date, Double)]
    let metric: HealthMetricType
    let target: Double?
    /// Stündlicher kumulativer Durchschnitt der letzten 7 Tage (für die Durchschnittslinie)
    var hourlyAverageData: [(Date, Double)] = []

    private var chartTitle: String {
        switch metric {
        case .steps: return String(localized: "health.chart.title.steps.plain", defaultValue: "Schritte")
        case .water: return String(localized: "health.chart.title.water.plain", defaultValue: "Wasser")
        case .sleep: return String(localized: "health.chart.title.sleep.plain", defaultValue: "Schlaf")
        case .mindfulness: return String(localized: "health.chart.title.mindfulness.plain", defaultValue: "Achtsamkeit")
        case .running: return String(localized: "health.chart.title.running.plain", defaultValue: "Laufen")
        case .strengthTraining: return String(localized: "health.chart.title.strength.plain", defaultValue: "Krafttraining")
        }
    }

    private var unitString: String {
        switch metric {
        case .steps: return String(localized: "health.unit.steps", defaultValue: "Schritte")
        case .water: return String(localized: "health.unit.water", defaultValue: "ml")
        case .sleep, .mindfulness, .running, .strengthTraining:
            return String(localized: "health.unit.hours", defaultValue: "Std")
        }
    }

    private var totalToday: Double { data.map { $0.1 }.reduce(0, +) }

    private var progressPercent: Int {
        guard let t = target, t > 0 else { return 0 }
        return min(100, Int((totalToday / t) * 100))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // ── Header ──────────────────────────────────────────────
            Text(chartTitle)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)

            // ── Stats Row ────────────────────────────────────────────
            HStack(alignment: .bottom, spacing: 0) {

                // Heute – absolute Schritte
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 5) {
                        Circle()
                            .fill(Color(red: 0.85, green: 0.35, blue: 0.0))
                            .frame(width: 9, height: 9)
                        Text(String(localized: "health.chart.label.today", defaultValue: "Heute"))
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(red: 0.85, green: 0.35, blue: 0.0))
                    }
                    Text(formatNumber(totalToday))
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundStyle(Color(red: 0.85, green: 0.35, blue: 0.0))
                    Text(unitString)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Ziel
                if let t = target {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 5) {
                            Rectangle()
                                .fill(Color.gruenPrimary.opacity(0.7))
                                .frame(width: 16, height: 2)
                            Text(String(localized: "health.chart.label.target", defaultValue: "Ziel"))
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.gruenPrimary)
                        }
                        Text(formatNumber(t))
                            .font(.system(size: 34, weight: .black, design: .rounded))
                            .foregroundStyle(Color.gruenPrimary)
                        Text(unitString)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                // Ø Tag
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 5) {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.5))
                            .frame(width: 16, height: 2)
                        Text(String(localized: "health.chart.label.avg_day", defaultValue: "Ø Tag"))
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    if let lastAvg = hourlyAverageData.last?.1, lastAvg > 0 {
                        Text(formatNumber(lastAvg))
                            .font(.system(size: 34, weight: .black, design: .rounded))
                            .foregroundStyle(.secondary)
                        Text(unitString)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                    } else {
                        Text(String(localized: "health.chart.average.unavailable", defaultValue: "k.A."))
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundStyle(.secondary.opacity(0.5))
                        Text(String(localized: "health.chart.average.hint", defaultValue: "< 3 Tage"))
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary.opacity(0.5))
                    }
                }
            }

            // ── Chart ────────────────────────────────────────────────
            Chart {
                // 1) Grüne gestrichelte horizontale Ziellinie (RuleMark = echte gerade Linie)
                if let t = target {
                    RuleMark(y: .value("Ziel", t))
                        .foregroundStyle(Color.gruenPrimary.opacity(0.65))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [7, 5]))
                }

                // 2) Graue Durchschnittslinie (stündlich kumulativ)
                if !hourlyAverageData.isEmpty {
                    ForEach(hourlyAverageData, id: \.0) { item in
                        LineMark(
                            x: .value("Uhrzeit", item.0),
                            y: .value("Durchschnitt", item.1),
                            series: .value("Serie", "avg")
                        )
                        .foregroundStyle(Color.secondary.opacity(0.45))
                        .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                    }
                }

                // 3) Dunkel-orange kumulative Schritt-Linie (KEIN Gradient, KEIN AreaMark)
                ForEach(cumulativeData(), id: \.0) { item in
                    LineMark(
                        x: .value("Uhrzeit", item.0),
                        y: .value("Wert", item.1),
                        series: .value("Serie", "today")
                    )
                    .foregroundStyle(Color(red: 0.85, green: 0.35, blue: 0.0))
                    .lineStyle(StrokeStyle(lineWidth: 3.5, lineCap: .round, lineJoin: .round))
                }

                // 4) Endpunkt
                if let lastItem = cumulativeData().last {
                    PointMark(
                        x: .value("Uhrzeit", lastItem.0),
                        y: .value("Wert", lastItem.1)
                    )
                    .foregroundStyle(Color(red: 0.85, green: 0.35, blue: 0.0))
                    .symbolSize(70)
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .hour, count: 6)) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            Text(date.formatted(Date.FormatStyle().hour(.defaultDigits(amPM: .abbreviated))))
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    }
                }
            }
            .chartYAxis(.hidden)
            .frame(height: 170)
        }
        .padding(22)
        .modifier(Item3DContainerModifier(
            farbe: Color(UIColor.systemBackground),
            sekundaerFarbe: Color(UIColor.systemGray5),
            shadowDepth: 6
        ))
    }

    private func formatNumber(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 0
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
