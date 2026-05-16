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
    @State private var zeigeIgelCustomizer = false
    
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
                        VStack(spacing: 28) {
                            // 1. Igel-Charakter Portrait (At the top)
                            Button(action: { zeigeIgelCustomizer = true }) {
                                VStack(spacing: 16) {
                                    ZStack {
                                        let istStehend = settings.igelCustomization.pose == .stehend
                                        RoundedRectangle(cornerRadius: 60, style: .continuous)
                                            .fill(settings.igelCustomization.background.color)
                                            .frame(width: 320, height: 320)
                                            .shadow(color: .black.opacity(0.06), radius: 20, x: 0, y: 12)
                                        
                                        // Centered Igel View (Maximum zoom as requested)
                                        IgelView(customization: settings.igelCustomization, size: istStehend ? 500 : 300)
                                            .frame(width: 320, height: 320)
                                            .clipShape(RoundedRectangle(cornerRadius: 60, style: .continuous))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 60, style: .continuous)
                                                    .stroke(Color.black.opacity(0.08), lineWidth: 2)
                                            )
                                    }
                                    
                                    VStack(spacing: 4) {
                                        // 2. Igel-Name (Groß)
                                        Text(settings.igelCustomization.name.isEmpty 
                                             ? settings.localizedString(for: "igel_name_placeholder") 
                                             : settings.igelCustomization.name)
                                            .font(.system(size: 32, weight: .black, design: .rounded))
                                            .foregroundStyle(.primary)
                                        
                                        // 3. Spieler-Titel (Interaktiv, Grauer Text-Stil mit Icons)
                                        Button(action: { showTitelAuswahl = true }) {
                                            HStack(spacing: 8) {
                                                Image("Spieler_Title")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 20, height: 20)
                                                
                                                Text(titelStore.aktiverTitel().map { settings.localizedString(for: $0.displayName) } ?? settings.localizedString(for: "titel.anfaenger"))
                                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                                    .foregroundStyle(Color.blauPrimary)
                                                    .textCase(.uppercase)
                                                    .tracking(1)
                                                
                                                Image("Spieler_Title")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 20, height: 20)
                                            }
                                            .padding(.top, 2)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                            
                            // 3. Garten-Pass Banner (Moved below Igel and Title)
                            VStack(spacing: 16) {
                                // 2. Garten-Pass Banner (3D Button)
                                Button(action: { zeigeGartenPass = true }) {
                                    HStack(spacing: 14) {
                                        // Trophy Icon
                                        Image("Erfolg")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 36, height: 36)
                                            .frame(width: 48, height: 48)
                                            .background(
                                                Circle()
                                                    .fill(.white.opacity(0.15))
                                            )

                                        // Text Links
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(settings.localizedString(for: "garten_pass_level_label"))
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .foregroundStyle(.white.opacity(0.8))
                                                .textCase(.uppercase)
                                                .tracking(1)

                                            Text("\(tierTitel) · \(settings.localizedString(for: "level_up_label")) \(level)")
                                                .font(.title3)
                                                .fontWeight(.bold)
                                                .foregroundStyle(.white)

                                            // Fortschrittsbalken
                                            GeometryReader { geo in
                                                ZStack(alignment: .leading) {
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .fill(.white.opacity(0.2))
                                                        .frame(height: 6)
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .fill(.white)
                                                        .frame(width: geo.size.width * CGFloat(fortschritt), height: 6)
                                                }
                                            }
                                            .frame(height: 6)

                                            Text("\(xpImLevel) / \(xpFuerNaechstenLevel) XP")
                                                .font(.caption2)
                                                .foregroundStyle(.white.opacity(0.7))
                                        }

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundStyle(.white.opacity(0.6))
                                    }
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 16)
                                    .background(
                                        ZStack {
                                            // Untere Schicht — 3D Effekt
                                            RoundedRectangle(cornerRadius: 18)
                                                .fill(Color(red: 0.55, green: 0.35, blue: 0.1))
                                                .offset(y: 4)
                                            // Obere Schicht
                                            RoundedRectangle(cornerRadius: 18)
                                                .fill(
                                                    LinearGradient(
                                                        colors: [
                                                            Color(red: 0.78, green: 0.52, blue: 0.2),
                                                            Color(red: 0.65, green: 0.4, blue: 0.12)
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                        }
                                    )
                                    .padding(.horizontal, 16)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 20)
                            

                        }
                        .padding(.top, 30)
                        
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("") // Hidden title
                }
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
            .sheet(isPresented: $showXPDetail) {
                XPInfoSheet()
                    .environmentObject(gardenStore)
                    .environmentObject(settings)
                    .presentationDetents([.medium])
            }
            .sheet(isPresented: $showTitelAuswahl) {
                TitelAuswahlSheet()
            }
            .sheet(isPresented: $zeigeIgelCustomizer) {
                IgelCustomizerView()
                    .environmentObject(settings)
                    .environmentObject(gardenStore)
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
    private var level: Int { GartenLevel.level(fuerXP: gardenStore.gesamtXP) }
    private var xpImLevel: Int { GartenLevel.xpImLevel(gesamtXP: gardenStore.gesamtXP) }
    private var xpFuerNaechstenLevel: Int { GartenLevel.xpFuerNaechstenLevel(gesamtXP: gardenStore.gesamtXP) }
    private var fortschritt: Double {
        let maxXP = xpFuerNaechstenLevel
        guard maxXP > 0 else { return 1.0 }
        return Double(xpImLevel) / Double(maxXP)
    }
    private var tierTitel: String { GartenTierStufe.fuer(level: level).lokalisiertTitel(settings: settings) }
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
