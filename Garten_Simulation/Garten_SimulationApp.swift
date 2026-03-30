import SwiftUI

@main
struct Garten_SimulationApp: App {
    @StateObject private var gardenStore   = GardenStore()
    @StateObject private var shopStore     = ShopStore()
    @StateObject private var settingsStore = SettingsStore()
    @StateObject private var streakStore   = StreakStore()
    @StateObject private var achievementStore: AchievementStore
    @StateObject private var powerUpStore: PowerUpStore
    
    init() {
        let garden = GardenStore()
        self._gardenStore = StateObject(wrappedValue: garden)
        self._shopStore = StateObject(wrappedValue: ShopStore())
        self._settingsStore = StateObject(wrappedValue: SettingsStore())
        self._streakStore = StateObject(wrappedValue: StreakStore())
        self._achievementStore = StateObject(wrappedValue: AchievementStore(gardenStore: garden))
        self._powerUpStore = StateObject(wrappedValue: PowerUpStore())
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gardenStore)
                .environmentObject(shopStore)
                .environmentObject(settingsStore)
                .environmentObject(streakStore)
                .environmentObject(achievementStore)
                .environmentObject(powerUpStore)
                .environment(\.locale, Locale(identifier: settingsStore.appLanguage))
                .onAppear {
                    // Link ShopStore coin closures to GardenStore (single source of truth)
                    shopStore.coinsProvider  = { [weak gardenStore] in gardenStore?.coins ?? 0 }
                    shopStore.coinsAbziehen  = { [weak gardenStore] amount in gardenStore?.coins -= amount }
                    
                    // Link GardenStore watering action to StreakStore
                    gardenStore.onWatering = { [weak streakStore] in
                        streakStore?.completeDay()
                    }

                    // Onboarding: Gratis-Pflanzen beim ersten Start
                    gardenStore.onboardingGratisPflanzen()
                }
        }
    }
}
