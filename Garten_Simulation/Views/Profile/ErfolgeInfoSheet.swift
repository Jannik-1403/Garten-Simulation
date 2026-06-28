import SwiftUI

struct ErfolgeInfoSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var settings: SettingsStore
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Visual Progression only
                    VStack(spacing: 16) {
                        TierRow(tier: .bronze, iconName: "Achievment_Gold", isLast: false)
                        TierRow(tier: .silber, iconName: "Achievment_Gold", isLast: false)
                        TierRow(tier: .gold, iconName: "Achievment_Gold", isLast: false)
                        TierRow(tier: .diamant, iconName: "Achievment_Gold", isLast: false)
                        TierRow(tier: .master, iconName: "Achievment_Rot", isLast: true)
                    }
                    .padding(.top, 24)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .standardNavigationX()
        }
    }
}

struct TierRow: View {
    let tier: ErfolgTier
    let iconName: String
    let isLast: Bool
    @EnvironmentObject var settings: SettingsStore
    
    var body: some View {
        VStack(spacing: 16) {
            // Icon & Name
            VStack(spacing: 8) {
                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220, height: 220)
                    .applyErfolgFarbe(for: tier)
                
                Text(tier.localizedName)
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundStyle(tier.color)
            }
            
            // Level Up Arrow
            if !isLast {
                Image(systemName: "arrow.down")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.gray.opacity(0.3))
                    .padding(.vertical, 8)
            }
        }
        .padding(.horizontal)
    }
}
