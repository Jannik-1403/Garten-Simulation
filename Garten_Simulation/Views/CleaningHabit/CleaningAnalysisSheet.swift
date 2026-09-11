import SwiftUI
import Charts

struct CleaningAnalysisSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var manager: CleaningManager
    var task: CleaningTask
    
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Icon
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: task.iconName)
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.blue)
                                .shadow(color: .blue.opacity(0.5), radius: 10, x: 0, y: 5)
                        }
                        .padding(.top, 20)
                        
                        Text(String(localized: String.LocalizationValue(task.nameKey)))
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                        
                        // Stats Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            StatCard(
                                title: String(localized: "cleaning.stat.total", defaultValue: "Insgesamt"),
                                value: "\(manager.totalCompletions(for: task.id))",
                                icon: "checkmark.circle.fill",
                                color: .green
                            )
                            
                            StatCard(
                                title: String(localized: "cleaning.stat.interval", defaultValue: "Intervall"),
                                value: String(localized: "cleaning.stat.interval.days", defaultValue: "Alle %@ Tage", table: nil).replacingOccurrences(of: "%@", with: "\(task.frequencyDays)"),
                                icon: "clock.fill",
                                color: .orange
                            )
                        }
                        .padding(.horizontal)
                        
                        // Chart Section
                        let recentLogs = manager.logs.filter { $0.taskId == task.id }
                        if !recentLogs.isEmpty {
                            VStack(alignment: .leading) {
                                Text(String(localized: "cleaning.chart.title", defaultValue: "Aktivität"))
                                    .font(.title3)
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                Chart(recentLogs) { log in
                                    PointMark(
                                        x: .value("Datum", log.timestamp),
                                        y: .value("Erledigt", 1)
                                    )
                                    .symbol(.circle)
                                    .foregroundStyle(Color.blue)
                                }
                                .chartYAxis(.hidden)
                                .frame(height: 150)
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(16)
                                .padding(.horizontal)
                            }
                        }
                        
                        Spacer(minLength: 40)
                        
                        // Delete Button
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Text(String(localized: "cleaning.action.delete", defaultValue: "Aufgabe löschen"))
                                .font(.headline)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(16)
                                .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "common.close", defaultValue: "Schließen")) {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .alert(String(localized: "cleaning.delete.title", defaultValue: "Aufgabe löschen?"), isPresented: $showingDeleteAlert) {
                Button(String(localized: "common.cancel", defaultValue: "Abbrechen"), role: .cancel) { }
                Button(String(localized: "common.delete", defaultValue: "Löschen"), role: .destructive) {
                    manager.deleteTask(task)
                    dismiss()
                }
            } message: {
                Text(String(localized: "cleaning.delete.message", defaultValue: "Möchtest du diese Aufgabe wirklich löschen? Die bisherigen Daten bleiben anonymisiert erhalten."))
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct StatCard: View {
    var title: String
    var value: String
    var icon: String
    var color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            Text(value)
                .font(.title3)
                .bold()
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}
