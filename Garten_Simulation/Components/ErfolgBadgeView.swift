import SwiftUI

struct ErfolgBadgeView: View {
    let erfolg: Erfolg
    let istFreigeschaltet: Bool
    
    var body: some View {
        ZStack {
            // Custom Badge Artwork
            Image(erfolg.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80) // Standard grid size
                .shadow(
                    color: istFreigeschaltet ? erfolg.farbe.opacity(0.3) : .clear,
                    radius: 8, y: 4
                )

            // Icon (ONLY if LOCKED)
            if !istFreigeschaltet {
                Image(systemName: "lock.fill")
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
            }

            // Progress Indicator (Anchored at the bottom)
            VStack {
                Spacer()
                Text(erfolg.fortschrittLabel)
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(.black.opacity(0.4))
                            .overlay(Capsule().stroke(.white.opacity(0.2), lineWidth: 0.5))
                    )
                    .offset(y: 4) // Positioned slightly below the badge
            }
            .frame(width: 80, height: 80)
        }
        .frame(width: 80, height: 90) // Extra height for the label
        // Locked State Aesthetics
        .grayscale(istFreigeschaltet ? 0 : 1)
        .opacity(istFreigeschaltet ? 1 : 0.6)
    }
}
