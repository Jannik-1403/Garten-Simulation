import SwiftUI

struct ContentView: View {
    @EnvironmentObject var gardenStore: GardenStore
    
    var body: some View {
        TabView {
            GartenView()
                .tabItem {
                    Label("Garten", systemImage: "leaf.fill")
                }
            
            UnifiedShopView()
                .tabItem {
                    Label("Shop", systemImage: "cart.fill")
                }
            ProfilView()
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
    }
}

#Preview {
    let garden = GardenStore()
    return ContentView()
        .environmentObject(garden)
        .environmentObject(ShopStore())
        .environmentObject(SettingsStore())
        .environmentObject(StreakStore())
        .environmentObject(PowerUpStore())
        .environmentObject(AchievementStore(gardenStore: garden))
}
