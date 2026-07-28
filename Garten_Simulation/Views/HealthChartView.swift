import SwiftUI
import Charts

struct HealthChartView: View {
    let data: [(Date, Double)]
    let metric: HealthMetricType
    let target: Double?
    
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
    
    private var chartSubtitle: String {
        guard let target = target, target > 0 else {
            return String(localized: "health.chart.subtitle.no_target", defaultValue: "Behalte deine Gesundheit im Blick.")
        }
        let total = data.map { $0.1 }.reduce(0, +)
        if total >= target {
            return String(localized: "health.chart.subtitle.reached", defaultValue: "Klasse! Du hast dein Ziel heute schon erreicht.")
        } else {
            return String(localized: "health.chart.subtitle.progress", defaultValue: "Du bist auf einem guten Weg, weiter so!")
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text(chartTitle)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.orangePrimary)
                
                Text(chartSubtitle)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Divider()
                .padding(.vertical, 4)
            
            // Stats Row
            HStack(alignment: .top, spacing: 32) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Circle().fill(Color.orangePrimary).frame(width: 8, height: 8)
                        Text(String(localized: "health.chart.label.today", defaultValue: "Heute"))
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.orangePrimary)
                    }
                    
                    let totalToday = data.map { $0.1 }.reduce(0, +)
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(formatNumber(totalToday))
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(Color.orangePrimary)
                        Text(unitString)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.orangePrimary)
                    }
                }
                
                if let target = target {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Circle().fill(Color.secondary).frame(width: 8, height: 8)
                            Text(String(localized: "health.chart.label.target", defaultValue: "Ziel"))
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(formatNumber(target))
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundStyle(.secondary)
                            Text(unitString)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            
            // Chart
            Chart {
                if let target = target {
                    // Target grey line
                    if let first = data.first?.0, let last = data.last?.0 {
                        LineMark(
                            x: .value("Uhrzeit", first),
                            y: .value("Ziel", target)
                        )
                        .foregroundStyle(Color.secondary.opacity(0.3))
                        .lineStyle(StrokeStyle(lineWidth: 3))
                        
                        LineMark(
                            x: .value("Uhrzeit", last),
                            y: .value("Ziel", target)
                        )
                        .foregroundStyle(Color.secondary.opacity(0.3))
                        .lineStyle(StrokeStyle(lineWidth: 3))
                    }
                }
                
                // Active Line
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
                            colors: [Color.orangePrimary.opacity(0.3), Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                
                // End Point Marker
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
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        AxisGridLine()
                    }
                }
            }
            .chartYAxis(.hidden)
            .frame(height: 140)
            .padding(.top, 16)
        }
        .padding(24)
        .modifier(Item3DContainerModifier(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5), shadowDepth: 6))
    }
    
    private func formatNumber(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(Int(value))"
    }
    
    // Apple Fitness lines are cumulative throughout the day
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
