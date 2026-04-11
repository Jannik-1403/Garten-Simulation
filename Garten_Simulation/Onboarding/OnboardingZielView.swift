import SwiftUI

struct OnboardingZielView: View {
    @EnvironmentObject var data: OnboardingData
    @EnvironmentObject var settings: SettingsStore
    @State private var innerPose: IgelPose = .fragt

    var body: some View {
        VStack(spacing: 0) {
            OnboardingIgelView(
                pose: innerPose,
                sprechblasenText: settings.localizedString(for: "onboarding_ziel_blase")
            )
            .padding(.top, 20)
            
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 24) {
                    ForEach(OnboardingZiel.allCases) { ziel in
                        VStack(spacing: 12) {
                            Item3DButton(
                                icon: ziel.iconName,
                                farbe: ziel.color,
                                sekundaerFarbe: ziel.color.darker(),
                                groesse: 100,
                                aktion: {
                                    selectZiel(ziel)
                                }
                            )
                            .overlay(alignment: .topTrailing) {
                                if data.gewaehltesZiel == ziel {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.green)
                                        .background(Circle().fill(.white))
                                        .font(.title)
                                        .offset(x: 10, y: -10)
                                }
                            }
                            
                            Text(settings.localizedString(for: ziel.labelKey))
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .multilineTextAlignment(.center)
                                .foregroundStyle(data.gewaehltesZiel == ziel ? .primary : .secondary)
                        }
                        .scaleEffect(data.gewaehltesZiel == ziel ? 1.05 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: data.gewaehltesZiel)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                
                Button {
                    selectZielMissing()
                } label: {
                    Text(settings.localizedString(for: "onboarding_ziel_fehlt"))
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 24)
                .padding(.bottom, 20)
            }
            
            // Fixed Bottom Button
            if data.gewaehltesZiel != nil || data.zielFehlt {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    withAnimation(.easeInOut(duration: 0.35)) {
                        data.currentStep += 1
                    }
                } label: {
                    Text(settings.localizedString(for: "onboarding_weiter"))
                }
                .buttonStyle(DuolingoButtonStyle(
                    size: .large,
                    backgroundColor: Color.blauPrimary,
                    shadowColor: Color.blauPrimary.darker(),
                    foregroundColor: .white
                ))
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    private func selectZiel(_ ziel: OnboardingZiel) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        withAnimation(.spring()) {
            data.gewaehltesZiel = ziel
            data.zielFehlt = false
            innerPose = .daumenHoch
        }
    }

    private func selectZielMissing() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation {
            data.gewaehltesZiel = nil
            data.zielFehlt = true
            innerPose = .fragt
        }
    }
}
