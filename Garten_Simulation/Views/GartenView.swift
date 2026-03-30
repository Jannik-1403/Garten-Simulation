import Combine
import SwiftUI

struct GartenView: View {

    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var streakStore: StreakStore
    @EnvironmentObject var powerUpStore: PowerUpStore

    @State private var herzen: Int = 5
    @State private var aktivesEvent: WetterEvent = .normal
    @State private var ausgewaehltePflanze: HabitModel? = nil
    @State private var ausgewaehltesItem: ShopDetailPayload? = nil
    @State private var ausgewaehltesAktivesPowerUp: ActivePowerUp? = nil
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
                        HStack(alignment: .firstTextBaseline, spacing: 12) {
                            Text(settings.localizedString(for: "garden.title"))
                                .font(.system(size: 32, weight: .black, design: .rounded))
                                .foregroundStyle(.primary)
                            
                            if powerUpStore.globalXPMultiplikator > 1.0 {
                                Text("XP x\(String(format: "%.1f", powerUpStore.globalXPMultiplikator))")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.gruenPrimary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.gruenPrimary.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                        }
                        
                        HStack(spacing: 12) {
                            if !powerUpStore.aktivePowerUps.filter({ $0.isActive && $0.targetPlantId == nil }).isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(powerUpStore.aktivePowerUps.filter { $0.isActive && $0.targetPlantId == nil }) { aktiv in
                                            Button {
                                                ausgewaehltesAktivesPowerUp = aktiv
                                            } label: {
                                                HStack(spacing: 4) {
                                                    Image(systemName: aktiv.symbolName)
                                                        .font(.system(size: 10, weight: .semibold))
                                                    if let zeit = aktiv.verbleibendeZeit {
                                                        Text(zeit)
                                                            .font(.system(size: 10, weight: .semibold))
                                                    }
                                                }
                                                .foregroundStyle(Color.primary)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(.regularMaterial)
                                                .clipShape(Capsule())
                                                .overlay(Capsule().strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5))
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                            }
                        }
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
                            Text(settings.localizedString(for: "garden.empty.title"))
                                .font(.headline)
                            Text(settings.localizedString(for: "garden.empty.subtitle"))
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
                                        gardenStore.giessen(pflanze: pflanze, powerUpStore: powerUpStore)
                                    },
                                    onTap: {
                                        ausgewaehltePflanze = pflanze
                                    }
                                )
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // MARK: - Power-Ups Lager
                        if !gardenStore.gekaufteItems.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(settings.localizedString(for: "garden.powerups"))
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundStyle(.primary)
                                    .padding(.horizontal, 8)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(gardenStore.gekaufteItems) { item in
                                            Item3DButton(
                                                icon: item.icon,
                                                farbe: item.color,
                                                sekundaerFarbe: item.color.darker(),
                                                groesse: 90
                                            ) {
                                                ausgewaehltesItem = item
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.top, 8) // Prevents clipping from 3D offset
                                    .padding(.bottom, 12)
                                }
                            }
                            .padding(.top, 24)
                            .padding(.horizontal, 20)
                        }

                        // MARK: - Müll & Herausforderungen
                        if !gardenStore.aktiverMuell.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(settings.localizedString(for: "garden.trash"))
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundStyle(.primary)
                                    .padding(.horizontal, 8)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(gardenStore.aktiverMuell) { item in
                                            Item3DButton(
                                                icon: item.icon,
                                                farbe: item.color,
                                                sekundaerFarbe: item.color.darker(),
                                                groesse: 90
                                            ) {
                                                ausgewaehltesItem = item
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.top, 8) // Prevents clipping from 3D offset
                                    .padding(.bottom, 12)
                                }
                            }
                            .padding(.top, 24)
                            .padding(.horizontal, 20)
                        }

                        Spacer().frame(height: 60)
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
            gardenStore.taeglicherStreakCheck(powerUpStore: powerUpStore)
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
            InventoryItemDetailSheet(item: item)
                .environmentObject(settings)
                .environmentObject(gardenStore)
                .environmentObject(powerUpStore)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
                .presentationBackground(.ultraThinMaterial)
        }
        .sheet(item: $ausgewaehltesAktivesPowerUp) { aktiv in
            ActivePowerUpDetailSheet(aktiv: aktiv)
                .environmentObject(settings)
                .presentationDetents([.fraction(0.55), .medium])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
                .presentationBackground(.ultraThinMaterial)
        }
        .sheet(isPresented: $zeigeWetterDetails) {
            WetterDetailView(event: aktivesEvent)
                .environmentObject(settings)
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
