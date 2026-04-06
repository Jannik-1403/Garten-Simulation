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
        let streak = StreakStore()
        self._gardenStore = StateObject(wrappedValue: garden)
        self._shopStore = StateObject(wrappedValue: ShopStore())
        self._settingsStore = StateObject(wrappedValue: SettingsStore())
        self._streakStore = StateObject(wrappedValue: streak)
        self._achievementStore = StateObject(wrappedValue: AchievementStore(gardenStore: garden, streakStore: streak))
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
                    shopStore.coinsAbziehen  = { [weak gardenStore] amount in 
                        gardenStore?.coinsAbziehen(amount: amount, beschreibung: "Shop-Kauf")
                    }
                    shopStore.coinsHinzufuegen = { [weak gardenStore] amount, title in
                        gardenStore?.coinsGutschreiben(amount: amount, beschreibung: "Verkauf: \(title)")
                    }
                    
                    // Link GardenStore watering action to StreakStore
                    gardenStore.onWatering = { [weak streakStore] in
                        streakStore?.completeDay()
                    }
                    
                    // Link GardenStore item-claimed action to ShopStore for ownership sync
                    gardenStore.onItemClaimed = { [weak shopStore] id in
                        shopStore?.purchasedIDs.insert(id)
                    }


                    // Onboarding: Gratis-Pflanzen beim ersten Start
                    gardenStore.onboardingGratisPflanzen()
                }
                .task {
                    await NotificationManager.shared.requestPermission()
                    NotificationManager.shared.scheduleAll(for: gardenStore.pflanzen)
                }
        }
    }
}
