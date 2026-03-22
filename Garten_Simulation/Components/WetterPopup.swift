import SwiftUI

struct WetterPopup: View {
    let event: WetterEvent
    let onDismiss: () -> Void

    @State private var erschienen = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { schliessen() }

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(event.bannerFarbe.opacity(0.15))
                            .frame(width: 100, height: 100)

                        Circle()
                            .fill(event.bannerFarbe.opacity(0.25))
                            .frame(width: 75, height: 75)

                        Image(systemName: event.systemIcon)
                            .font(.system(size: 36))
                            .foregroundStyle(event.bannerFarbe)
                            .symbolEffect(.bounce, value: erschienen)
                    }

                    VStack(spacing: 8) {
                        Text("Neues Wetter-Event!")
                            .font(.appCaption)
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .tracking(1.5)

                        Text(event.titel)
                            .font(.appTitel)
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.center)

                        Text(event.untertitel)
                            .font(.appBody)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }

                    HStack(spacing: 16) {
                        EffektBadge(
                            icon: "diamond.fill",
                            text: gemsText,
                            farbe: .purple
                        )

                        EffektBadge(
                            icon: "drop.fill",
                            text: giessText,
                            farbe: event.bannerFarbe
                        )
                    }

                    Button("Verstanden!") {
                        schliessen()
                    }
                    .font(.appButton)
                    .buttonStyle(DepthButtonStyle(
                        foregroundColor: event.bannerFarbe,
                        backgroundColor: event.bannerFarbeSekundaer,
                        cornerRadius: 16
                    ))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                }
                .padding(28)
                .background(
                    RoundedRectangle(cornerRadius: 32)
                        .fill(.regularMaterial)
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
                .offset(y: erschienen ? 0 : 400)
                .animation(
                    .spring(response: 0.5, dampingFraction: 0.75),
                    value: erschienen
                )
            }
        }
        .opacity(erschienen ? 1 : 0)
        .animation(.easeInOut(duration: 0.2), value: erschienen)
        .onAppear {
            withAnimation {
                erschienen = true
            }
        }
    }

    // MARK: - Helper Texte
    var gemsText: String {
        switch event {
        case .perfekt: return "2x Gems"
        case .schnee: return "0.5x Gems"
        default: return "1x Gems"
        }
    }

    var giessText: String {
        switch event {
        case .duerre: return "2x Gießen"
        case .schnee: return "Eingefroren"
        case .perfekt: return "Bonus XP"
        default: return "Normal"
        }
    }

    func schliessen() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            erschienen = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            onDismiss()
        }
    }
}

// MARK: - Effekt Badge
struct EffektBadge: View {
    let icon: String
    let text: String
    let farbe: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(farbe)
                .font(.appCaption)
            Text(text)
                .font(.appCaption)
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(farbe.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(farbe.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    WetterPopup(event: .duerre) {}
}
