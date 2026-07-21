import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var streakStore: StreakStore
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gartenPfadStore: GartenPfadStore
    @EnvironmentObject var interactiveTourManager: InteractiveTourManager
    @EnvironmentObject var iapStore: IAPStore
    @EnvironmentObject var assessmentStore: AssessmentStore
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var realShopStore: ShopStore
    
    @StateObject private var screenTimeManager = ScreenTimeManager.shared
    
    @State private var showWeeklyReportPopup = false
    @State private var showWeeklyReviewTeaser = false
    @State private var showRecoveredTimer = false
    @State private var recoveredPlantId: String? = nil
    
    @StateObject private var mockGardenStore = TourSimulationStore.createMockGardenStore()
    @StateObject private var mockStreakStore = TourSimulationStore.createMockStreakStore()
    @StateObject private var mockShopStore = TourSimulationStore.createMockShopStore()
    
    var activeGardenStore: GardenStore { interactiveTourManager.isActive ? mockGardenStore : gardenStore }
    var activeStreakStore: StreakStore { interactiveTourManager.isActive ? mockStreakStore : streakStore }
    var activeShopStore: ShopStore { interactiveTourManager.isActive ? mockShopStore : realShopStore }

    var body: some View {
        ZStack {
            if screenTimeManager.isDenied {
                CheatPunishmentOverlay()
                    .environmentObject(activeGardenStore)
                    .zIndex(100000)
            }
            
            MainAppTabView()
                .environmentObject(activeGardenStore)
                .environmentObject(activeStreakStore)
                .environmentObject(activeShopStore)
                .id(interactiveTourManager.isActive)
                
            .fullScreenCover(isPresented: $gardenStore.showDailySpinOverlay) {
                WheelOfFortuneView()
            }

            // Streak-Overlay über der gesamten App (inkl. Tab Bar)
            if streakStore.showingStreakIncrease {
                StreakIncreaseOverlayView(
                    isVisible: $streakStore.showingStreakIncrease,
                    streak: streakStore.currentStreak
                )
                .environmentObject(streakStore)
                .ignoresSafeArea()
                .zIndex(9999)
            }
            
            if gardenStore.zeigeComebackBoostOverlay {
                ComebackBoostOverlayView(
                    isVisible: $gardenStore.zeigeComebackBoostOverlay,
                    rewardPercent: gardenStore.comebackBoostRewardPercent
                )
                .environmentObject(settings)
                .ignoresSafeArea()
                .zIndex(10000)
            }

            // App Tour Prompt Overlay
            if settings.onboardingAbgeschlossen && !settings.appTourPromptShown && !settings.appTourAbgeschlossen {
                AppTourPromptOverlay {
                    interactiveTourManager.startTour()
                }
                .environmentObject(settings)
                .environmentObject(gardenStore)
                .zIndex(99999)
            }
            
            // Interactive Tour Overlay
            if interactiveTourManager.isActive {
                InteractiveTourOverlay()
                    .environmentObject(interactiveTourManager)
                    .environmentObject(settings)
                    .environmentObject(activeGardenStore)
            }
            
            // Rarity Level Up Overlay
            if let rarity = gardenStore.newlyAchievedRarity {
                RarityLevelUpOverlay(rarity: rarity, habit: gardenStore.newlyAchievedHabit) {
                    withAnimation {
                        gardenStore.newlyAchievedRarity = nil
                        gardenStore.newlyAchievedHabit = nil
                    }
                }
                .environmentObject(settings)
                .zIndex(10001)
            }
            
            if showWeeklyReviewTeaser {
                WeeklyReviewTeaserPopup {
                    showWeeklyReviewTeaser = false
                    // Slightly delay opening the report to allow the teaser to disappear
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showWeeklyReportPopup = true
                    }
                }
                .zIndex(10002)
            }
        }
        .sheet(isPresented: $showWeeklyReportPopup) {
            NavigationStack {
                ScrollView {
                    WeeklyReportDashboardView()
                        .padding(.top, 8)
                }
                .background(Color.appHintergrund.ignoresSafeArea())
                .navigationTitle(String(localized: "weekly_report.navigation.title", defaultValue: "Wochenbericht"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { showWeeklyReportPopup = false } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .environmentObject(gardenStore)
            .environmentObject(settings)
            .environmentObject(streakStore)
            .environmentObject(iapStore)
            .environmentObject(assessmentStore)
        }
        .onAppear {
            checkAndShowSundayWeeklyReport()
            if FocusTimerRecovery.shared.isActive {
                recoveredPlantId = FocusTimerRecovery.shared.plantId
                
                // Nur fortsetzen, wenn die Pflanze auch noch existiert
                if gardenStore.pflanzen.contains(where: { $0.id == recoveredPlantId }) {
                    // Kurze Verzögerung, damit die UI bereit ist
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showRecoveredTimer = true
                    }
                } else {
                    FocusTimerRecovery.shared.clearState()
                }
            }
        }
        .fullScreenCover(isPresented: $showRecoveredTimer) {
            if let plantId = recoveredPlantId, let pflanze = gardenStore.pflanzen.first(where: { $0.id == plantId }) {
                FocusSessionView(pflanze: pflanze)
                    .environmentObject(gardenStore)
                    .environmentObject(settings)
                    .environmentObject(streakStore)
            } else if let pflanze = gardenStore.pflanzen.first {
                FocusSessionView(pflanze: pflanze)
                    .environmentObject(gardenStore)
                    .environmentObject(settings)
                    .environmentObject(streakStore)
            }
        }
        .fullScreenCover(isPresented: $interactiveTourManager.showTimerSheet) {
            if let pflanze = gardenStore.pflanzen.first {
                FocusSessionView(pflanze: pflanze)
                    .environmentObject(gardenStore)
                    .environmentObject(settings)
                    .environmentObject(streakStore)
            } else if let fallbackPlant = GameDatabase.allPlants.first {
                let fallbackHabit = HabitModel(
                    name: fallbackPlant.name,
                    symbolName: fallbackPlant.symbolName,
                    symbolColor: fallbackPlant.symbolColor,
                    habitCategory: fallbackPlant.habitCategory,
                    symbolism: fallbackPlant.symbolism,
                    habitName: fallbackPlant.habitName,
                    maxLevel: fallbackPlant.maxLevel,
                    xpPerCompletion: fallbackPlant.xpPerCompletion,
                    waterNeedPerDay: fallbackPlant.waterNeedPerDay,
                    decayDays: fallbackPlant.decayDays,
                    plantID: fallbackPlant.id
                )
                FocusSessionView(pflanze: fallbackHabit)
                    .environmentObject(gardenStore)
                    .environmentObject(settings)
                    .environmentObject(streakStore)
            }
        }
        .fullScreenCover(isPresented: $gardenStore.triggerPaywall) {
            PaywallView()
        }
        .sheet(item: Binding<IdentifiableURL?>(
            get: { gardenStore.pendingImportURL.mapToIdentifiable() },
            set: { gardenStore.pendingImportURL = $0?.url }
        )) { (identifiableURL: IdentifiableURL) in
            ExportImportView(preselectedImportURL: identifiableURL.url)
                .onDisappear {
                    gardenStore.pendingImportURL = nil
                }
        }
    }

    // MARK: - Sunday Weekly Report Logic
    
    private func checkAndShowSundayWeeklyReport() {
        let calendar = Calendar.current
        let today = Date()
        
        // Prüfe ob heute Sonntag ist (weekday 1 = Sonntag)
        guard calendar.component(.weekday, from: today) == 1 else { return }
        
        // Eindeutiger Key pro Kalender-Woche
        let weekOfYear = calendar.component(.weekOfYear, from: today)
        let year = calendar.component(.yearForWeekOfYear, from: today)
        let key = "weeklyReportShown_\(year)_\(weekOfYear)"
        
        // Nur einmal pro Woche zeigen
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        
        // Erst nach Onboarding zeigen
        guard settings.onboardingAbgeschlossen else { return }
        
        // Kurze Verzögerung damit andere Overlays zuerst erscheinen
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            UserDefaults.standard.set(true, forKey: key)
            showWeeklyReviewTeaser = true
        }
    }
}

