import SwiftUI

struct GartenView: View {

    @State private var streak: Int = 12
    @State private var gems: Int = 281
    @State private var herzen: Int = 5
    @State private var aktivesEvent: WetterEvent = .normal
    @State private var zeigePopup = false
    @State private var letzesEvent: WetterEvent = .normal

    @State private var pflanzen: [PflanzenModel] = [
        PflanzenModel(name: "Gym", bildName: "icon-bonsaipng", seltenheit: .gewoehnlich),
        PflanzenModel(name: "Zuckerfrei", bildName: "icon-bonsaipng", seltenheit: .selten),
        PflanzenModel(name: "Meditation", bildName: "icon-bonsaipng", seltenheit: .episch),
        PflanzenModel(name: "Lesen", bildName: "icon-bonsaipng", seltenheit: .legendaer),
    ]

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]

    var body: some View {
        ZStack {
            aktivesEvent.hintergrundFarbe
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.8), value: aktivesEvent)

            VStack(spacing: 0) {

                // MARK: - Stats Bar
                HStack(spacing: 20) {
                    Spacer()
                    StreakIcon(wert: streak)
                    GemsIcon(wert: gems)
                    HerzenIcon(wert: herzen)
                }
                .padding(.horizontal, 28)
                .padding(.top, 16)
                .padding(.bottom, 20)

                // MARK: - Wetter Banner
                WetterBanner(event: aktivesEvent)
                    .padding(.bottom, 20)

                // MARK: - Event Wechsler (nur zum Testen)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(WetterEvent.allCases, id: \.self) { event in
                            Button(event.titel) {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    aktivesEvent = event
                                    if event != letzesEvent {
                                        zeigePopup = true
                                        letzesEvent = event
                                    }
                                }
                            }
                            .font(.appCaption)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(aktivesEvent == event
                                        ? aktivesEvent.bannerFarbe.opacity(0.25)
                                        : Color.gray.opacity(0.1))
                            )
                            .foregroundStyle(aktivesEvent == event
                                ? aktivesEvent.bannerFarbe
                                : Color.primary)
                        }
                    }
                    .padding(.horizontal, 28)
                }
                .padding(.bottom, 20)

                // MARK: - Sektion Titel
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Mein Garten")
                            .font(.appTitel)
                            .foregroundStyle(.primary)
                        Text("4 Gewohnheiten aktiv")
                            .font(.appCaption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 16)

                // MARK: - Pflanzen Grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(pflanzen.indices, id: \.self) { index in
                            PflanzenCard(
                                name: pflanzen[index].name,
                                bildName: pflanzen[index].bildName,
                                fortschritt: pflanzen[index].fortschritt,
                                gewaessert: pflanzen[index].gewaessert,
                                seltenheit: pflanzen[index].seltenheit,
                                wetterEvent: aktivesEvent,
                                onGiessen: {
                                    giessen(index: index)
                                },
                                onTap: {
                                    print("Detail für \(pflanzen[index].name)")
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 32)
                }
            }
        }
        .overlay {
            if zeigePopup {
                WetterPopup(event: aktivesEvent) {
                    zeigePopup = false
                }
                .zIndex(99)
            }
        }
    }

    // MARK: - Gieß Logik
    func giessen(index: Int) {
        guard !pflanzen[index].gewaessert else { return }

        withAnimation {
            var p = pflanzen[index]

            let gemBonus = Int(10.0 * aktivesEvent.gemMultiplikator)
            gems += gemBonus

            p.fortschritt = min(p.fortschritt + 0.05, 1.0)

            if aktivesEvent == .duerre {
                p.giessZaehler += 1
                if p.giessZaehler >= 2 {
                    p.gewaessert = true
                    p.giessZaehler = 0
                }
            } else {
                p.gewaessert = true
            }

            pflanzen[index] = p
        }
    }
}

struct PflanzenModel: Identifiable {
    let id = UUID()
    var name: String
    var bildName: String
    var fortschritt: Double = 0.0
    var gewaessert: Bool = false
    var giessZaehler: Int = 0
    var seltenheit: Seltenheit = .gewoehnlich
}

#Preview {
    GartenView()
}
