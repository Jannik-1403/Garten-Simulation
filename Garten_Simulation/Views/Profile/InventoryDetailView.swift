import SwiftUI

struct InventoryDetailView: View {
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var shopStore: ShopStore
    @EnvironmentObject var powerUpStore: PowerUpStore
    @EnvironmentObject var pfadStore: GartenPfadStore
    @State private var showCreationSheet = false
    @State private var showPlants = false
    @State private var showPowerUps = false
    @State private var showDecorations = false
    
    var body: some View {
        ZStack {
            Color.appHintergrund.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // MARK: - Hero Header
                    VStack(spacing: 16) {
                        Image("Inventar")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 140, height: 140)
                            .shadow(color: Color.orange.opacity(0.2), radius: 15, x: 0, y: 8)
                        
                        VStack(spacing: 4) {
                            Text("\(gardenStore.totalItemsCount)")
                                .font(.system(size: 56, weight: .black, design: .rounded))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    
                    // MARK: - Breakdown Section
                    VStack(spacing: 32) {
                        Divider()
                            .padding(.horizontal, 40)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 20),
                            GridItem(.flexible(), spacing: 20)
                        ], spacing: 24) {
                            Inventory3DStat(
                                titleKey: "profile.inventory.plants",
                                count: gardenStore.pflanzen.count,
                                icon: "Plants",
                                farbe: Color(hex: "#2ECC71"),
                                sekundaerFarbe: Color(hex: "#27AE60"),
                                aktion: { showPlants = true }
                            )
                            
                            Inventory3DStat(
                                titleKey: "profile.inventory.powerups",
                                count: gardenStore.gekauftePowerUps.count,
                                icon: "Powerup",
                                farbe: Color(hex: "#FFD000"),
                                sekundaerFarbe: Color(hex: "#D9A300"),
                                aktion: { showPowerUps = true }
                            )
                            
                            Inventory3DStat(
                                titleKey: "profile.inventory.decorations",
                                count: gardenStore.placedDecorations.count,
                                icon: "Dekoration",
                                farbe: Color(hex: "#FF4B00"),
                                sekundaerFarbe: Color(hex: "#C43D00"),
                                aktion: { showDecorations = true }
                            )
                            
                            Inventory3DStat(
                                titleKey: "inventory.seeds",
                                count: gardenStore.seeds,
                                icon: "Samen",
                                farbe: Color(hex: "#9B59B6"),
                                sekundaerFarbe: Color(hex: "#8E44AD"),
                                aktion: { showCreationSheet = true }
                            )
                        }
                        
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 40)
                }
                .padding(.top, 20)
            }
        }
        .navigationTitle(String(localized: "profile.inventory"))
        .navigationBarTitleDisplayMode(.inline)
        .standardNavigationX()
        .fullScreenCover(isPresented: $showCreationSheet) {
            CustomPlantCreationView()
                .environmentObject(gardenStore)
                .environmentObject(settings)
        }
        .navigationDestination(isPresented: $showPlants) {
            PflanzenDetailView()
                .environmentObject(gardenStore)
                .environmentObject(settings)
                .environmentObject(shopStore)
                .environmentObject(powerUpStore)
                .environmentObject(pfadStore)
        }
        .navigationDestination(isPresented: $showPowerUps) {
            InventoryListView(category: .powerUps)
                .environmentObject(gardenStore)
                .environmentObject(settings)
                .environmentObject(shopStore)
                .environmentObject(powerUpStore)
        }
        .navigationDestination(isPresented: $showDecorations) {
            InventoryListView(category: .decorations)
                .environmentObject(gardenStore)
                .environmentObject(settings)
                .environmentObject(shopStore)
                .environmentObject(powerUpStore)
        }
    }
}

struct Inventory3DStat: View {
    let titleKey: String
    let count: Int
    let icon: String
    let farbe: Color
    let sekundaerFarbe: Color
    var aktion: (() -> Void)? = nil
    
    @EnvironmentObject var settings: SettingsStore
    
    var body: some View {
        VStack(spacing: 6) {
            Item3DButton(
                icon: icon,
                farbe: farbe,
                sekundaerFarbe: sekundaerFarbe,
                groesse: 80,
                aktion: aktion
            )
            
            Text("\(count)")
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundStyle(.primary)
            
            Text(NSLocalizedString(titleKey, comment: ""))
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        InventoryDetailView()
            .environmentObject(GardenStore())
            .environmentObject(SettingsStore())
    }
}
