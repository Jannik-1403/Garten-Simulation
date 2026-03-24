import SwiftUI

struct GartenView: View {

    @State private var streak: Int = 12
    @State private var gems: Int = 281
    @State private var herzen: Int = 5
    @State private var aktivesEvent: WetterEvent = .normal
    @State private var ausgewaehltePflanze: PflanzenModel? = nil
    @State private var zeigeWetterDetails = false
    @State private var startAbstandAktiv = true

    @State private var pflanzen: [PflanzenModel] = [
        PflanzenModel(
            name: "Gym",
            bildName: Seltenheit.gewoehnlich.iconName,
            seltenheit: .gewoehnlich,
            thirstSystem: ThirstSystem.withRemaining(hours: 1, minutes: 0)
        ),
        PflanzenModel(
            name: "Zuckerfrei",
            bildName: Seltenheit.selten.iconName,
            seltenheit: .selten,
            thirstSystem: ThirstSystem.withRemaining(hours: 2, minutes: 0)
        ),
        PflanzenModel(
            name: "Meditation",
            bildName: Seltenheit.episch.iconName,
            seltenheit: .episch,
            thirstSystem: ThirstSystem.withRemaining(hours: 1, minutes: 30)
        ),
        PflanzenModel(
            name: "Lesen",
            bildName: Seltenheit.legendaer.iconName,
            seltenheit: .legendaer,
            thirstSystem: ThirstSystem.withRemaining(hours: 3, minutes: 0)
        ),
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
                WetterBanner(event: aktivesEvent) {
                    zeigeWetterDetails = true
                }
                    .padding(.top, 12)

                // MARK: - Pflanzen Grid
                ScrollView {
                    if startAbstandAktiv {
                        Color.clear
                            .frame(height: 12)
                    }

                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(pflanzen.indices, id: \.self) { index in
                            PflanzenCard(
                                name: pflanzen[index].name,
                                bildName: pflanzen[index].seltenheit.iconName,
                                fortschritt: pflanzen[index].fortschritt,
                                gewaessert: pflanzen[index].gewaessert,
                                giessZaehler: pflanzen[index].giessZaehler,
                                seltenheit: pflanzen[index].seltenheit,
                                thirstSystem: pflanzen[index].thirstSystem,
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
                .padding(.top, 0)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 2)
                        .onChanged { _ in
                            if startAbstandAktiv {
                                withAnimation(.easeOut(duration: 0.18)) {
                                    startAbstandAktiv = false
                                }
                            }
                        }
                )
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
                thirstSystem: pflanze.thirstSystem,
                gesamtGegossen: pflanze.gesamtGegossen,
                stuermUeberlebt: pflanze.stuermUeberlebt,
                erledigteTageDaten: pflanze.erledigteTageDaten,
                onLoeschen: {
                    pflanzen.removeAll { $0.id == pflanze.id }
                    ausgewaehltePflanze = nil
                }
            )
            .presentationDetents([
                PresentationDetent.medium,
                PresentationDetent.large,
            ])
            .presentationDragIndicator(.visible as Visibility)
            .presentationCornerRadius(32)
            .presentationBackground(.ultraThinMaterial)
        }
        .sheet(isPresented: $zeigeWetterDetails) {
            WetterDetailView(event: aktivesEvent)
                .presentationDetents([
                    PresentationDetent.medium,
                    PresentationDetent.large,
                ])
                .presentationDragIndicator(.visible as Visibility)
                .presentationCornerRadius(32)
                .presentationBackground(.ultraThinMaterial)
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

            let rewardFactor = p.thirstSystem.potentialReward()
            let gemBonus = Int((10.0 * aktivesEvent.gemMultiplikator * rewardFactor).rounded())
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
                if p.thirstSystem.state() == .dead {
                    p.streak = 0
                }
                p.streak += 1
                if aktivesEvent == .sturm {
                    p.stuermUeberlebt += 1
                }
                if !p.erledigteTageDaten.isEmpty {
                    p.erledigteTageDaten.removeFirst()
                    p.erledigteTageDaten.append(true)
                }
            } else if !p.erledigteTageDaten.isEmpty {
                p.erledigteTageDaten.removeFirst()
                p.erledigteTageDaten.append(false)
            }

            p.benoetigtZweiMal = aktivesEvent == .duerre && !p.gewaessert

            if p.gewaessert {
                p.thirstSystem.water()
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
    var benoetigtZweiMal: Bool = false
    var gesamtGegossen: Int = 0
    var stuermUeberlebt: Int = 0
    var streak: Int = 0
    var erledigteTageDaten: [Bool] = Array(repeating: false, count: 30)
    var seltenheit: Seltenheit = .gewoehnlich
    var thirstSystem: ThirstSystem

    init(
        name: String,
        bildName: String,
        fortschritt: Double = 0.0,
        gewaessert: Bool = false,
        giessZaehler: Int = 0,
        benoetigtZweiMal: Bool = false,
        gesamtGegossen: Int = 0,
        stuermUeberlebt: Int = 0,
        streak: Int = 0,
        erledigteTageDaten: [Bool] = Array(repeating: false, count: 30),
        seltenheit: Seltenheit = .gewoehnlich,
        thirstSystem: ThirstSystem = ThirstSystem()
    ) {
        self.name = name
        self.bildName = bildName
        self.fortschritt = fortschritt
        self.gewaessert = gewaessert
        self.giessZaehler = giessZaehler
        self.benoetigtZweiMal = benoetigtZweiMal
        self.gesamtGegossen = gesamtGegossen
        self.stuermUeberlebt = stuermUeberlebt
        self.streak = streak
        self.erledigteTageDaten = erledigteTageDaten
        self.seltenheit = seltenheit
        self.thirstSystem = thirstSystem
    }
}

#Preview {
    GartenView()
}
