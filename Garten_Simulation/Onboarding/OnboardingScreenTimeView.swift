import SwiftUI

struct OnboardingScreenTimeView: View {
    @EnvironmentObject var data: OnboardingData
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showContinueButton = false
    
    var body: some View {
        ZStack {
            // Top and Bottom Elements
            VStack(spacing: 0) {
                OnboardingIgelView(
                    pose: .erklaert,
                    sprechblasenText: String(localized: "onboarding_screentime_bubble_title", defaultValue: "Damit ich dir helfen kann, fokussiert zu bleiben, brauche ich Zugriff auf die Bildschirmzeit!")
                )
                .padding(.top, 20)
                
                Spacer()
                
                if showContinueButton {
                    Button {
                        finish()
                    } label: {
                        Text(String(localized: "onboarding_screentime_continue", defaultValue: "Weiter"))
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
                } else {
                    Spacer().frame(height: 104) // To keep the layout stable before the button appears (approximate height of button + padding)
                }
            }
            
            // Mock iOS Screen Time Permission Alert - Perfectly centered
            VStack(spacing: 16) {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text(String(localized: "onboarding_screentime_mock_title", defaultValue: "\"Grovy\" möchte auf die Bildschirmzeit zugreifen"))
                            .font(.system(size: 20, weight: .bold))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(String(localized: "onboarding_screentime_mock_desc", defaultValue: "Dies ermöglicht es der App, deine Bildschirmzeit-Daten zu verwenden, um dir bei der Konzentration zu helfen."))
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(Color.secondary)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.top, 24)
                    .padding(.horizontal, 24)
                    
                    HStack(spacing: 12) {
                        Button {
                            handleAllow() // Left button is now "Continue" (Allow)
                        } label: {
                            Text(String(localized: "onboarding_screentime_mock_allow", defaultValue: "Continue"))
                                .font(.system(size: 17, weight: .medium))
                                .foregroundStyle(.primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(colorScheme == .dark ? Color(white: 0.25) : Color(white: 0.88))
                                .clipShape(Capsule())
                        }
                        
                        Button {
                            handleDeny() // Right button is now "Don't Allow"
                        } label: {
                            Text(String(localized: "onboarding_screentime_mock_dont_allow", defaultValue: "Don't Allow"))
                                .font(.system(size: 17, weight: .medium))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.blue)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
                .background(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(colorScheme == .dark ? Color(white: 0.15) : Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
                )
                .frame(width: 320) // Make it slightly smaller/more compact on the sides
                
                if !showContinueButton {
                    // Arrow pointing up to "Continue" (Left Button)
                    Item3DButton(
                        farbe: Color.blauPrimary,
                        sekundaerFarbe: Color.blauPrimary.darker(),
                        groesse: 56,
                        iconSkalierung: 0.5,
                        aktion: {
                            handleAllow()
                        }
                    ) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .padding(.trailing, 150) // Move to the left side (under "Continue")
                } else {
                    Spacer().frame(height: 56) // To keep layout stable
                }
            }
        }
    }
    
    private func handleDeny() {
        FeedbackManager.shared.playTap()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showContinueButton = true
        }
    }
    
    private func handleAllow() {
        FeedbackManager.shared.playTap()
        
        Task {
            // Request native screen time permission
            await ScreenTimeManager.shared.requestAuthorization()
            
            await MainActor.run {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showContinueButton = true
                }
            }
        }
    }
    
    private func finish() {
        FeedbackManager.shared.playTap()
        
        withAnimation(.easeInOut(duration: 0.35)) {
            data.currentStep += 1
        }
    }
}

#Preview {
    OnboardingScreenTimeView()
        .environmentObject(OnboardingData())
}
