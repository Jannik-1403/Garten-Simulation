import SwiftUI

struct LiquidGlassDismissButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.secondary)
                .frame(width: 32, height: 32)
                .background(Circle().fill(.regularMaterial))
        }
        .buttonStyle(.plain)
    }
}
