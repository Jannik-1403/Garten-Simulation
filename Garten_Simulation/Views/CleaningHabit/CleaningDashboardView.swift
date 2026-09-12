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
            
            Text(String(localized: "cleaning.empty.suggestions", defaultValue: "Vorschläge:"))
                .font(.headline)
                .foregroundColor(.secondary)
            
            let suggestions = [
                (nameKey: "cleaning.task.bed", icon: "bed.double.fill", days: 7),
                (nameKey: "cleaning.task.room", icon: "squareshape.split.2x2", days: 3),
                (nameKey: "cleaning.task.kitchen", icon: "fork.knife", days: 2)
            ]
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 16) {
                ForEach(suggestions, id: \.nameKey) { suggestion in
                    Item3DPillButton(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5), groesse: 50) {
                        manager.addTask(nameKey: String(localized: String.LocalizationValue(suggestion.nameKey)), iconName: suggestion.icon, frequencyDays: suggestion.days, scheduledWeekday: nil)
                    } label: {
                        HStack {
                            Image(systemName: suggestion.icon)
                            Text(String(localized: String.LocalizationValue(suggestion.nameKey)))
                                .font(.subheadline)
                                .lineLimit(1)
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
            
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
            let due = task.dueDate(lastCompleted: manager.lastCompletedDate(for: task.id))
            return Calendar.current.startOfDay(for: due) <= today
        }
        let futureTasks = sortedTasks.filter { task in
            let due = task.dueDate(lastCompleted: manager.lastCompletedDate(for: task.id))
            return Calendar.current.startOfDay(for: due) > today
        }
        
        return VStack(spacing: 0) {
            // Header row with title + Plus button
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(String(localized: "cleaning.dashboard.section.next", defaultValue: "Zunächst fällige Aufgaben"))
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(.primary)
                    
                    if dueTasks.count > 0 {
                        Text(String(localized: "cleaning.dashboard.subtitle.overdue", defaultValue: "%@ Aufgaben sind fällig", table: nil).replacingOccurrences(of: "%@", with: "\(dueTasks.count)"))
                            .font(.caption)
                            .foregroundColor(.orange)
                    } else {
                        Text(String(localized: "cleaning.dashboard.subtitle.allDone", defaultValue: "Alles sauber für heute!"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                // Plus – same style as Todos toolbar button, but as Item3D
                Button {
                    showingAddSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                }
            }
            .padding(.bottom, 16)
            
            // Due tasks
            VStack(spacing: 12) {
                ForEach(dueTasks) { task in
                    CleaningTaskRowView(manager: manager, task: task, isFuture: false)
                        .onTapGesture { selectedTask = task }
                }
            }
            
            // Future tasks – collapsible
            if !futureTasks.isEmpty {
                DisclosureGroup {
                    VStack(spacing: 12) {
                        ForEach(futureTasks) { task in
                            CleaningTaskRowView(manager: manager, task: task, isFuture: true)
                        }
                    }
                    .padding(.top, 12)
                } label: {
                    Text(String(localized: "cleaning.dashboard.section.future", defaultValue: "Demnächst fällig"))
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                .tint(.blauPrimary)
                .padding(.top, 20)
            }
        }
    }
}

#Preview {
    ScrollView {
        CleaningDashboardView()
            .padding(.horizontal, 24)
    }
    .background(Color.appHintergrund)
}
