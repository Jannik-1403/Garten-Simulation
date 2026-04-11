import SwiftUI

struct OnboardingIgelView: View {
    @EnvironmentObject var settings: SettingsStore
    let pose: IgelPose
    let sprechblasenText: String

    // Backwards-compat initializer (old API)
    init(text: String, daumenHoch: Bool = false) {
        self.pose = daumenHoch ? .daumenHoch : .neutral
        self.sprechblasenText = text
    }
    
    // Primary initializer (new API)
    init(pose: IgelPose, sprechblasenText: String) {
        self.pose = pose
        self.sprechblasenText = sprechblasenText
    }

    private var rotationDegrees: Double {
        switch pose {
        case .daumenHoch: return -8
        case .winkt:      return -6
        default:          return 0
        }
    }

    private var scaleFactor: CGFloat {
        switch pose {
        case .daumenHoch, .feiert: return 1.12
        default:                   return 1.0
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            // MARK: - Sprechblase
            ZStack(alignment: .bottom) {
                // Background bubble
                Text(sprechblasenText)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .frame(maxWidth: 260)
                    .background {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color(UIColor.systemBackground))
                            .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                    }
                
                // Triangle pointer
                Image(systemName: "triangle.fill")
                    .resizable()
                    .frame(width: 12, height: 6)
                    .rotationEffect(.degrees(180))
                    .foregroundStyle(Color(UIColor.systemBackground))
                    .offset(y: 5)
            }
            .padding(.bottom, 6)
            
            // MARK: - Igel
            Image("Powerup-Tier-Freund")
                .resizable()
                .scaledToFit()
                .frame(width: 130, height: 130)
                .rotationEffect(.degrees(rotationDegrees))
                .scaleEffect(scaleFactor)
                .shadow(color: .black.opacity(0.04), radius: 5, y: 3)
                .id("igel_image")
        }
        .padding(.top, -20)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: scaleFactor)
    }
}

// MARK: - Pose Enum used across Onboarding
enum IgelPose {
    case neutral
    case erklaert
    case fragt
    case daumenHoch
    case giesst
    case winkt
    case feiert
}

#Preview {
    ZStack {
        Color.appHintergrund.ignoresSafeArea()
        OnboardingIgelView(pose: .daumenHoch, sprechblasenText: "Hallo! Ich bin Igel.")
    }
}
