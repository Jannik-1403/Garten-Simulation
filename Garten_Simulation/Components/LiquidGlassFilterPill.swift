import SwiftUI

struct LiquidGlassFilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isSelected ? Color.blauPrimary : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                // Liquid Glass — genau wie Apple App Store Pills:
                .background {
                    if isSelected {
                        // Aktiv: leicht getöntes Material
                        Capsule()
                            .fill(Color.blauPrimary.opacity(0.12))
                            .overlay(
                                Capsule()
                                    .strokeBorder(Color.blauPrimary.opacity(0.35), lineWidth: 1)
                            )
                    } else {
                        // Inaktiv: reines Liquid Glass
                        Capsule()
                            .fill(.regularMaterial)
                            .overlay(
                                Capsule()
                                    .strokeBorder(
                                        Color.primary.opacity(0.08),
                                        lineWidth: 0.5
                                    )
                            )
                    }
                }
        }
        .buttonStyle(.plain)
        // Kleine Press-Animation auch für Pills
        .scaleEffect(1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isSelected)
    }
}
