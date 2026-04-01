import Combine
import SwiftUI

struct GartenView: View {

    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var streakStore: StreakStore
    @EnvironmentObject var powerUpStore: PowerUpStore
    @EnvironmentObject var shopStore: ShopStore

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
                    if gardenStore.isWeedActive {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 14))
                            Text("\(gardenStore.dailyQuestsCompletedSinceWeed)/3")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.red)
                        .clipShape(Capsule())
                        .shadow(color: .red.opacity(0.3), radius: 4, x: 0, y: 2)
                        .transition(.scale.combined(with: .opacity))
                    }
                    
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
                            
                            if gardenStore.globalXPMultiplier > 1.0 {
                                Text("XP x\(String(format: "%.1f", gardenStore.globalXPMultiplier))")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.gruenPrimary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.gruenPrimary.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                        }
                        
                        HStack(spacing: 12) {
                            if !gardenStore.activePowerUps.filter({ $0.isActive && $0.targetPlantId == nil }).isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(gardenStore.activePowerUps.filter { $0.isActive && $0.targetPlantId == nil }) { aktiv in
                                            let base = GameDatabase.allPowerUps.first(where: { $0.id == aktiv.powerUpId })
                                            Button {
                                                ausgewaehltesAktivesPowerUp = aktiv
                                            } label: {
                                                HStack(spacing: 4) {
                                                    Image(systemName: base?.symbolName ?? "bolt.fill")
                                                        .font(.system(size: 10, weight: .semibold))
                                                    Text(aktiv.timeRemainingFormatted)
                                                        .font(.system(size: 10, weight: .semibold))
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
                                                    habitCategory: nil,
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
            
            // MARK: - Level-Up Overlay
            LevelUpOverlayView(
                isVisible: $gardenStore.showLevelUpAnimation,
                stufe: gardenStore.newlyReachedGartenStufe
            )
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

