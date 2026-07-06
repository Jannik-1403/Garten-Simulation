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
    @EnvironmentObject var interactiveTourManager: InteractiveTourManager

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
    
    struct TriggerSheetItem: Identifiable {
        let id: String
    }
    @State private var triggerSheetItem: TriggerSheetItem? = nil
    
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
                ScrollViewReader { proxy in
                    ScrollView {
                        ZStack(alignment: .top) {
                        VStack(spacing: 0) {
                            // Spacer for Header (since it's now an overlay)
                            Spacer().frame(height: headerSpacerHeight)

                            // MARK: - Pflanzen Grid
                            if gardenStore.pflanzen.isEmpty {
                                    GartenIgelView(text: String(localized: "garden.empty.subtitle"))
                                        .padding(.top, 20)
                                .frame(maxWidth: .infinity)
                                .padding(.top, 40)
                                .tourAnchor(.intro)
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
                                    
                                    LazyVStack(spacing: 16) {
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
                                            .tourAnchor(.intro, condition: pflanze.id == gardenStore.pflanzen.first?.id)
                                            .id(pflanze.id == gardenStore.pflanzen.first?.id ? TourStep.intro : nil)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .padding(.horizontal, 8)
                                .padding(.top, 60)
                                .padding(.bottom, 40)
                                
                                // MARK: - Power-Ups Lager
                                let powerUps = gardenStore.gekaufteItems.filter { $0.itemType == .powerUp }
                                if !powerUps.isEmpty {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text(String(localized: "garden.powerups"))
                                            .font(.system(size: 20, weight: .bold, design: .rounded))
                                            .foregroundStyle(.primary)
                                            .padding(.horizontal, 8)
                                        
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(spacing: 16) {
                                                ForEach(powerUps) { item in
                                                    Item3DButton(
                                                        icon: item.icon,
                                                        farbe: item.color,
                                                        sekundaerFarbe: item.color.darker(by: 0.2),
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
                                        Text(String(localized: "garden.trash"))
                                            .font(.system(size: 20, weight: .bold, design: .rounded))
                                            .foregroundStyle(.primary)

                                        LazyVGrid(columns: columns, spacing: 30) {
                                            ForEach(gardenStore.placedDecorations) { deko in
                                                BadHabitCard(
                                                    deko: deko,
                                                    onCrossApplied: {
                                                        triggerSheetItem = TriggerSheetItem(id: deko.id)
                                                    },
                                                    onTap: {
                                                        ausgewaehltesItem = ShopDetailPayload.from(decoration: deko)
                                                    }
                                                )
                                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                                                .tourAnchor(.badHabits, condition: deko.id == gardenStore.placedDecorations.first?.id)
                                            }
                                        }
                                    }
                                    .padding(.top, 24)
                                    .padding(.horizontal, 16)
                                    .id(TourStep.badHabits)
                                }
                            }

                            Spacer().frame(height: 60)
                        }
                    }
                    .coordinateSpace(name: "GartenGrid")
                }
                .onChange(of: interactiveTourManager.currentStep) { _, newStep in
                    if newStep == .badHabits {
                        withAnimation {
                            proxy.scrollTo(TourStep.badHabits, anchor: .bottom)
                        }
                    } else if newStep == .intro {
                        withAnimation {
                            proxy.scrollTo(TourStep.intro, anchor: .top) // Also good to scroll to top for intro
                        }
                    }
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
                } // End of ScrollViewReader

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
                            .tourAnchor(.dailyRingIntro)
                            .id(TourStep.dailyRingIntro)
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
                                        String(format: String(localized: "weed.comeback.banner"), "\(gardenStore.comebackBoostRewardPercent)%")
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
                                                String(format: String(localized: "weed_banner_subtitle"), "\(gardenStore.weedEffectiveRewardPercent)%")
                                            )
                                                .font(.caption)
                                                .opacity(0.85)
                                                .lineLimit(1)
                                            Text(
                                                gardenStore.weedCount > 1
                                                    ? String(format: String(localized: "weed_banner_title_multi"), gardenStore.weedCount)
                                                    : String(localized: "weed_banner_title")
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
            ZStack {
                NavigationStack {
                    PflanzeDetailSheet(
                        pflanze: pflanze,
                        wetterEvent: aktivesEvent,
                        onLoeschen: {
                            gardenStore.pflanzEntfernen(pflanze: pflanze)
                            ausgewaehltePflanze = nil
                        }
                    )
                }
                
                if interactiveTourManager.isActive {
                    InteractiveTourOverlay()
                        .zIndex(99998)
                }
            }
            .environmentObject(gardenStore)
            .environmentObject(shopStore)
            .environmentObject(settings)
            .environmentObject(powerUpStore)
            .environmentObject(pfadStore)
            .environmentObject(interactiveTourManager)
        }
        .onChange(of: interactiveTourManager.showPlantDetail) { _, newValue in
            ausgewaehltePflanze = newValue
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
        .sheet(item: $triggerSheetItem) { item in
            TriggerSelectionSheet(habitId: item.id)
                .environmentObject(gardenStore)
                .environmentObject(settings)
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
        .onChange(of: gardenStore.activeFocusHabitId) { _, habitId in
            guard let habitId else { return }
            // Pflanze anhand der ID finden und FocusSession direkt öffnen
            if let pflanze = gardenStore.pflanzen.first(where: { $0.id == habitId }) {
                ausgewaehltePflanze = pflanze
            }
            gardenStore.activeFocusHabitId = nil
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
                        gardenStore.coinsGutschreiben(amount: pfadStore.letzterAbschlussCoins, beschreibung: String(localized: "pfad_abgeschlossen_belohnung"))
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
        .overlay {
            // Global Watering FAB
            if gardenStore.pflanzen.contains(where: { !$0.istBewässert && !$0.isDead }) {
                GlobalDragToWater(cardPositions: cardPositions)
                    .environmentObject(gardenStore)
                    .environmentObject(powerUpStore)
                    .zIndex(100)
            }
        }
        .onPreferenceChange(HeaderPositionPreferenceKey.self) { prefs in
            if let c = prefs.first(where: { $0.id == "coins" }) { coinHeaderPosition = c.center }
            if let s = prefs.first(where: { $0.id == "streak" }) { streakHeaderPosition = s.center }
        }
        .onChange(of: gardenStore.giessTriggerID) { _, _ in
            if !gardenStore.pflanzen.isEmpty {
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
                    Text(String(localized: "wonder_water.rescue.title"))
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text(String(format: String(localized: "wonder_water.rescue.body_format"),
                        settings.showHabitInsteadOfName ? NSLocalizedString(pflanze.habitName, comment: "") : NSLocalizedString(pflanze.name, comment: "")))
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
                        Text(String(format: String(localized: "wonder_water.rescue.action_format"), String(localized: "item.wunder_wasser.name")))
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
                        Text(String(localized: "wonder_water.rescue.decline"))
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
                    Text(String(localized: "streak.freeze.used.title"))
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text(String(localized: "streak.freeze.used.message"))
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                
                Button(action: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    withAnimation { onDismiss() }
                }) {
                    Text(String(localized: "common.done_button"))
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
