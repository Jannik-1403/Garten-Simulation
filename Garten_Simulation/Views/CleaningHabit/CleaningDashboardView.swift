import SwiftUI

/// Aufräum-Dashboard in der Pflanzen-Detailansicht: Statistik → Heute (abhaken) → Demnächst.
struct CleaningDashboardView: View {
    @ObservedObject var pflanze: HabitModel
    @EnvironmentObject var gardenStore: GardenStore
    @StateObject private var viewModel = CleaningDashboardViewModel()

    @State private var editorTask: CleaningTask?
    @State private var isCreatingTask = false
    @State private var isUpcomingExpanded = false
    @State private var taskToDelete: CleaningTask?

    var body: some View {
        VStack(spacing: 16) {
            if viewModel.hasTasks {
                todayCard
                if !viewModel.upcomingItems.isEmpty {
                    upcomingCard
                }
            } else {
                emptyState
            }
        }
        .sheet(isPresented: $isCreatingTask) {
            CleaningTaskEditorSheet(task: nil) { task in
                viewModel.save(task, isNew: true, gardenStore: gardenStore)
            }
        }
        .sheet(item: $editorTask) { task in
            CleaningTaskEditorSheet(task: task, onSave: { updated in
                viewModel.save(updated, isNew: false, gardenStore: gardenStore)
            }, onDelete: {
                viewModel.delete(task, gardenStore: gardenStore)
            })
        }
        .confirmationDialog(
            String(localized: "cleaning.delete.confirm", defaultValue: "Aufgabe löschen?"),
            isPresented: Binding(get: { taskToDelete != nil }, set: { if !$0 { taskToDelete = nil } }),
            titleVisibility: .visible,
            presenting: taskToDelete
        ) { task in
            Button(String(localized: "cleaning.delete.action", defaultValue: "Löschen"), role: .destructive) {
                viewModel.delete(task, gardenStore: gardenStore)
            }
            Button(String(localized: "button.cancel", defaultValue: "Abbrechen"), role: .cancel) { }
        }
    }

    // MARK: - Heute

    private var todayCard: some View {
        let tasks = viewModel.todayTasks

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(String(localized: "cleaning.today.title", defaultValue: "Heute aufräumen"))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                Spacer()
                addButton
            }

            if tasks.isEmpty {
                Label(String(localized: "cleaning.today.none", defaultValue: "Heute steht nichts an – genieß den freien Tag!"), systemImage: "sun.max.fill")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 4)
            } else {
                ForEach(tasks) { task in
                    CleaningTaskRowView(
                        task: task,
                        mode: .today(isDone: viewModel.isCompletedToday(task)),
                        onTap: { viewModel.toggle(task, pflanze: pflanze, gardenStore: gardenStore) },
                        onEdit: { editorTask = task },
                        onDelete: { taskToDelete = task }
                    )
                }
            }
        }
        .padding(16)
        .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
    }

    // MARK: - Demnächst

    private var upcomingCard: some View {
        DisclosureGroup(isExpanded: $isUpcomingExpanded) {
            VStack(spacing: 10) {
                ForEach(viewModel.upcomingItems) { item in
                    CleaningTaskRowView(
                        task: item.task,
                        mode: .upcoming(nextDate: item.nextDate ?? Date()),
                        onTap: { editorTask = item.task },
                        onEdit: { editorTask = item.task },
                        onDelete: { taskToDelete = item.task }
                    )
                }
            }
            .padding(.top, 12)
        } label: {
            Text(String(localized: "cleaning.upcoming.title", defaultValue: "Demnächst"))
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
        }
        .tint(.primary)
        .padding(16)
        .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
    }

    // MARK: - Leerer Zustand

    private var emptyState: some View {
        VStack(spacing: 14) {
            Item3DButton(icon: "sparkles", farbe: .blauPrimary, sekundaerFarbe: .blauPrimary.darker(), groesse: 64, iconSkalierung: 0.45) {
                isCreatingTask = true
            }
            Text(String(localized: "cleaning.empty.title", defaultValue: "Keine Aufgaben"))
                .font(.system(size: 18, weight: .bold, design: .rounded))
            Text(String(localized: "cleaning.empty.explanation", defaultValue: "Lege Aufgaben wie „Bett abziehen“ mit eigenem Rhythmus an. Die Gewohnheit ist dann nur an Tagen fällig, an denen etwas ansteht."))
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
    }

    private var addButton: some View {
        Item3DButton(
            farbe: .blauPrimary,
            sekundaerFarbe: .blauPrimary.darker(),
            groesse: 36,
            aktion: { isCreatingTask = true }
        ) {
            Image(systemName: "plus")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
        }
        .accessibilityLabel(String(localized: "cleaning.add.title", defaultValue: "Neue Aufgabe"))
    }
}

#Preview {
    let habit = HabitModel(name: "plant.chrysantheme.name", symbolName: "house.fill", habitName: "habit.aufraeumen")
    return ScrollView {
        CleaningDashboardView(pflanze: habit)
            .padding(24)
    }
    .background(Color(UIColor.secondarySystemBackground))
    .environmentObject(GardenStore())
}
