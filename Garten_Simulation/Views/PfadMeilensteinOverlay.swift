import SwiftUI
import DotLottie

struct PfadMeilensteinOverlay: View {
    let meilensteinTitel: String
    let belohnung: String
    let onDismiss: () -> Void
    
    @EnvironmentObject var settings: SettingsStore
    @State private var zeigeInhalt = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Lottie Banner (Reuse Level Up Banner)
                SafeDotLottieView(
                    url: "https://lottie.host/bd7993da-11cc-4e38-8b7c-5eba53dd788b/zVMrBPKTNT.lottie",
                    animationConfig: .init(autoplay: true, loop: false, speed: 0.8),
                    fixedSize: CGSize(width: UIScreen.main.bounds.width * 1.2, height: UIScreen.main.bounds.width)
                )
                .overlay(
                    VStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(Color.goldPrimary.gradient)
                            .shadow(color: .goldPrimary.opacity(0.5), radius: 20)
                        
                        Text(settings.localizedString(for: "pfad_meilenstein_titel"))
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                    }
                    .offset(y: 40)
                )
                
                VStack(spacing: 12) {
                    Text(settings.localizedString(for: meilensteinTitel))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9))
                    
                    Text(belohnung)
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(Color.goldPrimary)
                }
                .padding(.top, 60)
                
                Spacer()
                
                Button {
                    onDismiss()
                } label: {
                    Text(settings.localizedString(for: "common_continue"))
                }
                .buttonStyle(DuolingoButtonStyle(
                    size: .large,
                    backgroundColor: Color.goldPrimary,
                    shadowColor: Color.goldPrimary.darker(),
                    foregroundColor: .white
                ))
                .padding(.horizontal, 24)
                .padding(.bottom, 60)
            }
            .scaleEffect(zeigeInhalt ? 1.0 : 0.8)
            .opacity(zeigeInhalt ? 1.0 : 0.0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                zeigeInhalt = true
            }
        }
        .onTapGesture {
            onDismiss()
        }
    }
}
