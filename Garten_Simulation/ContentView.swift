import SwiftUI

struct ContentView: View {
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var streakStore: StreakStore
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gartenPfadStore: GartenPfadStore
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack {
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
                    .tag(2)
                    .tabItem {
                        Label(settings.localizedString(for: "tab.profil"), systemImage: "person.fill")
                    }


            }
            .tint(.green)
            .onAppear {
                gartenPfadStore.setContext(modelContext, settings: settings, gardenStore: gardenStore)
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

// MARK: - Identifiable URL wrapper for sheet(item:)
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
        .environmentObject(AchievementStore(gardenStore: garden, streakStore: streak))
}
