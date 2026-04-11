import SwiftUI

struct OnboardingPowerUpTutorialView: View {
    @EnvironmentObject var data: OnboardingData
    @EnvironmentObject var settings: SettingsStore
    
    @State private var innerPose: IgelPose = .erklaert
    @State private var itemVerwendet = false
    @State private var showNext = false
    @State private var zeigeDetail = false
    
    // Golden Key details from GameDatabase
    private let powerUpID = "powerup.goldener_schluessel"
    
    var itemDetail: PowerUpItem? {
        GameDatabase.allPowerUps.first(where: { $0.id == powerUpID })
    }
    
    var bubbleText: String {
        if itemVerwendet {
            return settings.localizedString(for: "onboarding_tutorial_powerup_active_success")
        }
        return zeigeDetail ? settings.localizedString(for: "onboarding_tutorial_powerup_detail_hint") : settings.localizedString(for: "onboarding_tutorial_powerup_bubble")
    }
    
    var body: some View {
        VStack(spacing: 0) {
            OnboardingIgelView(
                pose: innerPose,
                sprechblasenText: bubbleText
            )
            .padding(.top, 20)
            
            Spacer()
            
            // Item 3D Button (Gameplay Style)
            if let item = itemDetail {
                VStack(spacing: 24) {
                    Item3DButton(
                        icon: item.symbolName,
                        farbe: item.color,
                        sekundaerFarbe: item.color.darker(),
                        groesse: 120
                    ) {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        zeigeDetail = true
                    }
                    .scaleEffect(itemVerwendet ? 0.8 : 1.0)
                    .opacity(itemVerwendet ? 0.6 : 1.0)
                    .grayscale(itemVerwendet ? 1.0 : 0.0)
                    .animation(.spring(), value: itemVerwendet)
                    
                    if !itemVerwendet {
                        Text(settings.localizedString(for: item.name))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .transition(.opacity)
                    }
                }
            }
            
            Spacer()
            
            if showNext {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    withAnimation(.easeInOut(duration: 0.35)) {
                        data.currentStep += 1
                    }
                } label: {
                    Text(settings.localizedString(for: "onboarding_weiter"))
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
                Spacer().frame(height: 100)
            }
        }
        .sheet(isPresented: $zeigeDetail) {
            OnboardingPowerUpDetailSheet {
                handleUsage()
            }
        }
        .animation(.spring(), value: itemVerwendet)
    }
    
    private func handleUsage() {
        // Simuliere die Aktivierung im Onboarding-Status
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            itemVerwendet = true
            innerPose = .daumenHoch
            data.globalXPMultiplier = 1.5 // Multiplikator setzen
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation {
                showNext = true
                innerPose = .erklaert
            }
        }
    }
}

#Preview {
    OnboardingPowerUpTutorialView()
        .environmentObject(OnboardingData())
        .environmentObject(SettingsStore())
}
