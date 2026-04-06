import SwiftUI

struct InventoryDetailView: View {
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    @State private var showCreationSheet = false
    
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
                            
                            Text(settings.localizedString(for: "profile.inventory").uppercased())
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                                .tracking(2.0)
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
                                icon: "leaf.fill",
                                farbe: Color(hex: "#2ECC71"),
                                sekundaerFarbe: Color(hex: "#27AE60")
                            )
                            
                            Inventory3DStat(
                                titleKey: "profile.inventory.powerups",
                                count: gardenStore.gekauftePowerUps.count,
                                icon: "Powerup",
                                farbe: Color(hex: "#FFD000"),
                                sekundaerFarbe: Color(hex: "#D9A300")
                            )
                            
                            Inventory3DStat(
                                titleKey: "profile.inventory.decorations",
                                count: gardenStore.placedDecorations.count,
                                icon: "lamp.table.fill",
                                farbe: Color(hex: "#FF4B00"),
                                sekundaerFarbe: Color(hex: "#C43D00")
                            )
                            
                            Inventory3DStat(
                                titleKey: "Samen",
                                count: gardenStore.seeds,
                                icon: "leaf.arrow.triangle.circlepath",
                                farbe: Color(hex: "#9B59B6"),
                                sekundaerFarbe: Color(hex: "#8E44AD")
                            )
                        }
                        
                        // MARK: - Seed Crafting Section
                        VStack(spacing: 16) {
                            HStack {
                                Text("Samen-Sammlung")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                Spacer()
                                Text("\(gardenStore.seeds)/10")
                                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 8)
                            
                            VStack(spacing: 20) {
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.1))
                                        .frame(height: 12)
                                    
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(LinearGradient(colors: [Color(hex: "#9B59B6"), Color(hex: "#8E44AD")], startPoint: .leading, endPoint: .trailing))
                                        .frame(width: CGFloat(min(Double(gardenStore.seeds) / 10.0, 1.0)) * (UIScreen.main.bounds.width - 80), height: 12)
                                }
                                
                                Button(action: {
                                    FeedbackManager.shared.playTap()
                                    showCreationSheet = true
                                }) {
                                    HStack {
                                        Image(systemName: "magicmouse.fill")
                                        Text("Pflanze kreieren")
                                    }
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                }
                                .buttonStyle(DuolingoButtonStyle(
                                    size: .medium,
                                    fillWidth: true,
                                    backgroundColor: gardenStore.seeds >= 10 ? Color(hex: "#9B59B6") : Color.gray.opacity(0.3),
                                    shadowColor: gardenStore.seeds >= 10 ? Color(hex: "#8E44AD") : Color.gray.opacity(0.5),
                                    foregroundColor: gardenStore.seeds >= 10 ? .white : .secondary
                                ))
                                .disabled(gardenStore.seeds < 10)
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                            )
                        }
                        .padding(.top, 16)
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 40)
                }
                .padding(.top, 20)
            }
        }
        .navigationTitle(settings.localizedString(for: "profile.inventory"))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showCreationSheet) {
            CustomPlantCreationView()
                .environmentObject(gardenStore)
        }
    }
}

struct Inventory3DStat: View {
    let titleKey: String
    let count: Int
    let icon: String
    let farbe: Color
    let sekundaerFarbe: Color
    
    @EnvironmentObject var settings: SettingsStore
    
    var body: some View {
        VStack(spacing: 6) {
            Item3DButton(
                icon: icon,
                farbe: farbe,
                sekundaerFarbe: sekundaerFarbe,
                groesse: 80
            )
            
            Text("\(count)")
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundStyle(.primary)
            
            Text(settings.localizedString(for: titleKey))
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
