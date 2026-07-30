import SwiftUI

/// Universelles Edit-Sheet für alle Zieltypen (Jahr, Monat, Woche)
/// Erstellt ein neues Ziel ODER updated ein bestehendes.
struct GoalEditSheet: View {
    let existingGoal: GoalModel?
    let type: GoalType
    @Binding var editTitle: String
    let goalStore: GoalStore
    @EnvironmentObject var gardenStore: GardenStore
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedWeights: [String: GoalWeight] = [:]
    
    private var isEditing: Bool { existingGoal != nil }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(goalPrompt)) {
                    TextField(goalPlaceholder, text: $editTitle)
                        .font(.system(size: 16, weight: .semibold))
                }
                
                // Gewohnheits-Verknüpfung nur für Jahres- und Wochenziele
                if (type == .year || type == .week) && !gardenStore.pflanzen.filter({ !$0.isDead && !$0.isNegative }).isEmpty {
                    Section(header: Text(String(localized: "goal.link.title", defaultValue: "Ziel-Beitrag"))) {
                        ForEach(gardenStore.pflanzen.filter { !$0.isDead && !$0.isNegative }) { habit in
                            HabitWeightRow(habit: habit, selectedWeight: Binding(
                                get: { selectedWeights[habit.id] ?? .none },
                                set: { selectedWeights[habit.id] = $0 }
                            ))
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? String(localized: "goal.edit.title", defaultValue: "Ziel bearbeiten") : goalAddTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "common.cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "common.save")) {
                        saveGoal()
                    }
                    .disabled(editTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                    .fontWeight(.bold)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .onAppear {
            loadExistingWeights()
        }
    }
    
    private func loadExistingWeights() {
        guard let goal = existingGoal else { return }
        for link in goalStore.habitLinks where link.goalId == goal.id {
            selectedWeights[link.habitId] = link.weight
        }
    }
    
    private func saveGoal() {
        let title = editTitle.trimmingCharacters(in: .whitespaces)
        guard !title.isEmpty else { return }
        
        let goalId: UUID
        if var existing = existingGoal {
            existing.title = title
            goalStore.updateGoal(existing)
            goalId = existing.id
        } else {
            let newGoal = GoalModel(title: title, type: type)
            goalStore.addGoal(newGoal)
            goalId = newGoal.id
        }
        
        // Save habit weights
        for (habitId, weight) in selectedWeights {
            goalStore.linkHabitToGoal(habitId: habitId, goalId: goalId, weight: weight)
        }
        
        dismiss()
    }
    
    private var goalPrompt: String {
        switch type {
        case .year: return String(localized: "goal.tree.prompt.year", defaultValue: "Deine große Vision für die nächsten 5 Jahre")
        case .month: return String(localized: "goal.tree.prompt.month", defaultValue: "Dein Fokus diesen Monat")
        case .week: return String(localized: "goal.tree.prompt.week", defaultValue: "Dein wichtigstes Ziel diese Woche")
        }
    }
    
    private var goalPlaceholder: String {
        switch type {
        case .year: return String(localized: "goal.tree.placeholder.year", defaultValue: "Z.B. 10 Mio. Umsatz aufbauen")
        case .month: return String(localized: "goal.tree.placeholder.month", defaultValue: "Z.B. 300 Punkte erreichen")
        case .week: return String(localized: "goal.tree.placeholder.week", defaultValue: "Z.B. 3x ins Gym gehen")
        }
    }
    
    private var goalAddTitle: String {
        switch type {
        case .year: return String(localized: "goal.year.add", defaultValue: "5-Jahresziel festlegen")
        case .month: return String(localized: "goal.monthly.add", defaultValue: "Monatsziel setzen")
        case .week: return String(localized: "goal.weekly.add", defaultValue: "Wochenziel festlegen")
        }
    }
}

// MARK: - Habit Weight Row
struct HabitWeightRow: View {
    let habit: HabitModel
    @Binding var selectedWeight: GoalWeight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(habit.name)
                .font(.system(size: 15, weight: .semibold))
            
            HStack(spacing: 8) {
                ForEach([GoalWeight.massive, .bit, .none], id: \.self) { weight in
                    let baseColor: Color = weight == .massive ? .green : (weight == .bit ? .orange : .red)
                    let isSelected = selectedWeight == weight
                    
                    Button {
                        selectedWeight = weight
                    } label: {
                        Text(weight == .massive ? "20 Pkt" : (weight == .bit ? "5 Pkt" : "0 Pkt"))
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(isSelected ? .white : baseColor)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(isSelected ? baseColor : baseColor.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