struct MainAppTabView: View {
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gartenPfadStore: GartenPfadStore
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView(selection: $gardenStore.selectedTab) {
            GartenView()
                .tag(0)
                .tabItem {
                    Label(String(localized: "tab.garten"), systemImage: "leaf.fill")
                }

            RoutinenView()
                .tag(4)
                .tabItem {
                    Label(String(localized: "tab.routines"), systemImage: "list.bullet.clipboard.fill")
                }

            UnifiedShopView()
                .tag(1)
                .tabItem {
                    Label(String(localized: "tab.shop"), systemImage: "cart.fill")
                }

            ProfilView()
                .tag(3)
                .tabItem {
                    Label(String(localized: "tab.profil"), systemImage: "person.fill")
                }
        }
        .applyBottomTabBar()
        .tint(.primary)
        .onAppear {
            gartenPfadStore.setContext(modelContext, settings: settings, gardenStore: gardenStore)
        }
    }
}

extension View {
    @ViewBuilder
    func applyBottomTabBar() -> some View {
        // Force the bottom tab bar on iPadOS 18+ by overriding the horizontal size class
        // This prevents TabView from using the floating sidebar style
        self
#if os(iOS)
            .environment(\.horizontalSizeClass, .compact)
#endif
    }
}

struct IdentifiableURL: Identifiable {
    let id = UUID()
    let url: URL
}

