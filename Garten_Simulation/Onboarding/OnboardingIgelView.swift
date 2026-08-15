import SwiftUI

struct OnboardingIgelView: View {
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var characterStore: CharacterStore
    let pose: OnboardingIgelPose
    let sprechblasenText: String

    // Backwards-compat initializer (old API)
    init(text: String, daumenHoch: Bool = false) {
        self.pose = daumenHoch ? .daumenHoch : .neutral
        self.sprechblasenText = text
    }
    
    // Primary initializer (new API)
    init(pose: OnboardingIgelPose, sprechblasenText: String) {
        self.pose = pose
        self.sprechblasenText = sprechblasenText
    }

    private var yOffset: CGFloat {
        switch pose {
        case .daumenHoch, .feiert: return -8
        default:                   return 0
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
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .frame(maxWidth: 260)
                    .background {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color(UIColor.systemBackground))
                            .shadow(color: Color(white: 0.85), radius: 0, x: 0, y: 8)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.gray.opacity(0.15), lineWidth: 2)
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
            
            // MARK: - Avatar
            Item3DButton(
                farbe: Color.characterBackground(for: characterStore.profile.backgroundIndex),
                sekundaerFarbe: Color.secondaryCharacterBackground(for: characterStore.profile.backgroundIndex),
                groesse: 140,
                shadowDepthFactor: 0.04,
                aktion: {}
            ) {
                AvatarView(profile: characterStore.profile)
                    .frame(width: 140, height: 140, alignment: .top)
                    .clipShape(Circle())
            }
            .offset(y: yOffset)
            .id("igel_image")
        }
        .padding(.top, -20)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: yOffset)
    }
}

// MARK: - Pose Enum used across Onboarding
enum OnboardingIgelPose {
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
            .environmentObject(SettingsStore())
            .environmentObject(CharacterStore())
    }
}
