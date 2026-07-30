import SwiftUI
import UniformTypeIdentifiers

struct GoalDropDelegate: DropDelegate {
    let item: FocusGoal
    @Binding var items: [FocusGoal]
    @Binding var draggedItem: FocusGoal?

    func dropEntered(info: DropInfo) {
        guard let draggedItem,
              draggedItem != item,
              let from = items.firstIndex(of: draggedItem),
              let to = items.firstIndex(of: item) else { return }

        withAnimation(.default) {
            items.move(fromOffsets: IndexSet(integer: from),
                       toOffset: to > from ? to + 1 : to)
        }
    }

    func performDrop(info: DropInfo) -> Bool {
        draggedItem = nil
        return true
    }
}


struct FocusSubtask: Identifiable, Equatable, Codable {
    var id = UUID()
    var text: String
    var isCompleted: Bool = false
}

struct FocusGoal: Identifiable, Equatable, Codable {
    var id = UUID()
    var text: String
    var priority: GoalPriority = .medium
    var subtasks: [FocusSubtask] = []
    
    var _isCompleted: Bool = false
    
    var isCompleted: Bool {
        get {
            if subtasks.isEmpty { return _isCompleted }
            return subtasks.allSatisfy { $0.isCompleted }
        }
        set {
            if subtasks.isEmpty { _isCompleted = newValue }
        }
    }
    
    mutating func cyclePriority() {
        switch priority {
        case .low: priority = .medium
        case .medium: priority = .high
        case .high: priority = .low
        }
    }
}

struct SubtaskInputField: View {
    @Binding var goal: FocusGoal
    @State private var text: String = ""
    @EnvironmentObject var settings: SettingsStore
    
    var body: some View {
        HStack {
            Image(systemName: "plus")
                .foregroundStyle(.secondary)
                .padding(.leading, 8)
            TextField(String(localized: "focus.session.subgoal.add", defaultValue: "Unterziel hinzufügen..."), text: $text)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .submitLabel(.done)
                .onSubmit {
                    if !text.trimmingCharacters(in: .whitespaces).isEmpty {
                        withAnimation {
                            goal.subtasks.append(FocusSubtask(text: text.trimmingCharacters(in: .whitespaces)))
                            text = ""
                        }
                    }
                }
        }
    }
}

struct FocusSessionPreparationStep: View {
    let iconName: String
    let title: String
    let description: String
    let buttonText: String
    let isLastStep: Bool
    var showTextInput: Bool = false
    var habitCategory: HabitCategory? = nil
    /// Nur für den Handy-Step: wird aufgerufen, wenn der Nutzer eine Wahl getroffen hat
    @Binding var textInput: String
    @Binding var goals: [FocusGoal]
    let action: () -> Void
    
    @State private var draggedGoal: FocusGoal?
    
    @EnvironmentObject var settings: SettingsStore
    
