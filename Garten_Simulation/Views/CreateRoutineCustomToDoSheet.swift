import SwiftUI

struct CreateRoutineCustomToDoSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    
    @Binding var selectedHabits: Set<String>
    
    @State private var todoName: String = ""
    @State private var selectedPlantID: String? = nil
    
    var availablePlants: [Plant] {
        GameDatabase.allPlants
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appHintergrund.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        
                        // Name Input
                        VStack(alignment: .leading, spacing: 12) {
                            Text(String(localized: "routine.todo.name", defaultValue: "To-Do Name"))
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)
                            
                            TextField(String(localized: "routine.todo.name.placeholder", defaultValue: "z.B. Müll rausbringen"), text: $todoName)
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .padding(16)
                                .background(Color(white: 0.95))
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        
                        // Plant Icon Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text(String(localized: "routine.todo.icon", defaultValue: "Pflanzen-Icon"))
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)
                                .padding(.horizontal, 24)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 16) {
                                ForEach(availablePlants, id: \.id) { plant in
                                    let isSelected = selectedPlantID == plant.id
                                    
                                    Button {
                                        withAnimation {
                                            selectedPlantID = plant.id
                                        }
                                    } label: {
                                        ZStack {
                                            if isSelected {
                                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                    .fill(Color.green.opacity(0.2))
                                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                    .strokeBorder(Color.green, lineWidth: 3)
                                            } else {
                                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                    .fill(Color(white: 0.95))
                                            }
                                            
                                            Image(plant.assetName ?? plant.symbolName)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 40, height: 40)
                                                .scaleEffect(plant.id == "plant.seeds" ? 0.6 : 1.0)
                                        }
                                        .frame(height: 60)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle(String(localized: "routine.todo.title", defaultValue: "Eigenes To-Do"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "common.cancel", defaultValue: "Abbrechen")) {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "common.save", defaultValue: "Speichern")) {
                        saveToDo()
                    }
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(todoName.isEmpty || selectedPlantID == nil ? .secondary : .primary)
                    .disabled(todoName.isEmpty || selectedPlantID == nil)
                }
            }
            .onAppear {
                if selectedPlantID == nil {
                    selectedPlantID = availablePlants.first?.id
                }
            }
        }
    }
    
    private func saveToDo() {
        guard let plantID = selectedPlantID, let plant = GameDatabase.shared.plant(for: plantID) else { return }
        
        let newHabit = HabitModel(
            name: "habit.custom.todo",
            symbolName: plant.symbolName,
            symbolColor: plant.symbolColor,
            habitCategory: .lifestyle,
            symbolism: plant.symbolism,
            habitName: todoName,
            maxLevel: plant.maxLevel,
            xpPerCompletion: plant.xpPerCompletion,
            waterNeedPerDay: plant.waterNeedPerDay,
            decayDays: plant.decayDays,
            plantID: plant.id,
            isRoutineOnly: true
        )
        
        gardenStore.pflanzen.append(newHabit)
        selectedHabits.insert(newHabit.id)
        dismiss()
    }
}
