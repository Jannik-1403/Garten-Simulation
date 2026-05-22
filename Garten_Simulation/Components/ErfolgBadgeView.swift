import SwiftUI

extension View {
    @ViewBuilder
    func applyErfolgFarbe(for tier: ErfolgTier) -> some View {
        switch tier {
        case .bronze:
            self
                .hueRotation(.degrees(-25))
                .saturation(0.6)
                .colorMultiply(Color(red: 0.85, green: 0.6, blue: 0.4))
                .contrast(1.25)
        case .silber:
            self
                .grayscale(1.0)
                .contrast(1.2)
                .brightness(0.05)
                .colorMultiply(Color(red: 0.8, green: 0.85, blue: 0.95))
        case .gold:
            self // Gold is the base image, so no filters needed
        case .diamant:
            self
                .hueRotation(.degrees(180))
                .colorMultiply(Color(hex: "#E0F7FA"))
        case .master, .max:
            self // Base image Achievment_Rot is already red, no filter needed
        }
    }
}
struct ErfolgBadgeView: View {
    let erfolg: Erfolg
    let istFreigeschaltet: Bool
    
    var body: some View {
        ZStack {
            // Custom Badge Artwork
            Image(erfolg.mixedImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100) // Compact size
                .applyErfolgFarbe(for: erfolg.tier)
                .grayscale(istFreigeschaltet ? 0 : 1)
                .opacity(istFreigeschaltet ? 1 : 0.5)
                .shadow(color: istFreigeschaltet ? erfolg.tier.color.opacity(0.6) : .clear, radius: 8, y: 4)

            // Icon (ONLY if LOCKED)
            if !istFreigeschaltet {
                Image(systemName: "lock.fill")
                    .font(.system(size: 24, weight: .black))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.3), radius: 3, y: 1.5)
            }

            // Progress Indicator (Anchored at the bottom) - ONLY shown if locked
            if !istFreigeschaltet {
                VStack {
                    Spacer()
                    Text(erfolg.fortschrittLabel)
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(.black.opacity(0.4))
                                .overlay(Capsule().stroke(.white.opacity(0.2), lineWidth: 0.5))
                        )
                        .offset(y: 4) // Positioned slightly below the badge
                }
                .frame(width: 100, height: 100)
            }
        }
        .frame(width: 100, height: istFreigeschaltet ? 90 : 105) // Tighter frame with no unused vertical padding
        // Locked State Aesthetics
        .grayscale(istFreigeschaltet ? 0 : 1)
        .opacity(istFreigeschaltet ? 1 : 0.6)
    }
}

