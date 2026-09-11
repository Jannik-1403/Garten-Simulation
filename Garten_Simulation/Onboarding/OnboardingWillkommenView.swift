import SwiftUI

struct OnboardingWillkommenView: View {
    @EnvironmentObject var data: OnboardingData
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.horizontalSizeClass) var hSize
    @State private var showContent = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            if showContent {
                OnboardingIgelView(
                    pose: .winkt,
                    sprechblasenText: String(localized: "onboarding_willkommen_blase")
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                
                    Text(String(localized: "onboarding_willkommen_untertitel"))
                        .font(.system(size: hSize == .regular ? 44 : 34, weight: .heavy, design: .rounded))
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.center)
                .padding(.top, 40)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            Spacer()
            
            if showContent {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    FeedbackManager.shared.playTap()
                    withAnimation(.easeInOut(duration: 0.35)) {
                        data.currentStep += 1
                    }
                } label: {
                    Text(String(localized: "onboarding_los_gehts"))
                }
                .buttonStyle(DuolingoButtonStyle(
                    size: .large,
                    backgroundColor: Color.blauPrimary,
                    shadowColor: Color.blauPrimary.darker(),
                    foregroundColor: .white
                ))
                .padding(.bottom, 40)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .frame(maxWidth: 650)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                showContent = true
            }
        }
    }
}
