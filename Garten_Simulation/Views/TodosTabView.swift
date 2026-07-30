import SwiftUI
import Combine

struct TodosTabView: View {
    @EnvironmentObject var gardenStore: GardenStore
    
    @State private var showingAddTodoSheet = false
    @State private var selectedPlantForTodo: HabitModel?
    @State private var todoToEditIndex: Int? = nil
    
    @EnvironmentObject var streakStore: StreakStore
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var shopStore: ShopStore
    
    @State private var zeigeStreakDetail = false
    @State private var zeigeCoinsDetail = false
    @State private var zeigeLebenDetail = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appHintergrund.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    GartenStatsBar(
                        streak: streakStore.currentStreak,
                        coins: gardenStore.coins,
                        leben: gardenStore.leben,
                        onStreakTap: { zeigeStreakDetail = true },
                        onCoinsTap: { zeigeCoinsDetail = true },
                        onLebenTap: { zeigeLebenDetail = true }
                    )
                    .background(Color.appHintergrund)
                    .overlay(alignment: .bottom) {
                        Divider().opacity(0.12).padding(.horizontal, 16)
                    }

                    WeeklyGoalBannerView()
                        .environmentObject(gardenStore)
                        .padding(.top, 16)
                        .padding(.bottom, 24)

                        
                    if alleTodosEmpty() {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "checklist")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        Text(String(localized: "todos.tab.empty", defaultValue: "Keine offenen To-Dos."))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 24) {
                            ForEach(gardenStore.pflanzen) { pflanze in
                                if !pflanze.todos.isEmpty {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text(NSLocalizedString(pflanze.displayedHabitName, comment: ""))
                                            .font(.system(size: 20, weight: .black, design: .rounded))
                                            .padding(.horizontal, 24)
                                        
                                        VStack(spacing: 12) {
                                            ForEach(pflanze.todos.sorted { $0.priority.sortValue < $1.priority.sortValue }, id: \.id) { todo in
                                                TodoRowView(
                                                    pflanze: pflanze,
                                                    todoId: todo.id,
                                                    onEdit: {
                                                        if let index = pflanze.todos.firstIndex(where: { $0.id == todo.id }) {
                                                            selectedPlantForTodo = pflanze
                                                            todoToEditIndex = index
                                                            showingAddTodoSheet = true
                                                        }
                                                    }
                                                )
                                            }
                                        }
                                        .padding(.horizontal, 24)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 24)
                    }
                }
                Spacer()
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            selectedPlantForTodo = nil
                            todoToEditIndex = nil
                            showingAddTodoSheet = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 56, height: 56)
                                .background(Color.gruenPrimary)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)
                        }
                        .padding(.trailing, 24)
                        .padding(.bottom, 24)
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingAddTodoSheet) {
                if let selected = selectedPlantForTodo {
                    TodoSheetView(pflanze: selected, editIndex: todoToEditIndex)
                } else {
                    GlobalTodoAddSheet()
                }
            }
            .fullScreenCover(isPresented: $zeigeLebenDetail) {
                LebenDetailView()
                    .environmentObject(gardenStore)
                    .environmentObject(settings)
            }
            .fullScreenCover(isPresented: $zeigeStreakDetail) {
                NavigationStack {
                    StreakView()
                        .environmentObject(streakStore)
                        .environmentObject(settings)
                }
            }
            .fullScreenCover(isPresented: $zeigeCoinsDetail) {
                NavigationStack {
                    CoinsDetailView()
                        .environmentObject(gardenStore)
                        .environmentObject(settings)
                        .environmentObject(shopStore)
                }
            }
        }
    }
    
    private func alleTodosEmpty() -> Bool {
        return gardenStore.pflanzen.allSatisfy { $0.todos.isEmpty }
    }
}

struct TodoRowView: View {
    @ObservedObject var pflanze: HabitModel
    let todoId: UUID
    let onEdit: () -> Void
    @EnvironmentObject var gardenStore: GardenStore
    
