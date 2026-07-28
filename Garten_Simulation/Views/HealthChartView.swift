import SwiftUI
import Charts

struct HealthChartView: View {
    let data: [(Date, Double)]
    let metric: HealthMetricType
    let target: Double?
    /// Wochendurchschnitt – nil wenn noch nicht genug Daten
    var weeklyAverage: Double? = nil

    private var chartTitle: String {
        switch metric {
        case .steps: return String(localized: "health.chart.title.steps", defaultValue: "👟 Schritte")
        case .water: return String(localized: "health.chart.title.water", defaultValue: "💧 Wasser")
        case .sleep: return String(localized: "health.chart.title.sleep", defaultValue: "🌙 Schlaf")
        case .mindfulness: return String(localized: "health.chart.title.mindfulness", defaultValue: "🧘 Achtsamkeit")
        case .running: return String(localized: "health.chart.title.running", defaultValue: "🏃 Laufen")
        case .strengthTraining: return String(localized: "health.chart.title.strength", defaultValue: "🏋️ Krafttraining")
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
        VStack(alignment: .leading, spacing: 12) {

            // Header
            Text(chartTitle)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(Color.gruenPrimary)

            Divider().padding(.vertical, 2)

            // Stats Row: Heute % | Ziel | Ø Woche
            HStack(alignment: .top, spacing: 0) {

                // Heute – Fortschritt in %
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Circle().fill(Color.orangePrimary).frame(width: 8, height: 8)
                        Text(String(localized: "health.chart.label.today", defaultValue: "Heute"))
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.orangePrimary)
                    }
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(progressPercent)")
                            .font(.system(size: 30, weight: .black, design: .rounded))
                            .foregroundStyle(Color.orangePrimary)
                        Text("%")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.orangePrimary)
                    }
                    Text(formatNumber(totalToday) + " " + unitString)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Ziel
                if let t = target {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Image(systemName: "flag.fill")
                                .font(.system(size: 9))
                                .foregroundStyle(Color.gruenPrimary)
                            Text(String(localized: "health.chart.label.target", defaultValue: "Ziel"))
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.gruenPrimary)
                        }
                        Text(formatNumber(t))
                            .font(.system(size: 30, weight: .black, design: .rounded))
                            .foregroundStyle(Color.gruenPrimary)
                        Text(unitString)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                // Ø Woche
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Circle().fill(Color.secondary.opacity(0.6)).frame(width: 8, height: 8)
                        Text(String(localized: "health.chart.label.average", defaultValue: "Ø Woche"))
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    if let avg = weeklyAverage {
                        Text(formatNumber(avg))
                            .font(.system(size: 30, weight: .black, design: .rounded))
                            .foregroundStyle(.secondary)
                        Text(unitString)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    } else {
                        Text(String(localized: "health.chart.average.unavailable", defaultValue: "k.A."))
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundStyle(.secondary.opacity(0.6))
                        Text(String(localized: "health.chart.average.hint", defaultValue: "< 3 Tage"))
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary.opacity(0.6))
                    }
                }
            }

            // Chart
            Chart {
                // Grüne gestrichelte Ziellinie oben
                if let t = target, let first = data.first?.0, let last = data.last?.0 {
                    LineMark(
                        x: .value("Uhrzeit", first),
                        y: .value("Ziel", t)
                    )
                    .foregroundStyle(Color.gruenPrimary.opacity(0.7))
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [6, 4]))

                    LineMark(
                        x: .value("Uhrzeit", last),
                        y: .value("Ziel", t)
                    )
                    .foregroundStyle(Color.gruenPrimary.opacity(0.7))
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [6, 4]))
                }

                // Grauer Durchschnittspunkt am Ende
                if let avg = weeklyAverage, let lastDate = data.last?.0 {
                    PointMark(
                        x: .value("Uhrzeit", lastDate),
                        y: .value("Durchschnitt", avg)
                    )
                    .foregroundStyle(Color.secondary.opacity(0.7))
                    .symbolSize(60)
                    .annotation(position: .top) {
                        Text(String(localized: "health.chart.label.average", defaultValue: "Ø Woche"))
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }

                // Orange kumulative Linie
                ForEach(cumulativeData(), id: \.0) { item in
                    LineMark(
                        x: .value("Uhrzeit", item.0),
                        y: .value("Wert", item.1)
                    )
                    .foregroundStyle(Color.orangePrimary)
                    .lineStyle(StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))

                    AreaMark(
                        x: .value("Uhrzeit", item.0),
                        y: .value("Wert", item.1)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.orangePrimary.opacity(0.25), Color.clear],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                }

                // Endpunkt Marker
                if let lastItem = cumulativeData().last {
                    PointMark(
                        x: .value("Uhrzeit", lastItem.0),
                        y: .value("Wert", lastItem.1)
                    )
                    .foregroundStyle(Color.orangePrimary)
                    .symbolSize(80)
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
                        AxisGridLine()
                    }
                }
            }
            .chartYAxis(.hidden)
            .frame(height: 130)
            .padding(.top, 8)
        }
        .padding(20)
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
