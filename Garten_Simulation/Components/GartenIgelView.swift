import SwiftUI

// Dieser View wurde offenbar umbenannt oder gelöscht, ist aber noch im Projekt referenziert.
// PfadIgelView.swift scheint der aktuelle Ersatz zu sein.
struct GartenIgelView: View {
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var characterStore: CharacterStore
    let text: String
    var daumenHoch: Bool = false
    
    var body: some View {
        VStack(spacing: 8) {
            // Name (optional)
            if !settings.igelCustomization.name.isEmpty {
                Text(settings.igelCustomization.name)
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(.primary)
            }
            
            // Sprechblase
            Text(text)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(.white.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.05), radius: 5, y: 2)

            // Avatar Image
            AvatarView(profile: characterStore.profile)
                .frame(width: 100, height: 100)
                .shadow(color: .black.opacity(0.05), radius: 5, y: 3)
        }
    }
}
