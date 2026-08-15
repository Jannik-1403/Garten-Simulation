import SwiftUI

struct OnboardingZielView: View {
    @EnvironmentObject var data: OnboardingData
    @EnvironmentObject var settings: SettingsStore

    private let maxAuswahl = 3

    var body: some View {
        VStack(spacing: 0) {
            OnboardingIgelView(
                pose: data.customZiel.isEmpty ? .fragt : .daumenHoch,
                sprechblasenText: String(localized: "onboarding_ziel_blase")
            )
            .padding(.top, 20)

            Spacer()

            VStack(spacing: 24) {
                Text(String(localized: "onboarding_ziel_titel"))
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)

                TextField(String(localized: "onboarding_ziel_placeholder"), text: $data.customZiel)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 24)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(data.customZiel.isEmpty ? Color.clear : Color.blauPrimary, lineWidth: 3)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal, 32)

            Spacer()

            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                FeedbackManager.shared.playTap()
                withAnimation(.easeInOut(duration: 0.35)) {
                    data.currentStep += 1
                }
            } label: {
                Text(String(localized: "onboarding_weiter"))
            }
            .buttonStyle(DuolingoButtonStyle(
                size: .large,
                backgroundColor: Color.blauPrimary,
                shadowColor: Color.blauPrimary.darker(),
                foregroundColor: .white
            ))
            .disabled(data.customZiel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
