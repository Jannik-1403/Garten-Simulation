import Combine
import SwiftUI

// MARK: - Card Position Preference (used by PflanzenCard + GartenView for connection lines)
struct CardPositionData: Equatable {
    let id: String
    let center: CGPoint
    let frame: CGRect
    
    static func == (lhs: CardPositionData, rhs: CardPositionData) -> Bool {
        guard lhs.id == rhs.id else { return false }
        
        let centerDiffX = abs(lhs.center.x - rhs.center.x)
        let centerDiffY = abs(lhs.center.y - rhs.center.y)
        let frameDiffX = abs(lhs.frame.origin.x - rhs.frame.origin.x)
        let frameDiffY = abs(lhs.frame.origin.y - rhs.frame.origin.y)
        let frameDiffW = abs(lhs.frame.size.width - rhs.frame.size.width)
        let frameDiffH = abs(lhs.frame.size.height - rhs.frame.size.height)
        
        let threshold: CGFloat = 1.0
        return centerDiffX < threshold && centerDiffY < threshold &&
               frameDiffX < threshold && frameDiffY < threshold &&
               frameDiffW < threshold && frameDiffH < threshold
    }
}

struct CardPositionPreferenceKey: PreferenceKey {
    static var defaultValue: [CardPositionData] = []
    static func reduce(value: inout [CardPositionData], nextValue: () -> [CardPositionData]) {
        value.append(contentsOf: nextValue())
    }
}

struct BadHabitPositionPreferenceKey: PreferenceKey {
    static var defaultValue: [CardPositionData] = []
    static func reduce(value: inout [CardPositionData], nextValue: () -> [CardPositionData]) {
        value.append(contentsOf: nextValue())
    }
}

struct GartenView: View {

    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var streakStore: StreakStore
    @EnvironmentObject var shopStore: ShopStore
    @EnvironmentObject var interactiveTourManager: InteractiveTourManager


    @State private var ausgewaehltePflanze: HabitModel? = nil
    @State private var liveActivityFocusHabit: HabitModel? = nil
    @State private var ausgewaehltesItem: ShopDetailPayload? = nil

    @State private var zeigeUnkrautDetail = false
    @State private var zeigeLebenDetail = false
    @State private var zeigeStreakDetail = false
    @State private var zeigeCoinsDetail = false
    @State private var zeigeWetterDetails = false
    @State private var zeigeStatistiken = false
    @State private var startAbstandAktiv = true
    @State private var timerAktuell = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var cardPositions: [CardPositionData] = []
    @State private var badHabitPositions: [CardPositionData] = []
    
    struct TriggerSheetItem: Identifiable {
        let id: String
    }
    @State private var triggerSheetItem: TriggerSheetItem? = nil
    
    // Fly-in Animationen
    @State private var flyingCoins: [FlyingCoinItem] = []
    @State private var coinHeaderPosition: CGPoint = .zero
    @State private var streakHeaderPosition: CGPoint = .zero
    

    var wateredCount: Int { gardenStore.sichtbarePflanzen.filter { $0.istBewässert }.count }
    var totalPlants: Int { gardenStore.sichtbarePflanzen.count }
    var wateringProgress: Double {
        guard totalPlants > 0 else { return 0 }
        return Double(wateredCount) / Double(totalPlants)
    }
    
    var headerSpacerHeight: CGFloat {
        gardenStore.sichtbarePflanzen.isEmpty ? 190 : 310 // Erhöht auf 310 für mehr Atempause
    }

    let columns = [
        GridItem(.adaptive(minimum: 160), spacing: 16)
    ]

    var body: some View {
        let v1 = mainContentView
            .onAppear {
                ladeTagesEvent()
                starteTageswechselTimer()
                gardenStore.taeglicherStreakCheck()
            }
        
        let v2 = applyCovers1(v1)
        let v3 = applyCovers2(v2)
        let v4 = applySheetsAndOverlays(v3)
        
        return v4
    }

    @ViewBuilder
    private func applyCovers1<V: View>(_ view: V) -> some View {
        view
            .fullScreenCover(item: $ausgewaehltePflanze) { pflanze in
                pflanzeDetailCover(for: pflanze)
            }
            .onChange(of: interactiveTourManager.showPlantDetail) { _, newValue in
                ausgewaehltePflanze = newValue
            }
            .fullScreenCover(item: $ausgewaehltesItem) { item in
                InventoryItemDetailSheet(item: item)
                    .environmentObject(settings)
                    .environmentObject(gardenStore)
                    .environmentObject(shopStore)
            }
            .fullScreenCover(isPresented: $zeigeLebenDetail) {
                LebenDetailView()
                    .environmentObject(gardenStore)
                    .environmentObject(settings)
            }
    }

