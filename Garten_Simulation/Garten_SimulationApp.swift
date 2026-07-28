import SwiftUI
import SwiftData
import Combine
import ActivityKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        QuickActionManager.shared.handle(shortcutItem)
        completionHandler(true)
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let shortcutItem = connectionOptions.shortcutItem {
            QuickActionManager.shared.handle(shortcutItem)
        }
    }
}

@MainActor
class AppDependencyContainer: ObservableObject {
    let settingsStore: SettingsStore
    let gardenStore: GardenStore
    let shopStore: ShopStore
    let streakStore: StreakStore
    let titelStore: TitelStore
    let achievementStore: AchievementStore
    let characterStore: CharacterStore
    let interactiveTourManager: InteractiveTourManager
    let assessmentStore: AssessmentStore
    let iapStore: IAPStore
    
    init() {
        // Perform cleanup on fresh install or reinstall to wipe out any cached App Group defaults
        let freshInstallKey = "first_launch_after_install_completed"
        if !UserDefaults.standard.bool(forKey: freshInstallKey) {
            SharedUserDefaults.suite.removePersistentDomain(forName: SharedUserDefaults.suiteName)
            SharedUserDefaults.suite.synchronize()
            UserDefaults.standard.set(true, forKey: freshInstallKey)
            UserDefaults.standard.synchronize()
        }

        SharedUserDefaults.migrateIfNeeded()
        
        let settings = SettingsStore()
        let garden = GardenStore()
        let streak = StreakStore()
        let titel = TitelStore()
        
        self.settingsStore = settings
        self.gardenStore = garden
        self.shopStore = ShopStore()
        self.streakStore = streak
        self.titelStore = titel
        self.achievementStore = AchievementStore(gardenStore: garden, streakStore: streak)
        self.characterStore = CharacterStore()
        self.interactiveTourManager = InteractiveTourManager()
        self.assessmentStore = AssessmentStore()
        self.iapStore = IAPStore()
        
        garden.titelStore = titel
    }
}

@main
struct Garten_SimulationApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var container = AppDependencyContainer()
    
    init() {
        // Ensure standard iOS navigation elements (back chevrons, texts) are black
        UINavigationBar.appearance().tintColor = UIColor.label
    }

    @Environment(\.scenePhase) private var scenePhase
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            AppRootView(
                settingsStore: container.settingsStore,
                container: container,
                showSplash: $showSplash
            )
            .onChange(of: scenePhase) {
                if scenePhase == .active {
                    container.gardenStore.reloadData()
                    container.streakStore.checkForMissedDays()
                    container.gardenStore.checkScreenTimeExceeded()
                } else if scenePhase == .background {
                    AutoBackupManager.shared.checkAndPerformBackup(
                        interval: container.settingsStore.autoBackupInterval,
                        gardenStore: container.gardenStore,
                        shopStore: container.shopStore,
                        achievementStore: container.achievementStore,
                        settingsStore: container.settingsStore,
                        streakStore: container.streakStore,
                        assessmentStore: container.assessmentStore
                    )
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        showSplash = false
                    }
                }
            }

        }
    }
}

struct AppRootView: View {
    @ObservedObject var settingsStore: SettingsStore
    @ObservedObject var container: AppDependencyContainer
    @Binding var showSplash: Bool
    
