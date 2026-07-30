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
    @State private var localOverrides: [String: GoalWeight] = [:]
    @State private var localFrequencyOverrides: [String: Int] = [:]
    
    private var isEditing: Bool { existingGoal != nil }
    
    private func currentWeight(for habitId: String) -> GoalWeight {
        if let w = localOverrides[habitId] { return w }
        guard let goal = existingGoal else { return .none }
        return goalStore.weightForHabit(habitId: habitId, goalId: goal.id) ?? .none
    }
    
    private func currentFrequency(for habitId: String) -> Int {
        if let f = localFrequencyOverrides[habitId] { return f }
        guard let goal = existingGoal else { return 7 }
        return goalStore.frequencyForHabit(habitId: habitId, goalId: goal.id) ?? 7
    }
    
    private var totalPoints: Int {
        var maxPointsPerWeek = 0
        for habit in gardenStore.pflanzen {
            let weight = currentWeight(for: habit.id)
            if weight != .none {
                let frequency = currentFrequency(for: habit.id)
                maxPointsPerWeek += (weight.rawValue * frequency)
            }
        }
        
        switch type {
        case .week: return maxPointsPerWeek
        case .month: return Int(Double(maxPointsPerWeek) * (52.0 / 12.0))
        case .year: return maxPointsPerWeek * 52 * 5
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: HStack {
                    Text(goalPrompt)
                    Spacer()
                    if totalPoints > 0 {
                        Text("\(String(localized: "goal.edit.targetLabel", defaultValue: "Ziel:")) \(totalPoints) \(String(localized: "goal.edit.pointsLabel", defaultValue: "Pkt."))")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.primary)
                            .textCase(.none)
                    }
                }) {
                    TextField(goalPlaceholder, text: $editTitle)
                        .font(.system(size: 16, weight: .semibold))
                }
                
                // Gewohnheits-Verknüpfung nur für Jahres- und Wochenziele
                if (type == .year || type == .week) && !gardenStore.pflanzen.filter({ !$0.isDead && !$0.isNegative }).isEmpty {
                    Section(header: Text(String(localized: "goal.link.title", defaultValue: "Ziel-Beitrag"))) {
                        ForEach(gardenStore.pflanzen.filter { !$0.isDead && !$0.isNegative }) { habit in
                            HabitWeightRow(
                                habit: habit,
                                selectedWeight: currentWeight(for: habit.id),
                                selectedFrequency: currentFrequency(for: habit.id),
                                onSelect: { weight in
                                    localOverrides[habit.id] = weight
                                },
                                onFrequencyChange: { frequency in
                                    localFrequencyOverrides[habit.id] = frequency
                                }
                            )
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
        for habit in gardenStore.pflanzen {
            let finalWeight: GoalWeight
            if let override = localOverrides[habit.id] {
                finalWeight = override
            } else if let existing = existingGoal {
                finalWeight = goalStore.weightForHabit(habitId: habit.id, goalId: existing.id) ?? .none
            } else {
                finalWeight = .none
            }
            
            let finalFrequency: Int?
            if finalWeight == .none {
                finalFrequency = nil
            } else if let fOverride = localFrequencyOverrides[habit.id] {
                finalFrequency = fOverride
            } else if let existing = existingGoal {
                finalFrequency = goalStore.frequencyForHabit(habitId: habit.id, goalId: existing.id)
            } else {
                finalFrequency = nil
            }
            
            // Only update if not none or if we are actively setting it
            if finalWeight != .none || localOverrides[habit.id] != nil {
                goalStore.linkHabitToGoal(habitId: habit.id, goalId: goalId, weight: finalWeight, frequency: finalFrequency)
            }
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
    let selectedWeight: GoalWeight
    let selectedFrequency: Int
    let onSelect: (GoalWeight) -> Void
    let onFrequencyChange: (Int) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(habit.localizedHabitName)
                .font(.system(size: 15, weight: .semibold))
            
            HStack(spacing: 8) {
                ForEach([GoalWeight.massive, .bit, .none], id: \.self) { weight in
                    let baseColor: Color = weight == .massive ? .green : (weight == .bit ? .orange : .red)
                    let isSelected = selectedWeight == weight
                    
                    Item3DButton(
                        farbe: isSelected ? baseColor : Color(UIColor.systemGray5),
                        sekundaerFarbe: isSelected ? baseColor.darker() : Color(UIColor.systemGray4),
                        groesse: 40,
                        isRectangular: true,
                        aktion: { onSelect(weight) }
                    ) {
                        Text(weight == .massive ? "20 Pkt" : (weight == .bit ? "5 Pkt" : "0 Pkt"))
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(isSelected ? .white : baseColor)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                }
            }
            
            if selectedWeight != .none {
                HStack {
                    Text(String(localized: "goal.frequency.label", defaultValue: "Häufigkeit pro Woche:"))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                    Spacer()
                    Stepper(value: Binding(
                        get: { selectedFrequency },
                        set: { onFrequencyChange($0) }
                    ), in: 1...7) {
                        Text("\(selectedFrequency)x")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .fixedSize() // Verhindert Umbruch
                    }
                    .fixedSize() // Stepper nimmt nur den benötigten Platz ein
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 4)
    }
}
