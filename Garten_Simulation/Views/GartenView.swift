import Combine
import SwiftUI

// MARK: - Card Position Preference (used by PflanzenCard + GartenView for connection lines)
struct CardPositionData: Equatable {
    let id: String
    let center: CGPoint
}

struct CardPositionPreferenceKey: PreferenceKey {
    static var defaultValue: [CardPositionData] = []
    static func reduce(value: inout [CardPositionData], nextValue: () -> [CardPositionData]) {
        value.append(contentsOf: nextValue())
    }
}

struct GartenView: View {

    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var streakStore: StreakStore
    @EnvironmentObject var powerUpStore: PowerUpStore
    @EnvironmentObject var shopStore: ShopStore
    @EnvironmentObject var pfadStore: GartenPfadStore

    @State private var aktivesEvent: WetterEvent = .normal
    @State private var ausgewaehltePflanze: HabitModel? = nil
    @State private var ausgewaehltesItem: ShopDetailPayload? = nil
    @State private var ausgewaehltesAktivesPowerUp: ActivePowerUp? = nil
    @State private var zeigeUnkrautDetail = false
    @State private var zeigeLebenDetail = false
    @State private var zeigeStreakDetail = false
    @State private var zeigeCoinsDetail = false
    @State private var zeigeWetterDetails = false
    @State private var zeigeStatistiken = false
    @State private var startAbstandAktiv = true
    @State private var timerAktuell = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var cardPositions: [CardPositionData] = []
    
    // Fly-in Animationen
    @State private var flyingCoins: [FlyingCoinItem] = []
    @State private var coinHeaderPosition: CGPoint = .zero
    @State private var streakHeaderPosition: CGPoint = .zero
    

    var wateredCount: Int { gardenStore.pflanzen.filter { $0.istBewässert }.count }
    var totalPlants: Int { gardenStore.pflanzen.count }
    var wateringProgress: Double {
        guard totalPlants > 0 else { return 0 }
        return Double(wateredCount) / Double(totalPlants)
    }
    
    var headerSpacerHeight: CGFloat {
        gardenStore.pflanzen.isEmpty ? 190 : 310 // Erhöht auf 310 für mehr Atempause
    }

    let columns = [
        GridItem(.adaptive(minimum: 160), spacing: 16)
    ]

    var body: some View {
        ZStack {
            Color.appHintergrund
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.8), value: aktivesEvent)

