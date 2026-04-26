import SwiftUI

// Dieser View wurde offenbar umbenannt oder gelöscht, ist aber noch im Projekt referenziert.
// PfadIgelView.swift scheint der aktuelle Ersatz zu sein.
struct GartenIgelView: View {
    let text: String
    var daumenHoch: Bool = false
    
    var body: some View {
        VStack(spacing: 12) {
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

            // Igel Image
            Image("Powerup-Tier-Freund")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .shadow(color: .black.opacity(0.05), radius: 5, y: 3)
        }
    }
}
