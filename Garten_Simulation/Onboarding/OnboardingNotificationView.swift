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
                VStack(spacing: 0) {
                    VStack(spacing: 4) {
                        Text(String(localized: "onboarding_notification_mock_title", defaultValue: "Grovy möchte dir Mitteilungen senden"))
                            .font(.system(size: 17, weight: .semibold))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                            .padding(.top, 20)
                        
                        Text(String(localized: "onboarding_notification_mock_desc", defaultValue: "Mitteilungen können Hinweise, Töne und Symbolzähler sein. Diese können in den Einstellungen konfiguriert werden."))
                            .font(.system(size: 13, weight: .regular))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 20)
                    }
                    
                    Divider()
                    
                    HStack(spacing: 0) {
                        Button {
                            handleDeny()
                        } label: {
                            Text(String(localized: "onboarding_notification_mock_dont_allow", defaultValue: "Nicht erlauben"))
                                .font(.system(size: 17, weight: .regular))
                                .foregroundStyle(.primary)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .contentShape(Rectangle())
                        }
                        
                        Divider()
                        
                        Button {
                            handleAllow()
                        } label: {
                            Text(String(localized: "onboarding_notification_mock_allow", defaultValue: "Erlauben"))
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.blue)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .contentShape(Rectangle())
                        }
                    }
                    .frame(height: 44)
                }
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(colorScheme == .dark ? Color(white: 0.15) : Color(white: 0.95))
                )
                .frame(width: 270)
                
                if !showContinueButton {
                    // Arrow pointing up to "Erlauben"
                    Image(systemName: "arrow.up")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(Color.blauPrimary)
                        .padding(.leading, 135) // Move to the right side (under "Erlauben")
                } else {
                    Spacer().frame(height: 30) // To keep layout stable
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
