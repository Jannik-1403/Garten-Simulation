import SwiftUI

struct TargetReachedPopup: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation { isPresented = false }
                }
            
            VStack(spacing: 24) {
                Item3DButton(
                    farbe: .blauPrimary,
                    sekundaerFarbe: .blauPrimary.darker(),
                    groesse: 80,
                    isRectangular: false,
                    aktion: {}
                ) {
                    Image("Drop water")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                }
                .allowsHitTesting(false)
                
                Text(String(localized: "target.reached.title", defaultValue: "Geschafft!"))
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text(String(localized: "target.reached.message", defaultValue: "Du hast dein Tagesziel erreicht und deine Pflanze wurde gegossen!"))
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                
                Item3DButton(
                    farbe: .blauPrimary,
                    sekundaerFarbe: .blauPrimary.darker(),
                    groesse: 56,
                    isRectangular: true,
                    aktion: {
                        withAnimation { isPresented = false }
                    }
                ) {
                    Text(String(localized: "common.awesome", defaultValue: "Super!"))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
            }
            .padding(.vertical, 32)
            .background(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
            )
            .padding(32)
            .transition(.scale(scale: 0.8).combined(with: .opacity))
        }
    }
}
