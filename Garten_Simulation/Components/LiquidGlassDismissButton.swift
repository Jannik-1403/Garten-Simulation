import SwiftUI

struct LiquidGlassDismissButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(.primary)
                .padding(10)
        }
        .buttonStyle(.plain)
    }
}
