import SwiftUI

struct FlyingCoinView: View {
    let startPosition: CGPoint
    let endPosition: CGPoint
    @EnvironmentObject var gardenStore: GardenStore
    var onFinish: () -> Void

    @State private var progress: CGFloat = 0
    @State private var opacity: Double = 1

    var body: some View {
        Image("coin")
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
            .modifier(FlyingCoinModifier(progress: progress, start: startPosition, end: endPosition))
            .opacity(opacity)
            .onAppear {
                // Ein einziger, flüssiger Animations-Zyklus
                withAnimation(.easeInOut(duration: 1.0)) {
                    progress = 1.0
                }
                
                // Timing für den Aufprall (Pop) exakt am Ende der Animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    gardenStore.coinPopTrigger += 1
                    
                    withAnimation(.easeOut(duration: 0.1)) {
                        opacity = 0
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        onFinish()
                    }
                }
            }
    }
}

// Hilfs-Modifier für die flüssige Kurve und Größenänderung
struct FlyingCoinModifier: AnimatableModifier {
    var progress: CGFloat
    let start: CGPoint
    let end: CGPoint
    
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scaleAt(progress))
            .position(positionAt(progress))
    }
    
    private func positionAt(_ p: CGFloat) -> CGPoint {
        // Ein hoher Bogen nach oben
        let midX = (start.x + end.x) / 2
        let midY = min(start.y, end.y) - 180
        
        // Quadratische Bezier-Kurve für maximale Flüssigkeit
        let x = pow(1 - p, 2) * start.x + 2 * (1 - p) * p * midX + pow(p, 2) * end.x
        let y = pow(1 - p, 2) * start.y + 2 * (1 - p) * p * midY + pow(p, 2) * end.y
        return CGPoint(x: x, y: y)
    }
    
    private func scaleAt(_ p: CGFloat) -> CGFloat {
        let peak: CGFloat = 1.8
        let startScale: CGFloat = 0.5
        let endScale: CGFloat = 0.5
        
        if p < 0.5 {
            // Wachsen bis zur Mitte
            return startScale + (p * 2) * (peak - startScale)
        } else {
            // Schrumpfen bis zum Ziel
            return peak - ((p - 0.5) * 2) * (peak - endScale)
        }
    }
}