extension Optional where Wrapped == URL {
    func mapToIdentifiable() -> IdentifiableURL? {
        if let url = self {
            return IdentifiableURL(url: url)
        }
        return nil
    }
}

#Preview {
    let garden = GardenStore()
    let streak = StreakStore()
    ContentView()
        .environmentObject(garden)
        .environmentObject(ShopStore())
        .environmentObject(SettingsStore())
        .environmentObject(streak)
        .environmentObject(PowerUpStore())
        .environmentObject(InteractiveTourManager())
        .environmentObject(GartenPfadStore(settings: SettingsStore()))
        .environmentObject(AchievementStore(gardenStore: garden, streakStore: streak))
}

// MARK: - Simulation Data for Interactive Tour
struct TourSimulationStore {
    static func createMockGardenStore() -> GardenStore {
        let store = GardenStore(isMock: true)
        
        // Füge eine Fake-Pflanze hinzu
        if let firstPlant = GameDatabase.allPlants.first {
            let habit = HabitModel(
                name: firstPlant.name,
                symbolName: firstPlant.symbolName,
                symbolColor: firstPlant.symbolColor,
                habitCategory: firstPlant.habitCategory,
                symbolism: firstPlant.symbolism,
                habitName: firstPlant.habitName,
                maxLevel: firstPlant.maxLevel,
                xpPerCompletion: firstPlant.xpPerCompletion,
                waterNeedPerDay: firstPlant.waterNeedPerDay,
                decayDays: firstPlant.decayDays,
                plantID: firstPlant.id
            )
            store.pflanzen = [habit]
        }
        // Füge Trash Item für Bad Habits hinzu (nutzt ein echtes aus dem Shop)
        if let trashDecoration = GameDatabase.allDecorations.first {
            store.placedDecorations = [trashDecoration]
        }
        
        store.coins = 0
        store.leben = 5
        store.activeWeeds = [WeedPatch(removalCost: 30, source: .decoration)]
        
        return store
    }
    
    static func createMockStreakStore() -> StreakStore {
        let store = StreakStore()
        store.currentStreak = 5
        return store
    }
    
    static func createMockShopStore() -> ShopStore {
        return ShopStore()
    }
}

