import SwiftUI

struct PlantDifficultySelectView: View {
    let payload: ShopDetailPayload
    let onStart: (PfadSchwierigkeit) -> Void
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.dismiss) private var dismiss

    @State private var ausgewaehlt: PfadSchwierigkeit = .anfaenger

    var body: some View {
        ZStack {
            Color.appHintergrund.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer().frame(height: 32)
                
                HStack {
                    Spacer()
                    LiquidGlassDismissButton {
                        FeedbackManager.shared.playTap()
                        dismiss()
                    }
                    .padding(.trailing, 16)
                }

                Spacer()

                // Icon/Plant graphic
                if let basePlant = GameDatabase.shared.plant(for: payload.id) {
                    PlantIconView(plant: basePlant, seltenheit: .bronze, size: 80, alwaysShowFullGrown: true)
                        .padding(.bottom, 8)
                } else if UIImage(named: payload.icon) != nil {
                    Image(payload.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .padding(.bottom, 8)
                } else {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.green)
                        .padding(.bottom, 8)
                }

                // Titel
                Text(settings.localizedString(for: "pfad_schwierigkeit_titel"))
                    .font(.system(size: 26, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Text(settings.localizedString(for: "pfad_schwierigkeit_untertitel"))
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 8)

                Spacer().frame(height: 36)

                // Drei Auswahl-Cards
                VStack(spacing: 12) {
                    ForEach(PfadSchwierigkeit.allCases, id: \.self) { stufe in
                        let isSelected = (ausgewaehlt == stufe)
                        Item3DButton(
                            farbe: isSelected ? stufe.farbe : Color(.secondarySystemGroupedBackground),
                            sekundaerFarbe: isSelected ? stufe.farbe.darker() : Color(.systemGray4),
                            groesse: 80,
                            isRectangular: true,
                            aktion: {
                                FeedbackManager.shared.playTap()
                                withAnimation { ausgewaehlt = stufe }
                            }
                        ) {
                            HStack(spacing: 16) {
                                Image(systemName: stufe.icon)
                                    .font(.system(size: 24))
                                    .frame(width: 44, height: 44)
                                    .background(Circle().fill(isSelected ? Color.white.opacity(0.2) : stufe.farbe.opacity(0.1)))
                                    .foregroundColor(isSelected ? .white : stufe.farbe)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(settings.localizedString(for: stufe.titelKey))
                                        .font(.system(size: 17, weight: .bold, design: .rounded))
                                        .foregroundColor(isSelected ? .white : .primary)
                                    Text(settings.localizedString(for: stufe.beschreibungKey))
                                        .font(.system(size: 13))
                                        .foregroundStyle(isSelected ? Color.white.opacity(0.8) : .secondary)
                                }
                                
                                Spacer()
                                
                                if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.white)
                                        .font(.system(size: 22))
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                // Start-Button
                Button {
                    onStart(ausgewaehlt)
                } label: {
                    Text(settings.localizedString(for: "pfad_schwierigkeit_starten"))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(DuolingoButtonStyle(size: .large, backgroundColor: ausgewaehlt.farbe, shadowColor: ausgewaehlt.farbe.darker()))
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
    }
}
