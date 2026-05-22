import SwiftUI

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
            // 1. Weißer Hintergrund
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Neues "LEVEL UP" Oben (Lokalisiert)
                Text(settings.localizedString(for: "level_up.title"))
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundColor(.orangePrimary)
                    .padding(.bottom, 60)

                // 2. Level-Kreis zentriert
                Button(action: {
                    onDismiss()
                }) {
                    Text("\(neuerLevel)")
                        .font(.system(size: 80, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.15), radius: 1, x: 0, y: 2)
                }
                .buttonStyle(Item3DButtonStyle(
                    farbe: Color(hex: "#FFC800"),
                    sekundaerFarbe: Color(hex: "#E59400"),
                    groesse: 160
                ))
                .shadow(color: Color(hex: "#FFC800").opacity(leuchtet ? 0.6 : 0.2), radius: leuchtet ? 30 : 10)

                // 3. Text-Block
                VStack(spacing: 12) {
                    Text(settings.localizedString(for: "level_up_garten_titel"))
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.6)

                    Text(settings.localizedString(for: "level_up_pass_hint"))
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .minimumScaleFactor(0.8)
                }
                .padding(.top, 60)

                Spacer()
                
                // Hinweis
                Text(settings.localizedString(for: "button.continue").uppercased())
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary.opacity(0.5))
                    .padding(.bottom, 40)
            }
            .scaleEffect(zeigeInhalt ? 1.0 : 0.6)
            .opacity(zeigeInhalt ? 1 : 0)
        }
        // Den ganzen ZStack tippbar machen, falls der Nutzer einfach tippt
        .contentShape(Rectangle()) 
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
