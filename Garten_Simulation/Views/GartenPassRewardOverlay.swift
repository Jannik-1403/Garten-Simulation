import SwiftUI

struct GartenPassRewardOverlay: View {
    let belohnung: GartenPassBelohnung
    let onDismiss: () -> Void
    
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
                        Text(NSLocalizedString("reward_button_super", comment: ""))
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
            let template = NSLocalizedString("reward_coins_title", comment: "")
            return template.replacingOccurrences(of: "{n}", with: "\(n)")
        case .powerUp:
            return NSLocalizedString("reward_powerup_title", comment: "")
        case .pflanze:
            return NSLocalizedString("reward_plant_title", comment: "")
        case .gluecksradDrehung(let n):
            let template = NSLocalizedString("reward_spin_title", comment: "")
            return template.replacingOccurrences(of: "{n}", with: "\(n)")
        case .dekoration:
            return NSLocalizedString("reward_deco_title", comment: "")
        case .paket:
            return NSLocalizedString("reward_paket_title", comment: "")
        case .seeds(let n):
            let template = NSLocalizedString("reward_seeds_title", comment: "")
            return template.replacingOccurrences(of: "{n}", with: "\(n)")
        }
    }
    
    private var rewardSubtitle: String {
        switch belohnung.typ {
        case .coins:
            return NSLocalizedString("reward_coins_subtitle", comment: "")
        case .powerUp:
            return NSLocalizedString("reward_powerup_subtitle", comment: "")
        case .pflanze:
            return NSLocalizedString("reward_plant_subtitle", comment: "")
        case .gluecksradDrehung:
            return NSLocalizedString("reward_spin_subtitle", comment: "")
        case .dekoration:
            return NSLocalizedString("reward_deco_subtitle", comment: "")
        case .paket:
            return NSLocalizedString("reward_paket_subtitle", comment: "")
        case .seeds:
            return NSLocalizedString("reward_seeds_subtitle", comment: "")
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
