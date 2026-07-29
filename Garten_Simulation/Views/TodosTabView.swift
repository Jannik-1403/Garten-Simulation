import SwiftUI

struct TodosTabView: View {
    @EnvironmentObject var gardenStore: GardenStore
    
    @State private var showingAddTodoSheet = false
    @State private var selectedPlantForTodo: HabitModel?
    @State private var todoToEditIndex: Int? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appHintergrund.ignoresSafeArea()
                
                if alleTodosEmpty() {
                    VStack(spacing: 16) {
                        Image(systemName: "checklist")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        Text(String(localized: "todos.tab.empty", defaultValue: "Keine offenen To-Dos."))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        Button {
                            showingAddTodoSheet = true
                        } label: {
                            Text(String(localized: "plant.detail.todo.add", defaultValue: "To-Do hinzufügen"))
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .frame(height: 24)
                                .padding(.horizontal, 24)
                        }
                        .buttonStyle(DuolingoButtonStyle(size: .medium, fillWidth: false, backgroundColor: .black, shadowColor: Color.black.opacity(0.8), foregroundColor: .white))
                    }
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
                                            ForEach(pflanze.todos.indices.sorted { pflanze.todos[$0].priority.sortValue < pflanze.todos[$1].priority.sortValue }, id: \.self) { index in
                                                TodoRowView(
                                                    pflanze: pflanze,
                                                    index: index,
                                                    onEdit: {
                                                        selectedPlantForTodo = pflanze
                                                        todoToEditIndex = index
                                                        showingAddTodoSheet = true
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
            }
            .navigationTitle(String(localized: "tab.todos", defaultValue: "To-Dos"))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        selectedPlantForTodo = nil
                        todoToEditIndex = nil
                        showingAddTodoSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
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
        return gardenStore.pflanzen.allSatisfy { $0.todos.isEmpty }
    }
}

struct TodoRowView: View {
    @ObservedObject var pflanze: HabitModel
    let index: Int
    let onEdit: () -> Void
    @EnvironmentObject var gardenStore: GardenStore
    
    var body: some View {
        Item3DButton(
            farbe: pflanze.todos[index].isCompleted ? .gruenPrimary : Color.white,
            sekundaerFarbe: pflanze.todos[index].isCompleted ? .gruenPrimary.darker() : Color(white: 0.9),
            groesse: 64,
            isRectangular: true,
            aktion: {
                withAnimation {
                    pflanze.todos[index].isCompleted.toggle()
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
                    pflanze.todos.remove(at: index)
                    gardenStore.savePlants()
                }
            } label: {
                Label(String(localized: "button.delete", defaultValue: "Löschen"), systemImage: "trash")
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
                        HStack(spacing: 12) {
                            ForEach(gardenStore.pflanzen) { pflanze in
                                Button {
                                    selectedPlant = pflanze
                                } label: {
                                    VStack(spacing: 8) {
                                        ZStack {
                                            Circle()
                                                .fill(selectedPlant?.id == pflanze.id ? Color.gruenPrimary.opacity(0.2) : Color.primary.opacity(0.05))
                                                .frame(width: 60, height: 60)
                                            
                                            Image(systemName: pflanze.symbolName)
                                                .font(.system(size: 24))
                                                .foregroundColor(Color(hex: pflanze.symbolColor))
                                        }
                                        .overlay(
                                            Circle()
                                                .stroke(selectedPlant?.id == pflanze.id ? Color.gruenPrimary : Color.clear, lineWidth: 2)
                                        )
                                        
                                        Text(NSLocalizedString(pflanze.displayedHabitName, comment: ""))
                                            .font(.system(size: 10, weight: .bold, design: .rounded))
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                            .frame(width: 70)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                    }
                }
                
                // Text Editor
                TextEditor(text: $todoText)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .scrollContentBackground(.hidden)
                    .padding(16)
                    .frame(minHeight: 140)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.primary.opacity(0.04))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                    )
                    .overlay(alignment: .topLeading) {
                        if todoText.isEmpty {
                            Text(String(localized: "plant.detail.todo.placeholder", defaultValue: "To-Do eingeben..."))
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundStyle(.tertiary)
                                .padding(20)
                                .allowsHitTesting(false)
                        }
                    }
                
                Spacer()
                
                Button {
                    guard let selected = selectedPlant else { return }
                    let trimmed = todoText.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    
                    let newTodo = FocusGoal(text: trimmed)
                    selected.todos.append(newTodo)
                    gardenStore.savePlants()
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

