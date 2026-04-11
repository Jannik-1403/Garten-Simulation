import SwiftUI
import DotLottie

struct GartenPassRewardOverlay: View {
    let belohnung: GartenPassBelohnung
    let onSpinNow: () -> Void
    let onContinue: () -> Void
    @EnvironmentObject var settings: SettingsStore
    
    @State private var contentOpacity: Double = 0
    @State private var iconScale: CGFloat = 0.5
    @State private var showConfetti = false
    
    private var info: (name: String, icon: String, isAsset: Bool) {
        belohnung.getDisplayInfo(settings: settings)
    }
    
    var body: some View {
        ZStack {
            // Full-screen white background
            Color.white
                .ignoresSafeArea()
            
            // Celebration Lottie (Confetti) — covering the whole screen
            if showConfetti {
                SafeDotLottieView(
                    url: "https://lottie.host/e9ce3227-f1fc-4135-9b98-b1f578638775/77KBz7dIev.lottie",
                    animationConfig: AnimationConfig(autoplay: true, loop: false),
                    fixedSize: UIScreen.main.bounds.size
                )
            }
            
            VStack(spacing: 35) {
                Spacer()
                
                // Celebration Title
                VStack(spacing: 12) {
                    Text(settings.localizedString(for: "reward_claim_title"))
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundStyle(.black)
                    
                    Text(settings.localizedString(for: "reward_claim_subtitle"))
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(.black.opacity(0.6))
                }
                
                // Featured Item (The Asset)
                ZStack {
                    Circle()
                        .fill(rewardColor.opacity(0.1))
                        .frame(width: 220, height: 220)
                    
                    if case .pflanze(let id) = belohnung.typ, 
                       let pl = GameDatabase.shared.plant(for: id) {
                        // Spezial-View für Pflanzen
                        PlantIconView(plant: pl, seltenheit: .bronze, size: 160, alwaysShowFullGrown: true)
                            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
                            .scaleEffect(iconScale)
                    } else if info.isAsset {
                        Image(info.icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 160, height: 160)
                            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
                            .scaleEffect(iconScale)
                    } else {
                        Image(systemName: info.icon)
                            .font(.system(size: 80, weight: .bold))
                            .foregroundColor(rewardColor)
                            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
                            .scaleEffect(iconScale)
                    }
                }
                
                // Item Name Label
                VStack(spacing: 8) {
                    Text(info.name)
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.center)
                    
                    Text(settings.localizedString(for: "reward_claimed_added_msg"))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(rewardColor)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(rewardColor.opacity(0.1))
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 15) {
                    if case .gluecksradDrehung = belohnung.typ {
                        Button(action: {
                            // Delay for premium 3D feeling (pop-back animation)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                                onSpinNow()
                            }
                        }) {
                            Text(settings.localizedString(for: "ice_wheel_button_spin"))
                                .font(.system(size: 20, weight: .black, design: .rounded))
                        }
                        .buttonStyle(DuolingoButtonStyle(
                            size: .large,
                            fillWidth: true,
                            backgroundColor: .blauPrimary,
                            shadowColor: Color.blauPrimary.darker(),
                            foregroundColor: .white
                        ))
                        
                        Button(action: {
                            // Delay for premium 3D feeling (pop-back animation)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                onContinue()
                            }
                        }) {
                            Text(settings.localizedString(for: "spin_button_later"))
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.blauPrimary)
                                .padding(.vertical, 8)
                        }
                    } else {
                        Button(action: {
                            // Delay for premium 3D feeling (pop-back animation)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                                onContinue()
                            }
                        }) {
                            Text(settings.localizedString(for: "reward_button_super"))
                                .font(.system(size: 20, weight: .black, design: .rounded))
                        }
                        .buttonStyle(DuolingoButtonStyle(
                            size: .large,
                            fillWidth: true,
                            backgroundColor: .gruenPrimary,
                            shadowColor: Color.gruenPrimary.darker(),
                            foregroundColor: .white
                        ))
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }
            .opacity(contentOpacity)
        }
        .onAppear {
            // Tiny delay to ensure the view hierarchy is stable before Lottie starts loading/rendering
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showConfetti = true
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                contentOpacity = 1.0
                iconScale = 1.0
            }
        }

        .statusBar(hidden: true)
    }
    
    private var rewardColor: Color {
        belohnung.kategorieFarbe
    }
}
