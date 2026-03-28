import SwiftUI

struct ProfilView: View {
    @State private var showSettings = false
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var streakStore: StreakStore
    @EnvironmentObject var achievementStore: AchievementStore
    
    // MARK: - Computed Global Rarity (based on total XP)
    private var globalRarity: PflanzenSeltenheit {
        if gardenStore.gesamtXP >= GameConstants.xpFuerDiamant * 10 { return .diamant } // Scaling for global
        if gardenStore.gesamtXP >= GameConstants.xpFuerGold * 5     { return .gold }
        if gardenStore.gesamtXP >= GameConstants.xpFuerSilber * 3   { return .silber }
        return .bronze
    }

    private var globalProgress: Double {
        let xp = gardenStore.gesamtXP
        if xp >= GameConstants.xpFuerDiamant * 10 { return 1.0 }
        // Simple linear progress for demo
        return min(Double(xp) / Double(GameConstants.xpFuerDiamant * 10), 1.0)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appHintergrund.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // User Profile Info
                        VStack(spacing: 4) {
                            Text("profile.user.name", bundle: .main)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                            Text("garden.habits.active", bundle: .main) // Simplified tag
                                .font(.system(size: 15))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 40)
                        
                        // Level Progress (Duolingo Style)
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text(globalRarity.lokalisiertTitel.uppercased())
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundStyle(.primary)
                                Spacer()
                                Text("\(gardenStore.gesamtXP) XP")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundStyle(.primary)
                            }
                            
                            // 3D Progress Bar
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color.gray.opacity(0.15))
                                        .frame(height: 16)
                                    
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(globalRarity.farbe)
                                        .frame(width: geo.size.width * CGFloat(globalProgress), height: 16)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .fill(.white.opacity(0.3))
                                                .frame(height: 4)
                                                .padding(.horizontal, 4)
                                                .offset(y: -4)
                                            , alignment: .top
                                        )
                                }
                            }
                            .frame(height: 16)
                        }
                        .padding(.horizontal, 24)
                        
                        // Stats Bento Grid (3D tactile)
                        VStack(spacing: 16) {
                            // Row 1: Coins (Wide)
                            NavigationLink(destination: CoinsDetailView()) {
                                StatCard(title: "profile.coins", value: "\(gardenStore.coins)", icon: "Coin", color: .goldPrimary, isWide: true)
                            }
                            .buttonStyle(StatCardButtonStyle())
                            
                            // Row 2: Secondary Stats (Side-by-side)
                            HStack(spacing: 16) {
                                NavigationLink(destination: PflanzenDetailView()) {
                                    StatCard(title: "profile.plants", value: "\(gardenStore.pflanzen.count)", icon: "leaf.fill", color: .green)
                                }
                                .buttonStyle(StatCardButtonStyle())
                                
                                NavigationLink(destination: StreakView()) {
                                    StatCard(title: "profile.streak", value: "\(streakStore.currentStreak)", icon: "calendar", color: .orange)
                                }
                                .buttonStyle(StatCardButtonStyle())
                            }
                            
                            // Row 3: Erfolge Vitrine (Wide)
                            NavigationLink(destination: ErfolgeDetailView()) {
                                AchievementVitrine(unlockedErfolge: achievementStore.freigeschalteteErfolge)
                            }
                            .buttonStyle(StatCardButtonStyle())
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { 
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                            showSettings = true 
                        }
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Color.primary)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .environmentObject(settings)
            }
        }
    }
}

// MARK: - Subviews

struct StatCard: View {
    let title: String
    let value: String
    let icon: String // Can be SF Symbol or Asset name
    let color: Color
    var isWide: Bool = false
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // Background Icon (Stylized Duolingo-like)
            Group {
                if icon == "Coin" {
                    Image("Coin")
                        .resizable()
                        .scaledToFit()
                        .frame(width: isWide ? 100 : 70)
                        .opacity(0.15)
                        .rotationEffect(.degrees(-15))
                        .offset(x: 20, y: 15)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: isWide ? 80 : 60))
                        .foregroundStyle(color.opacity(0.12))
                        .offset(x: 10, y: 10)
                }
            }
            .clipped()
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(value)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    Text(LocalizedStringKey(title))
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .kerning(1.0)
                }
                Spacer()
            }
            .padding(20)
            .padding(.top, isWide ? 0 : 20)
        }
        .frame(maxWidth: .infinity)
        .frame(height: isWide ? 110 : 130)
    }
}

struct AchievementVitrine: View {
    let unlockedErfolge: [ErfolgModel]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(unlockedErfolge.count) \(Text("profile.achievements", bundle: .main))")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                    Text("profile.achievements.subtitle", bundle: .main)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "trophy.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(Color.lilaPrimary)
                    .shadow(color: Color.lilaPrimary.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            
            HStack(spacing: 12) {
                if unlockedErfolge.isEmpty {
                    Text("Noch keine Erfolge freigeschaltet")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .italic()
                } else {
                    ForEach(unlockedErfolge.prefix(5)) { erfolg in
                        BadgeIcon(icon: erfolg.icon, color: erfolg.farbe, isUnlocked: true)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
    }
}

struct BadgeIcon: View {
    let icon: String
    let color: Color
    let isUnlocked: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isUnlocked ? color.opacity(0.15) : Color.gray.opacity(0.1))
                .frame(width: 45, height: 45)
            
            Image(systemName: icon)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(isUnlocked ? color : Color.gray.opacity(0.4))
                .shadow(color: isUnlocked ? color.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
        }
        .overlay(
            Circle()
                .stroke(isUnlocked ? color.opacity(0.2) : Color.clear, lineWidth: 2)
        )
    }
}

struct StatCardButtonStyle: ButtonStyle {
    @AppStorage("isHapticEnabled") var isHapticEnabled: Bool = true
    private let depth: CGFloat = 6
    private let cornerRadius: CGFloat = 20

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        
        ZStack(alignment: .top) {
            // Sockel
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color.gray.opacity(0.2))
                .offset(y: depth)

            // Face
            configuration.label
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                )
                .offset(y: isPressed ? depth : 0)
        }
        .animation(isPressed ? nil : .spring(response: 0.15, dampingFraction: 0.6), value: isPressed)
        .sensoryFeedback(trigger: isPressed) { _, newValue in
            (isHapticEnabled && newValue) ? .impact(flexibility: .soft, intensity: 0.5) : nil
        }
    }
}

#Preview { 
    NavigationStack {
        ProfilView()
            .environmentObject(GardenStore())
            .environmentObject(SettingsStore())
            .environmentObject(StreakStore())
    }
}
