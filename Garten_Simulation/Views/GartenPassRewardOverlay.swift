import SwiftUI

struct GartenPassRewardOverlay: View {
    let belohnung: GartenPassBelohnung
    let onDismiss: () -> Void
    @EnvironmentObject var settings: SettingsStore
    
    @State private var visible = false
    @State private var cardOffset: CGFloat = 300

    var body: some View {
        ZStack {
            // Hintergrund
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .opacity(visible ? 1 : 0)
                .onTapGesture {
                    safeDismiss()
                }
            
            if visible {
                VStack(spacing: 24) {
                    // Icon
                    rewardIcon
                        .frame(width: 100, height: 100)
                    
                    // Texte
                    VStack(spacing: 8) {
                        Text(rewardTitle)
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                        
                        Text(rewardSubtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Button
                    Button(action: {
                        safeDismiss()
                    }) {
                        Text(settings.localizedString(for: "reward_button_super"))
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                    }
                    .buttonStyle(DuolingoButtonStyle(
                        size: .large,
                        fillWidth: true,
                        backgroundColor: .green,
                        shadowColor: Color.green.darker(),
                        foregroundColor: .white
                    ))
                }
                .padding(32)
                .background(
                    ZStack(alignment: .bottom) {
                        // 3D Shadow Layer (Base)
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color(hex: "#E0E0E0"))
                            .offset(y: 8)
                        
                        // Main White Surface
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .stroke(Color.black.opacity(0.1), lineWidth: 1.5)
                            )
                    }
                )
                .padding(.horizontal, 24)
                .frame(maxWidth: 400)
                .offset(y: cardOffset)
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.2)) {
                visible = true
            }
            withAnimation(.spring(duration: 0.4)) {
                cardOffset = 0
            }
        }
    }
    
    @ViewBuilder
    private var rewardIcon: some View {
        let info = belohnung.getDisplayInfo()
        if info.isAsset || info.icon == "coin" {
            Image(info.icon)
                .resizable()
                .scaledToFit()
        } else {
            Image(systemName: info.icon)
                .resizable()
                .scaledToFit()
                .foregroundColor(.blauPrimary)
        }
    }
    
    private var rewardTitle: String {
        switch belohnung.typ {
        case .coins(let n):
            let template = settings.localizedString(for: "reward_coins_title")
            return template.replacingOccurrences(of: "{n}", with: "\(n)")
        case .powerUp:
            return settings.localizedString(for: "reward_powerup_title")
        case .pflanze:
            return settings.localizedString(for: "reward_plant_title")
        case .gluecksradDrehung(let n):
            let template = settings.localizedString(for: "reward_spin_title")
            return template.replacingOccurrences(of: "{n}", with: "\(n)")
        case .dekoration:
            return settings.localizedString(for: "reward_deco_title")
        case .paket:
            return settings.localizedString(for: "reward_paket_title")
        case .seeds(let n):
            let template = settings.localizedString(for: "reward_seeds_title")
            return template.replacingOccurrences(of: "{n}", with: "\(n)")
        }
    }
    
    private var rewardSubtitle: String {
        switch belohnung.typ {
        case .coins:
            return settings.localizedString(for: "reward_coins_subtitle")
        case .powerUp:
            return settings.localizedString(for: "reward_powerup_subtitle")
        case .pflanze:
            return settings.localizedString(for: "reward_plant_subtitle")
        case .gluecksradDrehung:
            return settings.localizedString(for: "reward_spin_subtitle")
        case .dekoration:
            return settings.localizedString(for: "reward_deco_subtitle")
        case .paket:
            return settings.localizedString(for: "reward_paket_subtitle")
        case .seeds:
            return settings.localizedString(for: "reward_seeds_subtitle")
        }
    }
    
    private func safeDismiss() {
        withAnimation(.spring(duration: 0.3)) {
            cardOffset = 400
            visible = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}
