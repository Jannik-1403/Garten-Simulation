import SwiftUI

enum TagStatus {
    case erledigt
    case verpasst
    case zukunft
}

struct SternPartikel: Identifiable {
    let id = UUID()
    var x: CGFloat = CGFloat.random(in: -80...80)
    var y: CGFloat = CGFloat.random(in: -100...100)
    var opazitaet: Double = Double.random(in: 0.5...1.0)
    var groesse: CGFloat = CGFloat.random(in: 6...14)
}

struct PflanzenDetailView: View {
    let name: String
    let bildName: String
    let seltenheit: Seltenheit
    let streak: Int
    let fortschritt: Double
    let gesamtGegossen: Int
    let stuermUeberlebt: Int
    let letzten30Tage: [Bool] // true = erledigt, false = nicht

    @State private var pulsieren = false
    @State private var wippen = false
    @State private var partikelFall: CGFloat = -130
    private let partikel = (0..<10).map { _ in SternPartikel() }

    private var prozentText: String {
        "\(Int((fortschritt * 100).rounded()))%"
    }

    private var naechsteStufeName: String {
        switch seltenheit {
        case .gewoehnlich: return "Selten"
        case .selten: return "Episch"
        case .episch: return "Legendär"
        case .legendaer: return "Meisterform"
        }
    }

    private var tageBisNaechsteStufe: Int {
        max(0, Int(ceil((1 - fortschritt) * 10)))
    }

    private var heuteTageIndex: Int {
        min(
            30,
            Calendar.current.dateComponents(
                [.day],
                from: Date().addingTimeInterval(-30 * 24 * 3600),
                to: Date()
            ).day ?? 0
        )
    }

    private let heatmapSpalten = Array(repeating: GridItem(.flexible(), spacing: 8), count: 10)

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                header
                heroVisual
                    .padding(.top, 8)
                statsCards
                naechsteStufeCard
                heatmapCard
                laborSektion
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(.regularMaterial)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                wippen.toggle()
            }
            if seltenheit == .episch {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    pulsieren.toggle()
                }
            }
            if seltenheit == .legendaer {
                withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                    partikelFall = 150
                }
            }
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            Text(name)
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(.primary)

            Text(seltenheit.bezeichnung)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .padding(.horizontal, seltenheit == .gewoehnlich ? 12 : 10)
                .padding(.vertical, seltenheit == .gewoehnlich ? 5 : 6)
                .background(
                    Capsule().fill(
                        seltenheit == .gewoehnlich
                            ? Color(red: 0.45, green: 0.45, blue: 0.47)
                            : seltenheit.tagHintergrund
                    )
                )
                .foregroundStyle(seltenheit == .gewoehnlich ? Color.white : seltenheit.tagTextFarbe)

            Spacer()
        }
    }

    private var heroVisual: some View {
        ZStack {
            Circle()
                .fill(Color.gruenPrimary.opacity(0.16))
                .frame(width: 220, height: 220)

            Circle()
                .trim(from: 0, to: fortschritt)
                .stroke(
                    seltenheit.ringFarbe,
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 200, height: 200)
                .shadow(
                    color: seltenheit == .episch
                        ? Color.epischPrimary.opacity(0.8)
                        : seltenheit.ringFarbe.opacity(0.35),
                    radius: seltenheit == .episch ? (pulsieren ? 20 : 8) : 8
                )

            if seltenheit == .legendaer {
                ForEach(partikel) { partikel in
                    Image(systemName: "star.fill")
                        .font(.system(size: partikel.groesse))
                        .foregroundStyle(Color.legendaerPrimary.opacity(partikel.opazitaet))
                        .offset(x: partikel.x, y: partikel.y + partikelFall)
                }
            }

            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.15))
                    .frame(width: 220, height: 220)

                Image(bildName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())
            }
            .rotationEffect(.degrees(wippen ? 5 : -5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
    }

    private var statsCards: some View {
        HStack(spacing: 12) {
            VStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
                    .font(.system(size: 28))
                Text("\(streak)")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                Text(streak == 1 ? "Tag Streak" : "Tage Streak")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.08))
            )
            statCard(
                icon: "drop.fill",
                iconColor: .blauPrimary,
                value: "\(gesamtGegossen)",
                label: gesamtGegossen == 1 ? "Mal gegossen" : "Mal gegossen"
            )
            statCard(
                icon: "cloud.bolt.fill",
                iconColor: .gray,
                value: "\(stuermUeberlebt)",
                label: stuermUeberlebt == 1 ? "Sturm überlebt" : "Stürme überlebt"
            )
        }
    }

    private func statCard(icon: String, iconColor: Color, value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(iconColor)
            Text(value)
                .font(.system(size: 24, weight: .black, design: .rounded))
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.08))
        )
    }

    private var naechsteStufeCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Nächste Stufe")
                Spacer()
                Text(prozentText)
            }
            .font(.system(size: 13, weight: .semibold, design: .rounded))

            ProgressView(value: fortschritt)
                .tint(seltenheit.ringFarbe)
                .scaleEffect(x: 1, y: 1.5, anchor: .center)

            Text("Noch \(tageBisNaechsteStufe) Tage bis \(naechsteStufeName)")
                .font(.appCaption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.08))
        )
    }

    private var heatmapCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Die letzten 30 Tage")
                .font(.system(size: 16, weight: .bold, design: .rounded))

            LazyVGrid(columns: heatmapSpalten, spacing: 8) {
                ForEach(letzten30Tage.indices, id: \.self) { index in
                    let status = tagStatus(for: index)
                    ZStack {
                        switch status {
                        case .erledigt:
                            Circle()
                                .fill(seltenheit.ringFarbe)
                        case .verpasst:
                            Circle()
                                .fill(Color.red.opacity(0.3))
                            Text("✕")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.red.opacity(0.8))
                        case .zukunft:
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1.5)
                                .background(Color.clear)
                        }
                    }
                    .frame(width: 24, height: 24)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.08))
        )
    }

    private var laborSektion: some View {
        VStack(spacing: 12) {
            laborButton(icon: "bell.fill", title: "Erinnerung setzen")
            laborButton(icon: "note.text", title: "Notiz hinzufügen")

            HStack(spacing: 12) {
                Image(systemName: "trash.fill")
                    .foregroundStyle(Color.rotPrimary)
                Text("Gewohnheit löschen")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.rotPrimary)
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.rotPrimary.opacity(0.08))
            )
        }
    }

    private func laborButton(icon: String, title: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.primary)
            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.08))
        )
    }

    private func tagStatus(for index: Int) -> TagStatus {
        if index >= heuteTageIndex {
            return .zukunft
        }
        return letzten30Tage[index] ? .erledigt : .verpasst
    }
}

#Preview {
    PflanzenDetailView(
        name: "Meditation",
        bildName: Seltenheit.episch.iconName,
        seltenheit: .episch,
        streak: 12,
        fortschritt: 0.8,
        gesamtGegossen: 42,
        stuermUeberlebt: 3,
        letzten30Tage: Array(repeating: true, count: 30)
    )
}