    var body: some View {
        if let index = pflanze.todos.firstIndex(where: { $0.id == todoId }) {
            Item3DButton(
                farbe: pflanze.todos[index].isCompleted ? .gruenPrimary : Color.white,
                sekundaerFarbe: pflanze.todos[index].isCompleted ? .gruenPrimary.darker() : Color(white: 0.9),
                groesse: 64,
                isRectangular: true,
                aktion: {
                    withAnimation {
                        pflanze.todos[index].isCompleted.toggle()
                        GoalStore.shared.logTodoCompletion(habitId: pflanze.id, priority: pflanze.todos[index].priority, isCompleted: pflanze.todos[index].isCompleted)
                        gardenStore.savePlants()
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                }
            ) {
                HStack {
                    Button {
                        withAnimation {
                            pflanze.todos[index].priority.next()
                            gardenStore.savePlants()
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    } label: {
                        Text(pflanze.todos[index].priority.icon)
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(pflanze.todos[index].priority.color)
                    }
                    
                    Image(systemName: pflanze.todos[index].isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 24))
                        .foregroundStyle(pflanze.todos[index].isCompleted ? Color.white : Color.gray)
                    
                    Text(pflanze.todos[index].text)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .strikethrough(pflanze.todos[index].isCompleted)
                        .foregroundColor(pflanze.todos[index].isCompleted ? Color.white.opacity(0.8) : .primary)
                    
                    Spacer()
                }
                .padding(.horizontal, 8)
            }
            .contextMenu {
                Button {
                    onEdit()
                } label: {
                    Label(String(localized: "common.edit", defaultValue: "Bearbeiten"), systemImage: "pencil")
                }
                
                Button(role: .destructive) {
                    withAnimation {
                        if let idx = pflanze.todos.firstIndex(where: { $0.id == todoId }) {
                            pflanze.todos.remove(at: idx)
                            gardenStore.savePlants()
                            gardenStore.objectWillChange.send()
                        }
                    }
                } label: {
                    Label(String(localized: "button.delete", defaultValue: "Löschen"), systemImage: "trash")
                }
            }
        }
    }
}

struct GlobalTodoAddSheet: View {
    @EnvironmentObject var gardenStore: GardenStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedPlant: HabitModel?
    @State private var todoText: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Plant Selector
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "todos.tab.select_plant", defaultValue: "Für welche Gewohnheit?"))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top, spacing: 12) {
                            ForEach(gardenStore.pflanzen) { pflanze in
                                VStack(spacing: 8) {
                                    let isSelected = selectedPlant?.id == pflanze.id
                                    PflanzenButton(
                                        plant: GameDatabase.shared.plant(for: pflanze.plantID),
                                        seltenheit: pflanze.seltenheit,
                                        farbe: isSelected ? pflanze.color : Color(UIColor.systemGray4),
                                        sekundaerFarbe: isSelected ? pflanze.color.darker() : Color(UIColor.systemGray3),
                                        groesse: 64,
                                        fallbackIcon: pflanze.symbolName,
                                        aktion: {
                                            selectedPlant = pflanze
                                        }
                                    )
                                    
                                    Text(NSLocalizedString(pflanze.displayedHabitName, comment: ""))
                                        .font(.system(size: 10, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.center)
                                        .frame(width: 70)
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                    }
                }
                
                // Text Input
                VStack(alignment: .leading, spacing: 8) {
                    TextField(String(localized: "plant.detail.todo.placeholder", defaultValue: "To-Do eingeben..."), text: $todoText, axis: .vertical)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .frame(minHeight: 140, alignment: .topLeading)
                        .contentShape(Rectangle())
                        .item3DContainer(farbe: .white, sekundaerFarbe: Color(UIColor.systemGray5))
                }
                
                Spacer()
                
                Button {
                    guard let selected = selectedPlant else { return }
                    let trimmed = todoText.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    
                    let newTodo = FocusGoal(text: trimmed)
                    selected.todos.append(newTodo)
                    gardenStore.savePlants()
                    gardenStore.objectWillChange.send()
                    dismiss()
                } label: {
                    Text(String(localized: "common.save", defaultValue: "Speichern"))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .frame(height: 24)
                }
                .buttonStyle(DuolingoButtonStyle(size: .medium, fillWidth: true, backgroundColor: .black, shadowColor: Color.black.opacity(0.8), foregroundColor: .white))
                .disabled(todoText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedPlant == nil)
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .navigationTitle(String(localized: "plant.detail.todo.add", defaultValue: "To-Do hinzufügen"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(String(localized: "common.cancel", defaultValue: "Abbrechen")) {
                        dismiss()
                    }
                    .foregroundColor(.primary)
                }
            }
        }
    }
}


