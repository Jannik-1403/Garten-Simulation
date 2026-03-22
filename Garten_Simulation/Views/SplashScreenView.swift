import SwiftUI

struct SplashScreenView: View {
    @State private var zeigeHauptApp = false
    @State private var skalierung: CGFloat = 0.3
    @State private var opazitaet: Double = 0
    @State private var wackeln = false
    @State private var blaetter: [BlattPartikel] = (0..<12).map { _ in BlattPartikel() }
    
    var body: some View {
        if zeigeHauptApp {
            ContentView()
                .transition(.opacity)
        } else {
            ZStack {
                LinearGradient(
                    colors: [.blue.opacity(0.6), .cyan.opacity(0.4), .green.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Fliegende Blätter
                ForEach(blaetter) { blatt in
                    Text("🍃")
                        .font(.system(size: blatt.groesse))
                        .position(x: blatt.x, y: blatt.y)
                        .rotationEffect(.degrees(blatt.rotation))
                        .opacity(opazitaet)
                }
                
                VStack(spacing: 24) {
                    // Pflanze mit Animation
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.2))
                            .frame(width: 160, height: 160)
                        
                        Text("🌱")
                            .font(.system(size: 90))
                            .rotationEffect(.degrees(wackeln ? -15 : 15))
                            .animation(
                                .easeInOut(duration: 0.8)
                                .repeatForever(autoreverses: true),
                                value: wackeln
                            )
                    }
                    .scaleEffect(skalierung)
                    
                    VStack(spacing: 8) {
                        Text("Mein Garten")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        
                        Text("Wachse jeden Tag 🌿")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .opacity(opazitaet)
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    skalierung = 1.0
                    opazitaet = 1.0
                }
                wackeln = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        zeigeHauptApp = true
                    }
                }
            }
        }
    }
}

struct BlattPartikel: Identifiable {
    let id = UUID()
    let x: CGFloat = CGFloat.random(in: 0...400)
    let y: CGFloat = CGFloat.random(in: 0...800)
    let groesse: CGFloat = CGFloat.random(in: 15...35)
    let rotation: Double = Double.random(in: 0...360)
}

#Preview {
    SplashScreenView()
}
