import SwiftUI

struct OnboardingNotificationView: View {
    @EnvironmentObject var data: OnboardingData
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isAnimatingArrow = false
    
    var body: some View {
        VStack(spacing: 0) {
            OnboardingIgelView(
                pose: .erklaert,
                sprechblasenText: String(localized: "onboarding_notification_bubble_title", defaultValue: "Ich erinnere dich ans Gießen, damit es zur Gewohnheit wird!")
            )
            .padding(.top, 20)
            
            Spacer()
            
            // Mock iOS Notification Permission Alert
            VStack(spacing: 16) {
                VStack(spacing: 0) {
                    VStack(spacing: 4) {
                        Text(String(localized: "onboarding_notification_mock_title", defaultValue: "\"Garten\" möchte dir Mitteilungen senden"))
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
                        Text(String(localized: "onboarding_notification_mock_dont_allow", defaultValue: "Nicht erlauben"))
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(.blue)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                        
                        Divider()
                        
                        Text(String(localized: "onboarding_notification_mock_allow", defaultValue: "Erlauben"))
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.blue)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(colorScheme == .dark ? Color(white: 0.2) : Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                .frame(width: 270)
                
                // Arrow pointing up to "Erlauben"
                Image(systemName: "arrow.up")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(Color.blauPrimary)
                    .padding(.leading, 135) // Move to the right side (under "Erlauben")
                    .offset(y: isAnimatingArrow ? -5 : 5)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isAnimatingArrow)
                    .onAppear {
                        isAnimatingArrow = true
                    }
            }
            
            Spacer()
            
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
        }
    }
    
    private func finish() {
        FeedbackManager.shared.playTap()
        
        Task {
            // Request Notification Permission
            _ = await NotificationManager.shared.requestPermission()
            
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.35)) {
                    data.currentStep += 1
                }
            }
        }
    }
}

#Preview {
    OnboardingNotificationView()
        .environmentObject(OnboardingData())
}
