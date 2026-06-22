import SwiftUI

struct RarityBackgroundView: View {
    let tag: String
    
    @State private var animate1 = false
    @State private var animate2 = false
    @State private var animate3 = false
    
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            
            ZStack {
                // Layer 1 (Base)
                baseColor
                    .ignoresSafeArea()
                
                // Layer 2 & 3 (Glow & Blend Mode)
                ZStack {
                    Circle()
                        .fill(glowColor1)
                        .frame(width: width * 0.8, height: width * 0.8)
                        .offset(x: animate1 ? width * 0.3 : -width * 0.2,
                                y: animate1 ? -height * 0.3 : height * 0.1)
                        .scaleEffect(animate1 ? 1.2 : 0.8)
                        .blur(radius: 80)
                        .blendMode(.screen)
                    
                    Circle()
                        .fill(glowColor2)
                        .frame(width: width * 0.9, height: width * 0.9)
                        .offset(x: animate2 ? -width * 0.4 : width * 0.2,
                                y: animate2 ? height * 0.4 : -height * 0.2)
                        .scaleEffect(animate2 ? 1.4 : 0.9)
                        .blur(radius: 90)
                        .blendMode(.screen)
                    
                    Ellipse()
                        .fill(glowColor1.opacity(0.7))
                        .frame(width: width * 1.1, height: width * 0.6)
                        .offset(x: animate3 ? width * 0.1 : -width * 0.1,
                                y: animate3 ? height * 0.1 : -height * 0.3)
                        .rotationEffect(.degrees(animate3 ? 45 : -20))
                        .scaleEffect(animate3 ? 1.1 : 0.85)
                        .blur(radius: 100)
                        .blendMode(.screen)
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 4.5).repeatForever(autoreverses: true)) {
                    animate1 = true
                }
                withAnimation(.easeInOut(duration: 5.2).repeatForever(autoreverses: true)) {
                    animate2 = true
                }
                withAnimation(.easeInOut(duration: 6.0).repeatForever(autoreverses: true)) {
                    animate3 = true
                }
            }
        }
        .clipped()
    }
    
    // MARK: - Colors based on Rarity Tier
    
    private var baseColor: Color {
        switch tag {
        case "common": return Color(hex: "#1A1A1A") // Sehr dunkles Grau
        case "rare": return Color(hex: "#0A1128") // Dunkles Tiefsee-Blau
        case "epic": return Color(hex: "#1A0B2E") // Dunkles Violett
        case "legendary": return Color(hex: "#331A00") // Dunkles Braun/Bronze
        case "mystic": return Color(hex: "#2B0000") // Tiefes Blutrot
        case "plant": return Color(hex: "#0A2910") // Dunkles Waldgrün
        default: return Color(hex: "#1A1A1A")
        }
    }
    
    private var glowColor1: Color {
        switch tag {
        case "common": return Color(hex: "#B0B0B0") // Kühles Silber
        case "rare": return Color(hex: "#00E5FF") // Neon-Cyan
        case "epic": return Color(hex: "#D500F9") // Grelles Magenta
        case "legendary": return Color(hex: "#FFD700") // Strahlendes Gold
        case "mystic": return Color(hex: "#FF3D00") // Feuriges Orange
        case "plant": return Color(hex: "#00E676") // Grelles Neon-Grün
        default: return Color(hex: "#B0B0B0")
        }
    }
    
    private var glowColor2: Color {
        switch tag {
        case "common": return Color.white.opacity(0.8) // Leichtes Weiß
        case "rare": return Color(hex: "#0044FF") // Sattes Blau
        case "epic": return Color(hex: "#B000FF") // Neon-Lila
        case "legendary": return Color.yellow.opacity(0.9) // Helles Gelb
        case "mystic": return Color(hex: "#FF0000") // Grelles Rot
        case "plant": return Color(hex: "#00B8D4") // Türkis-Grün
        default: return Color.white.opacity(0.8)
        }
    }
}

#Preview {
    VStack {
        RarityBackgroundView(tag: "mystic")
            .frame(height: 350)
        RarityBackgroundView(tag: "rare")
            .frame(height: 350)
    }
}
