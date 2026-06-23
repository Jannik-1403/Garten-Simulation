import SwiftUI

struct CardParticleEmitterView: View {
    let tier: ErfolgTier
    
    struct StaticDiamond: Identifiable {
        let id = UUID()
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
        let blur: CGFloat
        let opacity: Double
        let customColor: Color
    }
    
    var particles: [StaticDiamond] {
        let c1: Color
        let c3: Color
        let c4: Color
        
        switch tier {
        case .bronze:
            c1 = Color(red: 0.8, green: 0.4, blue: 0.2)
            c3 = Color(red: 1.0, green: 0.6, blue: 0.3)
            c4 = Color(red: 1.0, green: 0.8, blue: 0.5)
        case .silber:
            c1 = Color(red: 0.5, green: 0.55, blue: 0.65)
            c3 = Color(red: 0.85, green: 0.9, blue: 0.95)
            c4 = Color(white: 0.95)
        case .gold:
            c1 = Color(red: 1.0, green: 0.84, blue: 0.0)  // Pure Gold
            c3 = Color(red: 0.85, green: 0.65, blue: 0.13)// Dark Gold
            c4 = Color(red: 1.0, green: 0.9, blue: 0.3)   // Pale Gold
        case .diamant:
            c1 = Color(red: 0.1, green: 0.8, blue: 0.9)
            c3 = Color(red: 0.5, green: 0.95, blue: 1.0)
            c4 = Color(white: 1.0)
        case .master, .max:
            c1 = Color(red: 0.9, green: 0.1, blue: 0.1)
            c3 = Color(red: 0.7, green: 0.0, blue: 0.0)
            c4 = Color(white: 1.0)
        }
        
        return [
            // Top Left
            StaticDiamond(x: -35, y: -45, size: 10, blur: 1.5, opacity: 0.6, customColor: c1),
            
            // Top Right
            StaticDiamond(x: 35, y: -40, size: 12, blur: 2.0, opacity: 0.5, customColor: c1),
            StaticDiamond(x: 20, y: -15, size: 6, blur: 0.0, opacity: 0.9, customColor: c4),
            
            // Bottom Left
            StaticDiamond(x: -30, y: 35, size: 11, blur: 1.0, opacity: 0.6, customColor: c3),
            
            // Bottom Right
            StaticDiamond(x: 15, y: 25, size: 10, blur: 1.5, opacity: 0.6, customColor: c1)
        ]
    }
    
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            ForEach(Array(particles.enumerated()), id: \.offset) { index, particle in
                Image(systemName: "diamond.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: particle.size, height: particle.size)
                    .foregroundColor(particle.customColor)
                    // The shadow becomes larger to simulate "leuchten" (glowing)
                    .shadow(color: particle.customColor.opacity(0.8), radius: isAnimating ? 6 : 0)
                    // Blur decreases to 0 so it becomes "schärfer"
                    .blur(radius: isAnimating ? 0 : particle.blur + 2.0)
                    // Opacity goes from 0 (weg) to 1.0 (leuchten)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(x: particle.x, y: particle.y) // Static position, no movement
                    .animation(
                        .easeInOut(duration: 1.5 + Double(index % 3) * 0.5)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.6),
                        value: isAnimating
                    )
            }
        }
        // Ensure the ZStack stretches to fill the card
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            isAnimating = true
        }
    }
}
