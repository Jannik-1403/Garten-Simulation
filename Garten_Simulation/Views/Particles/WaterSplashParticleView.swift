import SwiftUI
import Combine

struct WaterSplashParticleView: View {
    @Binding var isVisible: Bool
    
    @State private var particles: [WaterParticle] = []
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .shadow(color: particle.color.opacity(0.8), radius: 3, x: 0, y: 0)
                        .position(x: particle.x, y: particle.y)
                        .opacity(particle.opacity)
                        // Scale drop depending on velocity for motion blur effect
                        .scaleEffect(x: 1.0, y: max(1.0, abs(particle.vy) * 0.1), anchor: .center)
                }
            }
            .onAppear {
                spawnParticles(in: geo.size)
            }
            .onReceive(Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()) { _ in
                if isVisible {
                    updateParticles()
                }
            }
        }
        .allowsHitTesting(false)
    }
    
    private func spawnParticles(in size: CGSize) {
        let colors: [Color] = [Color.cyan, Color.blue, Color(hex: "#40E0D0")]
        let centerX = size.width / 2
        let centerY = size.height / 2
        
        particles = (0..<25).map { _ in
            let angle = Double.random(in: .pi ... 2 * .pi) // Nur nach oben
            let speed = CGFloat.random(in: 10...30)
            
            return WaterParticle(
                x: centerX + CGFloat.random(in: -10...10),
                y: centerY + 20,
                vx: cos(angle) * speed * 0.5,
                vy: sin(angle) * speed,
                color: colors.randomElement()!,
                size: CGFloat.random(in: 4...10),
                opacity: 1.0
            )
        }
    }
    
    private func updateParticles() {
        var activeParticles = false
        
        for i in particles.indices {
            if particles[i].opacity <= 0 { continue }
            activeParticles = true
            
            particles[i].x += particles[i].vx
            particles[i].y += particles[i].vy
            
            particles[i].vy += 1.8 // Gravity
            particles[i].vx *= 0.92 // Drag
            
            // Ausblenden wenn sie anfangen zu fallen
            if particles[i].vy > 0 {
                particles[i].opacity -= 0.05
            }
        }
        
        if !activeParticles {
            isVisible = false
        }
    }
    
    struct WaterParticle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var vx: CGFloat
        var vy: CGFloat
        var color: Color
        var size: CGFloat
        var opacity: Double
    }
}
