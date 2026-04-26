import SwiftUI

struct PfadSchwierigkeitsView: View {
    @EnvironmentObject var pfadStore: GartenPfadStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settingsStore: SettingsStore

    @State private var ausgewaehlt: PfadSchwierigkeit = .anfaenger
    @State private var zeigeRitualConfig: Bool = false

    var body: some View {
        ZStack {
            Color.appHintergrund.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Igel oben
                Text("🦔")
                    .font(.system(size: 72))
                    .padding(.bottom, 8)

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
                        Button {
                            withAnimation(.bouncy(duration: 0.2)) {
                                ausgewaehlt = stufe
                            }
                        } label: {
                            SchwierigkeitsCard(
                                stufe: stufe,
                                istAusgewaehlt: ausgewaehlt == stufe
                            )
                        }
                        .buttonStyle(Card3DButtonStyle())
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                // Start-Button
                Button {
                    zeigeRitualConfig = true
                } label: {
                    Text(NSLocalizedString("pfad_schwierigkeit_starten", comment: ""))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(DuolingoButtonStyle(size: .large, backgroundColor: ausgewaehlt.farbe, shadowColor: ausgewaehlt.farbe.darker()))
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
        .sheet(isPresented: $zeigeRitualConfig) {
            HabitStackConfigView()
        }
    }
}

struct Card3DButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .offset(y: configuration.isPressed ? 3 : 0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct SchwierigkeitsCard: View {
    let stufe: PfadSchwierigkeit
    let istAusgewaehlt: Bool

    private var iconName: String {
        switch stufe {
        case .anfaenger: return "leaf.fill"
        case .fortgeschritten: return "shield.fill"
        case .experte: return "flame.fill"
        }
    }

    var body: some View {
        ZStack {
            // 3D Shadow/Depth
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(stufe.farbe.darker(by: 0.15))
                .frame(maxWidth: .infinity)
                .frame(height: 84)
                .offset(y: 4)

            // Main Face
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [stufe.farbe.lighter(by: 0.1), stufe.farbe],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(maxWidth: .infinity)
                .frame(height: 84)

            // Content
            HStack(spacing: 16) {
                // System-Icon
                Image(systemName: iconName)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 52, height: 52)
                    .background(.white.opacity(0.15), in: Circle())
                    .shadow(color: .black.opacity(0.1), radius: 2, y: 1)

                VStack(alignment: .leading, spacing: 3) {
                    Text(NSLocalizedString(stufe.titelKey, comment: ""))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Text(NSLocalizedString(stufe.beschreibungKey, comment: ""))
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.85))
                        .lineLimit(2)
                }

                Spacer()

                // Checkmark for Selection
                if istAusgewaehlt {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 26))
                        .foregroundColor(.white)
                        .background(Circle().fill(stufe.farbe.darker(by: 0.2)))
                } else {
                    Circle()
                        .strokeBorder(Color.white.opacity(0.5), lineWidth: 2)
                        .frame(width: 26, height: 26)
                }
            }
            .padding(.horizontal, 16)
        }
        .scaleEffect(istAusgewaehlt ? 1.02 : 1.0)
        .opacity(istAusgewaehlt ? 1.0 : 0.7)
        .animation(.bouncy(duration: 0.2), value: istAusgewaehlt)
    }
}