            ZStack(alignment: .top) {
                ScrollView {
                    ZStack(alignment: .top) {
                        VStack(spacing: 0) {
                            // Spacer for Header (since it's now an overlay)
                            Spacer().frame(height: headerSpacerHeight)

                            // MARK: - Pflanzen Grid
                            if gardenStore.pflanzen.isEmpty {
                                    GartenIgelView(text: settings.localizedString(for: "garden.empty.subtitle"))
                                        .padding(.top, 20)
                                .frame(maxWidth: .infinity)
                                .padding(.top, 40)
                            } else {
                                // MARK: - Stylized Acker (Field) Background
                                ZStack {
                                    // Subtle earth/grass texture background
                                    RoundedRectangle(cornerRadius: 40, style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.green.opacity(0.03), Color.brown.opacity(0.02)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                    
                                    LazyVGrid(columns: columns, spacing: 30) {
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
                                    .frame(maxWidth: .infinity)
                                }
                                .padding(.horizontal, 8)
                                .padding(.top, 60)
                                .padding(.bottom, 40)
                                
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
                                            .padding(.top, 8)
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
                                                        farbe: .orangePrimary,
                                                        sekundaerFarbe: .orangeSecondary,
                                                        groesse: 90
                                                    ) {
                                                        ausgewaehltesItem = ShopDetailPayload(
                                                            id: deko.id,
                                                            title: deko.nameKey,
                                                            subtitle: deko.category.localizationKey,
                                                            description: deko.descriptionKey,
                                                            price: deko.price,
                                                            icon: deko.sfSymbol,
                                                            colorHex: "#FF991A",
                                                            symbolColor: "orange",
                                                            shadowColorHex: "#D98216",
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
                                    .padding(.horizontal, 16)
                                }
                            }

                            Spacer().frame(height: 60)
                        }
                    }
                    .coordinateSpace(name: "GartenGrid")
                }
                .onPreferenceChange(CardPositionPreferenceKey.self) { cardPositions = $0 }
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

                // MARK: - Sticky Header Bar (Glassmorphic Window)
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        GartenStatsBar(
                            streak: streakStore.currentStreak,
                            coins: gardenStore.coins,
                            leben: gardenStore.leben,
                            onStreakTap: { zeigeStreakDetail = true },
                            onCoinsTap: { zeigeCoinsDetail = true },
                            onLebenTap: { zeigeLebenDetail = true }
                        )
                        .padding(.top, 16)
                        .padding(.bottom, 10)
                        .frame(maxWidth: 600)

                        if !gardenStore.pflanzen.isEmpty {
                            DailyWateringRingView(
                                progress: wateringProgress,
                                count: wateredCount,
                                total: totalPlants,
                                onTap: { zeigeStatistiken = true }
                            )
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .frame(maxWidth: 600)
                        }

                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(alignment: .center, spacing: 12) {
                                    if gardenStore.globalXPMultiplier > 1.0 {
                                        HStack(spacing: 4) {
                                            Image("XP").resizable().scaledToFit().frame(width: 20, height: 20)
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
                            }
                            Spacer()
                        }
                        .padding(.bottom, 10)

                        VStack(spacing: 10) {
                            WetterBanner(event: aktivesEvent) { zeigeWetterDetails = true }

                            if gardenStore.isComebackBoostActive {
                                HStack(spacing: 8) {
                                    Image(systemName: "bolt.fill")
                                        .foregroundStyle(.yellow)
                                    Text(
                                        settings.localizedFormat(
                                            "weed.comeback.banner",
                                            gardenStore.comebackBoostRewardPercent
                                        )
                                    )
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                }
                                .foregroundStyle(Color.gruenPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.gruenPrimary.opacity(0.12))
                                )
                            }
                            
                            if gardenStore.isWeedActive {
                                Item3DButton(
                                    farbe: Color(red: 0.72, green: 0.35, blue: 0.15),
                                    sekundaerFarbe: Color(red: 0.72, green: 0.35, blue: 0.15).darker(),
                                    groesse: 66,
                                    isRectangular: true,
                                    aktion: { zeigeUnkrautDetail = true }
                                ) {
                                    HStack(spacing: 12) {
                                        WeedStackIndicator(count: gardenStore.weedCount, iconSize: 20)

                                        VStack(alignment: .leading, spacing: 0) {
                                            Text(
                                                settings.localizedFormat(
                                                    "weed_banner_subtitle",
                                                    gardenStore.weedEffectiveRewardPercent
                                                )
                                            )
                                                .font(.caption)
                                                .opacity(0.85)
                                                .lineLimit(1)
                                            Text(
                                                gardenStore.weedCount > 1
                                                    ? settings.localizedFormat("weed_banner_title_multi", gardenStore.weedCount)
                                                    : settings.localizedString(for: "weed_banner_title")
                                            )
                                                .font(.subheadline)
                                                .fontWeight(.bold)
                                                .lineLimit(1)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                        Text("\(gardenStore.dailyQuestsCompletedSinceWeed)/\(gardenStore.habitsRequiredForCurrentWeed)")
                                            .font(.system(size: 16, weight: .black, design: .rounded))

                                        Rectangle()
                                            .fill(Color.white.opacity(0.3))
                                            .frame(width: 1, height: 28)

                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 11, weight: .semibold))
                                            .opacity(0.7)
                                    }
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 16)
                                }
                            }
                        }
                        .frame(maxWidth: 600)
                    }
                    .padding(.horizontal, 16)
                    .background(Color.appHintergrund.ignoresSafeArea(edges: .top))
                    .overlay(alignment: .bottom) {
                        Divider()
                            .opacity(0.12)
                            .padding(.horizontal, 16)
                    }
                }
            }
        }
        .onAppear {
            ladeTagesEvent()
            starteTageswechselTimer()
            gardenStore.taeglicherStreakCheck()
        }
        .fullScreenCover(item: $ausgewaehltePflanze) { pflanze in
            NavigationStack {
                PflanzeDetailSheet(
                    pflanze: pflanze,
                    wetterEvent: aktivesEvent,
                    onLoeschen: {
                        gardenStore.pflanzEntfernen(pflanze: pflanze)
                        ausgewaehltePflanze = nil
                    }
                )
                .environmentObject(gardenStore)
                .environmentObject(shopStore)
                .environmentObject(settings)
                .environmentObject(powerUpStore)
                .environmentObject(pfadStore)
            }
        }
        .fullScreenCover(item: $ausgewaehltesItem) { item in
            InventoryItemDetailSheet(item: item)
                .environmentObject(settings)
                .environmentObject(gardenStore)
                .environmentObject(powerUpStore)
                .environmentObject(shopStore)
        }
        .fullScreenCover(item: $ausgewaehltesAktivesPowerUp) { aktiv in
            ActivePowerUpDetailSheet(aktiv: aktiv)
                .environmentObject(settings)
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
        .fullScreenCover(isPresented: $zeigeLebenDetail) {
            LebenDetailView()
                .environmentObject(gardenStore)
                .environmentObject(settings)
        }
        .fullScreenCover(isPresented: $zeigeStreakDetail) {
            NavigationStack {
                StreakView()
                    .environmentObject(streakStore)
                    .environmentObject(settings)
            }
        }
        .fullScreenCover(isPresented: $zeigeCoinsDetail) {
            NavigationStack {
                CoinsDetailView()
                    .environmentObject(gardenStore)
                    .environmentObject(settings)
                    .environmentObject(shopStore)
                    .environmentObject(powerUpStore)
            }
        }
        .sheet(isPresented: $zeigeStatistiken) {
            NavigationStack {
                StatisticsDashboard()
                    .environmentObject(settings)
                    .environmentObject(gardenStore)
                    .environmentObject(streakStore)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(32)
        }
        .fullScreenCover(isPresented: $zeigeUnkrautDetail) {
            WeedDetailView()
                .environmentObject(gardenStore)
                .environmentObject(settings)
                .environmentObject(shopStore)
        }
        .onChange(of: gardenStore.pendingWeedPowerUpForRitual?.id) { _, newValue in
            if newValue != nil {
                zeigeUnkrautDetail = true
            }
        }
        .onChange(of: gardenStore.debugRequestWeedSheet) { _, open in
            guard open else { return }
            zeigeUnkrautDetail = true
            gardenStore.debugRequestWeedSheet = false
        }
        .overlay {
            if gardenStore.zeigeGameOverOverlay {
                GameOverOverlayView()
                    .environmentObject(gardenStore)
                    .environmentObject(settings)
            } else if let pflanze = gardenStore.plantToRescue {
                WonderWaterRescueOverlay(pflanze: pflanze) { useWater in
                    if useWater {
                        gardenStore.reviveWithWonderWater(pflanze: pflanze)
                    } else {
                        gardenStore.declineRescue(pflanze: pflanze)
                    }
                }
                .environmentObject(settings)
            }
            
            if streakStore.showingFreezeUsed {
                StreakFreezeRescueOverlay {
                    streakStore.showingFreezeUsed = false
                }
                .environmentObject(settings)
            }
            
            if pfadStore.zeigePfadAbschlussOverlay,
               let habitId = pfadStore.letzteAbschlussPflanzeID,
               let habit = gardenStore.pflanzen.first(where: { $0.id == habitId }) {
                PfadCompletedOverlay(
                    habit: habit,
                    coinsEarned: pfadStore.letzterAbschlussCoins,
                    onCollect: {
                        gardenStore.coinsGutschreiben(amount: pfadStore.letzterAbschlussCoins, beschreibung: settings.localizedString(for: "pfad_abgeschlossen_belohnung"))
                        gardenStore.completed90DayChallenges += 1
                        gardenStore.saveStats()
                        
                        gardenStore.letzteGiessCoins = pfadStore.letzterAbschlussCoins
                        gardenStore.giessTriggerID = UUID()
                        pfadStore.zeigePfadAbschlussOverlay = false
                        pfadStore.letzteAbschlussPflanzeID = nil
                    },
                    onDismiss: {
                        pfadStore.zeigePfadAbschlussOverlay = false
                        pfadStore.letzteAbschlussPflanzeID = nil
                    }
                )
                .environmentObject(settings)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            if gardenStore.isDailySpinAvailable {
                Item3DButton(
                    icon: "gift.fill",
                    farbe: .rotPrimary,
                    sekundaerFarbe: .rotSecondary,
                    groesse: 64,
                    iconSkalierung: 0.45
                ) {
                    gardenStore.checkDailySpin()
                }
                .padding(.trailing, 24)
                .padding(.bottom, 32)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .overlay(alignment: .topLeading) {
            GeometryReader { overlayGeo in
                let overlayOrigin = overlayGeo.frame(in: .global).origin
                let startPoint = CGPoint(x: overlayGeo.size.width / 2, y: overlayGeo.size.height * 0.8) // Weiter unten (80% der Bildschirmhöhe)
                
                ZStack {
                    ForEach(flyingCoins) { item in
                        FlyingCoinView(
                            startPosition: item.start == .zero ? startPoint : CGPoint(x: item.start.x - overlayOrigin.x, y: item.start.y - overlayOrigin.y),
                            endPosition: CGPoint(x: item.end.x - overlayOrigin.x, y: item.end.y - overlayOrigin.y)
                        ) {
                            flyingCoins.removeAll { $0.id == item.id }
                        }
                    }
                }
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)
        }

        .onPreferenceChange(HeaderPositionPreferenceKey.self) { prefs in
            if let c = prefs.first(where: { $0.id == "coins" }) { coinHeaderPosition = c.center }
            if let s = prefs.first(where: { $0.id == "streak" }) { streakHeaderPosition = s.center }
        }
        .onChange(of: gardenStore.giessTriggerID) { _, _ in
            let now = Date()
            if let p = gardenStore.pflanzen.min(by: { 
                abs(($0.letzteBewaesserung ?? .distantPast).timeIntervalSince(now)) < 
                abs(($1.letzteBewaesserung ?? .distantPast).timeIntervalSince(now)) 
            }) {
                // Anzahl der Münzen basierend auf dem Gewinn (z.B. 1 Münze pro 5 Coins, min 2, max 8)
                let coinsEarned = gardenStore.letzteGiessCoins
                let coinCount = min(8, max(2, coinsEarned / 5))
                
                for i in 0..<coinCount {
                    let delay = Double(i) * 0.08 + Double.random(in: 0...0.05)
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        flyingCoins.append(FlyingCoinItem(
                            start: .zero, // Signal für "Screen Center"
                            end: coinHeaderPosition
                        ))
                    }
                }
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

// MARK: - Flying Coin Model
struct FlyingCoinItem: Identifiable {
    let id = UUID()
    let start: CGPoint
    let end: CGPoint
}

#Preview {
    GartenView()
        .environmentObject(GardenStore())
        .environmentObject(StreakStore())
        .environmentObject(ShopStore())
}

struct WonderWaterRescueOverlay: View {
    let pflanze: HabitModel
    let onDecision: (Bool) -> Void
    @EnvironmentObject var settings: SettingsStore
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { }
            
            VStack(spacing: 24) {
                Image("Powerup-Wunderwasser")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
                
                VStack(spacing: 8) {
                    Text(settings.localizedString(for: "wonder_water.rescue.title"))
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text(String(format: settings.localizedString(for: "wonder_water.rescue.body_format"),
                        settings.showHabitInsteadOfName ? settings.localizedString(for: pflanze.habitName) : settings.localizedString(for: pflanze.name)))
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                }
                
                VStack(spacing: 12) {
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        onDecision(true)
                    }) {
                        Text(String(format: settings.localizedString(for: "wonder_water.rescue.action_format"), settings.localizedString(for: "item.wunder_wasser.name")))
                            .font(.system(size: 16, weight: .bold))
                    }
                    .buttonStyle(DuolingoButtonStyle(
                        backgroundColor: .blauPrimary,
                        shadowColor: .blauPrimary.darker(),
                        foregroundColor: .white
                    ))
                    
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        onDecision(false)
                    }) {
                        Text(settings.localizedString(for: "wonder_water.rescue.decline"))
                            .font(.system(size: 16, weight: .bold))
                    }
                    .buttonStyle(DuolingoButtonStyle(
                        backgroundColor: Color(UIColor.secondarySystemFill),
                        shadowColor: Color(UIColor.systemGray4),
                        foregroundColor: .secondary
                    ))
                }
            }
            .padding(32)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(.white.opacity(0.25), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.15), radius: 30, y: 15)
            .padding(24)
        }
    }
}

struct StreakFreezeRescueOverlay: View {
    let onDismiss: () -> Void
    @EnvironmentObject var settings: SettingsStore
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { 
                    withAnimation { onDismiss() }
                }
            
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(.blue.opacity(0.15))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "snowflake")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundStyle(.blue)
                        .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
                }
                
                VStack(spacing: 12) {
                    Text(settings.localizedString(for: "streak.freeze.used.title"))
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text(settings.localizedString(for: "streak.freeze.used.message"))
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                
                Button(action: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    withAnimation { onDismiss() }
                }) {
                    Text(settings.localizedString(for: "common.done_button"))
                        .font(.system(size: 18, weight: .bold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(DuolingoButtonStyle(
                    backgroundColor: .blue,
                    shadowColor: .blue.darker(),
                    foregroundColor: .white
                ))
                .padding(.top, 8)
            }
            .padding(32)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(.white.opacity(0.25), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.15), radius: 30, y: 15)
            .padding(24)
            .transition(.scale.combined(with: .opacity))
        }
    }
}
