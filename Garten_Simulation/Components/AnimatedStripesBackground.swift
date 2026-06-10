import SwiftUI

struct AnimatedStripesBackground: View {
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let diagonal = sqrt(width * width + height * height)
            
            // "Kleiner werden und dafür mehr"
            let stripeWidth: CGFloat = 8
            let spacing: CGFloat = 8
            let totalStripes = Int(diagonal / (stripeWidth + spacing)) + 6
            
            HStack(spacing: spacing) {
                ForEach(0..<totalStripes, id: \.self) { _ in
                    Rectangle()
                        .fill(color)
                        .frame(width: stripeWidth)
                        // "weicher werden"
                        .blur(radius: 0.5)
                }
            }
            .frame(width: diagonal * 2, height: diagonal * 2)
            // -45 Grad Neigung (///)
            .rotationEffect(.degrees(-45))
            .position(x: width / 2, y: height / 2)
        }
        .clipped()
        // "mehr im Hintergrund" aber wieder "stärker"
        .opacity(0.20)
        .allowsHitTesting(false)
    }
}
