import SwiftUI

struct InventoryDetailView: View {
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    
    var body: some View {
        ZStack {
            Color.appHintergrund.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // MARK: - Hero Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.orange.opacity(0.15))
                                .frame(width: 90, height: 90)
                            Image(systemName: "archivebox.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(.orange)
                        }
                        
                        Text("\(gardenStore.totalItemsCount)")
                            .font(.system(size: 48, weight: .black, design: .rounded))
                        
                        Text(settings.localizedString(for: "profile.inventory"))
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .tracking(1.0)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                    .background(Color(UIColor.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 20)
                    
                    // MARK: - Breakdown Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text(settings.localizedString(for: "common.details"))
                            .font(.system(size: 12, weight: .black, design: .rounded))
                            .foregroundStyle(.secondary)
                            .tracking(1.2)
                            .padding(.horizontal, 8)
                        
                        VStack(spacing: 16) {
                            InventoryBreakdownCard(
                                titleKey: "profile.inventory.plants",
                                count: gardenStore.pflanzen.count,
                                icon: "leaf.fill",
                                color: .green
                            )
                            
                            InventoryBreakdownCard(
                                titleKey: "profile.inventory.powerups",
                                count: gardenStore.gekaufteItems.count,
                                icon: "bolt.fill",
                                color: .blue
                            )
                            
                            InventoryBreakdownCard(
                                titleKey: "profile.inventory.decorations",
                                count: gardenStore.placedDecorations.count,
                                icon: "lamp.table.fill",
                                color: .orange
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 40)
                }
                .padding(.top, 20)
            }
        }
        .navigationTitle(settings.localizedString(for: "profile.inventory"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InventoryBreakdownCard: View {
    let titleKey: String
    let count: Int
    let icon: String
    let color: Color
    
    @EnvironmentObject var settings: SettingsStore
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(color)
            }
            
            Text(settings.localizedString(for: titleKey))
                .font(.system(size: 18, weight: .bold, design: .rounded))
            
            Spacer()
            
            Text("\(count)")
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundStyle(color)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    NavigationStack {
        InventoryDetailView()
            .environmentObject(GardenStore())
            .environmentObject(SettingsStore())
    }
}
