import SwiftUI

struct GoalOnboardingView: View {
    @EnvironmentObject var data: OnboardingData
    @State private var goalText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            OnboardingIgelView(
                pose: goalText.isEmpty ? .fragt : .daumenHoch,
                sprechblasenText: String(localized: "onboarding.goal.5year.title", defaultValue: "Was ist dein wichtigstes 5-Jahresziel?")
            )
            .padding(.top, 20)
            
            VStack(spacing: 24) {
                TextField(String(localized: "goal.custom.5year.placeholder", defaultValue: "Mein 5-Jahresziel (z. B. Abnehmen)"), text: $goalText, axis: .vertical)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .contentShape(Rectangle())
                    .item3DContainer(farbe: .white, sekundaerFarbe: Color(UIColor.systemGray5))
            }
            .padding(.horizontal, 32)
            .padding(.top, 24)
            .padding(.bottom, 24)
            
            VStack {
                Item3DButton(
                    farbe: goalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color(UIColor.systemGray4) : .blauPrimary,
                    sekundaerFarbe: goalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color(UIColor.systemGray5) : .blauPrimary.darker(),
                    groesse: 50,
                    isRectangular: true,
                    aktion: {
                        if !goalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            saveGoal(title: goalText.trimmingCharacters(in: .whitespacesAndNewlines))
                            advanceStep()
                        }
                    }
                ) {
                    Text(String(localized: "button.continue", defaultValue: "Weiter"))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(goalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .white)
                        .frame(maxWidth: .infinity)
                }
                .disabled(goalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 30)
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    private func saveGoal(title: String) {
        data.customZiel = title
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
