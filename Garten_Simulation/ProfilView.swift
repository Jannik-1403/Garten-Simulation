import SwiftUI

struct ProfilView: View {
    @State private var showSettings = false
    @State private var showXPDetail = false
    @State private var showPflanzenDetail = false
    @State private var showErfolgeDetail = false
    @State private var showStreakDetail = false
    @State private var showWasserDetail = false
    @State private var zeigeGartenPass = false
    @State private var zeigeGartenPassWheel = false
    
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var streakStore: StreakStore
    @EnvironmentObject var achievementStore: AchievementStore
    
    private var freigeschalteteErfolgeAnzahl: Int {
        achievementStore.alleErfolge.filter { $0.istFreigeschaltet }.count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appHintergrund.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // User Profile Info (Name + Level-Badge)
                        VStack(spacing: 8) {
                            Text("Jannik Schill")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .padding(.top, 24)
                            
                            ProfilTierBadgeView(level: gardenStore.gartenStufe)
                        }
                        
                        // Anklickbarer XP-Header → öffnet GartenPassView
                        VStack(spacing: 12) {
                            ProfilXPHeaderView(
                                gesamtXP: gardenStore.gesamtXP,
                                onTippen: { zeigeGartenPass = true }
                            )
                            
                            if gardenStore.gluecksradDrehungen > 0 {
                                Button {
                                    zeigeGartenPassWheel = true
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "arrow.2.circlepath")
                                            .font(.system(size: 14, weight: .bold))
                                        Text(String(format: NSLocalizedString("spin_verfuegbar", comment: ""), 
                                                    gardenStore.gluecksradDrehungen))
                                            .font(.system(size: 14, weight: .bold, design: .rounded))
                                    }
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(Color.blauPrimary) 
                                            .shadow(color: Color.blauPrimary.opacity(0.3), radius: 4, x: 0, y: 2)
                                    )
                                }
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // --- 3D STAT BUTTONS GRID ---
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 20),
                            GridItem(.flexible(), spacing: 20)
                        ], spacing: 24) {
                            XPStatButton(xp: gardenStore.gesamtXP, showDetail: $showXPDetail)
                            InventoryStatButton(count: gardenStore.totalItemsCount, showDetail: $showPflanzenDetail)
                            StreakStatButton(
                                currentStreak: streakStore.currentStreak,
                                bestStreak: streakStore.bestStreak,
                                aktion: { showStreakDetail = true }
                            )
                            ErfolgeStatButton(count: freigeschalteteErfolgeAnzahl, showDetail: $showErfolgeDetail)
                            WasserStatButton(liter: gardenStore.gesamtLiterFormatiert, showDetail: $showWasserDetail)
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 8)
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle(settings.localizedString(for: "profile.title"))
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
            .sheet(isPresented: $showWasserDetail) {
                WasserDetailView()
                    .environmentObject(gardenStore)
                    .environmentObject(settings)
            }
            // Navigation Destinations
            .navigationDestination(isPresented: $showXPDetail) {
                GesamtXPDetailView()
                    .environmentObject(gardenStore)
                    .environmentObject(settings)
            }
            .navigationDestination(isPresented: $showPflanzenDetail) {
                InventoryDetailView()
                    .environmentObject(gardenStore)
                    .environmentObject(settings)
            }
            .navigationDestination(isPresented: $showErfolgeDetail) {
                ErfolgeDetailView()
                    .environmentObject(achievementStore)
                    .environmentObject(gardenStore)
            }
            .navigationDestination(isPresented: $showStreakDetail) {
                StreakView()
                    .environmentObject(streakStore)
            }
            .fullScreenCover(isPresented: $zeigeGartenPass) {
                GartenPassView()
                    .environmentObject(gardenStore)
            }
            .fullScreenCover(isPresented: $zeigeGartenPassWheel) {
                GartenPassWheelView()
                    .environmentObject(gardenStore)
                    .environmentObject(settings)
            }
        }
    }
    
    // MARK: - Computed Properties
}

#Preview { 
    NavigationStack {
        ProfilView()
            .environmentObject(GardenStore())
            .environmentObject(SettingsStore())
            .environmentObject(StreakStore())
            .environmentObject(AchievementStore(gardenStore: GardenStore(), streakStore: StreakStore()))
    }
}
