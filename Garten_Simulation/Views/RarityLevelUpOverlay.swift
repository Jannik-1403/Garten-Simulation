import SwiftUI

struct RarityLevelUpOverlay: View {
    let rarity: PflanzenSeltenheit
    var habit: HabitModel? = nil
    let onDismiss: () -> Void
    @EnvironmentObject var settings: SettingsStore
    
    @State private var iconScale: CGFloat = 0.5
    @State private var iconRotation: Double = -30
    @State private var opacity: Double = 0
    @State private var cardOffset: CGFloat = 300
    
    var body: some View {
        ZStack {
            // Premium Backdrop
            Color.black.opacity(0.6)
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
                    if habit != nil {
                        Text(String(localized: "level_up.subtitle.habit", defaultValue: "Deine Gewohnheit ist jetzt"))
                            .font(.system(size: 16))
                            .foregroundStyle(.secondary)
                    } else {
                        Text(String(localized: "level_up.subtitle"))
                            .font(.system(size: 16))
                            .foregroundStyle(.secondary)
                    }
                    
                    Stat3DTitleView(title: rarity.lokalisiertTitel.uppercased(), color: rarity.farbe, size: 40)
                        .padding(.vertical, 10)
                        
                    if rarity == .diamant {
                        Text(String(localized: "level_up.diamond.title_unlocked", defaultValue: "Du hast einen neuen Spiel-Titel freigeschaltet!"))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.goldPrimary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                            .padding(.bottom, 8)
                    }
                        
                    if let habitName = habit?.displayedHabitName {
                        let customText = String(format: String(localized: "level_up.custom_text", defaultValue: "Du hast %@ schon lange gemeistert. Es wird immer einfacher für dich, die Gewohnheit beizubehalten!"), habitName)
                        Text(customText)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                            .padding(.horizontal, 20)
                    } else {
                        Text(String(localized: "psychology.fact.levelup", defaultValue: "Dein Gehirn bildet gerade neue neuronale Bahnen! Jeder Fortschritt festigt deine neue Identität."))
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                            .padding(.horizontal, 20)
                    }
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
                    .fill(Color(UIColor.systemBackground))
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