    private func suggestions(for category: HabitCategory?) -> [String] {
        switch category {
        case .fitness: return [
            String(localized: "focus.suggestion.fitness.stretch", defaultValue: "10 Min Dehnen"),
            String(localized: "focus.suggestion.fitness.warmup", defaultValue: "Workout aufwärmen"),
            String(localized: "focus.suggestion.fitness.gear", defaultValue: "Ausrüstung richten")
        ]
        case .health: return [
            String(localized: "focus.suggestion.health.water", defaultValue: "Wasser trinken"),
            String(localized: "focus.suggestion.health.mealplan", defaultValue: "Gesundes Rezept planen"),
            String(localized: "focus.suggestion.health.diary", defaultValue: "Ernährungstagebuch")
        ]
        case .mental: return [
            String(localized: "focus.suggestion.mental.breathing", defaultValue: "Tiefes Atmen"),
            String(localized: "focus.suggestion.mental.journaling", defaultValue: "Journaling"),
            String(localized: "focus.suggestion.mental.meditation", defaultValue: "Meditation starten")
        ]
        case .growth: return [
            String(localized: "focus.suggestion.growth.read", defaultValue: "1 Kapitel lesen"),
            String(localized: "focus.suggestion.growth.vocab", defaultValue: "Vokabeln wiederholen"),
            String(localized: "focus.suggestion.growth.summary", defaultValue: "Zusammenfassung schreiben")
        ]
        case .lifestyle: return [
            String(localized: "focus.suggestion.lifestyle.cleanup", defaultValue: "Zimmer aufräumen"),
            String(localized: "focus.suggestion.lifestyle.waterplants", defaultValue: "Pflanzen gießen"),
            String(localized: "focus.suggestion.lifestyle.weeklyplan", defaultValue: "Wochenplan erstellen")
        ]
        case .finance: return [
            String(localized: "focus.suggestion.finance.track", defaultValue: "Ausgaben tracken"),
            String(localized: "focus.suggestion.finance.budget", defaultValue: "Budget überprüfen"),
            String(localized: "focus.suggestion.finance.bills", defaultValue: "Rechnungen bezahlen")
        ]
        case .seeds: return []
        case .none: return [
            String(localized: "focus.suggestion.none.focus", defaultValue: "Fokus setzen"),
            String(localized: "focus.suggestion.none.dnd", defaultValue: "Handy weglegen"),
            String(localized: "focus.suggestion.none.no_distractions", defaultValue: "Ablenkungen blockieren")
        ]
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    Image(iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: (iconName == "Handy" || iconName == "Goal") ? 300 : 100, height: (iconName == "Handy" || iconName == "Goal") ? 300 : 100)
                        .padding(.top, 40)
                        .padding(.bottom, (iconName == "Handy" || iconName == "Goal") ? -40 : 0)
            
            // Texte
            VStack(spacing: 16) {
                Text(title)
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                if showTextInput {
                    VStack(spacing: 16) {
                        // Vorschläge Chips (ABOVE text input)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                let unusedSuggestions = suggestions(for: habitCategory).filter { suggestion in
                                    !goals.contains(where: { $0.text == suggestion })
                                }
                                ForEach(unusedSuggestions, id: \.self) { suggestion in
                                    Button {
                                        withAnimation {
                                            goals.append(FocusGoal(text: suggestion))
                                        }
                                    } label: {
                                        Text(suggestion)
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(.ultraThinMaterial)
                                            .foregroundStyle(Color.goldPrimary)
                                            .cornerRadius(20)
                                    }
                                }
                            }
                            .padding(.horizontal, 32)
                        }
                        
                        // Eingabefeld
                        HStack {
                            TextField(String(localized: "focus.session.task.placeholder", defaultValue: "Neue Aufgabe..."), text: $textInput)
                                .padding()
                                .background(.ultraThinMaterial)
                                .cornerRadius(12)
                                .submitLabel(.done)
                                .onSubmit {
                                    addGoal()
                                }
                            
                            Button(action: addGoal) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundStyle(textInput.isEmpty ? Color.gray : Color.goldPrimary)
                            }
                            .disabled(textInput.isEmpty)
                        }
                        .padding(.horizontal, 32)
                        
                        // Aktuelle Ziele
                        if !goals.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                    ForEach($goals) { $goal in
                                        VStack(alignment: .leading, spacing: 12) {
                                            HStack {
                                                Image(systemName: "target")
                                                    .foregroundStyle(goal.priority.color)
                                                
                                                Text(goal.text)
                                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                                
                                                Spacer()
                                                
                                                Button {
                                                    withAnimation {
                                                        goal.cyclePriority()
                                                    }
                                                } label: {
                                                    HStack(spacing: 4) {
                                                        Image(systemName: "exclamationmark.circle.fill")
                                                        Text(goal.priority.displayName)
                                                    }
                                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .foregroundStyle(goal.priority.color)
                                                    .background(goal.priority.color.opacity(0.15))
                                                    .cornerRadius(8)
                                                }
                                                .buttonStyle(.plain)
                                                
                                                Button {
                                                    if let index = goals.firstIndex(where: { $0.id == goal.id }) {
                                                        _ = withAnimation { goals.remove(at: index) }
                                                    }
                                                } label: {
                                                    Image(systemName: "trash")
                                                        .foregroundStyle(.red.opacity(0.7))
                                                }
                                            }
                                            
                                            // Unterziele
                                            ForEach($goal.subtasks) { $subtask in
                                                HStack {
                                                    Image(systemName: "arrow.turn.down.right")
                                                        .foregroundStyle(.secondary)
                                                        .padding(.leading, 8)
                                                    
                                                    Text(subtask.text)
                                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                                        .foregroundStyle(.secondary)
                                                    
                                                    Spacer()
                                                    
                                                    Button {
                                                        if let index = goal.subtasks.firstIndex(where: { $0.id == subtask.id }) {
                                                            _ = withAnimation { goal.subtasks.remove(at: index) }
                                                        }
                                                    } label: {
                                                        Image(systemName: "xmark")
                                                            .foregroundStyle(.red.opacity(0.7))
                                                    }
                                                }
                                            }
                                            
                                            // Unterziel hinzufügen
                                            SubtaskInputField(goal: $goal)
                                        }
                                        .padding()
                                        .background(.ultraThinMaterial)
                                        .cornerRadius(12)
                                    }
                                }
                                .padding(.horizontal, 32)
                                .padding(.top, 8)
                        }
                    }
                    .padding(.top, 8)
                }
            }
            }
            .padding(.bottom, 24)
        }
        
        // Weiter-Button
        Button(action: action) {
            Text(buttonText)
        }
            .buttonStyle(DuolingoButtonStyle(
                size: .large,
                fillWidth: true,
                backgroundColor: .goldPrimary,
                shadowColor: .goldPrimary.darker(),
                foregroundColor: .white
            ))
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
            .padding(.top, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground).ignoresSafeArea())
    }
    
    private func addGoal() {
        guard !textInput.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let newGoal = FocusGoal(text: textInput.trimmingCharacters(in: .whitespaces))
        withAnimation {
            goals.append(newGoal)
            textInput = ""
        }
    }
}
