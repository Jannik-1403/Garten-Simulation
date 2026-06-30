import SwiftUI

// MARK: - Size Variants

enum DuoButtonSize {
    case small, medium, large

    var verticalPadding: CGFloat {
        switch self {
        case .small:  return 10
        case .medium: return 14
        case .large:  return 18
        }
    }

    var horizontalPadding: CGFloat {
        switch self {
        case .small:  return 16
        case .medium: return 20
        case .large:  return 24
        }
    }

    var font: Font {
        switch self {
        case .small:  return .system(.subheadline, design: .rounded, weight: .bold)
        case .medium: return .system(.body,        design: .rounded, weight: .bold)
        case .large:  return .system(.title3,      design: .rounded, weight: .bold)
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .small:  return 10
        case .medium: return 12
        case .large:  return 16
        }
    }

    var shadowDepth: CGFloat { 6 }
}

// MARK: - Color Tokens
// Swap Color(red:green:blue:) for Color("DuoGreenFace") / Color("DuoGreenShadow")
// once you add those to the asset catalog.

private extension Color {
    static let duoGreenFace   = Color(red: 0.330, green: 0.758, blue: 0.009)
    static let duoGreenShadow = Color(red: 0.345, green: 0.646, blue: 0.000)
}

extension Color {
    func darker() -> Color {
        let ui = UIColor(self)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return Color(hue: h, saturation: min(s + 0.1, 1.0),
                     brightness: max(b - 0.22, 0), opacity: a)
    }
}

// MARK: - DuolingoButtonStyle

struct DuolingoButtonStyle: ButtonStyle {
    var size: DuoButtonSize = .medium
    var fillWidth: Bool = true
    var backgroundColor: Color = .duoGreenFace
    var shadowColor: Color = .duoGreenShadow
    var foregroundColor: Color = .white
    var isPermanentlyPressed: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        DuolingoButtonVisualView(
            configuration: configuration,
            size: size,
            fillWidth: fillWidth,
            backgroundColor: backgroundColor,
            shadowColor: shadowColor,
            foregroundColor: foregroundColor,
            isPermanentlyPressed: isPermanentlyPressed
        )
    }
}

private struct DuolingoButtonVisualView: View {
    let configuration: ButtonStyle.Configuration
    let size: DuoButtonSize
    let fillWidth: Bool
    let backgroundColor: Color
    let shadowColor: Color
    let foregroundColor: Color
    let isPermanentlyPressed: Bool

    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        let pressed = configuration.isPressed
        let depth = size.shadowDepth
        
        let actualBackground = isEnabled ? backgroundColor : Color(hex: "#E5E5EA")
        let actualShadow = isEnabled ? shadowColor : Color(hex: "#C7C7CC")
        let actualForeground = isEnabled ? foregroundColor : Color(hex: "#AEAEB2")
        
        return configuration.label
            .font(size.font)
            .textCase(.uppercase)
            .foregroundStyle(actualForeground)
            .padding(.vertical, size.verticalPadding)
            .padding(.horizontal, size.horizontalPadding)
            .frame(maxWidth: fillWidth ? .infinity : nil)
            .offset(y: (pressed || isPermanentlyPressed) ? 0 : -depth)
            .background(
                ZStack {
                    // Static Shadow (Bottom Layer)
                    RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
                        .fill(actualShadow)
                        .overlay(RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous).stroke(Color.black.opacity(0.1), lineWidth: 1))
                    
                    // Main face (Top Layer)
                    RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
                        .fill(actualBackground)
                        .overlay(RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous).stroke(Color.black.opacity(0.15), lineWidth: 1))
                        .offset(y: (pressed || isPermanentlyPressed) ? 0 : -depth)
                }
            )
            .animation(pressed ? nil : .spring(response: 0.15, dampingFraction: 0.6), value: pressed)
            .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.8), trigger: pressed)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        Button("Continue") {}
            .buttonStyle(DuolingoButtonStyle(size: .large))

        Button("Save") {}
            .buttonStyle(DuolingoButtonStyle())

        Button("OK") {}
            .buttonStyle(DuolingoButtonStyle(size: .small))

        Button("Inline") {}
            .buttonStyle(DuolingoButtonStyle(size: .small, fillWidth: false))
    }
    .padding(32)
}
