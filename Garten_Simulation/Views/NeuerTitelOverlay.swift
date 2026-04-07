import SwiftUI

struct NeuerTitelOverlay: View {
    @EnvironmentObject var settings: SettingsStore
    let titel: PlayerTitle
    let onDismiss: () -> Void
    
    @State private var animateIcon = false
    @State private var animateText = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 24) {
                // 3D Text Celebration
                TitelTextView(
                    titel: titel,
                    fontSize: 26
                )
                .scaleEffect(animateText ? 1.0 : 0.8)

                // Confirm Button
                Button {
                    onDismiss()
                } label: {
                    Text(settings.localizedString(for: "button.ok"))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(titel.titleColor)
                                .shadow(color: titel.titleColor.opacity(0.4), radius: 8, y: 4)
                        )
                        .foregroundStyle(.white)
                }
                .padding(.top, 20)
                .padding(.horizontal, 40)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .shadow(color: .black.opacity(0.15), radius: 20)
            )
            .padding(.horizontal, 24)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1)) {
                    animateIcon = true
                }
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                    animateText = true
                }
            }
        }
    }
}

#Preview {
    NeuerTitelOverlay(
        titel: GameDatabase.allTitles[0],
        onDismiss: {}
    )
}
