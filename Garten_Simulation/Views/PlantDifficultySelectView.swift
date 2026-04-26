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
                    Button { 
                        FeedbackManager.shared.playTap()
                        dismiss() 
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.secondary)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(.regularMaterial))
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 24)
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
                    Text("🦔")
                        .font(.system(size: 80))
                        .padding(.bottom, 8)
                }

                // Titel
                Text(NSLocalizedString("pfad_schwierigkeit_titel", comment: ""))
                    .font(.system(size: 26, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Text(NSLocalizedString("pfad_schwierigkeit_untertitel", comment: ""))
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 8)

                Spacer().frame(height: 36)

                // Drei Auswahl-Cards
                VStack(spacing: 12) {
                    ForEach(PfadSchwierigkeit.allCases, id: \.self) { stufe in
                        SchwierigkeitsCard(
                            stufe: stufe,
                            istAusgewaehlt: ausgewaehlt == stufe
                        )
                        .onTapGesture {
                            withAnimation(.bouncy(duration: 0.2)) {
                                ausgewaehlt = stufe
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                // Start-Button
                Button {
                    onStart(ausgewaehlt)
                } label: {
                    Text(NSLocalizedString("pfad_schwierigkeit_starten", comment: ""))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(DuolingoButtonStyle(size: .large, backgroundColor: ausgewaehlt.farbe, shadowColor: ausgewaehlt.farbe.darker()))
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
    }
}
