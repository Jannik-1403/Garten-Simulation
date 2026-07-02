import SwiftUI

struct PfadMeilensteinOverlay: View {
    let meilensteinTitel: String
    let belohnung: String
    let onDismiss: () -> Void
    
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    @State private var zeigeInhalt = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Lottie Banner entfernt wegen Abstürzen
                Color.clear
                .frame(width: ScreenSize.width * 1.2, height: ScreenSize.width)
                .overlay(
                    VStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(Color.goldPrimary.gradient)
                            .shadow(color: .goldPrimary.opacity(0.5), radius: 20)
                        
                        Text(String(localized: "pfad_meilenstein_titel"))
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                    }
                    .offset(y: 40)
                )
                
                VStack(spacing: 12) {
                    Text(NSLocalizedString(meilensteinTitel, comment: ""))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9))
                    
                    Text(belohnung)
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(Color.goldPrimary)
                    
                    if gardenStore.isProUser {
                        Stat3DTitleView(title: "pro Bonus", color: .goldPrimary, size: 14)
                            .padding(.top, 2)
                    }
                    
                    Text(String(localized: "psychology.fact.milestone", defaultValue: "Dopamin-Ausschüttung erkannt: Du bist auf dem absolut richtigen Weg!"))
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.top, 16)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 60)
                
                Spacer()
                
                Button {
                    onDismiss()
                } label: {
                    Text(String(localized: "common_continue"))
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
