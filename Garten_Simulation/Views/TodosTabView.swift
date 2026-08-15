import SwiftUI
import Combine

struct TodosTabView: View {
    @EnvironmentObject var gardenStore: GardenStore
    
    @State private var showingAddTodoSheet = false
    @State private var selectedPlantForTodo: HabitModel?
    @State private var todoToEditIndex: Int? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appHintergrund.ignoresSafeArea()
                
                VStack(spacing: 0) {
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
                            // 1. Standalone Todos Section
                            if !gardenStore.standaloneTodos.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(String(localized: "todos.tab.general", defaultValue: "Allgemeine To-Dos"))
                                        .font(.system(size: 20, weight: .black, design: .rounded))
                                        .padding(.horizontal, 24)
                                    
                                    VStack(spacing: 12) {
                                        ForEach(gardenStore.standaloneTodos.sorted { $0.priority.sortValue < $1.priority.sortValue }, id: \.id) { todo in
                                            StandaloneTodoRowView(
                                                todoId: todo.id,
                                                onEdit: {
                                                    if let index = gardenStore.standaloneTodos.firstIndex(where: { $0.id == todo.id }) {
                                                        selectedPlantForTodo = nil
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
                            
                            // 2. Habit-specific Todos Section
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
            }
            // Title removed based on user request
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        selectedPlantForTodo = nil
                        todoToEditIndex = nil
                        showingAddTodoSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                    }
                }
            }
            .sheet(isPresented: $showingAddTodoSheet) {
                if let selected = selectedPlantForTodo {
                    TodoSheetView(pflanze: selected, editIndex: todoToEditIndex)
                } else {
                    GlobalTodoAddSheet()
                }
            }
        }
    }
    
    private func alleTodosEmpty() -> Bool {
        return gardenStore.pflanzen.allSatisfy { $0.todos.isEmpty } && gardenStore.standaloneTodos.isEmpty
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

struct StandaloneTodoRowView: View {
    let todoId: UUID
    let onEdit: () -> Void
    @EnvironmentObject var gardenStore: GardenStore
    
    var body: some View {
        if let index = gardenStore.standaloneTodos.firstIndex(where: { $0.id == todoId }) {
            Item3DButton(
                farbe: gardenStore.standaloneTodos[index].isCompleted ? .gruenPrimary : Color.white,
                sekundaerFarbe: gardenStore.standaloneTodos[index].isCompleted ? .gruenPrimary.darker() : Color(white: 0.9),
                groesse: 64,
                isRectangular: true,
                aktion: {
                    withAnimation {
                        gardenStore.standaloneTodos[index].isCompleted.toggle()
                        GoalStore.shared.logTodoCompletion(habitId: "standalone", priority: gardenStore.standaloneTodos[index].priority, isCompleted: gardenStore.standaloneTodos[index].isCompleted)
                        gardenStore.saveStandaloneTodos()
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                }
            ) {
                HStack {
                    Button {
                        withAnimation {
                            gardenStore.standaloneTodos[index].priority.next()
                            gardenStore.saveStandaloneTodos()
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    } label: {
                        Text(gardenStore.standaloneTodos[index].priority.icon)
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(gardenStore.standaloneTodos[index].priority.color)
                    }
                    
                    Image(systemName: gardenStore.standaloneTodos[index].isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 24))
                        .foregroundStyle(gardenStore.standaloneTodos[index].isCompleted ? Color.white : Color.gray)
                    
                    Text(gardenStore.standaloneTodos[index].text)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .strikethrough(gardenStore.standaloneTodos[index].isCompleted)
                        .foregroundColor(gardenStore.standaloneTodos[index].isCompleted ? Color.white.opacity(0.8) : .primary)
                    
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
                        if let idx = gardenStore.standaloneTodos.firstIndex(where: { $0.id == todoId }) {
                            gardenStore.standaloneTodos.remove(at: idx)
                            gardenStore.saveStandaloneTodos()
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
                    Text(String(localized: "todos.tab.select_plant_optional", defaultValue: "Für welche Gewohnheit? (Optional)"))
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
                    let trimmed = todoText.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    
                    let newTodo = FocusGoal(text: trimmed)
                    
                    if let selected = selectedPlant {
                        selected.todos.append(newTodo)
                        gardenStore.savePlants()
                    } else {
                        gardenStore.standaloneTodos.append(newTodo)
                        // saveStandaloneTodos() is called via property observer
                    }
                    
                    gardenStore.objectWillChange.send()
                    dismiss()
                } label: {
                    Text(String(localized: "common.save", defaultValue: "Speichern"))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .frame(height: 24)
                }
                .buttonStyle(DuolingoButtonStyle(size: .medium, fillWidth: true, backgroundColor: .black, shadowColor: Color.black.opacity(0.8), foregroundColor: .white))
                .disabled(todoText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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


