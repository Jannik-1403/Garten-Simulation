import SwiftUI
import Combine

struct FloatingBackgroundView: View {
    @State private var items: [FloatingItem] = []
    @State private var animateGradient = false
    
    // Assets from the game (No plants!)
    let images = ["XP", "Powerup", "coin", "Drop water", "Heart", "streak", "Powerup-Diamanterde", "Powerup-Zauberstarb"]
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(
                    colors: [Color.orange, Color.red],
                    startPoint: animateGradient ? .topLeading : .bottomLeading,
                    endPoint: animateGradient ? .bottomTrailing : .topTrailing
                )
                .opacity(0.15)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true), value: animateGradient)
                
                ForEach(items) { item in
                    Image(item.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: item.size, height: item.size)
                        .rotationEffect(.degrees(item.rotation))
                        .position(x: item.xPosition * geo.size.width, y: item.yOffset)
                        // 3D Block shadow
                        .shadow(color: Color.black.opacity(0.12), radius: 0, x: 0, y: 6)
                        .opacity(0.12)
                }
            }
            .onAppear {
                setupItems(in: geo.size.height)
                withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                    animateGradient = true
                }
            }
            // Use a Timer to drive the animation for an infinite, smooth loop
            .onReceive(Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()) { _ in
                updateItems(in: geo.size.height)
            }
        }
        .ignoresSafeArea()
    }
    
    private func setupItems(in height: CGFloat) {
        // Create 15 items scattered randomly
        items = (0..<15).map { _ in
            FloatingItem(
                imageName: images.randomElement()!,
                size: CGFloat.random(in: 20...45),
                xPosition: CGFloat.random(in: 0.05...0.95),
                yOffset: CGFloat.random(in: 0...height),
                speed: 1.5,
                rotation: Double.random(in: 0...360),
                rotationSpeed: Double.random(in: -0.5...0.5)
            )
        }
    }
    
    private func updateItems(in height: CGFloat) {
        for i in items.indices {
            // Move up
            items[i].yOffset -= items[i].speed
            // Rotate
            items[i].rotation += items[i].rotationSpeed
            
            // If it goes completely off top, reset to bottom
            if items[i].yOffset < -100 {
                items[i].yOffset = height + 100
                items[i].xPosition = CGFloat.random(in: 0.05...0.95)
                items[i].imageName = images.randomElement()!
            }
        }
    }
}

struct FloatingItem: Identifiable {
    let id = UUID()
    var imageName: String
    var size: CGFloat
    var xPosition: CGFloat
    var yOffset: CGFloat
    var speed: CGFloat
    var rotation: Double
    var rotationSpeed: Double
}
