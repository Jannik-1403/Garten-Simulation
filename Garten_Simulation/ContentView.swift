import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var streakStore: StreakStore
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gartenPfadStore: GartenPfadStore
    @EnvironmentObject var interactiveTourManager: InteractiveTourManager
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var realShopStore: ShopStore
    
    @StateObject private var mockGardenStore = TourSimulationStore.createMockGardenStore()
    @StateObject private var mockStreakStore = TourSimulationStore.createMockStreakStore()
    @StateObject private var mockShopStore = TourSimulationStore.createMockShopStore()
    
    var activeGardenStore: GardenStore { interactiveTourManager.isActive ? mockGardenStore : gardenStore }
    var activeStreakStore: StreakStore { interactiveTourManager.isActive ? mockStreakStore : streakStore }
    var activeShopStore: ShopStore { interactiveTourManager.isActive ? mockShopStore : realShopStore }

    var body: some View {
        ZStack {
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
                .zIndex(99999)
            }
            
            // Interactive Tour Overlay
            if interactiveTourManager.isActive {
                InteractiveTourOverlay()
                    .environmentObject(interactiveTourManager)
                    .environmentObject(settings)
                    .environmentObject(activeGardenStore)
                    .zIndex(99998)
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
                    Label(settings.localizedString(for: "tab.garten"), systemImage: "leaf.fill")
                }

            UnifiedShopView()
                .tag(1)
                .tabItem {
                    Label(settings.localizedString(for: "tab.shop"), systemImage: "cart.fill")
                }

            ProfilView()
                .tag(3)
                .tabItem {
                    Label(settings.localizedString(for: "tab.profil"), systemImage: "person.fill")
                }
        }
        .tint(.primary)
        .onAppear {
            gartenPfadStore.setContext(modelContext, settings: settings, gardenStore: gardenStore)
        }
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

