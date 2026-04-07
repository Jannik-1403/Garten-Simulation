import SwiftUI
import UserNotifications

struct RetentionSurveyView: View {
    @EnvironmentObject var gardenStore: GardenStore
    @Environment(\.dismiss) var dismiss
    @State private var schritt: Int = 1
    @State private var gewaehlterGrund: RetentionGrund? = nil
    @State private var zeigeNotificationHinweis = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Fortschrittsanzeige
                HStack(spacing: 8) {
                    ForEach(1...3, id: \.self) { i in
                        Capsule()
                            .fill(i <= schritt ? Color.blauPrimary : Color.secondary.opacity(0.3))
                            .frame(height: 4)
                    }
                }
                .padding(.horizontal)

                Spacer()

                switch schritt {
                case 1: schritt1
                case 2: schritt2
                case 3: schritt3
                default: EmptyView()
                }

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    LiquidGlassDismissButton {
                        gardenStore.zeigeGameOverOverlay = false
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: Schritt 1 — Warum aufgehört?
    var schritt1: some View {
        VStack(spacing: 20) {
            Text(NSLocalizedString("retention.frage1.titel", comment: ""))
                .font(.title3)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            VStack(spacing: 12) {
                ForEach(RetentionGrund.allCases) { grund in
                    Button {
                        gewaehlterGrund = grund
                        withAnimation { schritt = 2 }
                    } label: {
                        Text(grund.lokaliserterText)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(DuolingoButtonStyle(
                        size: .medium,
                        backgroundColor: color(for: grund),
                        shadowColor: shadowColor(for: grund)
                    ))
                }
            }
        }
    }

    private func color(for grund: RetentionGrund) -> Color {
        switch grund {
        case .vergessen: return .blauPrimary
        case .keineZeit: return .orangePrimary
        case .keineLust: return .rotPrimary
        case .nichtMehrNoetig: return .gruenPrimary
        case .nichtMotiviert: return .lilaPrimary
        }
    }

    private func shadowColor(for grund: RetentionGrund) -> Color {
        switch grund {
        case .vergessen: return .blauSecondary
        case .keineZeit: return .orangeSecondary
        case .keineLust: return .rotSecondary
        case .nichtMehrNoetig: return .gruenSecondary
        case .nichtMotiviert: return .lilaSecondary
        }
    }

    // MARK: Schritt 2 — Gezielte Folgefrage
    var schritt2: some View {
        VStack(spacing: 20) {
            switch gewaehlterGrund {

            case .vergessen:
                VStack(spacing: 16) {
                    Text(NSLocalizedString("retention.frage2.vergessen", comment: ""))
                        .font(.title3).fontWeight(.bold).multilineTextAlignment(.center)
                    Button {
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
                        withAnimation { schritt = 3 }
                    } label: {
                        Text(NSLocalizedString("retention.notification.aktivieren", comment: ""))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(DuolingoButtonStyle(size: .large, backgroundColor: .blauPrimary, shadowColor: .blauSecondary))
                    weiterButton
                }

            case .keineZeit:
                VStack(spacing: 16) {
                    Text(NSLocalizedString("retention.frage2.keineZeit", comment: ""))
                        .font(.title3).fontWeight(.bold).multilineTextAlignment(.center)
                    ForEach([2, 3, 5], id: \.self) { anzahl in
                        Button {
                            // Tipp für den Nutzer speichern — keine echte Logik nötig
                            withAnimation { schritt = 3 }
                        } label: {
                            Text(String(format: NSLocalizedString("retention.pflanzen.anzahl", comment: ""), anzahl))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(DuolingoButtonStyle(
                            size: .medium,
                            backgroundColor: .orangePrimary,
                            shadowColor: .orangeSecondary
                        ))
                    }
                }

            case .keineLust:
                VStack(spacing: 16) {
                    Text(NSLocalizedString("retention.frage2.keineLust", comment: ""))
                        .font(.title3).fontWeight(.bold).multilineTextAlignment(.center)
                    ForEach(Array(["retention.spass.pflanzen", "retention.spass.coins", "retention.spass.streak", "retention.spass.nichts"].enumerated()), id: \.offset) { index, key in
                        Button {
                            withAnimation { schritt = 3 }
                        } label: {
                            Text(NSLocalizedString(key, comment: ""))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(DuolingoButtonStyle(
                            size: .medium,
                            backgroundColor: index == 3 ? .secondary.opacity(0.8) : .rotPrimary,
                            shadowColor: index == 3 ? .secondary.opacity(0.4) : .rotSecondary
                        ))
                    }
                }

            case .nichtMehrNoetig:
                VStack(spacing: 16) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.yellow)
                    Text(NSLocalizedString("retention.frage2.nichtMehrNoetig", comment: ""))
                        .font(.title3).fontWeight(.bold).multilineTextAlignment(.center)
                    Text(NSLocalizedString("retention.frage2.nichtMehrNoetig.sub", comment: ""))
                        .font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
                    weiterButton
                }

            case .nichtMotiviert:
                VStack(spacing: 16) {
                    Text(NSLocalizedString("retention.frage2.nichtMotiviert", comment: ""))
                        .font(.title3).fontWeight(.bold).multilineTextAlignment(.center)
                    ForEach(["retention.mehr.belohnungen", "retention.mehr.pflanzen", "retention.mehr.erinnerungen", "retention.mehr.anderes"], id: \.self) { key in
                        Button {
                            withAnimation { schritt = 3 }
                        } label: {
                            Text(NSLocalizedString(key, comment: ""))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(DuolingoButtonStyle(
                            size: .medium,
                            backgroundColor: .lilaPrimary,
                            shadowColor: .lilaSecondary
                        ))
                    }
                }

            default:
                weiterButton
            }
        }
    }

    // MARK: Schritt 3 — Abschluss
    var schritt3: some View {
        VStack(spacing: 20) {
            Image(systemName: "leaf.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)

            Text(NSLocalizedString("retention.abschluss.titel", comment: ""))
                .font(.title3).fontWeight(.bold).multilineTextAlignment(.center)

            Text(NSLocalizedString("retention.abschluss.sub", comment: ""))
                .font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)

            Button {
                gardenStore.zeigeGameOverOverlay = false
                dismiss()
            } label: {
                Text(NSLocalizedString("retention.abschluss.button", comment: ""))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(DuolingoButtonStyle(
                size: .large,
                backgroundColor: .gruenPrimary,
                shadowColor: .gruenSecondary
            ))

            Button {
                gardenStore.zeigeGameOverOverlay = false
                dismiss()
            } label: {
                Text(NSLocalizedString("retention.abschluss.nein", comment: ""))
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            }
        }
    }

    var weiterButton: some View {
        Button {
            withAnimation { schritt = 3 }
        } label: {
            Text(NSLocalizedString("retention.weiter", comment: ""))
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(DuolingoButtonStyle(
            size: .medium,
            backgroundColor: .secondary.opacity(0.8),
            shadowColor: .secondary.opacity(0.4)
        ))
    }
}
