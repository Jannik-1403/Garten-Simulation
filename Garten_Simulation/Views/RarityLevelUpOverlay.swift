import SwiftUI

struct RarityLevelUpOverlay: View {
    let rarity: SeltenheitsStufe
    let onDismiss: () -> Void
    
    @State private var iconScale: CGFloat = 0.5
    @State private var iconRotation: Double = -30
    @State private var opacity: Double = 0
    @State private var cardOffset: CGFloat = 300
    
    var body: some View {
        ZStack {
            // Backdrop
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }
            
            // Popup Card
            VStack(spacing: 30) {
                // Header
                Text("STUFEN-AUFSTIEG! 🎉")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.primary)
                
                // Rarity Icon
                ZStack {
                    Circle()
                        .fill(rarity.primaryColor.opacity(0.15))
                        .frame(width: 140, height: 140)
                        .blur(radius: 20)
                    
                    Image(systemName: rarity.iconName)
                        .font(.system(size: 80, weight: .bold))
                        .foregroundStyle(rarity.gradient)
                        .scaleEffect(iconScale)
                        .rotationEffect(.degrees(iconRotation))
                        .shadow(color: rarity.primaryColor.opacity(0.3), radius: 15, x: 0, y: 10)
                }
                
                // Details
                VStack(spacing: 8) {
                    Text("Dein Garten ist jetzt")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                    
                    Text(rarity.titel)
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundStyle(rarity.gradient)
                }
                
                // Action Button
                Button(action: onDismiss) {
                    Text("Super!")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(DuolingoButtonStyle(
                    size: .large,
                    backgroundColor: rarity.primaryColor,
                    shadowColor: rarity.secondaryColor,
                    foregroundColor: .white
                ))
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: .black.opacity(0.2), radius: 40, x: 0, y: 20)
            )
            .padding(.horizontal, 30)
            .offset(y: cardOffset)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.72)) {
                opacity = 1
                cardOffset = 0
            }
            
            withAnimation(.spring(response: 0.62, dampingFraction: 0.52).delay(0.25)) {
                iconScale = 1.0
                iconRotation = 0
            }
        }
    }
}

#Preview {
    RarityLevelUpOverlay(rarity: .silber, onDismiss: {})
}
