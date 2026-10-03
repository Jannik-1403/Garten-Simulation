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
            statsCard
            
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

    // MARK: - Statistik

    private var statsCard: some View {
        let stats = viewModel.stats
        let todayProgress = stats.dueToday > 0 ? Double(stats.doneToday) / Double(stats.dueToday) : 0

        return VStack(alignment: .leading, spacing: 16) {
            Text(String(localized: "cleaning.stats.title", defaultValue: "Statistik"))
                .font(.system(size: 20, weight: .bold, design: .rounded))

            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(Color(UIColor.systemGray5), lineWidth: 10)
                    Circle()
                        .trim(from: 0, to: todayProgress)
                        .stroke(Color.gruenPrimary, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: todayProgress)
                    VStack(spacing: 0) {
                        Text("\(stats.doneToday)/\(stats.dueToday)")
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .contentTransition(.numericText())
                        Text(String(localized: "cleaning.stats.today", defaultValue: "Heute"))
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 92, height: 92)
                .accessibilityElement(children: .combine)

                VStack(alignment: .leading, spacing: 10) {
                    statRow(
                        icon: "chart.bar.fill",
                        color: .blauPrimary,
                        value: stats.weekRate.map { "\(Int(($0 * 100).rounded()))%" } ?? "–",
                        label: String(localized: "cleaning.stats.week", defaultValue: "Letzte 7 Tage")
                    )
                    statRow(
                        icon: "flame.fill",
                        color: .orangePrimary,
                        value: "\(stats.cleanStreak)",
                        label: String(localized: "cleaning.stats.streak", defaultValue: "Aufräum-Tage in Folge")
                    )
                    statRow(
                        icon: "checkmark.seal.fill",
                        color: .gruenPrimary,
                        value: "\(stats.totalCompletions)",
                        label: String(localized: "cleaning.stats.total", defaultValue: "Erledigt insgesamt")
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
    }

    private func statRow(icon: String, color: Color, value: String, label: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(color)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 0) {
                Text(value)
                    .font(.system(size: 16, weight: .black, design: .rounded))
                Text(label)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .accessibilityElement(children: .combine)
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
        .tint(.blauPrimary)
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
