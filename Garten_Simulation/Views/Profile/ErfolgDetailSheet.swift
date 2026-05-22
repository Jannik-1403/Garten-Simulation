import SwiftUI
import Photos

struct ErfolgDetailSheet: View {
    let erfolg: Erfolg
    let istFreigeschaltet: Bool
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var achievementStore: AchievementStore
    
    @State private var showShareSheet = false
    
    // Dynamic reactive lookup of the achievement from the store to handle upgrades in real-time
    private var liveErfolg: Erfolg {
        achievementStore.alleErfolge.first(where: { $0.id == erfolg.id }) ?? erfolg
    }
    
    // Helper to format the date
    private func formatDate(_ date: Date, language: String) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: language)
        return formatter.string(from: date)
    }
    
    // Determines correct vibrant particle and glow color based on the asset name
    private var assetColor: Color {
        switch liveErfolg.tier {
        case .bronze: return Color(red: 0.85, green: 0.6, blue: 0.4)
        case .silber: return Color(white: 0.8)
        case .gold: return Color(hex: "#FFD60A")
        case .diamant: return Color(hex: "#0A84FF")
        case .master, .max: return Color(hex: "#FF3B30")
        }
    }

    
    var body: some View {
        let isDiamond = liveErfolg.tier == .diamant || liveErfolg.tier == .max
        let isReadyToUpgrade = liveErfolg.istFreigeschaltet && liveErfolg.tier != .max
        
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea() 
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // ZStack hosting the comets, vertical 3D reflection, and badge
                    ZStack {
                        // 1. Kometen-Spritz-Effekt (Particles behind badge matching color)
                        if liveErfolg.istFreigeschaltet {
                            ParticleEmitterView(tier: liveErfolg.tier)
                                .frame(width: 240, height: 240)
                                .id(liveErfolg.tier) // Force recreate particles on tier upgrade
                        }
                        
                        // 2. 3D Reflection underneath the badge
                        Image(liveErfolg.mixedImageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 240, height: 240)
                            .scaleEffect(y: -1) // Vertically flipped
                            .opacity(0.12) // Soft reflection
                            .blur(radius: 6)
                            .offset(y: 190) // Positioned directly below
                            .grayscale(liveErfolg.istFreigeschaltet ? 0 : 1)
                            .applyErfolgFarbe(for: liveErfolg.tier)
                        
                        // 3. Main Achievement Badge
                        Image(liveErfolg.mixedImageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 240, height: 240)
                            .shadow(color: liveErfolg.istFreigeschaltet ? assetColor.opacity(0.4) : .clear, radius: 40, y: 20)
                            .grayscale(liveErfolg.istFreigeschaltet ? 0 : 1)
                            .opacity(liveErfolg.istFreigeschaltet ? 1 : 0.6)
                            .applyErfolgFarbe(for: liveErfolg.tier)
                            .overlay {
                                if !liveErfolg.istFreigeschaltet {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 50, weight: .black))
                                        .foregroundStyle(.white)
                                        .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
                                }
                            }
                    }
                    .padding(.bottom, 60) // Extra padding to clear the 3D reflection
                    
                    VStack(spacing: 24) {
                        VStack(spacing: 12) {
                            Text(settings.localizedString(for: liveErfolg.titelKey))
                                .font(.system(size: 34, weight: .black, design: .rounded))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                            
                            // Tier Subtitle
                            Text(liveErfolg.tier == .max ? settings.localizedString(for: "erfolg.max_reached") : liveErfolg.tier.label)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(liveErfolg.tier.color)
                            
                            Text(settings.localizedString(for: liveErfolg.beschreibungKey))
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                    }
                    
                    Spacer()
                    
                    // Status / Progress Section
                    VStack(spacing: 24) {
                        VStack(spacing: 12) {
                            HStack {
                                Text(settings.localizedString(for: "erfolge.fortschritt"))
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("\(liveErfolg.aktuellerWert) / \(liveErfolg.zielWert)")
                                    .font(.headline.weight(.bold))
                                    .foregroundStyle(.primary)
                            }
                            .frame(maxWidth: 280)
                            
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.secondary.opacity(0.1))
                                    
                                    Capsule()
                                        .fill(liveErfolg.tier.color)
                                        .frame(width: geo.size.width * CGFloat(min(Double(liveErfolg.aktuellerWert) / Double(liveErfolg.zielWert), 1.0)))
                                        .shadow(color: liveErfolg.tier.color.opacity(0.3), radius: 4, x: 0, y: 0)
                                }
                            }
                            .frame(maxWidth: 280)
                            .frame(height: 14)
                        }
                    }
                    .padding(.bottom, 60)
                }
            }
            .navigationTitle(settings.localizedString(for: liveErfolg.titelKey))
            .navigationBarTitleDisplayMode(.inline)
            .standardNavigationX()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showShareSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.primary)
                            .padding(8)
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                ErfolgSharePreviewSheet(erfolg: liveErfolg)
                    .environmentObject(settings)
            }
        }
    }
}

