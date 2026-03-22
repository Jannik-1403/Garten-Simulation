import SwiftUI

struct DepthButtonStyle: ButtonStyle {
    private enum ButtonForm {
        case rectangle
        case ellipse
    }
    
    private var foregroundColor: Color
    private var backgroundColor: Color
    private var form: ButtonForm
    private var cornerRadius: CGFloat = 0
    
    // Rechteckiger Button (z.B. "Gießen", "Weiter")
    init(foregroundColor: Color, backgroundColor: Color, cornerRadius: CGFloat) {
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.form = .rectangle
        self.cornerRadius = cornerRadius
    }
    
    // Runder Button (z.B. Pflanzen im Grid)
    init(foregroundColor: Color, backgroundColor: Color) {
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.form = .ellipse
    }
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            buttonForm(color: backgroundColor)
            buttonForm(color: foregroundColor)
                .overlay {
                    configuration.label
                }
                .offset(y: configuration.isPressed ? 0 : -8)
        }
        .animation(.spring(.snappy(duration: 0.02)), value: configuration.isPressed)
    }
    
    @ViewBuilder
    private func buttonForm(color: Color) -> some View {
        switch form {
        case .rectangle:
            RoundedRectangle(cornerRadius: cornerRadius).fill(color)
        case .ellipse:
            Ellipse().fill(color)
        }
    }
}
