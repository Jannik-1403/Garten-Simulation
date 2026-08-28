import SwiftUI
import Charts
import HealthKit

enum BodyDataTimeRange: String, CaseIterable, Identifiable {
    case t = "T"
    case w = "W"
    case m = "M"
    case sixM = "6 M."
    case j = "J"
    
    var id: String { rawValue }
}

enum BodyMeasurementCategory: String, CaseIterable, Identifiable {
    case bizeps = "body.measure.bizeps"
    case unterarm = "body.measure.unterarm"
    case schultern = "body.measure.schultern"
    case oberschenkel = "body.measure.oberschenkel"
    case waden = "body.measure.waden"
    case taille = "body.measure.taille"
    
    var id: String { rawValue }
    
    var localizedName: String {
        switch self {
        case .bizeps: return String(localized: "body.measure.bizeps", defaultValue: "Bizeps (Oberarm)")
        case .unterarm: return String(localized: "body.measure.unterarm", defaultValue: "Unterarm")
        case .schultern: return String(localized: "body.measure.schultern", defaultValue: "Schultern")
        case .oberschenkel: return String(localized: "body.measure.oberschenkel", defaultValue: "Oberschenkel")
        case .waden: return String(localized: "body.measure.waden", defaultValue: "Waden")
        case .taille: return String(localized: "body.measure.taille", defaultValue: "Taille (Bauch)")
        }
    }
}

struct BodyDataFactoryView: View {
    @ObservedObject var pflanze: HabitModel
    let type: BodyTrackingType
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var gardenStore: GardenStore
    
    @State private var timeRange: BodyDataTimeRange = .m
    @State private var selectedMeasurement: BodyMeasurementCategory = .bizeps
    
    @State private var showAddSheet = false
    @State private var inputValue: Double? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Picker (T, W, M, 6M, J)
            Picker("", selection: $timeRange) {
                ForEach(BodyDataTimeRange.allCases) { r in
                    Text(r.rawValue).tag(r)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top, 16)
            
            if type == .measurements {
                Picker("", selection: $selectedMeasurement) {
                    ForEach(BodyMeasurementCategory.allCases) { cat in
                        Text(cat.localizedName).tag(cat)
                    }
                }
                .pickerStyle(.menu)
                .padding(.horizontal)
            }
            
            // Durchschnitt / Header
            VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "body.tracking.average", defaultValue: "DURCHSCHNITT"))
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(String(format: "%.2f", currentAverage))
                        .font(.system(size: 36, weight: .black, design: .rounded))
                    Text(unit)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                
                Text(dateRangeString)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            
            // Diagramm
            Chart {
                ForEach(filteredData, id: \.timestamp) { entry in
                    LineMark(
                        x: .value("Date", entry.timestamp),
                        y: .value("Value", entry.progress)
                    )
                    .interpolationMethod(.linear)
                    .foregroundStyle(Color.pink)
                    .symbol {
                        Circle()
                            .strokeBorder(Color.pink, lineWidth: 2)
                            .background(Circle().fill(.white))
                            .frame(width: 8, height: 8)
                    }
                }
            }
            .chartXAxis {
                AxisMarks(preset: .aligned) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [4]))
                    AxisValueLabel()
                }
            }
            .chartYAxis {
                AxisMarks(position: .trailing) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [4]))
                    AxisValueLabel()
                }
            }
            .frame(height: 250)
            .padding(.horizontal)
            .padding(.top, 24)
            
            Spacer()
        }
        .navigationTitle(type == .weight ? String(localized: "body.tracking.weight", defaultValue: "Gewicht") : String(localized: "body.tracking.measurements", defaultValue: "Körperumfänge"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    inputValue = nil
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .bold))
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            NavigationStack {
                Form {
                    Section {
                        TextField(String(localized: "body.tracking.enter_value", defaultValue: "Wert eingeben"), value: $inputValue, format: .number)
                            .keyboardType(.decimalPad)
                    }
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
                            if let val = inputValue {
                                addEntry(val)
                            }
                            showAddSheet = false
                        }
                        .bold()
                        .disabled(inputValue == nil)
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }
    
    // MARK: - Logic
    
    private var unit: String {
        type == .weight ? "kg" : "cm"
    }
    
    private var allData: [DailyProgressEntry] {
        if type == .weight {
            return pflanze.manualWeightEntries
        } else {
            return pflanze.bodyMeasurements[selectedMeasurement.rawValue] ?? []
        }
    }
    
    private var dateRangeString: String {
        switch timeRange {
        case .t: return String(localized: "body.tracking.today", defaultValue: "Heute")
        case .w: return String(localized: "body.tracking.this_week", defaultValue: "Diese Woche")
        case .m: return String(localized: "body.tracking.this_month", defaultValue: "Dieser Monat")
        case .sixM: return String(localized: "body.tracking.six_months", defaultValue: "6 Monate")
        case .j: return String(localized: "body.tracking.this_year", defaultValue: "Dieses Jahr")
        }
    }
    
    private var filteredData: [DailyProgressEntry] {
        let now = Date()
        let calendar = Calendar.current
        var startDate: Date
        
        switch timeRange {
        case .t: startDate = calendar.startOfDay(for: now)
        case .w: startDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .m: startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case .sixM: startDate = calendar.date(byAdding: .month, value: -6, to: now) ?? now
        case .j: startDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        }
        
        return allData.filter { $0.timestamp >= startDate }.sorted(by: { $0.timestamp < $1.timestamp })
    }
    
    private var currentAverage: Double {
        let data = filteredData
        if data.isEmpty { return 0 }
        return data.reduce(0) { $0 + $1.progress } / Double(data.count)
    }
    
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
