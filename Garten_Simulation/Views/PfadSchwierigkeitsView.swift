import SwiftUI

struct PfadSchwierigkeitsView: View {
    let pflanze: HabitModel
    let onAuswahl: (PfadSchwierigkeit) -> Void

    @State private var ausgewaehlt: PfadSchwierigkeit? = nil
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.appHintergrund.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    Text(NSLocalizedString("schwierigkeit.titel", comment: ""))
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .multilineTextAlignment(.center)

                    Text(NSLocalizedString("schwierigkeit.untertitel", comment: ""))
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.top, 36)
                .padding(.bottom, 32)

                // Drei Karten
                VStack(spacing: 14) {
                    ForEach(PfadSchwierigkeit.allCases, id: \.self) { stufe in
                        SchwierigkeitKarte(
                            stufe: stufe,
                            istAusgewaehlt: ausgewaehlt == stufe
                        ) {
                            withAnimation(.bouncy(duration: 0.2)) {
                                ausgewaehlt = stufe
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()

                // Bestätigen-Button
                Button {
                    guard let wahl = ausgewaehlt else { return }
                    onAuswahl(wahl)
                    dismiss()
                } label: {
                    Text(NSLocalizedString("schwierigkeit.bestaetigen", comment: ""))
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(DuolingoButtonStyle(
                    size: .large,
                    backgroundColor: ausgewaehlt != nil ? .gruenPrimary : .gray,
                    shadowColor: ausgewaehlt != nil ? .gruenSecondary : .gray.opacity(0.6),
                    foregroundColor: .white
                ))
                .disabled(ausgewaehlt == nil)
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .presentationDetents([.height(520)])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Einzelne Schwierigkeits-Karte

private struct SchwierigkeitKarte: View {
    let stufe: PfadSchwierigkeit
    let istAusgewaehlt: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(stufe.farbe.opacity(0.15))
                        .frame(width: 52, height: 52)
                    Text(stufe.icon)
                        .font(.system(size: 28))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(NSLocalizedString(stufe.titelKey, comment: ""))
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    Text(NSLocalizedString(stufe.beschreibungKey, comment: ""))
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                // Checkmark
                ZStack {
                    Circle()
                        .stroke(istAusgewaehlt ? stufe.farbe : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    if istAusgewaehlt {
                        Circle()
                            .fill(stufe.farbe)
                            .frame(width: 16, height: 16)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(
                        color: istAusgewaehlt ? stufe.farbe.opacity(0.3) : .black.opacity(0.05),
                        radius: istAusgewaehlt ? 8 : 4,
                        x: 0, y: 2
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(istAusgewaehlt ? stufe.farbe : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}
