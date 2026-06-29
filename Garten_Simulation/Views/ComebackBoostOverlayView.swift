import SwiftUI

struct ComebackBoostOverlayView: View {
    @Binding var isVisible: Bool
    let rewardPercent: Int
    @EnvironmentObject var settings: SettingsStore

    var body: some View {
        if isVisible {
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 20) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 72))
                        .foregroundStyle(Color.gruenPrimary)
                        .symbolEffect(.bounce, value: isVisible)

                    Text(String(localized: "weed.comeback.overlay.title"))
                        .font(.title)
                        .fontWeight(.black)
                        .multilineTextAlignment(.center)

                    Text(
                        String(format: String(localized: "weed.comeback.overlay.body"), Int(GameConstants.comebackBoostDurationHours),
                            "\(rewardPercent)%"
                        )
                    )
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                    Button(String(localized: "weed.comeback.overlay.button")) {
                        withAnimation { isVisible = false }
                    }
                    .buttonStyle(DuolingoButtonStyle(
                        size: .large,
                        backgroundColor: .gruenPrimary,
                        shadowColor: .gruenSecondary
                    ))
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
                }
            }
            .transition(.opacity.combined(with: .scale(scale: 0.92)))
        }
    }
}
