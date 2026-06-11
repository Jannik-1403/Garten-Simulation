import SwiftUI

struct FocusGoal: Identifiable, Equatable {
    let id = UUID()
    var text: String
    var isCompleted: Bool = false
}

struct FocusSessionPreparationStep: View {
    let iconName: String
    let title: String
    let description: String
    let buttonText: String
    let isLastStep: Bool
    let showTextInput: Bool
    @Binding var textInput: String
    @Binding var goals: [FocusGoal]
    let action: () -> Void
    
    init(
        iconName: String,
        title: String,
        description: String,
        buttonText: String,
        isLastStep: Bool,
        showTextInput: Bool = false,
        textInput: Binding<String> = .constant(""),
        goals: Binding<[FocusGoal]> = .constant([]),
        action: @escaping () -> Void
    ) {
        self.iconName = iconName
        self.title = title
        self.description = description
        self.buttonText = buttonText
        self.isLastStep = isLastStep
        self.showTextInput = showTextInput
        self._textInput = textInput
        self._goals = goals
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon mit Hintergrund-Kreis
            ZStack {
                Circle()
                    .fill(Color.blauPrimary.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: iconName)
                    .font(.system(size: 50))
                    .foregroundStyle(Color.blauPrimary)
            }
            
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
                    HStack {
                        TextField("Neues Ziel...", text: $textInput)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            .submitLabel(.done)
                            .onSubmit {
                                addGoal()
                            }
                        
                        Button(action: addGoal) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(textInput.isEmpty ? Color.gray : Color.blauPrimary)
                        }
                        .disabled(textInput.isEmpty)
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
                    
                    if !goals.isEmpty {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(goals) { goal in
                                    HStack {
                                        Image(systemName: "circle")
                                            .foregroundStyle(.secondary)
                                        Text(goal.text)
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                        Spacer()
                                        Button {
                                            if let index = goals.firstIndex(where: { $0.id == goal.id }) {
                                                withAnimation {
                                                    goals.remove(at: index)
                                                }
                                            }
                                        } label: {
                                            Image(systemName: "xmark")
                                                .foregroundStyle(.red.opacity(0.7))
                                        }
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.05))
                                    .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal, 32)
                            .padding(.top, 8)
                        }
                        .frame(maxHeight: 150)
                    }
                }
            }
            
            Spacer()
            
            // Weiter-Button
            Button(action: action) {
                Text(buttonText)
            }
            .buttonStyle(DuolingoButtonStyle(
                size: .large,
                fillWidth: true,
                backgroundColor: isLastStep ? .orangePrimary : .blauPrimary,
                shadowColor: isLastStep ? .orangePrimary.darker() : .blauPrimary.darker(),
                foregroundColor: .white
            ))
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
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
