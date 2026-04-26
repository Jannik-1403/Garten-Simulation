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
            // 1. Dunkler Glass-Hintergrund
            Color.black.opacity(0.4)
                .background(.ultraThinMaterial)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top content pushed even further down
                Spacer().frame(height: 130)

                // 2. Lottie Banner + Level-Kreis übereinander
                GeometryReader { geo in
                    ZStack(alignment: .bottom) {
                        // Lottie Animation (roter Banner mit Trompeten)
                        SafeDotLottieView(
                            url: "https://lottie.host/bd7993da-11cc-4e38-8b7c-5eba53dd788b/zVMrBPKTNT.lottie",
                            animationConfig: .init(autoplay: true, loop: false, speed: 0.7),
                            fixedSize: CGSize(width: UIScreen.main.bounds.width * 1.4, height: UIScreen.main.bounds.width * 1.2)
                        )
                        .offset(x: -UIScreen.main.bounds.width * 0.05, y: -UIScreen.main.bounds.width * 0.30)
                        .opacity(zeigeInhalt ? 1.0 : 0.0)

                        // Level Button
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
                            groesse: min(185, geo.size.width * 0.45)
                        ))
                        .shadow(color: Color(hex: "#FFC800").opacity(leuchtet ? 0.9 : 0.3), radius: leuchtet ? 30 : 10)
                        .offset(y: 30)
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                }
                .aspectRatio(1, contentMode: .fit)
                .padding(.horizontal, 20)

                // 3. Text-Block
                VStack(spacing: 12) {
                    Text(settings.localizedString(for: "level_up_garten_titel"))
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.6)

                    Text(settings.localizedString(for: "level_up_pass_hint"))
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .minimumScaleFactor(0.8)
                }
                .padding(.top, 90)

                Spacer(minLength: 20)
                
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
