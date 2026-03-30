import SwiftUI

struct WetterDetailView: View {
    let event: WetterEvent
    @EnvironmentObject var settings: SettingsStore
    @State private var perfektIconPressed = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                ZStack {
                    if event == .perfekt {
                        Circle()
                            .fill(event.bannerFarbe.opacity(0.28))
                            .frame(width: 110, height: 110)

                        Circle()
                            .fill(event.bannerFarbe)
                            .frame(width: 110, height: 110)
                            .overlay {
                                Image(systemName: event.systemIcon)
                                    .font(.system(size: 42, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                            .offset(y: perfektIconPressed ? 0 : -8)
                            .animation(.spring(.snappy(duration: 0.02)), value: perfektIconPressed)
                    } else {
                        Circle()
                            .fill(event.bannerFarbe.opacity(0.18))
                            .frame(width: 110, height: 110)

                        Image(systemName: event.systemIcon)
                            .font(.system(size: 42, weight: .bold))
                            .foregroundStyle(event.bannerFarbe)
                    }
                }
                .padding(.top, 22)
                .gesture(
                    event == .perfekt
                        ? DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                perfektIconPressed = true
                            }
                            .onEnded { _ in
                                perfektIconPressed = false
                            }
                        : nil
                )

                VStack(spacing: 6) {
                    Text(event.titel)
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .multilineTextAlignment(.center)
                    Text(event.untertitel)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                HStack(spacing: 12) {
                    infoCard(
                        icon: "diamond.fill",
                        title: "Gems",
                        value: gemsText,
                        color: .purple
                    )
                    infoCard(
                        icon: "drop.fill",
                        title: "Gießen",
                        value: giessText,
                        color: event.bannerFarbe
                    )
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text(settings.localizedString(for: "weather.today_is"))
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                    Text(ruleText)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(.ultraThinMaterial)
                )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 30)
        }
        .background(event.hintergrundFarbe.ignoresSafeArea())
    }

    private func infoCard(icon: String, title: String, value: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(title)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 16, weight: .black, design: .rounded))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }

    private var gemsText: String {
        switch event {
        case .perfekt: return "2x"
        case .schnee: return "0.5x"
        default: return "1x"
        }
    }

    private var giessText: String {
        switch event {
        case .duerre: return "2x nötig"
        case .schnee: return "erschwert"
        default: return "normal"
        }
    }

    private var ruleText: String {
        switch event {
        case .normal:
            return "Alles läuft normal. Einmal gießen reicht."
        case .duerre:
            return "Dürre-Alarm: Du musst heute zweimal gießen."
        case .schnee:
            return "Frost: Du bekommst nur halbe Gems."
        case .sturm:
            return "Sturm: empfindliche Pflanzen verlieren schneller Gesundheit."
        case .perfekt:
            return "Perfektes Wetter: heute gibt es doppelte Gems."
        }
    }

}

#Preview {
    WetterDetailView(event: .perfekt)
}
