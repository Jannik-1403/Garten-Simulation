import SwiftUI
import Charts

struct IntradayProgressChartView: View {
    let history: [DailyProgressEntry]
    var target: Double? = nil
    var onEditTarget: (() -> Void)? = nil
    
    // MARK: Computed
    
    private var chartTitle: String {
        return String(localized: "chart.title.progress", defaultValue: "Fortschritt")
    }
    
    private var unitString: String {
        return "%"
    }
    
    private var todayTotal: Double {
        return (history.last?.progress ?? 0.0) * 100.0
    }
    
    private var dayStart: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    private var lastDataDate: Date {
        history.last?.timestamp ?? Date()
    }
    
    private var chartData: [(Date, Double)] {
        var result: [(Date, Double)] = []
        result.append((dayStart, 0.0))
        for entry in history {
            result.append((entry.timestamp, entry.progress * 100.0))
        }
        return result
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
                              text: String(localized: "health.chart.label.today", defaultValue: "Heute"))
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
                    Text(String(localized: "health.chart.average.unavailable", defaultValue: "k.A."))
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(Color(UIColor.systemGray3))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.bottom, 14)
            
            // Chart
            Chart {
                RuleMark(y: .value("Ziel", target ?? 100.0))
                    .foregroundStyle(Color.gruenPrimary.opacity(0.6))
                    .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                
                ForEach(chartData, id: \.0) { pt in
                    LineMark(
                        x: .value("Uhrzeit", pt.0),
                        y: .value("Prozent", pt.1),
                        series: .value("s", "today")
                    )
                    .foregroundStyle(Color.orangePrimary)
                    .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                    .interpolationMethod(.monotone) // Or .stepCenter depending on preference
                }
                
                if let last = chartData.last, last.0 > dayStart {
                    PointMark(x: .value("Uhrzeit", last.0), y: .value("Prozent", last.1))
                        .foregroundStyle(Color.orangePrimary)
                        .symbolSize(60)
                    
                    RuleMark(x: .value("Jetzt", last.0))
                        .foregroundStyle(Color(UIColor.systemGray4))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [3, 4]))
                        .annotation(position: .top, alignment: .center) {
                            Text(timeLabel(for: last.0))
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(UIColor.systemGray))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(Color(UIColor.systemBackground)))
                        }
                }
            }
            .chartXScale(domain: dayStart...max(dayStart.addingTimeInterval(3600), lastDataDate))
            .chartYScale(domain: 0...max(120.0, (target ?? 100.0) * 1.2))
            .chartXAxis {
                AxisMarks(values: [dayStart, lastDataDate]) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel(anchor: date == dayStart ? .topLeading : .topTrailing) {
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
    
    private func statLabel(dotColor: Color, text: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(dotColor)
                .frame(width: 6, height: 6)
            Text(text)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(UIColor.systemGray))
        }
    }
    
    private func formatNumber(_ value: Double) -> String {
        return String(format: "%.0f", value)
    }
    
    private func timeLabel(for date: Date) -> String {
        let df = DateFormatter()
        df.timeStyle = .short
        return df.string(from: date)
    }
}
