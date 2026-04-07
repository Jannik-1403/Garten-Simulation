import Combine
import SwiftUI

struct GartenView: View {

    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var streakStore: StreakStore
    @EnvironmentObject var powerUpStore: PowerUpStore
    @EnvironmentObject var shopStore: ShopStore

    @State private var aktivesEvent: WetterEvent = .normal
    @State private var ausgewaehltePflanze: HabitModel? = nil
    @State private var ausgewaehltesItem: ShopDetailPayload? = nil
    @State private var ausgewaehltesAktivesPowerUp: ActivePowerUp? = nil
    @State private var zeigeUnkrautDetail = false
    @State private var zeigeLebenDetail = false
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

                // MARK: - Sticky Header
                VStack(spacing: 0) {

                    VStack(spacing: 0) {
                        GartenStatsBar(
                            streak: streakStore.currentStreak,
                            coins: gardenStore.coins,
                            leben: gardenStore.leben,
                            onLebenTap: {
                                zeigeLebenDetail = true
                            }
                        )
                        .padding(.top, 16)
                        .padding(.bottom, 10)

                        // MARK: - Sticky Titel
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(alignment: .firstTextBaseline, spacing: 12) {
                                    Text(settings.localizedString(for: "garden.title"))
                                        .font(.system(size: 32, weight: .black, design: .rounded))
                                        .foregroundStyle(.primary)
                                    
                                    if gardenStore.globalXPMultiplier > 1.0 {
                                        HStack(spacing: 4) {
                                            Image("XP")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 20, height: 20)
                                            
                                            Text("x\(String(format: "%.1f", gardenStore.globalXPMultiplier))")
                                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                        }
                                        .foregroundStyle(Color.gruenPrimary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.gruenPrimary.opacity(0.1))
                                        .clipShape(Capsule())
                                    }
                                }
                                
                                if gardenStore.isWeedActive {
                                    Button {
                                        zeigeUnkrautDetail = true
                                    } label: {
                                        HStack(spacing: 6) {
                                            Image(systemName: "exclamationmark.triangle.fill")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundStyle(Color.orangePrimary)
                                            
                                            Text("\(gardenStore.dailyQuestsCompletedSinceWeed)/3")
                                                .font(.system(size: 15, weight: .black, design: .rounded))
                                                .foregroundStyle(.secondary)
                                        }
                                        .padding(.vertical, 2)
                                }
                                .buttonStyle(.plain)
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }
                        }
                        Spacer()
                    }
                    .padding(.bottom, 10)

                        // MARK: - Sticky Wetter Banner
                        WetterBanner(event: aktivesEvent) {
                            zeigeWetterDetails = true
                        }
                        .padding(.bottom, 0)
                    }
                    .padding(.horizontal, 16)
                }

                ScrollView {
                    VStack(spacing: 0) {
                        Spacer().frame(height: 12)

                        // MARK: - Pflanzen Grid

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
                            .padding(.horizontal, 16)
                            
                            // MARK: - Power-Ups Lager
                            if !gardenStore.gekaufteItems.filter({ $0.itemType == .powerUp }).isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(settings.localizedString(for: "garden.powerups"))
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundStyle(.primary)
                                        .padding(.horizontal, 8)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 16) {
                                            ForEach(gardenStore.gekaufteItems.filter { $0.itemType == .powerUp }) { item in
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
                                .padding(.horizontal, 16)
                            }

                            // MARK: - Dekorationen
                            if !gardenStore.placedDecorations.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(settings.localizedString(for: "garden.trash"))
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundStyle(.primary)
                                        .padding(.horizontal, 8)

                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 16) {
                                            ForEach(gardenStore.placedDecorations) { deko in
                                                Item3DButton(
                                                    icon: deko.sfSymbol,
                                                    farbe: .orange,
                                                    sekundaerFarbe: .orange.darker(),
                                                    groesse: 90
                                                ) {
                                                    ausgewaehltesItem = ShopDetailPayload(
                                                        id: deko.id,
                                                        title: deko.nameKey,
                                                        subtitle: deko.category.localizationKey,
                                                        description: deko.descriptionKey,
                                                        price: deko.price,
                                                        icon: deko.sfSymbol,
                                                        colorHex: "#FF991A", // orange
                                                        symbolColor: "orange",
                                                        shadowColorHex: "#D98216", // darker orange
                                                        tag: "DEKO",
                                                        itemType: .decoration,
                                                        habitCategories: nil,
                                                        symbolism: nil,
                                                        howToUse: nil
                                                    )
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 8)
                                        .padding(.top, 8)
                                        .padding(.bottom, 12)
                                    }
                                }
                                .padding(.top, 24)
                                .padding(.horizontal, 16)
                            }

                            Spacer().frame(height: 60)
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
                .onReceive(timerAktuell) { _ in
                    gardenStore.pruefePflanzenStatus()
                }
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
                    gardenStore.pflanzEntfernen(pflanze: pflanze)
                    ausgewaehltePflanze = nil
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(32)
            .presentationBackground(.ultraThinMaterial)
            .environmentObject(gardenStore)
            .environmentObject(shopStore)
            .environmentObject(settings)
        }
        .sheet(item: $ausgewaehltesItem) { item in
            InventoryItemDetailSheet(item: item)
                .environmentObject(settings)
                .environmentObject(gardenStore)
                .environmentObject(powerUpStore)
                .environmentObject(shopStore)
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
        .sheet(isPresented: $zeigeLebenDetail) {
            LebenDetailView()
                .environmentObject(gardenStore)
                .environmentObject(settings)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
                .presentationBackground(.ultraThinMaterial)
        }
        .sheet(isPresented: $zeigeUnkrautDetail) {
            WeedDetailView()
                .environmentObject(gardenStore)
                .environmentObject(settings)
                .presentationDetents([PresentationDetent.medium])
                .presentationDragIndicator(Visibility.visible)
                .presentationCornerRadius(32)
                .presentationBackground(Material.ultraThinMaterial)
        }
        .overlay {
            if gardenStore.zeigeGameOverOverlay {
                GameOverOverlayView()
                    .environmentObject(gardenStore)
                    .environmentObject(settings)
            }
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
        .environmentObject(ShopStore())
}
