import SwiftUI

struct ProfilView: View {
    @State private var showSettings = false
    @State private var showXPDetail = false
    @State private var showPflanzenDetail = false
    @State private var showErfolgeDetail = false
    @State private var showStreakDetail = false
    @State private var showWasserDetail = false
    @State private var zeigeGartenPass = false
    @State private var showTitelAuswahl = false
    
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var streakStore: StreakStore
    @EnvironmentObject var achievementStore: AchievementStore
    @EnvironmentObject var titelStore: TitelStore
    
    private var freigeschalteteErfolgeAnzahl: Int {
        achievementStore.alleErfolge.filter { $0.istFreigeschaltet }.count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appHintergrund.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // User Profile Info (Name, Title, Level)
                        VStack(spacing: 8) {
                            Text("Jannik Schill")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .padding(.top, 24)
                            
                            // 1. Name (above)
                            // Aktiver Titel
                            if let titel = titelStore.aktiverTitel() {
                                Button {
                                    showTitelAuswahl = true
                                } label: {
                                    TitelTextView(titel: titel)
                                }
                                .buttonStyle(.plain)
                                .transition(.scale.combined(with: .opacity))
                            } else {
                                Button {
                                    showTitelAuswahl = true
                                } label: {
                                    Text(settings.localizedString(for: "titel.keiner"))
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 4)
                                        .background(Capsule().fill(Color.secondary.opacity(0.1)))
                                }
                                .buttonStyle(.plain)
                            }

                            // 3. Level (now below Title, and without background via its own view)
                            ProfilTierBadgeView(level: gardenStore.gartenStufe)
                        }
                        
                        // Anklickbarer XP-Header → öffnet GartenPassView
                        VStack(spacing: 12) {
                            ProfilXPHeaderView(
                                gesamtXP: gardenStore.gesamtXP,
                                onTippen: { zeigeGartenPass = true }
                            )
                            
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
            .sheet(isPresented: $showTitelAuswahl) {
                TitelAuswahlSheet()
            }
            .overlay {
                if let neuerTitel = titelStore.neuerTitelZumAnzeigen {
                    NeuerTitelOverlay(titel: neuerTitel) {
                        withAnimation {
                            titelStore.neuerTitelZumAnzeigen = nil
                        }
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                    .zIndex(100)
                }
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