// Sparkle/Comet Particle View that replicates the exact, artfully scattered, sparse 3D diamond layout of the reference photo (Picture 2) with adaptive colors
struct ParticleEmitterView: View {
    let tier: ErfolgTier
    
    // Stable pre-defined particles for a perfect static depth-of-field layout
    struct StaticDiamond: Identifiable {
        let id = UUID()
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
        let blur: CGFloat
        let opacity: Double
        let customColor: Color
    }
    
    @State private var particles: [StaticDiamond] = []
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Image(systemName: "diamond.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: particle.size, height: particle.size)
                    .foregroundColor(particle.customColor)
                    .shadow(color: particle.customColor.opacity(0.8), radius: 6) // Gorgeous glowing aura
                    .opacity(particle.opacity)
                    .blur(radius: particle.blur) // Real depth-of-field camera blur
                    .offset(x: particle.x, y: particle.y)
            }
        }
        .onAppear {
            // Replicate the exact, sparse horizontal distribution from Picture 2 with dynamic colors
            if particles.isEmpty {
                // Determine colors based on the tier
                let c1: Color // far left/right background (large blurry)
                let c2: Color // mid left/right (sharp/semi-blurry)
                let c3: Color // lower left/right background (very blurry)
                let c4: Color // inner left/right (small sharp accents)
                
                switch tier {
                case .bronze:
                    c1 = Color(red: 0.8, green: 0.4, blue: 0.2)   // Deep Bronze
                    c2 = Color(red: 0.9, green: 0.5, blue: 0.3)   // Warm Bronze
                    c3 = Color(red: 1.0, green: 0.6, blue: 0.3)   // Light Orange
                    c4 = Color(red: 1.0, green: 0.8, blue: 0.5)   // Shiny Copper
                case .silber:
                    c1 = Color(red: 0.5, green: 0.55, blue: 0.65) // Dark Slate
                    c2 = Color(red: 0.7, green: 0.75, blue: 0.85) // Shiny Silver
                    c3 = Color(red: 0.85, green: 0.9, blue: 0.95) // Light Blue/Silver
                    c4 = Color(white: 0.95)                       // White/Silver Accent
                case .gold:
                    c1 = Color(red: 0.1, green: 0.75, blue: 0.35) // Emerald Green
                    c2 = Color(red: 0.95, green: 0.85, blue: 0.1) // Vibrant Gold
                    c3 = Color(red: 0.2, green: 0.85, blue: 0.5)  // Mint Green
                    c4 = Color(red: 1.0, green: 0.9, blue: 0.3)   // Pale Gold
                case .diamant:
                    c1 = Color(red: 0.1, green: 0.8, blue: 0.9)   // Bright Cyan
                    c2 = Color(red: 0.3, green: 0.9, blue: 1.0)   // Ice Blue
                    c3 = Color(red: 0.5, green: 0.95, blue: 1.0)  // Light Cyan
                    c4 = Color(white: 1.0)                        // White sparkle
                case .master, .max:
                    c1 = Color(red: 0.9, green: 0.1, blue: 0.1)   // Bright Red
                    c2 = Color(red: 1.0, green: 0.3, blue: 0.3)   // Light Red
                    c3 = Color(red: 0.7, green: 0.0, blue: 0.0)   // Dark Red
                    c4 = Color(white: 1.0)                        // White sparkle
                }
                
                self.particles = [
                    // --- LEFT SIDE PARTICLES ---
                    // 1. Blurry far left background
                    StaticDiamond(x: -200, y: 40, size: 18, blur: 3.5, opacity: 0.5, customColor: c1),
                    // 2. Smaller sharp mid-left
                    StaticDiamond(x: -120, y: -50, size: 13, blur: 0.8, opacity: 0.8, customColor: c2),
                    // 3. Very blurry mid-left lower
                    StaticDiamond(x: -150, y: 100, size: 15, blur: 4.0, opacity: 0.6, customColor: c3),
                    // 4. Small sharp near left
                    StaticDiamond(x: -80, y: 80, size: 10, blur: 0.0, opacity: 0.9, customColor: c4),
                    
                    // --- RIGHT SIDE PARTICLES ---
                    // 5. Blurry mid-right
                    StaticDiamond(x: 95, y: -30, size: 15, blur: 2.0, opacity: 0.75, customColor: c4),
                    // 6. Sharp near right
                    StaticDiamond(x: 130, y: 60, size: 12, blur: 0.5, opacity: 0.85, customColor: c1),
                    // 7. Blurry mid-right lower
                    StaticDiamond(x: 120, y: 110, size: 12, blur: 2.5, opacity: 0.7, customColor: c2),
                    // 8. Blurry far right background
                    StaticDiamond(x: 220, y: -20, size: 19, blur: 4.5, opacity: 0.55, customColor: c1),
                    // 9. Very blurry far right lower
                    StaticDiamond(x: 175, y: 120, size: 16, blur: 4.0, opacity: 0.6, customColor: c3)
                ]
            }
        }
    }
}

