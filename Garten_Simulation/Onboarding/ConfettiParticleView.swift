import SwiftUI
import Combine

struct ConfettiParticleView: View {
    @State private var particles: [Particle] = []
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .shadow(color: particle.color.darker(), radius: 0, x: 0, y: 3)
                        .rotationEffect(.degrees(particle.rotation))
                        .position(x: particle.x, y: particle.y)
                        .opacity(particle.opacity)
                }
            }
            .onAppear {
                spawnParticles(in: geo.size)
            }
            .onReceive(Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()) { _ in
                updateParticles()
            }
        }
        .allowsHitTesting(false)
    }
    
    private func spawnParticles(in size: CGSize) {
        let colors: [Color] = [.green, .blauPrimary, .yellow, .red]
        let centerX = size.width / 2
        let centerY = size.height / 2
        
        particles = (0..<40).map { _ in
            let angle = Double.random(in: 0...(2 * .pi))
            let speed = CGFloat.random(in: 8...25)
            
            return Particle(
                x: centerX,
                y: centerY,
                vx: cos(angle) * speed,
                vy: sin(angle) * speed - 15, // initial upward burst
                rotation: Double.random(in: 0...360),
                rotationSpeed: Double.random(in: -10...10),
                color: colors.randomElement()!,
                size: CGFloat.random(in: 10...20),
                opacity: 1.0
            )
        }
    }
    
    private func updateParticles() {
        for i in particles.indices {
            // Apply velocity
            particles[i].x += particles[i].vx
            particles[i].y += particles[i].vy
            
            // Gravity
            particles[i].vy += 1.5
            
            // Drag
            particles[i].vx *= 0.95
            
            // Rotate
            particles[i].rotation += particles[i].rotationSpeed
            
            // Fade out slightly
            particles[i].opacity -= 0.02
        }
    }
    
    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var vx: CGFloat
        var vy: CGFloat
        var rotation: Double
        var rotationSpeed: Double
        var color: Color
        var size: CGFloat
        var opacity: Double
    }
}
