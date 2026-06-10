import SwiftUI

struct ProfilView: View {
    @State private var zeigeEinstellungen = false
    @State private var showXPDetail = false
    @State private var showPflanzenDetail = false
    @State private var showErfolgeDetail = false
    @State private var showStreakDetail = false
    @State private var showWasserDetail = false
    @State private var showTitelAuswahl = false
    @State private var zeigeNameEdit = false
    @State private var showSettings = false
    @State private var showCharacterCustomization = false
    @State private var ausgewaehlterErfolg: Erfolg? = nil
    
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var streakStore: StreakStore
    @EnvironmentObject var achievementStore: AchievementStore
    @EnvironmentObject var titelStore: TitelStore
    @EnvironmentObject var characterStore: CharacterStore
    
    private var freigeschalteteErfolgeAnzahl: Int {
        achievementStore.alleErfolge.filter { $0.istFreigeschaltet }.count
    }

    private var spielerTitel: String {
        titelStore.aktiverTitel().map { settings.localizedString(for: $0.displayName) } ?? settings.localizedString(for: "titel.anfaenger")
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color.appHintergrund.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // --- AVATAR PREVIEW ---
                        Item3DButton(
                            farbe: Color.characterBackground(for: characterStore.profile.backgroundIndex),
                            sekundaerFarbe: Color.secondaryCharacterBackground(for: characterStore.profile.backgroundIndex),
                            groesse: 250,
                            shadowDepthFactor: 0.02,
                            aktion: { showCharacterCustomization = true }
                        ) {
                            AvatarView(profile: characterStore.profile)
                                .frame(width: 250, height: 250, alignment: .top)
                                .clipShape(Circle())
                        }
                        .padding(.top, 16)
                        
                        // --- PLAYER NAME & TITLE ---
                        VStack(spacing: 4) {
                            Button {
                                zeigeNameEdit = true
                            } label: {
                                Text(settings.igelCustomization.name.isEmpty
                                     ? settings.localizedString(for: "igel_name_placeholder")
                                     : settings.igelCustomization.name)
                                    .font(.title2)
                                    .fontWeight(.heavy)
                                    .foregroundStyle(.primary)
                            }
                            
                            Button {
                                showTitelAuswahl = true
                            } label: {
                                Text(spielerTitel.uppercased())
                            }
                            .buttonStyle(ProfilTitle3DStyle())
                        }
                        .padding(.bottom, 8)
                        
                        // --- TOP 3 ACHIEVEMENTS ---
                        topAchievementsSection
                        
                        // --- 3D STAT BUTTONS DASHBOARD ---
                        VStack(spacing: 20) {
                            WasserStatButton(liter: gardenStore.gesamtLiterFormatiert, showDetail: $showWasserDetail)
                            
                            HStack(spacing: 20) {
                                XPStatButton(xp: gardenStore.gesamtXP, showDetail: $showXPDetail)
                                StreakStatButton(
                                    currentStreak: streakStore.currentStreak,
                                    bestStreak: streakStore.bestStreak,
                                    aktion: { showStreakDetail = true }
                                )
                            }
                            
                            InventoryStatButton(count: gardenStore.totalItemsCount, showDetail: $showPflanzenDetail)
                        }
                        .padding(.horizontal, 24)
                        
                        // Bottom Bounce Filler
                        Color.clear
                            .frame(height: 100)
                    }
                } // closes ScrollView
            } // closes ZStack
            .navigationBarHidden(false)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.appHintergrund, for: .navigationBar)
            .toolbar {
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
            .fullScreenCover(isPresented: $showCharacterCustomization) {
                CharacterCustomizationView()
                    .environmentObject(characterStore)
                    .environmentObject(settings)
            }
            .sheet(isPresented: $zeigeEinstellungen) {
                HabitStackConfigView()
                    .environmentObject(achievementStore)
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
            .sheet(isPresented: $zeigeNameEdit) {
                NameEditSheet()
                    .environmentObject(settings)
                    .environmentObject(gardenStore)
                    .presentationDetents([.medium])
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
                            DuolingoCard(action: { ausgewaehlterErfolg = erfolg }, tier: erfolg.tier) {
                                VStack(spacing: 8) {
                                    ErfolgBadgeView(erfolg: erfolg, istFreigeschaltet: true)
                                        .frame(width: 60, height: 60)
                                    
                                    Text(settings.localizedString(for: erfolg.titelKey))
                                        .font(.system(size: 11, weight: .bold, design: .rounded))
                                        .foregroundStyle(.primary)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.7)
                                        .frame(maxWidth: .infinity)
                                }
                                .frame(width: 90)
                            }
                            .frame(height: 125)
                        }
                        
                        // "Mehr ansehen" Button at the end
                        Button(action: { showErfolgeDetail = true }) {
                            ZStack {
                                Color.clear
                                    .frame(width: 80, height: 80)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundStyle(.primary)
                            }
                        }
                        .buttonStyle(BadgeBounceButtonStyle())
                        .padding(.leading, 8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
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

struct ProfilTitle3DStyle: ButtonStyle {
    @State private var shimmerOffset: CGFloat = -150
    
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        ZStack {
            // Lower layer (shadow)
            configuration.label
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(Color.blauPrimary.opacity(0.35))
                .offset(y: 4)

            // Upper layer (visible text)
            ZStack {
                configuration.label
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(Color.blauPrimary)
                
                // Shimmer Effect
                LinearGradient(
                    gradient: Gradient(colors: [.clear, Color.white.opacity(0.8), .clear]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: 80)
                .offset(x: shimmerOffset)
                .mask(
                    configuration.label
                        .font(.system(size: 18, weight: .black, design: .rounded))
                )
            }
            .offset(y: isPressed ? 4 : 0)
            .overlay(alignment: .topTrailing) {
                TitleGlitterView()
                    .offset(x: 12, y: -8)
            }
        }
        .onAppear {
            // Shimmer moves left to right, then restarts
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                shimmerOffset = 150
            }
        }
        .animation(.spring(response: 0.15, dampingFraction: 0.6), value: isPressed)
    }
}

struct TitleGlitterView: View {
    @State private var isAnimating = false
    
    var body: some View {
        Image(systemName: "sparkle")
            .foregroundStyle(Color.blauPrimary)
            .font(.system(size: 14))
            .opacity(isAnimating ? 1.0 : 0.0)
            .scaleEffect(isAnimating ? 1.2 : 0.2)
            .rotationEffect(Angle(degrees: isAnimating ? 45 : 0))
            .animation(
                .easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
                .delay(0.5),
                value: isAnimating
            )
            .allowsHitTesting(false)
            .onAppear {
                isAnimating = true
            }
    }
}


struct BadgeBounceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
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
