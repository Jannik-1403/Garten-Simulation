import SwiftUI

/// Kompakte Stapel-Anzeige für mehrere aktive Unkräuter (Duolingo-Stil).
struct WeedStackIndicator: View {
    let count: Int
    var iconSize: CGFloat = 22
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Zeige immer nur ein Unkraut-Icon
            Image("Unkraut")
                .resizable()
                .scaledToFit()
                .frame(width: 90, height: 90)
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
