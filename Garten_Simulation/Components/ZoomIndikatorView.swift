import SwiftUI

struct ZoomIndikatorView: View {
    let zoom: CGFloat
    @State private var sichtbar = true

    var body: some View {
        Text("\(Int(zoom * 100))%")
            .font(.system(size: 12, weight: .semibold, design: .monospaced))
            .foregroundColor(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(.regularMaterial, in: Capsule())
            .opacity(sichtbar ? 1 : 0)
            .onChange(of: zoom) { _ in
                sichtbar = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation { sichtbar = false }
                }
            }
    }
}
