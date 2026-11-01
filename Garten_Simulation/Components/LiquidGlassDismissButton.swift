import SwiftUI

struct LiquidGlassDismissButton: View {
    @Environment(\.colorScheme) private var colorScheme
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.system(size: 24, weight: .heavy))
                .foregroundStyle(colorScheme == .dark ? .white : .black)
                .padding(8)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(String(localized: "common.close", defaultValue: "Schließen"))
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
                .padding(.top, 20)
                .padding(.trailing, 24)
            }
    }
}

extension View {
    func glassDismissOverlay(onDismiss: (() -> Void)? = nil) -> some View {
        modifier(GlassDismissOverlayModifier(onDismiss: onDismiss))
    }
}
