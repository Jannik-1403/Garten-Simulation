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
                        // Flat Header Section (Name, Title, Level)
                        VStack(spacing: 8) {
                            Text(settings.localizedString(for: "profile.user.name.default"))
                                .font(.system(size: 30, weight: .black, design: .rounded))
                            
                            // Aktiver Titel
                            if let titel = titelStore.aktiverTitel() {
                                Button {
                                    showTitelAuswahl = true
                                } label: {
                                    TitelTextView(titel: titel, fontSize: 18)
                                }
                                .buttonStyle(.plain)
                            } else {
                                Button {
                                    showTitelAuswahl = true
                                } label: {
                                    Text(settings.localizedString(for: "titel.keiner"))
                                        .font(.system(size: 14, weight: .black, design: .rounded))
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                            }

                            ProfilTierBadgeView(level: gardenStore.gartenStufe)
                                .padding(.top, 2)
                        }
                        .padding(.top, 30)
                        .padding(.horizontal, 20)
                        
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
            .fullScreenCover(isPresented: $showSettings) {
                SettingsView()
                    .environmentObject(settings)
            }
            .fullScreenCover(isPresented: $showWasserDetail) {
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
            .onChange(of: gardenStore.triggerStreakDetail) { _, newValue in
                if newValue {
                    showStreakDetail = true
                    gardenStore.triggerStreakDetail = false
                }
            }
            .onChange(of: gardenStore.triggerWaterDetail) { _, newValue in
                if newValue {
                    showWasserDetail = true
                    gardenStore.triggerWaterDetail = false
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