    var body: some View {
        ZStack {
            ContentView()
                .environmentObject(container.gardenStore)
                .environmentObject(container.shopStore)
                .environmentObject(container.settingsStore)
                .environmentObject(container.streakStore)
                .environmentObject(container.achievementStore)
                .environmentObject(container.titelStore)

                .environmentObject(container.characterStore)
                .environmentObject(container.interactiveTourManager)
                .environmentObject(container.assessmentStore)
                .environmentObject(container.iapStore)
                .environment(\.locale, Locale(identifier: settingsStore.appLanguage))
                .preferredColorScheme(.light)
                .onAppear {
                    QuickActionManager.setupDynamicShortcuts()
                    
                    // Link ShopStore coin closures to GardenStore (single source of truth)
                    container.shopStore.coinsProvider  = { [weak gardenStore = container.gardenStore] in gardenStore?.coins ?? 0 }
                    container.shopStore.coinsAbziehen  = { [weak gardenStore = container.gardenStore] amount in 
                        let desc = NSLocalizedString("transaction.shop_purchase", comment: "")
                        gardenStore?.coinsAbziehen(amount: amount, beschreibung: desc)
                    }
                    container.shopStore.coinsHinzufuegen = { [weak gardenStore = container.gardenStore] amount, title in
                        let format = NSLocalizedString("transaction.sale_format", comment: "")
                        let desc = String(format: format, title)
                        gardenStore?.coinsGutschreiben(amount: amount, beschreibung: desc)
                    }
                    
                    // Link GardenStore watering action to StreakStore
                    container.gardenStore.onWatering = { [weak streakStore = container.streakStore] in
                        streakStore?.completeDay()
                    }
                    
                    // Link GardenStore item-claimed action to ShopStore for ownership sync
                    container.gardenStore.onItemClaimed = { [weak shopStore = container.shopStore] id in
                        shopStore?.purchasedIDs.insert(id)
                    }
                    
                    // Link GardenStore isProUserProvider to IAPStore
                    container.gardenStore.isProUserProvider = { [weak iapStore = container.iapStore] in
                        iapStore?.isProUser ?? false
                    }
                }
                .fullScreenCover(isPresented: .init(
                    get: { !settingsStore.onboardingAbgeschlossen && !showSplash },
                    set: { _ in }
                )) {
                    OnboardingView()
                        .environmentObject(container.gardenStore)
                        .environmentObject(container.shopStore)
                        .environmentObject(container.settingsStore)

                        .environmentObject(container.characterStore)
                }
                .task {
                    NotificationManager.shared.scheduleAll(for: container.gardenStore.pflanzen)
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)) { _ in
                    let semaphore = DispatchSemaphore(value: 0)
                    let activities = Activity<FocusTimerActivityAttributes>.activities
                    if activities.isEmpty { return }
                    
                    var completedCount = 0
                    for activity in activities {
                        Task {
                            await activity.end(nil, dismissalPolicy: .immediate)
                            completedCount += 1
                            if completedCount == activities.count {
                                semaphore.signal()
                            }
                        }
                    }
                    
                    _ = semaphore.wait(timeout: .now() + 1.0)
                }
                .onOpenURL { url in
                    if url.scheme == "grovy" {
                        // Handle internal deep links from Widgets
                        switch url.host {
                        case "garden", "plant":
                            container.gardenStore.selectedTab = 0
                        case "shop":
                            container.gardenStore.selectedTab = 1
                        case "streak":
                            container.gardenStore.selectedTab = 2
                            container.gardenStore.triggerStreakDetail = true
                        case "water":
                            container.gardenStore.selectedTab = 2
                            container.gardenStore.triggerWaterDetail = true
                        case "routines":
                            container.gardenStore.selectedTab = 4
                        case "pro":
                            container.gardenStore.triggerPaywall = true
                        case "focus":
                            // Live Activity tap → zurück zum laufenden Fokus-Timer
                            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                               let habitIdItem = components.queryItems?.first(where: { $0.name == "habitId" }),
                               let habitId = habitIdItem.value {
                                container.gardenStore.selectedTab = 0
                                container.gardenStore.activeFocusHabitId = habitId
                            }
                        default:
                            break
                        }
                    } else if url.pathExtension == "gartensave" {
                        container.gardenStore.pendingImportURL = url
                    }
                }
                .tint(.primary)
            
            if showSplash {
                SplashScreenView()
                    .transition(.opacity)
                    .zIndex(100)
            }
        }
    }
}
