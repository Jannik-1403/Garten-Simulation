import SwiftUI

struct GartenView: View {

    @State private var streak: Int = 12
    @State private var gems: Int = 281
    @State private var herzen: Int = 5
    @State private var aktivesEvent: WetterEvent = .normal
    @State private var ausgewaehltePflanze: PflanzenModel? = nil

    @State private var pflanzen: [PflanzenModel] = [
        PflanzenModel(name: "Gym", bildName: Seltenheit.gewoehnlich.iconName, seltenheit: .gewoehnlich),
        PflanzenModel(name: "Zuckerfrei", bildName: Seltenheit.selten.iconName, seltenheit: .selten),
        PflanzenModel(name: "Meditation", bildName: Seltenheit.episch.iconName, seltenheit: .episch),
        PflanzenModel(name: "Lesen", bildName: Seltenheit.legendaer.iconName, seltenheit: .legendaer),
    ]

    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20),
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

                // MARK: - Sektion Titel
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Mein Garten")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundStyle(.primary)
                        Text("4 Gewohnheiten aktiv")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.primary.opacity(0.6))
                    }
                    Spacer()
                }
                .padding(.horizontal, 28)
                .padding(.top, 20)

                // MARK: - Wetter Banner
                WetterBanner(event: aktivesEvent)
                    .padding(.top, 12)

                // MARK: - Pflanzen Grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(pflanzen.indices, id: \.self) { index in
                            PflanzenCard(
                                name: pflanzen[index].name,
                                bildName: pflanzen[index].seltenheit.iconName,
                                fortschritt: pflanzen[index].fortschritt,
                                gewaessert: pflanzen[index].gewaessert,
                                giessZaehler: pflanzen[index].giessZaehler,
                                seltenheit: pflanzen[index].seltenheit,
                                wetterEvent: aktivesEvent,
                                onGiessen: {
                                    giessen(index: index)
                                },
                                onTap: {
                                    ausgewaehltePflanze = pflanzen[index]
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
                .padding(.top, 20)
            }
        }
        .onAppear {
            ladeTagesEvent()
            starteTageswechselTimer()
        }
        .sheet(item: $ausgewaehltePflanze) { pflanze in
            PflanzenDetailView(
                name: pflanze.name,
                bildName: pflanze.seltenheit.iconName,
                seltenheit: pflanze.seltenheit,
                streak: pflanze.streak,
                fortschritt: pflanze.fortschritt,
                gesamtGegossen: pflanze.gesamtGegossen,
                stuermUeberlebt: pflanze.stuermUeberlebt,
                letzten30Tage: (0..<30).map { _ in Bool.random() }
            )
            .presentationDetents([
                PresentationDetent.medium,
                PresentationDetent.large,
            ])
            .presentationDragIndicator(.visible as Visibility)
            .presentationCornerRadius(32)
            .presentationBackground(Material.regular)
        }
    }

    // MARK: - Tages-Event
    func ladeTagesEvent() {
        let heute = Calendar.current.startOfDay(for: Date())
        let seed = Int(heute.timeIntervalSince1970)
        srand48(seed)
        let zufallsIndex = Int(drand48() * Double(WetterEvent.allCases.count))
        aktivesEvent = WetterEvent.allCases[zufallsIndex]
    }

    func starteTageswechselTimer() {
        let jetzt = Date()
        let kalender = Calendar.current
        guard let morgen = kalender.date(
            byAdding: .day,
            value: 1,
            to: kalender.startOfDay(for: jetzt)
        ) else { return }

        let zeitBisMitternacht = morgen.timeIntervalSince(jetzt)

        DispatchQueue.main.asyncAfter(deadline: .now() + zeitBisMitternacht) {
            ladeTagesEvent()
            starteTageswechselTimer()
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
            p.gesamtGegossen += 1

            if aktivesEvent == .duerre {
                p.giessZaehler += 1
                if p.giessZaehler >= 2 {
                    p.gewaessert = true
                    p.giessZaehler = 0
                }
            } else {
                p.gewaessert = true
                p.giessZaehler = 0
            }

            if p.gewaessert {
                p.streak += 1
                if aktivesEvent == .sturm {
                    p.stuermUeberlebt += 1
                }
            }

            p.benoetigtZweiMal = aktivesEvent == .duerre && !p.gewaessert

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
    var benoetigtZweiMal: Bool = false
    var gesamtGegossen: Int = 0
    var stuermUeberlebt: Int = 0
    var streak: Int = 0
    var seltenheit: Seltenheit = .gewoehnlich
}

#Preview {
    GartenView()
}
