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

    var shadowDepth: CGFloat { 4 }
}

// MARK: - Color Tokens
// Swap Color(red:green:blue:) for Color("DuoGreenFace") / Color("DuoGreenShadow")
// once you add those to the asset catalog.

private extension Color {
    static let duoGreenFace   = Color(red: 0.330, green: 0.758, blue: 0.009)
    static let duoGreenShadow = Color(red: 0.345, green: 0.646, blue: 0.000)
}

// MARK: - DuolingoButtonStyle

struct DuolingoButtonStyle: ButtonStyle {
    var size: DuoButtonSize = .medium
    var fillWidth: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed

        configuration.label
            .font(size.font)
            .textCase(.uppercase)
            .foregroundStyle(.white)
            .padding(.vertical, size.verticalPadding)
            .padding(.horizontal, size.horizontalPadding)
            .frame(maxWidth: fillWidth ? .infinity : nil)
            .background(
                RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
                    .fill(Color.duoGreenFace)
                    .shadow(
                        color: .duoGreenShadow,
                        radius: 0,
                        y: pressed ? 0 : size.shadowDepth
                    )
            )
            .offset(y: pressed ? size.shadowDepth : 0)
            .animation(.bouncy(duration: 0.2), value: pressed)
            // Haptic fires only on press-down (condition: newValue == true)
            .sensoryFeedback(
                .impact(flexibility: .soft, intensity: 0.75),
                trigger: pressed
            ) { _, newValue in
                newValue
            }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        Button("Weiter") {}
            .buttonStyle(DuolingoButtonStyle(size: .large))

        Button("Speichern") {}
            .buttonStyle(DuolingoButtonStyle())

        Button("OK") {}
            .buttonStyle(DuolingoButtonStyle(size: .small))

        Button("Inline") {}
            .buttonStyle(DuolingoButtonStyle(size: .small, fillWidth: false))
    }
    .padding(32)
}
