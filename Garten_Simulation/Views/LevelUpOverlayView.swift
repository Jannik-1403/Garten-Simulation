import SwiftUI
import DotLottie

struct LevelUpOverlayView: View {
    @Binding var isVisible: Bool
    var stufe: PflanzenStufe?

    var body: some View {
        if isVisible {
            ZStack {
                // Dunkles Dimm-Overlay
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                VStack(spacing: 20) {
                    // Lottie-Animation zentriert
                    DotLottieAnimation(
                        webURL: "https://lottie.host/bd7993da-11cc-4e38-8b7c-5eba53dd788b/zVMrBPKTNT.lottie",
                        config: .init(autoplay: true, loop: false)
                    )
                    .view()
                    .frame(width: 300, height: 300)
                    .allowsHitTesting(false)
                    
                    if let stufe = stufe {
                        Text(NSLocalizedString(stufe.labelKey, comment: ""))
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(stufe.farbe.opacity(0.8))
                                    .overlay(Capsule().stroke(Color.white.opacity(0.5), lineWidth: 1))
                            )
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
            .zIndex(999)
            .onAppear {
                // Haptic Feedback beim Level-Up
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)

                // Overlay nach 2,5 Sekunden automatisch ausblenden
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.easeOut(duration: 0.4)) {
                        isVisible = false
                    }
                }
            }
        }
    }
}

#Preview {
    LevelUpOverlayView(isVisible: .constant(true), stufe: .gold2)
}
