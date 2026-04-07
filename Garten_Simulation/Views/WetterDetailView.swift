import SwiftUI

struct WetterDetailView: View {
    let event: WetterEvent
    @EnvironmentObject var settings: SettingsStore
    @State private var perfektIconPressed = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 28) {
                // MARK: - 3D Header Icon
                Item3DButton(
                    icon: event.systemIcon,
                    farbe: event.bannerFarbe,
                    sekundaerFarbe: event.bannerFarbeSekundaer,
                    groesse: 120
                )
                .padding(.top, 32)

                VStack(spacing: 6) {
                    Text(event.titel)
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.primary)
                    
                    Text(event.untertitel)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                // MARK: - 3D Info Cards
                HStack(spacing: 24) {
                    weatherInfoBlock(
                        icon: "coin",
                        isAsset: true,
                        title: settings.localizedString(for: "weather.detail.gems"),
                        value: gemsText
                    )
                    
                    weatherInfoBlock(
                        icon: "Drop water",
                        isAsset: true,
                        title: settings.localizedString(for: "weather.detail.watering"),
                        value: giessText
                    )
                }
                .padding(.horizontal, 16)

                // MARK: - 3D Rules Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 10) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(event.bannerFarbe)
                        Text(settings.localizedString(for: "weather.today_is").uppercased())
                            .font(.system(size: 12, weight: .black, design: .rounded))
                            .tracking(1.2)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text(ruleText)
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundStyle(.primary)
                        .lineSpacing(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color.primary.opacity(0.05))
                            .offset(y: 4)
                        
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                            )
                    }
                )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(
            ZStack {
                event.hintergrundFarbe.ignoresSafeArea()
                
                // Subtile Glow-Spheres im Hintergrund
                Circle()
                    .fill(event.bannerFarbe.opacity(0.08))
                    .frame(width: 300)
                    .blur(radius: 60)
                    .offset(x: -150, y: -200)
            }
        )
    }

    private func handleIconPress() {
        perfektIconPressed = true
        UISelectionFeedbackGenerator().selectionChanged()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            perfektIconPressed = false
        }
    }

    private var gemsText: String {
        switch event {
        case .perfekt: return settings.localizedString(for: "weather.detail.double")
        case .schnee: return settings.localizedString(for: "weather.detail.half")
        default: return settings.localizedString(for: "weather.detail.normal")
        }
    }

    private var giessText: String {
        switch event {
        case .duerre: return settings.localizedString(for: "weather.detail.double")
        case .schnee: return settings.localizedString(for: "weather.detail.difficult")
        default: return settings.localizedString(for: "weather.detail.normal")
        }
    }

    private var ruleText: String {
        settings.localizedString(for: "weather.rule.\(event.rawValue)")
    }

    private func weatherInfoBlock(icon: String, isAsset: Bool, title: String, value: String) -> some View {
        VStack(spacing: 12) {
            Item3DButton(
                icon: icon,
                farbe: event.bannerFarbe,
                sekundaerFarbe: event.bannerFarbeSekundaer,
                groesse: 90
            )
            
            VStack(spacing: 4) {
                Text(title.uppercased())
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(.secondary)
                    .tracking(1.0)
                
                Text(value)
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(.primary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}


#Preview {
    WetterDetailView(event: .perfekt)
}
