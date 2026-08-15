import SwiftUI

struct OnboardingNotificationView: View {
    @EnvironmentObject var data: OnboardingData
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showContinueButton = false
    @State private var isBouncing = false
    
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
                VStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Text(String(localized: "onboarding_notification_mock_title", defaultValue: "\"Grovy\" möchte dir Mitteilungen senden"))
                            .font(.system(size: 20, weight: .bold))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Text(String(localized: "onboarding_notification_mock_desc", defaultValue: "Mitteilungen können Hinweise, Töne und Symbolzähler sein. Diese können in den Einstellungen konfiguriert werden."))
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(Color.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 16)
                    
                    HStack(spacing: 12) {
                        Item3DButton(
                            farbe: colorScheme == .dark ? Color(white: 0.25) : Color(white: 0.88),
                            sekundaerFarbe: colorScheme == .dark ? Color(white: 0.15) : Color(white: 0.75),
                            groesse: 50,
                            isRectangular: true,
                            aktion: handleDeny
                        ) {
                            Text(String(localized: "onboarding_notification_mock_dont_allow", defaultValue: "Nicht erlauben"))
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)
                                .frame(maxWidth: .infinity)
                        }
                        
                        Item3DButton(
                            farbe: .blauPrimary,
                            sekundaerFarbe: .blauPrimary.darker(),
                            groesse: 50,
                            isRectangular: true,
                            aktion: handleAllow
                        ) {
                            Text(String(localized: "onboarding_notification_mock_allow", defaultValue: "Erlauben"))
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
                .padding(.top, -16) // offset the built-in padding from item3DContainer a bit for visual balance
                .item3DContainer(
                    farbe: colorScheme == .dark ? Color(white: 0.15) : .white,
                    sekundaerFarbe: colorScheme == .dark ? Color(white: 0.1) : Color(UIColor.systemGray5)
                )
                .frame(width: 320) // Make it slightly smaller/more compact on the sides
                
                if !showContinueButton {
                    // Arrow pointing up to "Erlauben"
                    Button {
                        handleAllow()
                    } label: {
                        Image(systemName: "arrowshape.up.fill")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundStyle(Color.blauPrimary)
                            .shadow(color: Color.blauPrimary.darker(), radius: 0, x: 0, y: 4)
                            .offset(y: isBouncing ? -10 : 10)
                            .onAppear {
                                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                                    isBouncing = true
                                }
                            }
                    }
                    .buttonStyle(.plain)
                    .padding(.top, -10)
                    .padding(.leading, 140) // Move to the right side (under "Erlauben")
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
