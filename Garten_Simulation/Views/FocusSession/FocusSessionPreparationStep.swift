import SwiftUI

enum GoalPriority: String, CaseIterable, Equatable {
    case low = "Niedrig"
    case medium = "Mittel"
    case high = "Hoch"
    
    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .orangePrimary
        case .high: return .red
        }
    }
}

struct FocusSubtask: Identifiable, Equatable {
    let id = UUID()
    var text: String
    var isCompleted: Bool = false
}

struct FocusGoal: Identifiable, Equatable {
    let id = UUID()
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
            TextField(settings.localizedString(for: "Unterziel hinzufügen..."), text: $text)
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
    @Binding var textInput: String
    @Binding var goals: [FocusGoal]
    let action: () -> Void
    
    @EnvironmentObject var settings: SettingsStore
    
    private func suggestions(for category: HabitCategory?) -> [String] {
        switch category {
        case .fitness: return ["10 Min Dehnen", "Workout aufwärmen", "Ausrüstung richten"]
        case .health: return ["Wasser trinken", "Gesundes Rezept planen", "Ernährungstagebuch"]
        case .mental: return ["Tiefes Atmen", "Journaling", "Meditation starten"]
        case .growth: return ["1 Kapitel lesen", "Vokabeln wiederholen", "Zusammenfassung schreiben"]
        case .lifestyle: return ["Zimmer aufräumen", "Pflanzen gießen", "Wochenplan erstellen"]
        case .finance: return ["Ausgaben tracken", "Budget überprüfen", "Rechnungen bezahlen"]
        case .none: return ["Fokus setzen", "Handy weglegen", "Ablenkungen blockieren"]
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
                Text(settings.localizedString(for: title))
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .multilineTextAlignment(.center)
                
                Text(settings.localizedString(for: description))
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
                                        Text(settings.localizedString(for: suggestion))
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
                            TextField(settings.localizedString(for: "Neues Hauptziel..."), text: $textInput)
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
                                                
                                                Text(settings.localizedString(for: goal.text))
                                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                                
                                                Spacer()
                                                
                                                Menu {
                                                    Picker(settings.localizedString(for: "Priorität"), selection: $goal.priority) {
                                                        ForEach(GoalPriority.allCases, id: \.self) { priority in
                                                            Text(settings.localizedString(for: priority.rawValue)).tag(priority)
                                                        }
                                                    }
                                                } label: {
                                                    HStack(spacing: 4) {
                                                        Image(systemName: "exclamationmark.circle.fill")
                                                        Text(settings.localizedString(for: goal.priority.rawValue))
                                                    }
                                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .foregroundStyle(goal.priority.color)
                                                }
                                                
                                                Button {
                                                    if let index = goals.firstIndex(where: { $0.id == goal.id }) {
                                                        withAnimation { goals.remove(at: index) }
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
                                                    
                                                    Text(settings.localizedString(for: subtask.text))
                                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                                        .foregroundStyle(.secondary)
                                                    
                                                    Spacer()
                                                    
                                                    Button {
                                                        if let index = goal.subtasks.firstIndex(where: { $0.id == subtask.id }) {
                                                            withAnimation { goal.subtasks.remove(at: index) }
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
            Text(settings.localizedString(for: buttonText))
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
