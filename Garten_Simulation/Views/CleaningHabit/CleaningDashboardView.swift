import SwiftUI

struct CleaningDashboardView: View {
    @StateObject private var manager = CleaningManager.shared
    @State private var showingAddSheet = false
    @State private var selectedTask: CleaningTask?
    
    var body: some View {
        VStack(spacing: 0) {
            if manager.tasks.isEmpty {
                emptyState
            } else {
                taskList
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddCleaningTaskSheet(manager: manager)
        }
        .sheet(item: $selectedTask) { task in
            CleaningAnalysisSheet(manager: manager, task: task)
        }
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()
            Item3DButton(icon: "plus", farbe: .blauPrimary, sekundaerFarbe: .blauPrimary.darker(), groesse: 80) {
                showingAddSheet = true
            }
            Text(String(localized: "cleaning.empty.title", defaultValue: "Keine Aufgaben"))
                .font(.headline)
                .foregroundColor(.secondary)
            Text(String(localized: "cleaning.empty.subtitle", defaultValue: "Füge deine erste Aufräum-Aufgabe hinzu"))
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
        }
    }
    
    // MARK: - Task List
    private var taskList: some View {
        let sortedTasks = manager.tasks.sorted {
            $0.dueDate(lastCompleted: manager.lastCompletedDate(for: $0.id)) < $1.dueDate(lastCompleted: manager.lastCompletedDate(for: $1.id))
        }
        let today = Calendar.current.startOfDay(for: Date())
        let dueTasks = sortedTasks.filter { task in
            Calendar.current.startOfDay(for: task.dueDate(lastCompleted: manager.lastCompletedDate(for: task.id))) <= today
        }
        let futureTasks = sortedTasks.filter { task in
            Calendar.current.startOfDay(for: task.dueDate(lastCompleted: manager.lastCompletedDate(for: task.id))) > today
        }
        
        return VStack(spacing: 16) {
            // ── Header ──
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(String(localized: "cleaning.dashboard.section.next", defaultValue: "Zunächst fällige Aufgaben"))
                        .font(.system(size: 20, weight: .black, design: .rounded))
                    if dueTasks.count > 0 {
                        Text(String(localized: "cleaning.dashboard.subtitle.overdue", defaultValue: "%@ Aufgaben sind fällig", table: nil).replacingOccurrences(of: "%@", with: "\(dueTasks.count)"))
                            .font(.caption).foregroundColor(.orange)
                    } else {
                        Text(String(localized: "cleaning.dashboard.subtitle.allDone", defaultValue: "Alles sauber für heute!"))
                            .font(.caption).foregroundColor(.secondary)
                    }
                }
                Spacer()
                // Blue item3D Plus Button (same as Todos-Header)
                Item3DButton(
                    icon: "plus",
                    farbe: .blauPrimary,
                    sekundaerFarbe: .blauPrimary.darker(),
                    groesse: 36,
                    iconSkalierung: 0.45
                ) {
                    showingAddSheet = true
                }
            }
            
            // ── Due Tasks ──
            VStack(spacing: 12) {
                ForEach(dueTasks) { task in
                    CleaningTaskRowView(manager: manager, task: task, isFuture: false) {
                        selectedTask = task
                    }
                }
            }
            
            // ── Future Tasks (collapsible) ──
            if !futureTasks.isEmpty {
                DisclosureGroup {
                    VStack(spacing: 12) {
                        ForEach(futureTasks) { task in
                            CleaningTaskRowView(manager: manager, task: task, isFuture: true) {
                                selectedTask = task
                            }
                        }
                    }
                    .padding(.top, 12)
                } label: {
                    Text(String(localized: "cleaning.dashboard.section.future", defaultValue: "Demnächst fällig"))
                        .font(.headline).foregroundColor(.primary)
                }
                .tint(.blauPrimary)
            }
        }
        .padding(16)
        .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
    }
}

#Preview {
    ScrollView {
        CleaningDashboardView()
            .padding(.horizontal, 24)
    }
    .background(Color.appHintergrund)
}
