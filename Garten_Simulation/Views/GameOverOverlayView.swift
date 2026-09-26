import SwiftUI

struct GameOverOverlayView: View {
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture {
                        gardenStore.zeigeGameOverOverlay = false
                    }

                VStack(spacing: 32) {
                    // Icon Header
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.1))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "heart.slash.fill")
                            .font(.system(size: 44, weight: .bold))
                            .foregroundStyle(.red)
                    }

                    VStack(spacing: 12) {
                        Text(String(localized: "gameover.coinslost.titel", defaultValue: "Bankrott!"))
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundStyle(.primary)
                        
                        Text(String(localized: "gameover.coinslost.beschreibung", defaultValue: "Du hast alle deine Leben verloren. Zur Strafe wurden all deine Münzen entfernt. Deine Pflanzen bleiben dir aber erhalten!"))
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }

                    VStack(spacing: 14) {
                        Button {
                            // Delay for 3D feeling
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                gardenStore.zeigeGameOverOverlay = false
                            }
                        } label: {
                            Text(String(localized: "gameover.coinslost.button", defaultValue: "Verstanden"))
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                        }
                        .buttonStyle(DuolingoButtonStyle(size: .large, fillWidth: true, backgroundColor: .gruenPrimary))
                    }
                }
                .padding(32)
                .frame(width: min(420, geo.size.width * 0.9))
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.2), radius: 40, x: 0, y: 20)
            }
        }
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }
}
