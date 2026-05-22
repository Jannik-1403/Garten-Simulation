import SwiftUI

struct ProfilView: View {
    @State private var zeigeEinstellungen = false
    @State private var showXPDetail = false
    @State private var showPflanzenDetail = false
    @State private var showErfolgeDetail = false
    @State private var showStreakDetail = false
    @State private var showWasserDetail = false
    @State private var showTitelAuswahl = false
    @State private var showSettings = false
    @State private var zeigeIgelCustomizer = false
    @State private var ausgewaehlterErfolg: Erfolg? = nil
    @State private var navBarIsWhite = false
    
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var streakStore: StreakStore
    @EnvironmentObject var achievementStore: AchievementStore
    @EnvironmentObject var titelStore: TitelStore
    
    private var freigeschalteteErfolgeAnzahl: Int {
        achievementStore.alleErfolge.filter { $0.istFreigeschaltet }.count
    }

    private var spielerTitel: String {
        titelStore.aktiverTitel().map { settings.localizedString(for: $0.displayName) } ?? settings.localizedString(for: "titel.anfaenger")
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color.white.ignoresSafeArea()
                
                if !navBarIsWhite {
                    settings.igelCustomization.background.color
                        .frame(height: 0)
                        .frame(maxWidth: .infinity)
                        .ignoresSafeArea(edges: .top)
                }
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                    
                    // MARK: - Top Bounce Filler (Blau)
                    // Dieser Bereich ist normalerweise unsichtbar, wird aber beim Runterziehen sichtbar
                    settings.igelCustomization.background.color
                        .frame(height: 1000)
                        .offset(y: -1000)
                        .padding(.bottom, -1000)

                    // 1. Top-Bereich (scrollt mit dem Igel)
                    VStack(spacing: 0) {
                        // Igel
                        Button(action: { zeigeIgelCustomizer = true }) {
                            IgelView(customization: settings.igelCustomization, size: 200)
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity)
                        .frame(height: 280)
                    }
                    .background(settings.igelCustomization.background.color)
                    
                    // 2. Weißer Content-Bereich
                    VStack(spacing: 24) {
                        // --- TOP 3 ACHIEVEMENTS ---
                        topAchievementsSection
                            .padding(.top, 8)
                        
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
                            WasserStatButton(liter: gardenStore.gesamtLiterFormatiert, showDetail: $showWasserDetail)
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 8)

                        // Bottom Bounce Filler (Weiß)
                        Color.white
                            .frame(height: 1000)
                    }
                    .padding(.top, 24)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .offset(y: -24)
                    .padding(.bottom, -24)
                }
                .background(
                    GeometryReader { proxy in
                        Color.clear.preference(key: ProfilScrollOffsetKey.self, value: proxy.frame(in: .named("profilScroll")).minY)
                    }
                )
            } // closes ScrollView
            } // closes ZStack
            .coordinateSpace(name: "profilScroll")
            .onPreferenceChange(ProfilScrollOffsetKey.self) { offset in
                let shouldBeWhite = offset < -240
                if navBarIsWhite != shouldBeWhite {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        navBarIsWhite = shouldBeWhite
                    }
                }
            }
            .navigationBarHidden(false)
            .toolbarBackground(navBarIsWhite ? .visible : .hidden, for: .navigationBar)
            .toolbarBackground(Color.white, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        zeigeIgelCustomizer = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .black))
                            .foregroundStyle(.primary)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 0) {
                        Text(settings.igelCustomization.name.isEmpty
                             ? settings.localizedString(for: "igel_name_placeholder")
                             : settings.igelCustomization.name)
                            .font(.title3)
                            .fontWeight(.bold)
                        Text(spielerTitel.uppercased())
                            .font(.system(size: 11, weight: .black))
                    }
                    .fixedSize()
                    .allowsHitTesting(false)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 20, weight: .black))
                            .foregroundStyle(.primary)
                    }
                }
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
            .sheet(isPresented: $showXPDetail) {
                XPInfoSheet()
                    .environmentObject(gardenStore)
                    .environmentObject(settings)
                    .presentationDetents([.medium])
            }
            .sheet(isPresented: $showTitelAuswahl) {
                TitelAuswahlSheet()
                    .environmentObject(settings)
                    .presentationDetents([.medium, .large])
            }
            .navigationDestination(isPresented: $showSettings) {
                SettingsView()
                    .environmentObject(settings)
            }
            .sheet(isPresented: $zeigeIgelCustomizer) {
                IgelCustomizerView()
                    .environmentObject(settings)
                    .environmentObject(gardenStore)
            }
            .fullScreenCover(item: $ausgewaehlterErfolg) { erfolg in
                ErfolgDetailSheet(erfolg: erfolg, istFreigeschaltet: erfolg.istFreigeschaltet)
                    .environmentObject(settings)
                    .environmentObject(gardenStore)
                    .environmentObject(streakStore)
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
    
    // MARK: - Achievements Section
    private var topAchievementsSection: some View {
        VStack(spacing: 0) {
            // Horizontal Scroll List
            let unlockedAchievements = getUnlockedErfolge()
            if unlockedAchievements.isEmpty {
                Text(settings.localizedString(for: "profile.achievements.empty"))
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(unlockedAchievements) { erfolg in
                            Button(action: { ausgewaehlterErfolg = erfolg }) {
                                VStack(spacing: 12) {
                                    ErfolgBadgeView(erfolg: erfolg, istFreigeschaltet: true)
                                        .scaleEffect(1.25)
                                        .frame(width: 120, height: 120)
                                    
                                    Text(settings.localizedString(for: erfolg.titelKey))
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundStyle(.primary)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                        .frame(width: 120, height: 36, alignment: .top)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        
                        // "Mehr ansehen" Button at the end
                        Button(action: { showErfolgeDetail = true }) {
                            VStack(spacing: 12) {
                                ZStack {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundStyle(.primary)
                                }
                                .frame(width: 120, height: 120) // Match height of badge container
                                
                                Text("Alle Erfolge")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundStyle(.primary)
                                    .multilineTextAlignment(.center)
                                    .frame(width: 100, height: 36, alignment: .top)
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(.leading, 8)
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
    }
    
    private func getUnlockedErfolge() -> [Erfolg] {
        return achievementStore.alleErfolge
            .filter { $0.istFreigeschaltet }
            .sorted(by: { 
                if $0.tier != $1.tier { return $0.tier.rawValue > $1.tier.rawValue }
                return ($0.freigeschaltetAm ?? Date.distantPast) > ($1.freigeschaltetAm ?? Date.distantPast)
            })
    }
}

struct ProfilScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
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
