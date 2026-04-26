import SwiftUI
import SwiftData
import Combine

@main
struct Garten_SimulationApp: App {
    @StateObject private var gardenStore: GardenStore
    @StateObject private var shopStore: ShopStore
    @StateObject private var settingsStore: SettingsStore
    @StateObject private var streakStore: StreakStore
    @StateObject private var achievementStore: AchievementStore
    @StateObject private var powerUpStore: PowerUpStore
    @StateObject private var titelStore: TitelStore
    @StateObject private var gartenPfadStore: GartenPfadStore
    
    init() {
        SharedUserDefaults.migrateIfNeeded()
        let settings = SettingsStore()
        let garden = GardenStore()
        let streak = StreakStore()
        let titel = TitelStore()
        self._settingsStore = StateObject(wrappedValue: settings)
        self._gardenStore = StateObject(wrappedValue: garden)
        self._shopStore = StateObject(wrappedValue: ShopStore())
        self._streakStore = StateObject(wrappedValue: streak)
        self._achievementStore = StateObject(wrappedValue: AchievementStore(gardenStore: garden, streakStore: streak))
        self._powerUpStore = StateObject(wrappedValue: PowerUpStore())
        self._titelStore = StateObject(wrappedValue: titel)
        self._gartenPfadStore = StateObject(wrappedValue: GartenPfadStore(settings: settings))
        
        garden.titelStore = titel
    }

    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gardenStore)
                .environmentObject(shopStore)
                .environmentObject(settingsStore)
                .environmentObject(streakStore)
                .environmentObject(achievementStore)
                .environmentObject(powerUpStore)
                .environmentObject(titelStore)
                .environmentObject(gartenPfadStore)
                .modelContainer(for: [PfadStrang.self, PfadStrangTag.self, PfadVerschmelzung.self])
                .environment(\.locale, Locale(identifier: settingsStore.appLanguage))
                .preferredColorScheme(.light)
                .onChange(of: scenePhase) { oldPhase, newPhase in
                    if newPhase == .inactive || newPhase == .background {
                        gardenStore.checkAndStartLiveActivity()
                    }
                }
                .onAppear {
                    // Link ShopStore coin closures to GardenStore (single source of truth)
                    shopStore.coinsProvider  = { [weak gardenStore] in gardenStore?.coins ?? 0 }
                    shopStore.coinsAbziehen  = { [weak gardenStore] amount in 
                        let desc = settingsStore.localizedString(for: "transaction.shop_purchase")
                        gardenStore?.coinsAbziehen(amount: amount, beschreibung: desc)
                    }
                    shopStore.coinsHinzufuegen = { [weak gardenStore] amount, title in
                        let format = settingsStore.localizedString(for: "transaction.sale_format")
                        let desc = String(format: format, title)
                        gardenStore?.coinsGutschreiben(amount: amount, beschreibung: desc)
                    }
                    
                    // Link GardenStore watering action to StreakStore
                    gardenStore.onWatering = { [weak streakStore] in
                        streakStore?.completeDay()
                    }
                    
                    // Link GardenStore item-claimed action to ShopStore for ownership sync
                    gardenStore.onItemClaimed = { [weak shopStore] id in
                        shopStore?.purchasedIDs.insert(id)
                    }
                }
                .fullScreenCover(isPresented: .init(
                    get: { !settingsStore.onboardingAbgeschlossen },
                    set: { _ in }
                )) {
                    OnboardingView()
                        .environmentObject(gardenStore)
                        .environmentObject(shopStore)
                        .environmentObject(settingsStore)
                        .environmentObject(gartenPfadStore)
                }
                .task {
                    await NotificationManager.shared.requestPermission()
                    NotificationManager.shared.scheduleAll(for: gardenStore.pflanzen)
                }
                .onOpenURL { url in
                    if url.scheme == "grovy" {
                        // Handle internal deep links from Widgets
                        switch url.host {
                        case "garden", "plant":
                            gardenStore.selectedTab = 0
                        case "shop":
                            gardenStore.selectedTab = 1
                        case "streak":
                            gardenStore.selectedTab = 2
                            gardenStore.triggerStreakDetail = true
                        case "water":
                            gardenStore.selectedTab = 2
                            gardenStore.triggerWaterDetail = true
                        default:
                            break
                        }
                    } else if url.pathExtension == "gartensave" {
                        gardenStore.pendingImportURL = url
                    }
                }
        }
    }
}
