import SwiftUI

struct CleaningDashboardView: View {
    @StateObject private var manager = CleaningManager.shared
    @State private var showingAddSheet = false
    @State private var selectedTask: CleaningTask?
    
    var body: some View {
        VStack(spacing: 24) {
            if manager.tasks.isEmpty {
                // Empty State
                Spacer()
                
                Item3DButton(icon: "plus", farbe: .blue, sekundaerFarbe: Color(UIColor.systemBlue).opacity(0.5), groesse: 80) {
                    showingAddSheet = true
                }
                .padding(.bottom, 24)
                
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
                .padding(.horizontal)
                
                Spacer()
                
            } else {
                // Tasks List
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
                
                VStack(spacing: 24) {
                    // "Zunächst fällige" Section
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(String(localized: "cleaning.dashboard.section.next", defaultValue: "Zunächst fällige Aufgaben"))
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.primary)
                                
                                if dueTasks.count > 0 {
                                    Text(String(localized: "cleaning.dashboard.subtitle.overdue", defaultValue: "%@ Aufgaben sind fällig", table: nil).replacingOccurrences(of: "%@", with: "\(dueTasks.count)"))
                                        .font(.subheadline)
                                        .foregroundColor(.orange)
                                } else {
                                    Text(String(localized: "cleaning.dashboard.subtitle.allDone", defaultValue: "Alles sauber für heute!"))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                            
                            Item3DButton(
                                icon: "plus",
                                farbe: .blauPrimary,
                                sekundaerFarbe: .blauPrimary.darker(),
                                groesse: 36,
                                iconSkalierung: 0.4
                            ) {
                                showingAddSheet = true
                            }
                        }
                        
                        LazyVStack(spacing: 16) {
                            ForEach(dueTasks) { task in
                                CleaningTaskRowView(manager: manager, task: task, isFuture: false)
                                    .onTapGesture {
                                        selectedTask = task
                                    }
                            }
                        }
                    }
                    
                    // "Demnächst fällig" Section
                    if !futureTasks.isEmpty {
                        DisclosureGroup {
                            LazyVStack(spacing: 16) {
                                ForEach(futureTasks) { task in
                                    CleaningTaskRowView(manager: manager, task: task, isFuture: true)
                                }
                            }
                            .padding(.top, 16)
                        } label: {
                            Text(String(localized: "cleaning.dashboard.section.future", defaultValue: "Demnächst fällig"))
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .tint(.blauPrimary)
                    }
                }
                .padding(16)
                .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
                .padding(.horizontal)
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddCleaningTaskSheet(manager: manager)
        }
        .sheet(item: $selectedTask) { task in
            CleaningAnalysisSheet(manager: manager, task: task)
        }
    }
}



#Preview {
    NavigationView {
        CleaningDashboardView()
    }
}