    @ViewBuilder
    private func applyCovers2<V: View>(_ view: V) -> some View {
        view
            .fullScreenCover(isPresented: $zeigeStreakDetail) {
                NavigationStack {
                    StreakView()
                        .environmentObject(streakStore)
                        .environmentObject(settings)
                }
            }
            .fullScreenCover(item: $liveActivityFocusHabit) { pflanze in
                FocusSessionView(pflanze: pflanze)
                    .environmentObject(gardenStore)
                    .environmentObject(settings)
                    .environmentObject(streakStore)
            }
            .fullScreenCover(isPresented: $zeigeCoinsDetail) {
                NavigationStack {
                    CoinsDetailView()
                        .environmentObject(gardenStore)
                        .environmentObject(settings)
                        .environmentObject(shopStore)
                }
            }
    }

    @ViewBuilder
    private func applySheetsAndOverlays<V: View>(_ view: V) -> some View {
        view
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
            .onChange(of: gardenStore.debugRequestWeedSheet) { _, open in
                handleDebugWeedSheetChange(open)
            }
            .onChange(of: gardenStore.activeFocusHabitId) { _, habitId in
                handleActiveFocusHabitChange(habitId)
            }
            .overlay { gameOverAndRescueOverlay }
            .overlay(alignment: .topLeading) { flyingCoinsOverlay }
            .overlay { globalFabsOverlay }
            .onPreferenceChange(HeaderPositionPreferenceKey.self, perform: handleHeaderPositions)
            .onChange(of: gardenStore.giessTriggerID) { _, _ in
                handleGiessTrigger()
            }
    }

    private func handleHeaderPositions(_ prefs: [HeaderPositionData]) {
        if let c = prefs.first(where: { $0.id == "coins" }) { coinHeaderPosition = c.center }
        if let s = prefs.first(where: { $0.id == "streak" }) { streakHeaderPosition = s.center }
    }

