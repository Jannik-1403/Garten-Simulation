import SwiftUI

struct OnboardingZielView: View {
    @EnvironmentObject var data: OnboardingData
    @EnvironmentObject var settings: SettingsStore

    private let maxAuswahl = 3

    var body: some View {
        VStack(spacing: 0) {
            OnboardingIgelView(
                pose: data.gewaehltesZiele.isEmpty ? .fragt : .daumenHoch,
                sprechblasenText: NSLocalizedString("onboarding_ziel_blase", comment: "")
            )
            .padding(.top, 20)

            ScrollView(showsIndicators: false) {
                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 24
                ) {
                    ForEach(OnboardingZiel.allCases) { ziel in
                        let isSelected = data.gewaehltesZiele.contains(ziel)
                        VStack(spacing: 12) {
                            Item3DButton(
                                icon: ziel.iconName,
                                farbe: isSelected ? ziel.color : Color(.systemGray4),
                                sekundaerFarbe: isSelected ? ziel.color.darker() : Color(.systemGray5),
                                groesse: 100,
                                aktion: { toggleZiel(ziel) }
                            )
                            .overlay(alignment: .topTrailing) {
                                if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.green)
                                        .background(Circle().fill(.white))
                                        .font(.title)
                                        .offset(x: 10, y: -10)
                                }
                            }

                            Text(NSLocalizedString(ziel.labelKey, comment: ""))
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .multilineTextAlignment(.center)
                                .foregroundStyle(isSelected ? .primary : .secondary)
                        }
                        .scaleEffect(isSelected ? 1.05 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)

                // "Nicht dabei" → zeigt alle Pflanzen
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation {
                        data.gewaehltesZiele = []
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            data.currentStep += 1
                        }
                    }
                } label: {
                    Text(NSLocalizedString("onboarding_ziel_fehlt", comment: ""))
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 24)
                .padding(.bottom, 20)
            }

            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                FeedbackManager.shared.playTap()
                withAnimation(.easeInOut(duration: 0.35)) {
                    data.currentStep += 1
                }
            } label: {
                Text(NSLocalizedString("onboarding_weiter", comment: ""))
            }
            .buttonStyle(DuolingoButtonStyle(
                size: .large,
                backgroundColor: Color.blauPrimary,
                shadowColor: Color.blauPrimary.darker(),
                foregroundColor: .white
            ))
            .disabled(data.gewaehltesZiele.isEmpty)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    private func toggleZiel(_ ziel: OnboardingZiel) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        FeedbackManager.shared.playTap()
        withAnimation(.spring()) {
            if data.gewaehltesZiele.contains(ziel) {
                data.gewaehltesZiele.removeAll { $0 == ziel }
            } else if data.gewaehltesZiele.count < maxAuswahl {
                data.gewaehltesZiele.append(ziel)
            }
        }
    }
}
