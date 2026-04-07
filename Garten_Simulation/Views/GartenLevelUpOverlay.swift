import SwiftUI
import DotLottie

struct GartenLevelUpOverlay: View {
    @EnvironmentObject var settings: SettingsStore
    
    let neuerLevel: Int
    let freischaltungen: [GartenLevelFreischaltung]
    let onDismiss: () -> Void
    let onGluecksradDrehen: (() -> Void)?
    
    @State private var zeigeInhalt = false
    @State private var leuchtet = false
    @AppStorage("isHapticEnabled") var isHapticEnabled: Bool = true
    
    var body: some View {
        ZStack {
            // 1. Dunkler Hintergrund
            Color.black.opacity(0.85)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // 2. Lottie Banner + Level-Kreis übereinander
                ZStack(alignment: .bottom) {
                    // Lottie Animation (roter Banner mit Trompeten) — KEINE Maske
                    // Lottie Animation (roter Banner mit Trompeten) — IMMER in Hierarchie für Stabilität
                    DotLottieAnimation(
                        webURL: "https://lottie.host/bd7993da-11cc-4e38-8b7c-5eba53dd788b/zVMrBPKTNT.lottie",
                        config: .init(autoplay: true, loop: false, speed: 0.7)
                    )
                    .view()
                    .frame(width: 580, height: 520)
                    .offset(x: -20, y: -80)
                    .allowsHitTesting(false)
                    .opacity(zeigeInhalt ? 1.0 : 0.0)

                    // Level Button — Nutzt den globalen Item3DButtonStyle
                    Button(action: {
                        onDismiss()
                    }) {
                        VStack(spacing: -8) {
                            Text(settings.localizedString(for: "level_up_label").uppercased())
                                .font(.system(size: 15, weight: .black, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                            Text("\(neuerLevel)")
                                .font(.system(size: 90, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.15), radius: 1, x: 0, y: 2)
                        }
                    }
                    .buttonStyle(Item3DButtonStyle(
                        farbe: Color(hex: "#FFC800"),
                        sekundaerFarbe: Color(hex: "#E59400"),
                        groesse: 185
                    ))
                    .shadow(color: Color(hex: "#FFC800").opacity(leuchtet ? 0.9 : 0.3), radius: leuchtet ? 30 : 10)
                    .offset(y: 30)
                }
                .frame(height: 480)

                // 3. Text-Block
                VStack(spacing: 10) {
                    Text(settings.localizedString(for: "level_up_garten_titel"))
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text(settings.localizedString(for: "level_up_pass_hint"))
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .padding(.top, 50)

                Spacer()
                
                // Kein expliziter Button mehr — ganzer Screen ist tippbar
            }
            .scaleEffect(zeigeInhalt ? 1.0 : 0.6)
            .opacity(zeigeInhalt ? 1 : 0)
        }
        .contentShape(Rectangle()) // Macht den ganzen ZStack tippbar
        .onTapGesture {
            onDismiss()
        }
        .onAppear {
            if isHapticEnabled {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
            FeedbackManager.shared.playLevelUp()
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                zeigeInhalt = true
            }
            
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                leuchtet = true
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        GartenLevelUpOverlay(
            neuerLevel: 26,
            freischaltungen: [],
            onDismiss: {},
            onGluecksradDrehen: {}
        )
        .environmentObject(SettingsStore())
    }
}
