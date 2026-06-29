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
                    icon: event.customIconName,
                    farbe: event.bannerFarbe,
                    sekundaerFarbe: event.bannerFarbeSekundaer,
                    groesse: 120,
                    iconSkalierung: 1.8
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
                        title: String(localized: "weather.detail.gems", defaultValue: "COINS"),
                        value: gemsText
                    )
                    
                    if event == .sturm {
                        weatherInfoBlock(
                            icon: "Heart",
                            isAsset: true,
                            title: String(localized: "leben.titel", defaultValue: "Leben"),
                            value: "-2"
                        )
                    } else {
                        weatherInfoBlock(
                            icon: "XP",
                            isAsset: true,
                            title: String(localized: "common.xp", defaultValue: "XP"),
                            value: xpText
                        )
                    }
                }
                .padding(.horizontal, 16)

                // MARK: - 3D Rules Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 10) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(event.bannerFarbe)
                        Text(String(localized: "weather.today_is", defaultValue: "Heute gilt").uppercased())
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
        .background(.ultraThinMaterial)
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
        case .perfekt: return String(localized: "weather.detail.double", defaultValue: "2x")   // +50%
        case .schnee: return String(localized: "weather.detail.half", defaultValue: "0.5x")    // -30%
        default: return String(localized: "weather.detail.normal", defaultValue: "Normal")
        }
    }

    private var xpText: String {
        switch event {
        case .regen: return String(localized: "weather.detail.double", defaultValue: "2x")     // +50%
        case .perfekt: return String(localized: "weather.detail.double", defaultValue: "2x")   // +50%
        default: return String(localized: "weather.detail.normal", defaultValue: "Normal")
        }
    }

    private var ruleText: String {
        event.regel
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
