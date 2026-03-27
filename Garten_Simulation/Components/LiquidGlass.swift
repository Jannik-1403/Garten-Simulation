import SwiftUI

struct LiquidGlassModifier: ViewModifier {
    var opacity: Double = 0.08
    var borderColor: Color = .primary.opacity(0.1)
    
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .background(Color.white.opacity(opacity))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(borderColor, lineWidth: 0.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.03), radius: 10, x: 0, y: 5)
    }
}

extension View {
    func liquidGlass(opacity: Double = 0.08, borderColor: Color = .primary.opacity(0.1)) -> some View {
        self.modifier(LiquidGlassModifier(opacity: opacity, borderColor: borderColor))
    }
}
