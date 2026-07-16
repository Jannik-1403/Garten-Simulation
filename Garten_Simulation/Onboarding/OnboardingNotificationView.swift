import SwiftUI

struct OnboardingNotificationView: View {
    @EnvironmentObject var data: OnboardingData
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showContinueButton = false
    
    var body: some View {
        ZStack {
            // Top and Bottom Elements
            VStack(spacing: 0) {
                OnboardingIgelView(
                    pose: .erklaert,
                    sprechblasenText: String(localized: "onboarding_notification_bubble_title", defaultValue: "Ich erinnere dich ans Gießen, damit es zur Gewohnheit wird!")
                )
                .padding(.top, 20)
                
                Spacer()
                
                if showContinueButton {
                    Button {
                        finish()
                    } label: {
                        Text(String(localized: "onboarding_notification_continue", defaultValue: "Weiter"))
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
            
            // Mock iOS Notification Permission Alert - Perfectly centered
            VStack(spacing: 16) {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text(String(localized: "onboarding_notification_mock_title", defaultValue: "\"Grovy\" möchte dir Mitteilungen senden"))
                            .font(.system(size: 20, weight: .bold))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(String(localized: "onboarding_notification_mock_desc", defaultValue: "Mitteilungen können Hinweise, Töne und Symbolzähler sein. Diese können in den Einstellungen konfiguriert werden."))
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(Color.secondary)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.top, 24)
                    .padding(.horizontal, 24)
                    
                    HStack(spacing: 12) {
                        Button {
                            handleDeny()
                        } label: {
                            Text(String(localized: "onboarding_notification_mock_dont_allow", defaultValue: "Nicht erlauben"))
                                .font(.system(size: 17, weight: .medium))
                                .foregroundStyle(.primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(colorScheme == .dark ? Color(white: 0.25) : Color(white: 0.88))
                                .clipShape(Capsule())
                        }
                        
                        Button {
                            handleAllow()
                        } label: {
                            Text(String(localized: "onboarding_notification_mock_allow", defaultValue: "Erlauben"))
                                .font(.system(size: 17, weight: .medium))
                                .foregroundStyle(.primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(colorScheme == .dark ? Color(white: 0.25) : Color(white: 0.88))
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
                .padding(.horizontal, 24)
                
                if !showContinueButton {
                    // Arrow pointing up to "Erlauben"
                    Image(systemName: "arrow.up")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Color.blauPrimary)
                        .padding(.leading, 150) // Move to the right side (under "Erlauben")
                } else {
                    Spacer().frame(height: 28) // To keep layout stable
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
            // Request native permission
            _ = await NotificationManager.shared.requestPermission()
            
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
    OnboardingNotificationView()
        .environmentObject(OnboardingData())
}