    @ViewBuilder
    private func pflanzeDetailCover(for pflanze: HabitModel) -> some View {
        ZStack {
            NavigationStack {
                PflanzeDetailSheet(
                    pflanze: pflanze,
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
        .environmentObject(interactiveTourManager)
    }

    @ViewBuilder
    private var mainContentView: some View {
        ZStack {
            Color.appHintergrund
                .ignoresSafeArea()

            ZStack(alignment: .top) {
                ScrollViewReader { proxy in
                    ScrollView {
                        ZStack(alignment: .top) {
                            VStack(spacing: 0) {
                                Spacer().frame(height: headerSpacerHeight)

                                // MARK: - Pflanzen Grid
                                if gardenStore.sichtbarePflanzen.isEmpty {
                                    GartenIgelView(text: String(localized: "garden.empty.subtitle", defaultValue: "Füge deine erste Pflanze hinzu!"))
                                        .padding(.top, 20)
                                        .frame(maxWidth: .infinity)
                                        .padding(.top, 40)
                                        .tourAnchor(.intro)
                                } else {
                                    pflanzenGridSection
                                }

                                Spacer().frame(height: 60)
                            }
                            .frame(maxWidth: 850)
                        }
                        .coordinateSpace(name: "GartenGrid")
                    }
                    .onChange(of: interactiveTourManager.currentStep) { _, newStep in
                        handleTourStepChange(newStep, proxy: proxy)
                    }
                    .onPreferenceChange(CardPositionPreferenceKey.self) { prefs in
                        cardPositions = prefs
                    }
                    .onPreferenceChange(BadHabitPositionPreferenceKey.self) { prefs in
                        badHabitPositions = prefs
                    }
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

                // MARK: - Sticky Header Bar
                stickyHeaderBar
            }
        }
    }

    // MARK: - Tages-Event
    func ladeTagesEvent() {
        let heute = Calendar.current.startOfDay(for: Date())
        let seed = Int(heute.timeIntervalSince1970)
        srand48(seed)
    }
    
    // MARK: - Sub-Views
    @ViewBuilder
    private var dekorationenSection: some View {
        if !gardenStore.placedDecorations.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text(String(localized: "garden.trash"))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                VStack(spacing: 16) {
                    ForEach(gardenStore.placedDecorations) { deko in
                        BadHabitCard(
                            deko: deko,
                            onTap: { ausgewaehltesItem = ShopDetailPayload.from(decoration: deko) },
                            onLongPress: {
                                triggerSheetItem = TriggerSheetItem(id: deko.id)
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
    
    @ViewBuilder
    private var stickyHeaderBar: some View {
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
                .frame(maxWidth: 850)

                if !gardenStore.sichtbarePflanzen.isEmpty {
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
                    .frame(maxWidth: 850)
                }

                xpMultiplierSection
                VStack(spacing: 10) {
                    comebackBoostSection
                    weedSection
                }
                .frame(maxWidth: 850)
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
    
    @ViewBuilder
    private var gameOverAndRescueOverlay: some View {
        Group {
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
        }
    }
    
    @ViewBuilder
    private var flyingCoinsOverlay: some View {
        GeometryReader { overlayGeo in
            let overlayOrigin = overlayGeo.frame(in: .global).origin
            let startPoint = CGPoint(x: overlayGeo.size.width / 2, y: overlayGeo.size.height * 0.8)
            
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
    
    @ViewBuilder
    private var globalFabsOverlay: some View {
        EmptyView()
    }
    
    @ViewBuilder
    private var weedSection: some View {
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
                        Text(String(format: String(localized: "weed_banner_subtitle"), "\(gardenStore.weedEffectiveRewardPercent)%"))
                            .font(.caption)
                            .opacity(0.85)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        Text(gardenStore.weedCount > 1 ? String(format: String(localized: "weed_banner_title_multi"), gardenStore.weedCount) : String(localized: "weed_banner_title"))
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Text(verbatim: "\(gardenStore.dailyQuestsCompletedSinceWeed)/\(gardenStore.habitsRequiredForCurrentWeed)")
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
    
    @ViewBuilder
    private var comebackBoostSection: some View {
        if gardenStore.isComebackBoostActive {
            HStack(spacing: 8) {
                Image(systemName: "bolt.fill")
                    .foregroundStyle(.yellow)
                Text(String(format: String(localized: "weed.comeback.banner"), "\(gardenStore.comebackBoostRewardPercent)%"))
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
    }
    
    @ViewBuilder
    private var xpMultiplierSection: some View {
        EmptyView()
    }

    // powerUpsSection removed – powerUp is not a ShopItemType case
    @ViewBuilder
    private var powerUpsSection: some View { EmptyView() }
    
    @ViewBuilder
    private var pflanzenGridSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 40, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.green.opacity(0.03), Color.brown.opacity(0.02)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            LazyVStack(spacing: 16) {
                ForEach(gardenStore.sichtbarePflanzen) { pflanze in
                    pflanzenCardRow(pflanze: pflanze)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 8)
        .padding(.top, 60)
        .padding(.bottom, 40)
        
        dekorationenSection
        powerUpsSection
    }
    
    @ViewBuilder
    private func pflanzenCardRow(pflanze: HabitModel) -> some View {
        let isFirst = pflanze.id == gardenStore.sichtbarePflanzen.first?.id
        PflanzenCard(
            pflanze: pflanze,
            onGiessen: { gardenStore.giessen(pflanze: pflanze) },
            onTap: { ausgewaehltePflanze = pflanze }
        )
        .tourAnchor(.intro, condition: isFirst)
        .id(isFirst ? TourStep.intro : nil)
    }

    private func handleDebugWeedSheetChange(_ open: Bool) {
        guard open else { return }
        zeigeUnkrautDetail = true
        gardenStore.debugRequestWeedSheet = false
    }
    
    private func handleGiessTrigger() {
        guard !gardenStore.sichtbarePflanzen.isEmpty else { return }
        let coinsEarned: Int = gardenStore.letzteGiessCoins
        let coinCount: Int = min(8, max(2, coinsEarned / 5))
        for i in 0..<coinCount {
            let delay = Double(i) * 0.08 + Double.random(in: 0...0.05)
            let endPos = coinHeaderPosition
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                flyingCoins.append(FlyingCoinItem(start: .zero, end: endPos))
            }
        }
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
    
    private func handleActiveFocusHabitChange(_ habitId: String?) {
        guard let habitId else { return }
        let pflanzen: [HabitModel] = gardenStore.pflanzen
        if let pflanze = pflanzen.first(where: { $0.id == habitId }) {
            liveActivityFocusHabit = pflanze
        }
        gardenStore.activeFocusHabitId = nil
    }
    
    private func handleTourStepChange(_ newStep: TourStep, proxy: ScrollViewProxy) {
        if newStep == .badHabits {
            withAnimation {
                proxy.scrollTo(TourStep.badHabits, anchor: .bottom)
            }
        } else if newStep == .intro {
            withAnimation {
                proxy.scrollTo(TourStep.intro, anchor: .top)
            }
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
