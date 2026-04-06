import SwiftUI

struct ContentView: View {
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var streakStore: StreakStore

    var body: some View {
        ZStack {
            TabView(selection: $gardenStore.selectedTab) {
                GartenView()
                    .tag(0)
                    .tabItem {
                        Label(NSLocalizedString("tab.garten", comment: ""), systemImage: "leaf.fill")
                    }

                UnifiedShopView()
                    .tag(1)
                    .tabItem {
                        Label(NSLocalizedString("tab.shop", comment: ""), systemImage: "cart.fill")
                    }
                ProfilView()
                    .tag(2)
                    .tabItem {
                        Label("Profil", systemImage: "person.fill")
                    }
            }
            .tint(.green)
            .onAppear {
                gardenStore.checkDailySpin()
            }
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
        }
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
        .environmentObject(AchievementStore(gardenStore: garden, streakStore: streak))
}
