import SwiftUI

/// Kompakte Stapel-Anzeige für mehrere aktive Unkräuter (Duolingo-Stil).
struct WeedStackIndicator: View {
    let count: Int
    var iconSize: CGFloat = 22
    var maxVisibleLayers: Int = 3

    private var visibleLayers: Int {
        min(max(count, 1), maxVisibleLayers)
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ZStack {
                ForEach(0..<visibleLayers, id: \.self) { layer in
                    Image(systemName: "leaf.fill")
                        .font(.system(size: iconSize - CGFloat(layer) * 3, weight: .bold))
                        .foregroundStyle(.white.opacity(0.95 - Double(layer) * 0.12))
                        .rotationEffect(.degrees(Double(layer - 1) * 14))
                        .offset(x: CGFloat(layer) * 3, y: CGFloat(-layer) * 2)
                }
            }
            .frame(width: iconSize + 10, height: iconSize + 6)

            if count > 1 {
                Text("×\(count)")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Color.black.opacity(0.22))
                    .clipShape(Capsule())
                    .offset(x: 8, y: 4)
            }
        }
        .accessibilityLabel(Text("\(count) Unkraut"))
    }
}

/// Segment-Leiste: ein Segment pro Unkraut in der Queue, erstes Segment zeigt Teilschritte.
struct WeedQueueStrip: View {
    let weeds: [WeedPatch]
    var segmentHeight: CGFloat = 8

    var body: some View {
        HStack(spacing: 4) {
            ForEach(Array(weeds.enumerated()), id: \.element.id) { index, weed in
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(.systemGray4))

                        Capsule()
                            .fill(index == 0 ? Color.orange : Color.orange.opacity(0.35))
                            .frame(width: geo.size.width * fillRatio(for: weed, isCurrent: index == 0))
                    }
                }
                .frame(height: segmentHeight)
            }
        }
    }

    private func fillRatio(for weed: WeedPatch, isCurrent: Bool) -> CGFloat {
        guard isCurrent else { return 0 }
        return CGFloat(weed.habitsCompleted) / CGFloat(GameConstants.habitsRequiredPerWeed)
    }
}

#Preview {
    VStack(spacing: 24) {
        WeedStackIndicator(count: 1)
        WeedStackIndicator(count: 5)
        WeedQueueStrip(weeds: [
            WeedPatch(removalCost: 30, habitsCompleted: 2, source: .decoration),
            WeedPatch(removalCost: 150, habitsCompleted: 0, source: .decoration),
            WeedPatch(removalCost: 300, habitsCompleted: 0, source: .decoration),
        ])
        .padding(.horizontal, 24)
    }
    .padding()
}
