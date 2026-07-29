import SwiftUI

struct GoalOnboardingView: View {
    @EnvironmentObject var data: OnboardingData
    @State private var selectedGoalId: String? = nil
    @State private var showCustomGoalAlert = false
    @State private var customGoalText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            OnboardingIgelView(
                pose: .fragt,
                sprechblasenText: String(localized: "onboarding.goal.title", defaultValue: "Was ist dein wichtigstes Jahresziel?")
            )
            .padding(.top, 20)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    ForEach(GoalTemplate.yearTemplates, id: \.id) { template in
                        GoalTemplateCard(
                            template: template,
                            isSelected: selectedGoalId == template.id
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                selectedGoalId = template.id
                                saveGoal(template: template)
                                advanceStep()
                            }
                        }
                    }
                    
                    // Custom Goal Button
                    Item3DButton(
                        farbe: Color(UIColor.systemGray5),
                        sekundaerFarbe: Color(UIColor.systemGray4),
                        groesse: 44,
                        isRectangular: true,
                        aktion: {
                            showCustomGoalAlert = true
                        }
                    ) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text(String(localized: "goal.template.custom.button", defaultValue: "Eigenes Ziel erstellen"))
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.primary)
                        .padding()
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .alert(String(localized: "goal.template.custom.button", defaultValue: "Eigenes Ziel erstellen"), isPresented: $showCustomGoalAlert) {
            TextField(String(localized: "goal.custom.placeholder", defaultValue: "Mein Jahresziel"), text: $customGoalText)
            Button(String(localized: "button.cancel", defaultValue: "Abbrechen"), role: .cancel) { }
            Button(String(localized: "button.save", defaultValue: "Speichern")) {
                let trimmed = customGoalText.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    let customTemplate = GoalTemplate(id: "custom_\(UUID().uuidString)", titleKey: trimmed, type: .year, suggestedHabitIds: [:])
                    withAnimation {
                        selectedGoalId = customTemplate.id
                        saveGoal(template: customTemplate, isCustom: true)
                        advanceStep()
                    }
                }
            }
        } message: {
            Text(String(localized: "goal.custom.message", defaultValue: "Gib einen kurzen Namen für dein Jahresziel ein."))
        }
    }
    
    private func saveGoal(template: GoalTemplate, isCustom: Bool = false) {
        let title = isCustom ? template.titleKey : NSLocalizedString(template.titleKey, comment: "")
        let newGoal = GoalModel(
            title: title,
            type: .year
        )
        GoalStore.shared.addGoal(newGoal)
    }
    
    private func advanceStep() {
        FeedbackManager.shared.playSuccess()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeInOut(duration: 0.35)) {
                data.currentStep += 1
            }
        }
    }
}

struct GoalTemplateCard: View {
    let template: GoalTemplate
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Item3DButton(
            farbe: isSelected ? Color.blauPrimary : Color(UIColor.systemGray5),
            sekundaerFarbe: isSelected ? Color.blauPrimary.darker() : Color(UIColor.systemGray4),
            groesse: 44,
            isRectangular: true,
            aktion: action
        ) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(NSLocalizedString(template.titleKey, comment: ""))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(isSelected ? .white : .primary)
                }
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.title2)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
    }
}
