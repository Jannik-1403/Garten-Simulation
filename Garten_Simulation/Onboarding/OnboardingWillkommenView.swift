import SwiftUI

struct OnboardingWillkommenView: View {
    @EnvironmentObject var data: OnboardingData
    @EnvironmentObject var settings: SettingsStore
    @State private var showContent = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            if showContent {
                OnboardingIgelView(
                    pose: .winkt,
                    sprechblasenText: settings.localizedString(for: "onboarding_willkommen_blase")
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                
                VStack(spacing: 8) {
                    Text(settings.localizedString(for: "onboarding_willkommen_titel"))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.primary)
                    
                    Text(settings.localizedString(for: "onboarding_willkommen_untertitel"))
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .padding(.top, 40)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            Spacer()
            
            if showContent {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    withAnimation(.easeInOut(duration: 0.35)) {
                        data.currentStep += 1
                    }
                } label: {
                    Text(settings.localizedString(for: "onboarding_los_gehts"))
                }
                .buttonStyle(DuolingoButtonStyle(
                    size: .large,
                    backgroundColor: Color.blauPrimary,
                    shadowColor: Color.blauPrimary.darker(),
                    foregroundColor: .white
                ))
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                showContent = true
            }
        }
    }
}
