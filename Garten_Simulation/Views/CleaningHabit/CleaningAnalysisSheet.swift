import SwiftUI
import Charts

struct CleaningAnalysisSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var manager: CleaningManager
    var task: CleaningTask
    
    @State private var showingDeleteAlert = false
    @State private var frequencyDays: Int
    
    init(manager: CleaningManager, task: CleaningTask) {
        self.manager = manager
        self.task = task
        _frequencyDays = State(initialValue: task.frequencyDays)
    }
    
    var taskColor: Color { AppColors.color(for: task.colorHex) }
    
    private var chartTitle: String {
        String(localized: String.LocalizationValue(task.nameKey))
    }
    
    private var totalCompletions: Int {
        manager.totalCompletions(for: task.id)
    }
    
    // Group logs by month for the chart
    private var chartData: [(Date, Int)] {
        let logs = manager.logs.filter { $0.taskId == task.id }
        var grouped: [Date: Int] = [:]
        let cal = Calendar.current
        for log in logs {
            let comps = cal.dateComponents([.year, .month], from: log.timestamp)
            if let date = cal.date(from: comps) {
                grouped[date, default: 0] += 1
            }
        }
        return grouped.map { ($0.key, $0.value) }.sorted { $0.0 < $1.0 }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appHintergrund.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        
                        // Header & Stats
                        VStack(alignment: .leading, spacing: 0) {
                            // Title
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(taskColor)
                                    .frame(width: 10, height: 10)
                                Text(chartTitle)
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundStyle(taskColor)
                            }
                            .padding(.bottom, 14)
                            
                            // Stats Row
                            HStack(alignment: .top, spacing: 0) {
                                VStack(alignment: .leading, spacing: 1) {
                                    statLabel(dotColor: taskColor, text: String(localized: "cleaning.stat.total", defaultValue: "Insgesamt"))
                                    Text("\(totalCompletions)")
                                        .font(.system(size: 42, weight: .black, design: .rounded))
                                        .foregroundStyle(taskColor)
                                    Text(String(localized: "cleaning.stat.completions", defaultValue: "Mal erledigt"))
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundStyle(taskColor.opacity(0.7))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.bottom, 14)
                            
                            // Chart
                            if chartData.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "chart.bar.xaxis")
                                        .font(.system(size: 40))
                                        .foregroundColor(.secondary.opacity(0.5))
                                    Text(String(localized: "cleaning.chart.empty", defaultValue: "Noch keine Daten vorhanden"))
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 150)
                            } else {
                                Chart {
                                    ForEach(chartData, id: \.0) { item in
                                        BarMark(
                                            x: .value("Monat", item.0, unit: .month),
                                            y: .value("Anzahl", item.1)
                                        )
                                        .foregroundStyle(taskColor)
                                        .cornerRadius(4)
                                    }
                                }
                                .chartXAxis {
                                    AxisMarks(values: .stride(by: .month)) { _ in
                                        AxisValueLabel(format: .dateTime.month(.abbreviated), centered: true)
                                    }
                                }
                                .frame(height: 200)
                            }
                        }
                        .padding(20)
                        .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
                        
                        // Edit Interval
                        VStack(alignment: .leading, spacing: 16) {
                            Text(String(localized: "cleaning.edit.interval", defaultValue: "Intervall ändern"))
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Stepper(value: $frequencyDays, in: 1...90) {
                                Text("\(frequencyDays) \(frequencyDays == 1 ? String(localized: "cleaning.add.day.singular", defaultValue: "Tag") : String(localized: "cleaning.add.days", defaultValue: "Tage"))")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
                            .onChange(of: frequencyDays) { _, newValue in
                                var updated = task
                                updated.frequencyDays = newValue
                                manager.updateTask(updated)
                            }
                        }
                        .padding(20)
                        .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
                        
                        // Delete Button (item3D-Style)
                        Item3DButton(
                            farbe: .red,
                            sekundaerFarbe: Color(red: 0.7, green: 0, blue: 0),
                            groesse: 56,
                            isRectangular: true,
                            aktion: {
                                showingDeleteAlert = true
                            }
                        ) {
                            HStack {
                                Image(systemName: "trash")
                                    .font(.system(size: 20, weight: .bold))
                                Text(String(localized: "common.delete", defaultValue: "Löschen"))
                                    .font(.system(size: 18, weight: .black, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.top, 24)
                        
                    }
                    .padding(24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "common.close", defaultValue: "Schließen")) {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                }
            }
            .alert(String(localized: "cleaning.delete.title", defaultValue: "Aufgabe löschen?"), isPresented: $showingDeleteAlert) {
                Button(String(localized: "common.cancel", defaultValue: "Abbrechen"), role: .cancel) { }
                Button(String(localized: "common.delete", defaultValue: "Löschen"), role: .destructive) {
                    manager.deleteTask(task)
                    dismiss()
                }
            }
        }
    }
    
    private func statLabel(dotColor: Color, text: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(dotColor)
                .frame(width: 6, height: 6)
            Text(text)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(Color.secondary)
        }
        .padding(.bottom, 2)
    }
}

#Preview {
    let manager = CleaningManager.shared
    manager.tasks = [CleaningTask(nameKey: "Bett abziehen", iconName: "bed.double.fill", frequencyDays: 7, colorHex: "blauPrimary")]
    return CleaningAnalysisSheet(manager: manager, task: manager.tasks[0])
}