// Gorgeous premium share card containing custom tier background glows, title, active tier capsule and description
struct ShareAchievementCard: View {
    let erfolg: Erfolg
    let theme: ShareImageTheme
    let settings: SettingsStore
    
    private var textColor: Color {
        theme == .dark ? .white : .primary
    }
    
    private var secondaryTextColor: Color {
        theme == .dark ? Color.white.opacity(0.7) : .secondary
    }
    
    private var username: String {
        let name = settings.igelCustomization.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty ? settings.localizedString(for: "profile.user.name.default") : name
    }
    
    var body: some View {
        let isDiamond = erfolg.tier == .diamant || erfolg.tier == .max
        
        VStack(spacing: 24) {
            ZStack {
                // 1. Gorgeous scattered 3D diamonds/comets behind badge matching the detail sheet
                ParticleEmitterView(tier: erfolg.tier)
                    .frame(width: 220, height: 220)
                    .applyErfolgFarbe(for: erfolg.tier)
                
                // 2. Main badge
                Image(erfolg.mixedImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 170, height: 170)
                    .applyErfolgFarbe(for: erfolg.tier)
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 6)
            }
            .padding(.top, 32)
            
            VStack(spacing: 12) {
                Text(settings.localizedString(for: erfolg.titelKey))
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundStyle(textColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                
                Text(erfolg.tier.label.uppercased())
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(erfolg.tier.color)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(erfolg.tier.color.opacity(0.12))
                    .clipShape(Capsule())
                
                Text(settings.localizedString(for: erfolg.beschreibungKey))
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(secondaryTextColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .lineSpacing(4)
            }
            .padding(.bottom, 16)
            
            // FOOTER
            HStack(spacing: 12) {
                Image("AppIcon")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                
                Spacer()
                
                Text("@\(username)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(textColor.opacity(0.8))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(textColor.opacity(0.1), in: Capsule())
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .frame(width: 320)
        .background(
            Group {
                switch theme {
                case .vibrant:
                    RadialGradient(
                        colors: [erfolg.tier.color.opacity(0.25), Color.white],
                        center: .center,
                        startRadius: 10,
                        endRadius: 300
                    )
                case .dark:
                    Color(hex: "#1C1C1E")
                case .light:
                    Color.white
                }
            }
        )
        // Kein clipShape – Hintergrundfarbe füllt das volle rechteckige Bild beim Export
        .shadow(color: theme == .dark ? .black.opacity(0.3) : .black.opacity(0.06), radius: 25, x: 0, y: 12)
    }
}

// Replicates the exact swipable theme selector sheet (preview card selection for .light, .dark, .vibrant) of the statistics dashboard for achievements
struct ErfolgSharePreviewSheet: View {
    let erfolg: Erfolg
    @State private var selectedTheme: ShareImageTheme = .light
    @State private var isExporting = false
    @State private var savedToPhotos = false
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var settings: SettingsStore
    
    private let themes: [ShareImageTheme] = [.light, .dark, .vibrant]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Swipable Preview Area
                    TabView(selection: $selectedTheme) {
                        ForEach(themes, id: \.self) { theme in
                            previewCard(theme: theme)
                                .tag(theme)
                                .padding(.horizontal, 24)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                    .frame(maxHeight: .infinity)
                    .onAppear {
                        UIPageControl.appearance().currentPageIndicatorTintColor = .black
                        UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
                    }
                    
                    VStack(spacing: 8) {
                        Text(settings.localizedString(for: themeNameKey(for: selectedTheme)))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        
                        Text(settings.localizedString(for: "stats.share.swipe_hint"))
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        if savedToPhotos {
                            Label("In Fotos gespeichert", systemImage: "checkmark.circle.fill")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(.green)
                                .transition(.opacity.combined(with: .scale))
                        }
                    }
                    .animation(.spring(), value: savedToPhotos)
                    .padding(.bottom, 60)
                }
            }
            .navigationTitle(settings.localizedString(for: "stats.share.preview_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { exportSelectedTheme() } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.primary)
                    }
                    .disabled(isExporting)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { saveToPhotos() } label: {
                        if savedToPhotos {
                            Image(systemName: "checkmark")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.green)
                        } else {
                            Image(systemName: "photo.badge.arrow.down")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.primary)
                        }
                    }
                    .disabled(isExporting)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: savedToPhotos)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .black))
                            .foregroundStyle(.primary)
                    }
                }
            }
        }
    }
    
    // Vorschau-Karte mit abgerundeten Ecken (nur in der UI)
    private func previewCard(theme: ShareImageTheme) -> some View {
        ShareAchievementCard(erfolg: erfolg, theme: theme, settings: settings)
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .stroke(Color.primary.opacity(theme == .dark ? 0.15 : 0.05), lineWidth: 1)
            )
            .shadow(color: theme == .dark ? .black.opacity(0.3) : .black.opacity(0.08), radius: 20, x: 0, y: 10)
    }
    
    private func themeNameKey(for theme: ShareImageTheme) -> String {
        switch theme {
        case .vibrant: return "stats.share.style.vibrant"
        case .light: return "stats.share.style.light"
        case .dark: return "stats.share.style.dark"
        }
    }
    
    private func makeImage() -> UIImage? {
        let view = ShareAchievementCard(erfolg: erfolg, theme: selectedTheme, settings: settings)
        let renderer = ImageRenderer(content: view)
        renderer.scale = 3.0
        return renderer.uiImage
    }
    
    private func saveToPhotos() {
        isExporting = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            guard let image = makeImage() else { isExporting = false; return }
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                DispatchQueue.main.async {
                    if status == .authorized || status == .limited {
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                        withAnimation { savedToPhotos = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation { savedToPhotos = false }
                        }
                    }
                    isExporting = false
                }
            }
        }
    }
    
    private func exportSelectedTheme() {
        isExporting = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            guard let image = makeImage() else { isExporting = false; return }
            let activityVC = UIActivityViewController(
                activityItems: [image],
                applicationActivities: nil
            )
            if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
               let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
                var topVC = window.rootViewController
                while let presented = topVC?.presentedViewController { topVC = presented }
                topVC?.present(activityVC, animated: true)
            }
            isExporting = false
        }
    }
}
