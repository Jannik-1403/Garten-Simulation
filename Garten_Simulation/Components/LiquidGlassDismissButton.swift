import SwiftUI

struct LiquidGlassDismissButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(.secondary)
                .frame(width: 32, height: 32)
                .background(Circle().fill(.regularMaterial))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("Schließen"))
    }
}

private struct GlassDismissOverlayModifier: ViewModifier {
    @Environment(\.dismiss) private var dismiss
    var onDismiss: (() -> Void)?

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topTrailing) {
                LiquidGlassDismissButton {
                    FeedbackManager.shared.playTap()
                    onDismiss?()
                    dismiss()
                }
                .padding(.top, 16)
                .padding(.trailing, 20)
            }
    }
}

extension View {
    /// Schließen-Button oben rechts (Glas-Kreis) wie im Shop.
    func glassDismissOverlay(onDismiss: (() -> Void)? = nil) -> some View {
        modifier(GlassDismissOverlayModifier(onDismiss: onDismiss))
    }
}
