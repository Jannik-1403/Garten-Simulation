import SwiftUI

struct ProfilView: View {
    @State private var showSettings = false
    @State private var showCoinsDetail = false
    @State private var showPflanzenDetail = false
    @State private var showErfolgeDetail = false
    @State private var showStreakDetail = false
    
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var streakStore: StreakStore
    @EnvironmentObject var achievementStore: AchievementStore
    
    // MARK: - Computed Global Stufe (based on total XP)
    private var userStufe: PflanzenStufe {
        PflanzenStufe.allCases.reversed().first {
            GameConstants.xpSchwelleGarten(fuer: $0) <= gardenStore.gesamtXP
        } ?? .bronze1
    }

    private var userFortschritt: Double {
        guard let naechste = userStufe.naechste else { return 1.0 }
        let aktuelleMin = GameConstants.xpSchwelleGarten(fuer: userStufe)
        let naechsteMin = GameConstants.xpSchwelleGarten(fuer: naechste)
        return Double(gardenStore.gesamtXP - aktuelleMin) / Double(naechsteMin - aktuelleMin)
    }

    private var xpZurNaechstenStufe: Int {
        guard let naechste = userStufe.naechste else { return 0 }
        return GameConstants.xpSchwelleGarten(fuer: naechste) - gardenStore.gesamtXP
    }
    
    private var xpNaechsteStufeAbsolut: Int {
        guard let naechste = userStufe.naechste else { return gardenStore.gesamtXP }
        return GameConstants.xpSchwelleGarten(fuer: naechste)
    }
    
    private var freigeschalteteErfolgeAnzahl: Int {
        achievementStore.alleErfolge.filter { $0.istFreigeschaltet }.count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appHintergrund.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // User Profile Info (Name + Badge + XP-Bar)
                        VStack(spacing: 20) {
                            ProfilHeaderView(name: "Jannik Schill", stufe: userStufe)
                                .padding(.top, 24)
                            
                            ProfilXPBarView(
                                stufe: userStufe,
                                fortschritt: userFortschritt,
                                aktuelleXP: gardenStore.gesamtXP,
                                xpNaechsteStufe: xpNaechsteStufeAbsolut
                            )
                            .padding(.horizontal, 24)
                        }
                        
                        // --- 3D STAT BUTTONS GRID ---
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 20),
                            GridItem(.flexible(), spacing: 20)
                        ], spacing: 24) {
                            CoinsStatButton(coins: gardenStore.coins, showDetail: $showCoinsDetail)
                            PflanzenStatButton(count: gardenStore.pflanzen.count, showDetail: $showPflanzenDetail)
                            StreakStatButton(streak: gardenStore.gesamtStreak, aktion: { showStreakDetail = true })
                            ErfolgeStatButton(count: freigeschalteteErfolgeAnzahl, showDetail: $showErfolgeDetail)
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
            // Navigation Destinations
            .navigationDestination(isPresented: $showCoinsDetail) {
                CoinsDetailView()
                    .environmentObject(gardenStore)
            }
            .navigationDestination(isPresented: $showPflanzenDetail) {
                PflanzenDetailView()
                    .environmentObject(gardenStore)
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
        }
    }
}

#Preview { 
    NavigationStack {
        ProfilView()
            .environmentObject(GardenStore())
            .environmentObject(SettingsStore())
            .environmentObject(StreakStore())
            .environmentObject(AchievementStore(gardenStore: GardenStore()))
    }
}
