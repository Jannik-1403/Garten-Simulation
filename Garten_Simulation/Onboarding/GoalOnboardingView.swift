import SwiftUI

struct GoalOnboardingView: View {
    @EnvironmentObject var data: OnboardingData
    @State private var selectedGoalId: String? = nil
    
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
                            }
                        }
                    }
                    
                    // Custom Goal Button
                    Button(action: {
                        // In einer echten App würde man hier ein Textfeld einblenden
                        let customTemplate = GoalTemplate(id: "custom", titleKey: "goal.template.custom", type: .year, suggestedHabitIds: [:])
                        withAnimation {
                            selectedGoalId = customTemplate.id
                            saveGoal(template: customTemplate)
                        }
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text(String(localized: "goal.template.custom.button", defaultValue: "Eigenes Ziel erstellen"))
                        }
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func saveGoal(template: GoalTemplate) {
        let newGoal = GoalModel(
            title: NSLocalizedString(template.titleKey, comment: ""),
            type: .year
        )
        GoalStore.shared.addGoal(newGoal)
    }
}

struct GoalTemplateCard: View {
    let template: GoalTemplate
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(NSLocalizedString(template.titleKey, comment: ""))
                        .font(.headline)
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
            .background(isSelected ? Color.blue : Color(.systemGray5))
            .cornerRadius(16)
            .shadow(color: isSelected ? Color.blue.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
    }
}
