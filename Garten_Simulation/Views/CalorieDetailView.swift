import SwiftUI
import Charts
import HealthKit

enum CalorieTimeframe: String, CaseIterable {
    case week = "1W"
    case month = "1M"
    case sixMonths = "6M"
    case year = "1J"
    
    var days: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .sixMonths: return 180
        case .year: return 365
        }
    }
    
    var interval: DateComponents {
        switch self {
        case .week, .month:
            var c = DateComponents()
            c.day = 1
            return c
        case .sixMonths:
            var c = DateComponents()
            c.weekOfYear = 1
            return c
        case .year:
            var c = DateComponents()
            c.month = 1
            return c
        }
    }
}

struct CalorieDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var hm = HealthManager.shared
    
    @State private var selectedTimeframe: CalorieTimeframe = .week
    @State private var chartData: [(Date, Double)] = []
    @State private var showCalculationSheet = false
    
    @AppStorage("goal_energy") private var goalEnergy: Double = 2000.0
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Timeframe Selector
                    Picker("", selection: $selectedTimeframe) {
                        ForEach(CalorieTimeframe.allCases, id: \.self) { tf in
                            Text(tf.rawValue).tag(tf)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .onChange(of: selectedTimeframe) { _, _ in
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        loadData()
                    }
                    .padding(.top, 16)
                    
                    // Chart Area
                    VStack(alignment: .leading, spacing: 16) {
                        Text(String(localized: "calorie.history.title", defaultValue: "Kalorien Historie"))
                            .font(.headline)
                        
                        Chart {
                            RuleMark(y: .value("Ziel", goalEnergy))
                                .foregroundStyle(Color.cyan.opacity(0.8))
                                .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                            
                            ForEach(chartData, id: \.0) { pt in
                                BarMark(
                                    x: .value("Datum", pt.0, unit: selectedTimeframe == .year ? .month : (selectedTimeframe == .sixMonths ? .weekOfYear : .day)),
                                    y: .value("Kalorien", pt.1)
                                )
                                .foregroundStyle(pt.1 < goalEnergy ? Color.red.darker() : Color.green.darker())
                                .cornerRadius(2)
                            }
                        }
                        .chartScrollableAxes(.horizontal)
                        .chartXVisibleDomain(length: Double(selectedTimeframe.days) * 86400.0)
                        .chartScrollPosition(initialX: Date())
                        .chartYAxis {
                            AxisMarks(position: .trailing) { value in
                                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                AxisValueLabel() {
                                    if let intValue = value.as(Int.self) {
                                        Text("\(intValue)")
                                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                                            .foregroundColor(Color(UIColor.systemGray2))
                                    }
                                }
                            }
                        }
                        .chartXAxis {
                            AxisMarks() { value in
                                AxisValueLabel() {
                                    if let dateValue = value.as(Date.self) {
                                        Text(formatXAxisLabel(date: dateValue, tf: selectedTimeframe))
                                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                                            .foregroundColor(Color(UIColor.systemGray2))
                                    }
                                }
                            }
                        }
                        .frame(height: 220)
                    }
                    .padding()
                    .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
                    
                    // Today's summary
                    VStack(alignment: .leading, spacing: 16) {
                        Text(String(localized: "calorie.history.today", defaultValue: "Heute"))
                            .font(.headline)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(String(localized: "calorie.history.consumed", defaultValue: "Konsumiert"))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("\(Int(hm.todaysEnergy)) kcal")
                                    .font(.title2.bold())
                                    .foregroundColor(hm.todaysEnergy < goalEnergy ? Color.red.darker() : Color.green.darker())
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                Text(String(localized: "calorie.history.target", defaultValue: "Ziel"))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("\(Int(goalEnergy)) kcal")
                                    .font(.title2.bold())
                                    .foregroundColor(hm.todaysEnergy < goalEnergy ? Color.red.darker() : Color.green.darker())
                            }
                        }
                    }
                    .padding()
                    .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
                }
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle(String(localized: "calorie.detail.nav", defaultValue: "Kalorien Details"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showCalculationSheet = true
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.title3.bold())
                            .foregroundColor(.primary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.title3.bold())
                            .foregroundColor(.primary)
                    }
                }
            }
            .sheet(isPresented: $showCalculationSheet) {
                CalorieCalculationSheet()
            }
            .onAppear {
                loadData()
            }
        }
    }
    
    private func loadData() {
        // Lade 5x so viele Tage, um nach hinten wischen zu können
        hm.fetchHistoricalData(for: .energy, days: selectedTimeframe.days * 5, interval: selectedTimeframe.interval) { data in
            self.chartData = data
        }
    }
    
    private func formatXAxisLabel(date: Date, tf: CalorieTimeframe) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        switch tf {
        case .week:
            formatter.dateFormat = "EE"
            return formatter.string(from: date).prefix(2).description // Mo, Di, Mi
        case .month:
            formatter.dateFormat = "d"
            return formatter.string(from: date) // 1, 13, 17
        case .sixMonths:
            formatter.dateFormat = "MMM"
            return formatter.string(from: date) // Jan, Feb, Mär
        case .year:
            formatter.dateFormat = "MMM"
            return formatter.string(from: date).prefix(1).description // J, F, M
        }
    }
}
