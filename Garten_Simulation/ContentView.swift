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
            
            // Globaler Level-Up Overlay
            if gardenStore.zeigeGartenLevelUpOverlay {
                GartenLevelUpOverlay(
                    neuerLevel: gardenStore.neuerGartenLevel,
                    freischaltungen: gardenStore.neueFreischaltungen,
                    onDismiss: {
                        withAnimation {
                            gardenStore.zeigeGartenLevelUpOverlay = false
                        }
                    },
                    onGluecksradDrehen: {
                        withAnimation {
                            gardenStore.zeigeGartenLevelUpOverlay = false
                            gardenStore.showDailySpinOverlay = true
                        }
                    }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
                .ignoresSafeArea()
                .zIndex(10001)
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
