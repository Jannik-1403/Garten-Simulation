import SwiftUI

struct RarityLevelUpOverlay: View {
    let rarity: PflanzenSeltenheit
    let onDismiss: () -> Void
    @EnvironmentObject var settings: SettingsStore
    
    @State private var iconScale: CGFloat = 0.5
    @State private var iconRotation: Double = -30
    @State private var opacity: Double = 0
    @State private var cardOffset: CGFloat = 300
    
    var body: some View {
        ZStack {
            // Premium Glassmorphism Backdrop
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .background(.ultraThinMaterial)
                .onTapGesture { onDismiss() }
            
            // Particles
            ConfettiParticleView()
                .opacity(opacity)
            
            // Glowing Aura behind card
            Circle()
                .fill(rarity.farbe.opacity(0.3))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .scaleEffect(iconScale)
                .opacity(opacity)
            
            // Popup Card
            VStack(spacing: 30) {
                // Header
                Text(String(localized: "level_up.title"))
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.primary)
                
                // Details
                VStack(spacing: 8) {
                    Text(String(localized: "level_up.subtitle"))
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                    
                    Text(rarity.lokalisiertTitel)
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(rarity.gradient)
                        .shadow(color: rarity.farbe.opacity(0.5), radius: 10, x: 0, y: 5)
                        
                    Text(String(localized: "psychology.fact.levelup", defaultValue: "Dein Gehirn bildet gerade neue neuronale Bahnen! Jeder Fortschritt festigt deine neue Identität."))
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 16)
                        .padding(.horizontal, 20)
                }
                
                // Action Button
                Button(action: onDismiss) {
                    Text(String(localized: "shop.purchase_success.awesome"))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(DuolingoButtonStyle(
                    size: .large,
                    backgroundColor: rarity.farbe,
                    shadowColor: rarity.secondaryColor,
                    foregroundColor: .white
                ))
                .padding(.top, 10)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(Color(UIColor.systemBackground).opacity(0.85))
                    .background(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(rarity.gradient, lineWidth: 2)
                    .blendMode(.overlay)
            )
            .shadow(color: rarity.farbe.opacity(0.25), radius: 40, x: 0, y: 20)
            .padding(.horizontal, 30)
            .offset(y: cardOffset)
            .opacity(opacity)
        }
        .onAppear {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.72)) {
                opacity = 1
                cardOffset = 0
            }
            
            withAnimation(.spring(response: 0.8, dampingFraction: 0.5).delay(0.1)) {
                iconScale = 1.0
            }
        }
    }
}

#Preview {
    RarityLevelUpOverlay(rarity: .silber, onDismiss: {})
}
