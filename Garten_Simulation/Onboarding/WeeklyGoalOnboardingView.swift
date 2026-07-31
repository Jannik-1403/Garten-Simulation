import SwiftUI

struct WeeklyGoalOnboardingView: View {
    @EnvironmentObject var data: OnboardingData
    @State private var selectedTemplate: GoalTemplate? = nil
    @State private var showCustomGoalAlert = false
    @State private var customGoalText = ""
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                OnboardingIgelView(
                    pose: .fragt,
                    sprechblasenText: String(localized: "onboarding.goal.week.title", defaultValue: "Was ist ein Ziel für diese Woche?")
                )
                .padding(.top, 20)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(GoalTemplate.weekTemplates, id: \.id) { template in
                            GoalTemplateCard(
                                template: template,
                                isSelected: selectedTemplate?.id == template.id
                            ) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    selectedTemplate = template
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
                                withAnimation {
                                    showCustomGoalAlert = true
                                }
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
                    .padding(.bottom, 20)
                }
                
                if let template = selectedTemplate {
                    VStack {
                        Item3DButton(
                            farbe: .blauPrimary,
                            sekundaerFarbe: .blauPrimary.darker(),
                            groesse: 50,
                            isRectangular: true,
                            aktion: {
                                saveGoal(template: template, isCustom: template.id.starts(with: "custom_"))
                                advanceStep()
                            }
                        ) {
                            Text(String(localized: "button.continue", defaultValue: "Weiter"))
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            
            if showCustomGoalAlert {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation { showCustomGoalAlert = false }
                    }
                
                VStack(spacing: 20) {
                    Text(String(localized: "goal.template.custom.button", defaultValue: "Eigenes Ziel erstellen"))
                        .font(.headline)
                    
                    Text(String(localized: "goal.custom.week.message", defaultValue: "Gib einen kurzen Namen für dein Wochenziel ein."))
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    TextField(String(localized: "goal.custom.week.placeholder", defaultValue: "Mein Wochenziel"), text: $customGoalText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    HStack(spacing: 16) {
                        Button(action: {
                            withAnimation { showCustomGoalAlert = false }
                        }) {
                            Text(String(localized: "common.cancel", defaultValue: "Abbrechen"))
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(UIColor.systemGray5))
                                .foregroundColor(.primary)
                                .cornerRadius(12)
                        }
                        
                        Button(action: {
                            let trimmed = customGoalText.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !trimmed.isEmpty {
                                let customTemplate = GoalTemplate(id: "custom_\(UUID().uuidString)", titleKey: trimmed, type: .week, suggestedHabitIds: [:])
                                withAnimation {
                                    selectedTemplate = customTemplate
                                    showCustomGoalAlert = false
                                }
                            }
                        }) {
                            Text(String(localized: "common.save", defaultValue: "Speichern"))
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blauPrimary)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(24)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(20)
                .shadow(radius: 20)
                .padding(.horizontal, 40)
            }
        }
    }
    
    private func saveGoal(template: GoalTemplate, isCustom: Bool = false) {
        let title = isCustom ? template.titleKey : NSLocalizedString(template.titleKey, comment: "")
        let newGoal = GoalModel(
            title: title,
            type: .week
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
