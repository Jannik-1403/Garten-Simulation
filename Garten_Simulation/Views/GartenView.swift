import Combine
import SwiftUI

struct GartenView: View {

    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var streakStore: StreakStore

    @State private var herzen: Int = 5
    @State private var aktivesEvent: WetterEvent = .normal
    @State private var ausgewaehltePflanze: HabitModel? = nil
    @State private var ausgewaehltesItem: ShopDetailPayload? = nil
    @State private var zeigeWetterDetails = false
    @State private var startAbstandAktiv = true
    @State private var timerAktuell = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

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
                    StreakIcon(wert: gardenStore.gesamtStreak)
                    GemsIcon(wert: gardenStore.coins)
                    HerzenIcon(wert: herzen)
                }
                .padding(.horizontal, 28)
                .padding(.top, 16)

                // MARK: - Sektion Titel
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("garden.title", bundle: .main)
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundStyle(.primary)
                        Text(String(format: NSLocalizedString("garden.habits.active", comment: ""), gardenStore.pflanzen.count))
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

                    if gardenStore.pflanzen.isEmpty {
                        VStack(spacing: 12) {
                            Spacer().frame(height: 60)
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(.secondary.opacity(0.3))
                            Text("garden.empty.title", bundle: .main)
                                .font(.headline)
                            Text("garden.empty.subtitle", bundle: .main)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                    } else {
                        LazyVGrid(columns: columns, spacing: 26) {
                            ForEach(gardenStore.pflanzen) { pflanze in
                                PflanzenCard(
                                    pflanze: pflanze,
                                    wetterEvent: aktivesEvent,
                                    onGiessen: {
                                        gardenStore.giessen(pflanze: pflanze)
                                    },
                                    onTap: {
                                        ausgewaehltePflanze = pflanze
                                    }
                                )
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // MARK: - Items Lager (Horizontal Scroll)
                        if !gardenStore.boughtItems.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Meine Items")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundStyle(.primary)
                                    .padding(.horizontal, 8)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(gardenStore.boughtItems) { item in
                                            Item3DButton(
                                                icon: item.icon,
                                                farbe: .white,
                                                sekundaerFarbe: Color.primary.opacity(0.1),
                                                groesse: 110
                                            ) {
                                                ausgewaehltesItem = item
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.bottom, 12) // Space for 3D shadow
                                }
                            }
                            .padding(.top, 16) // Added space to prevent clipping at the top
                            .padding(.horizontal, 20)
                            .padding(.bottom, 40)
                        } else {
                            // Bottom padding if no items
                            Spacer().frame(height: 32)
                        }
                    }
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
        .onReceive(timerAktuell) { _ in
            gardenStore.taeglicherStreakCheck()
        }
        .sheet(item: $ausgewaehltePflanze) { pflanze in
            PflanzeDetailSheet(
                pflanze: pflanze,
                onLoeschen: {
                    gardenStore.pflanzen.removeAll { $0.id == pflanze.id }
                    ausgewaehltePflanze = nil
                }
            )
            .presentationDetents([
                PresentationDetent.medium,
                PresentationDetent.large,
            ])
            .presentationDragIndicator(.visible as Visibility)
            .presentationBackground(.ultraThinMaterial)
        }
        .sheet(item: $ausgewaehltesItem) { item in
            ShopItemDetailView(payload: item)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
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
}

#Preview {
    GartenView()
        .environmentObject(GardenStore())
        .environmentObject(StreakStore())
}
