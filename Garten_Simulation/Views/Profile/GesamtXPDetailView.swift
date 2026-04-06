import SwiftUI

struct GesamtXPDetailView: View {
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    
    var body: some View {
        ZStack {
            Color.appHintergrund.ignoresSafeArea()
            
            VStack(spacing: 32) {
                // MARK: - Hero Header
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#409CFF").opacity(0.15))
                            .frame(width: 120, height: 120)
                        Image("XP")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .shadow(color: Color(hex: "#409CFF").opacity(0.3), radius: 15, x: 0, y: 8)
                    }
                    
                    VStack(spacing: 4) {
                        Text("\(gardenStore.gesamtXP)")
                            .font(.system(size: 56, weight: .black, design: .rounded))
                        
                        Text(settings.localizedString(for: "profile.xp.total"))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .tracking(1.0)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(Color(UIColor.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .padding(.top, 40)
        }
        .navigationTitle(settings.localizedString(for: "profile.xp.total"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        GesamtXPDetailView()
            .environmentObject(GardenStore())
            .environmentObject(SettingsStore())
    }
}
