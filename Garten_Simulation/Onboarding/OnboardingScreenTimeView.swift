import SwiftUI

struct OnboardingScreenTimeView: View {
    @EnvironmentObject var data: OnboardingData
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showContinueButton = false
    @State private var isBouncing = false
    @State private var errorMessage: String?
    @State private var showErrorAlert = false
    
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
                VStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Text(String(localized: "onboarding_screentime_mock_title", defaultValue: "\"Grovy\" möchte auf die Bildschirmzeit zugreifen"))
                            .font(.system(size: 17, weight: .bold)) // Typically iOS permission titles are bold and size 17
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Text(String(localized: "onboarding_screentime_mock_desc", defaultValue: "Wenn du \"Grovy\" Zugriff auf die Bildschirmzeit gewährst, kann die App deine Aktivitätsdaten sehen, Inhalte beschränken und die Nutzung von Apps und Websites limitieren."))
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 2)
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
                            Text(String(localized: "onboarding_screentime_mock_dont_allow", defaultValue: "Nicht erlauben"))
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
                            Text(String(localized: "onboarding_screentime_mock_allow", defaultValue: "Weiter"))
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
                .frame(width: 270) // iOS standard alert width is 270
                
                if !showContinueButton {
                    // Arrow pointing up to "Continue" (Left Button)
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
                    .padding(.trailing, 110) // Move to the left side (under "Continue")
                } else {
                    Spacer().frame(height: 56) // To keep layout stable
                }
            }
        }
        .alert("Berechtigung fehlgeschlagen", isPresented: $showErrorAlert) {
            Button("Zu den Einstellungen") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Abbrechen", role: .cancel) { }
        } message: {
            Text("iOS hat die Berechtigung verweigert. Fehlermeldung: \(errorMessage ?? "Unbekannt").\n\nBitte überprüfe deine Berechtigungen in den Einstellungen.")
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
            do {
                // Request native screen time permission
                try await ScreenTimeManager.shared.requestAuthorization()
                
                // If it succeeded without throwing, we show the continue button
                await MainActor.run {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showContinueButton = true
                    }
                }
            } catch {
                // If it failed, show the exact error message
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.showErrorAlert = true
                    
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showContinueButton = true
                    }
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
