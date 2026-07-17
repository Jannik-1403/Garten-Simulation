import SwiftUI
import UniformTypeIdentifiers
import SwiftData
import StoreKit

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var shopStore: ShopStore
    @EnvironmentObject var streakStore: StreakStore
    @EnvironmentObject var powerUpStore: PowerUpStore
    @EnvironmentObject var titelStore: TitelStore
    @EnvironmentObject var achievementStore: AchievementStore
    @EnvironmentObject var pfadStore: GartenPfadStore
    @EnvironmentObject var characterStore: CharacterStore
    @EnvironmentObject var tourManager: InteractiveTourManager
    @EnvironmentObject var assessmentStore: AssessmentStore
    @EnvironmentObject var iapStore: IAPStore
    @StateObject private var healthManager = HealthManager.shared
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) var scenePhase
    
    @State private var showResetAlert = false
    @State private var zeigeAccountLoeschenDialog = false
    @State private var zeigePaywall = false
    @State private var showFinalResetAlert = false
    @State private var showBackupSheet = false
    @State private var showPDFExport = false
    
    private var aktuelleTierStufe: GartenTierStufe {
        GartenTierStufe.fuer(level: gardenStore.gartenStufe)
    }

    // MARK: - Sub-Views
    @ViewBuilder
    private var primarySettingsSections: some View {
        // MARK: - Pro Upgrade
                                if !iapStore.isProUser {
                                Button {
                                    zeigePaywall = true
                                } label: {
                                    HStack(spacing: 12) {
                                        Image("ProFeature")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 22, height: 22)
                                            .scaleEffect(2.5)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(String(localized: "settings.pro.unlock", defaultValue: "Grovy Pro freischalten"))
                                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                                .foregroundStyle(.white)
                                            Text(String(localized: "settings.pro.subtitle", defaultValue: "Erhalte vollen Zugriff"))
                                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                                .foregroundStyle(.white.opacity(0.8))
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(.white.opacity(0.8))
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                }
                                .buttonStyle(ProUpgradeButtonStyle())
                            }
                            
                            // MARK: - Integrationen (Pro Feature)
                            settingsSection(title: String(localized: "settings.section.integrations", defaultValue: "Integrationen")) {
                                VStack(alignment: .leading, spacing: 0) {
                                    NavigationLink {
                                        ScreenTimeSettingsView()
                                    } label: {
                                        HStack(spacing: 12) {
                                            Image(systemName: "hourglass")
                                                .font(.system(size: 20, weight: .medium))
                                                .foregroundStyle(.white)
                                                .frame(width: 28, height: 28)
                                                .background(Color.blue, in: RoundedRectangle(cornerRadius: 6))
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(String(localized: "screenTime.title", defaultValue: "Bildschirmzeit"))
                                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                                    .foregroundStyle(.primary)
                                                
                                                Text(String(localized: "settings.screenTime.instruction", defaultValue: "Verwalte Block-Zeiten und App-Kategorien."))
                                                    .font(.system(size: 10, weight: .regular, design: .rounded))
                                                    .foregroundStyle(.secondary)
                                                    .lineLimit(2)
                                            }
                                            
                                            Spacer()
                                            
                                            
                                            Text(ScreenTimeManager.shared.isAuthorized ? String(localized: "settings.on", defaultValue: "Ein") : String(localized: "settings.off", defaultValue: "Aus"))
                                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                                .foregroundStyle(ScreenTimeManager.shared.isAuthorized ? Color.gruenPrimary : Color.red)
                                            
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundStyle(.tertiary)
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.plain)
                                    
                                    Divider().padding(.leading, 44)
                                    
                                    Button {
                                        if !iapStore.isProUser {
                                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                            zeigePaywall = true
                                        } else if !healthManager.isAuthorized {
                                            healthManager.requestAuthorization()
                                        } else {
                                            if let url = URL(string: "x-apple-health://") {
                                                UIApplication.shared.open(url)
                                            }
                                        }
                                    } label: {
                                        HStack(spacing: 12) {
                                            Image(systemName: "heart.text.square.fill")
                                                .font(.system(size: 20, weight: .medium))
                                                .foregroundStyle(.white)
                                                .frame(width: 28, height: 28)
                                                .background(Color.red, in: RoundedRectangle(cornerRadius: 6))
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(String(localized: "settings.health.title", defaultValue: "Apple Health"))
                                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                                    .foregroundStyle(.primary)
                                                
                                                if healthManager.isAuthorized {
                                                    Text(String(localized: "settings.health.instruction", defaultValue: "Profil > Apps > Grovy, um Berechtigungen zu ändern."))
                                                        .font(.system(size: 10, weight: .regular, design: .rounded))
                                                        .foregroundStyle(.secondary)
                                                        .lineLimit(2)
                                                }
                                            }
                                            
                                            Spacer()
                                            
                                            if !iapStore.isProUser {
                                                Text(String(localized: "settings.pro.badge", defaultValue: "PRO"))
                                                    .font(.system(size: 10, weight: .black, design: .rounded))
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 4)
                                                    .background(Color.orangePrimary)
                                                    .foregroundStyle(.white)
                                                    .clipShape(Capsule())
                                            } else {
                                                Image(systemName: "chevron.right")
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundStyle(.tertiary)
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            
                            settingsSection(title: String(localized: "settings.section.profile")) {
                                VStack(spacing: 0) {
                                    NavigationLink {
                                        StatisticsDashboard()
                                            .environmentObject(settings)
                                            .environmentObject(gardenStore)
                                            .environmentObject(streakStore)
                                    } label: {
                                        settingRow(
                                            title: String(localized: "settings.stats_button"),
                                            icon: "chart.bar.fill",
                                            color: .purple
                                        )
                                    }
                                    
                                    Divider().padding(.leading, 44)
                                    
                                    Button {
                                        showPDFExport = true
                                    } label: {
                                        settingRow(
                                            title: String(localized: "settings.pdf_export", defaultValue: "PDF Export"),
                                            icon: "square.and.arrow.up",
                                            color: .blauPrimary
                                        )
                                    }
                                    .fullScreenCover(isPresented: $showPDFExport) {
                                        PDFExportConfigView()
                                            .environmentObject(gardenStore)
                                            .environmentObject(settings)
                                            .environmentObject(streakStore)
                                            .environmentObject(assessmentStore)
                                    }
                                }
                            }

                            settingsSection(title: String(localized: "settings.section.personalization")) {
                                Button {
                                    if let url = URL(string: UIApplication.openSettingsURLString) {
                                        UIApplication.shared.open(url)
                                    }
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: "globe")
                                            .font(.system(size: 20, weight: .medium))
                                            .foregroundStyle(.primary)
                                            .frame(width: 28, height: 28)
                                        
                                        Text(String(localized: "settings.language", defaultValue: "App-Sprache"))
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                            .foregroundStyle(.primary)
                                        
                                        Spacer()
                                        
                                        let langCode = Bundle.main.preferredLocalizations.first ?? "de"
                                        Text(Locale(identifier: langCode).localizedString(forIdentifier: langCode) ?? "Deutsch")
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundStyle(.secondary)
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(.tertiary)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }



                            settingsSection(title: String(localized: "settings.section.general")) {
                                VStack(spacing: 0) {
                                    settingToggle(title: String(localized: "settings.haptic"), icon: "hand.tap.fill", color: .blauPrimary, isOn: $settings.isHapticEnabled)
                                    Divider().padding(.leading, 44)
                                    Button {
                                        if let url = URL(string: UIApplication.openSettingsURLString) {
                                            UIApplication.shared.open(url)
                                        }
                                    } label: {
                                        HStack(spacing: 12) {
                                            Image(systemName: "bell.fill")
                                                .font(.system(size: 20, weight: .medium))
                                                .foregroundStyle(.primary)
                                                .frame(width: 28, height: 28)
                                            
                                            Text(String(localized: "settings.notifications"))
                                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                            Spacer()
                                            
                                            Text(settings.isNotificationsEnabled ? String(localized: "settings.on") : String(localized: "settings.off"))
                                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                                .foregroundStyle(settings.isNotificationsEnabled ? Color.gruenPrimary : Color.red)
                                                
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundStyle(.tertiary)
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            
                            settingsSection(title: String(localized: "settings.section.display")) {
                                VStack(alignment: .leading, spacing: 12) {
                                    settingToggle(title: String(localized: "settings.display.mode"), icon: "square.text.square.fill", color: .purple, isOn: $settings.showHabitInsteadOfName)
                                    
                                    Text(String(localized: "settings.display.mode.desc"))
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal, 16)
                                        .padding(.bottom, 12)
                                }
                            }
    }
    
    @ViewBuilder
    private var secondarySettingsSections: some View {
        settingsSection(title: String(localized: "settings.section.privacy")) {
                                VStack(spacing: 0) {
                                    Button {
                                        if let url = URL(string: "https://shrouded-parka-be8.notion.site/Privacy-Policy-37dd74b814d28080acc3c9303df218c8") {
                                            UIApplication.shared.open(url)
                                        }
                                    } label: {
                                        settingRow(title: String(localized: "settings.privacy_settings"), icon: "lock.shield.fill", color: .green)
                                    }
                                    .buttonStyle(.plain)
                                    
                                    Divider().padding(.leading, 44)
                                    
                                    Button {
                                        if let url = URL(string: "https://shrouded-parka-be8.notion.site/Terms-of-Use-37dd74b814d2805393b6e17145019e9c") {
                                            UIApplication.shared.open(url)
                                        }
                                    } label: {
                                        settingRow(title: String(localized: "settings.terms"), icon: "doc.text.fill", color: .gray)
                                    }
                                    .buttonStyle(.plain)
                                    Divider().padding(.leading, 44)
                                    
                                    // Backup & Import
                                    Button {
                                        showBackupSheet = true
                                    } label: {
                                        settingRow(
                                            title: String(localized: "backup_profil_button"),
                                            icon: "arrow.up.arrow.down.circle.fill",
                                            color: .blue
                                        )
                                    }
                                }
                            }
                            
                            settingsSection(title: String(localized: "settings.section.social", defaultValue: "Community")) {
                                VStack(spacing: 0) {
                                    Button {
                                        if let url = URL(string: "https://www.tiktok.com/@grovy807?is_from_webapp=1&sender_device=pc") {
                                            UIApplication.shared.open(url)
                                        }
                                    } label: {
                                        settingRow(title: String(localized: "settings.tiktok", defaultValue: "Folge uns auf TikTok"), icon: "tiktok_logo", color: .primary, isAsset: true)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.top, 16)
                            
                            settingsSection(title: String(localized: "settings.section.support")) {
                                VStack(spacing: 0) {
                                    Button {
                                        settings.contactSupport()
                                    } label: {
                                        settingRow(title: String(localized: "settings.contact"), icon: "message.fill", color: .blauPrimary)
                                    }
                                    
                                    Divider().padding(.leading, 44)
                                    
                                    Button {
                                        let viewToRender = GrovyShareCardView(settings: settings).environmentObject(settings)
                                        let renderer = ImageRenderer(content: viewToRender)
                                        renderer.isOpaque = true
                                        renderer.scale = UIScreen.main.scale
                                        if let image = renderer.uiImage {
                                            settings.shareApp(image: image)
                                        } else {
                                            settings.shareApp()
                                        }
                                    } label: {
                                        settingRow(title: String(localized: "settings.share"), icon: "heart.fill", color: .pink)
                                    }
                                    

                                    
                                    Button {
                                        if let url = URL(string: "https://apps.apple.com/app/grovy?action=write-review") {
                                            UIApplication.shared.open(url)
                                        }
                                    } label: {
                                        settingRow(title: String(localized: "settings.rate_app"), icon: "star.fill", color: .yellow)
                                    }
                                }
                            }
                            
                            .padding(.top, 16)



                            

                            
                            // MARK: - Danger Zone
                            settingsSection(title: String(localized: "settings.section.danger")) {
                                Button {
                                    showResetAlert = true
                                } label: {
                                    Text(String(localized: "settings.reset.title"))
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                }
                                .buttonStyle(DangerButtonStyle())
                            }
                            .padding(.top, 16)
                            
                            // MARK: - Manage Subscriptions
                            if iapStore.isProUser && iapStore.activeProSubscriptionID != "com.jannik.grovy.pro.lifetime" {
                                Button {
                                    zeigePaywall = true
                                } label: {
                                    HStack(spacing: 8) {
                                        Text(String(localized: "settings.manage_subscription", defaultValue: "Abo verwalten"))
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                    }
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                }
                                .buttonStyle(Item3DButtonStyle(
                                    farbe: .blauPrimary,
                                    sekundaerFarbe: .blauSecondary,
                                    groesse: 50,
                                    shadowDepthFactor: 0.1,
                                    isRectangular: true
                                ))
                                .padding(.top, 8)
                            }
                            
                            // MARK: - Restore Purchases
                            Button(action: {
                                Task {
                                    await iapStore.restorePurchases(characterStore: characterStore)
                                }
                            }) {
                                if iapStore.isPurchasing {
                                    ProgressView()
                                        .padding(.top, 8)
                                } else {
                                    Text(String(localized: "iap_restore_btn"))
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundStyle(.secondary)
                                        .underline()
                                        .padding(.top, 8)
                                        .padding(.bottom, 8)
                                }
                            }
                            .disabled(iapStore.isPurchasing)
                            
                            Text(String(localized: "iap_restore_hint"))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                                .padding(.bottom, 24)

                            // MARK: - Developer Menu (Clean & at the bottom)
                            #if DEBUG
                            settingsSection(title: "Developer") {
                                NavigationLink {
                                    DeveloperView()
                                        .environmentObject(settings)
                                        .environmentObject(gardenStore)
                                        .environmentObject(shopStore)
                                        .environmentObject(streakStore)
                                        .environmentObject(powerUpStore)
                                        .environmentObject(titelStore)
                                        .environmentObject(achievementStore)
                                        .environmentObject(pfadStore)
                                        .environmentObject(tourManager)
                                } label: {
                                    settingRow(
                                        title: "Developer / Debug Menu",
                                        icon: "ladybug.fill",
                                        color: .orange
                                    )
                                }
                            }
                            .padding(.top, 16)
                            #endif
    }
    
    var body: some View {
        ZStack {
                Color.appHintergrund.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {

                        // Sections
                        VStack(spacing: 32) {
                            primarySettingsSections
                            secondarySettingsSections
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 40)
                    }
                }
            }
            .alert(String(localized: "settings.reset.alert.title"), isPresented: $showResetAlert) {
                Button(String(localized: "settings.reset.confirm"), role: .destructive) {
                    showFinalResetAlert = true
                }
                Button(String(localized: "button.cancel"), role: .cancel) { }
            } message: {
                Text(String(localized: "settings.reset.alert.message"))
            }
            .alert(String(localized: "settings.reset.final.title"), isPresented: $showFinalResetAlert) {
                Button(String(localized: "settings.reset.confirm"), role: .destructive) {
                    SharedUserDefaults.suite.removeObject(forKey: "customRoutinesData")
                    SharedUserDefaults.suite.set(Data(), forKey: "customRoutinesData") // AppStorage sofort leeren
                    settings.routineOnboardingAbgeschlossen = false
                    
                    gardenStore.resetAllData()
                    shopStore.reset()
                    streakStore.reset()
                    powerUpStore.reset()
                    characterStore.reset()
                    achievementStore.reset()
                    titelStore.reset()
                    assessmentStore.resetAll()
                    pfadStore.pfadZuruecksetzen(settings: settings, gardenStore: gardenStore)
                    settings.appTourPromptShown = false
                    settings.appTourAbgeschlossen = false
                    settings.onboardingAbgeschlossen = false
                    
                    // Clear all pending notifications
                    NotificationManager.shared.scheduleAll(for: [])
                    
                    FeedbackManager.shared.playError()
                    dismiss()
                }
                Button(String(localized: "button.cancel"), role: .cancel) { }
            } message: {
                Text(String(localized: "settings.reset.final.message"))
            }
            .onAppear {
                Task {
                    await settings.refreshNotificationStatus()
                }
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    Task {
                        await settings.refreshNotificationStatus()
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    LiquidGlassDismissButton { dismiss() }
                }
            }
            .tint(.primary)
            .foregroundStyle(.primary)
            .sheet(isPresented: $showBackupSheet) {
                ExportImportView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .fullScreenCover(isPresented: $zeigePaywall) {
                PaywallView()
                    .environmentObject(iapStore)
            }
        }
    
    // MARK: - Helpers
    
    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.leading, 8)
            
            content()
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(UIColor.secondarySystemGroupedBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.primary.opacity(0.05), lineWidth: 1)
                )
        }
    }
    
    private func settingToggle(title: String, icon: String, color: Color, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.primary)
                .frame(width: 28, height: 28)
            
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(Color.gruenPrimary)
                .onChange(of: isOn.wrappedValue) { _, newValue in
                    if newValue {
                        FeedbackManager.shared.playSuccess()
                    }
                }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private func settingLink(title: String, description: String, icon: String, color: Color, isAsset: Bool = false) -> some View {
        NavigationLink(destination: SettingsDetailView(
            title: title,
            description: description,
            actionTitle: String(localized: "settings.understood"),
            icon: icon,
            iconColor: color,
            action: {})) {
            settingRow(title: title, icon: icon, color: color, isAsset: isAsset)
        }
    }
    
    private func settingRow(title: String, icon: String, color: Color, isAsset: Bool = false) -> some View {
        HStack(spacing: 12) {
            Group {
                if isAsset {
                    Image(icon)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.primary)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.primary)
                }
            }
            .frame(width: 28, height: 28)
            
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(.primary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.quaternary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
    
    private func debugTimeButton(title: String, hours: Double) -> some View {
        Button {
            gardenStore.simulateTimeJump(hours: hours)
            FeedbackManager.shared.playSuccess()
        } label: {
            Text(title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.indigo))
        }
    }
    
    private func healthDataBubble(icon: String, value: String, title: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(UIColor.tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Specialized 3D Danger Button

struct DangerButtonStyle: ButtonStyle {
    @AppStorage("isHapticEnabled") var isHapticEnabled: Bool = true
    private let depth: CGFloat = 4
    
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        
        ZStack {
            // Shadow
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.red.opacity(0.3))
                .offset(y: depth)
            
            // Base
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.red)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.black.opacity(0.1), lineWidth: 1)
                )
                .overlay(
                    configuration.label
                )
                .offset(y: isPressed ? depth : 0)
        }
        .frame(height: 54)
        .animation(isPressed ? nil : .spring(response: 0.15, dampingFraction: 0.6), value: isPressed)
        .sensoryFeedback(trigger: isPressed) { _, newValue in
            (isHapticEnabled && newValue) ? .impact(flexibility: .rigid, intensity: 0.8) : nil
        }
    }
}

// MARK: - Specialized Pro Upgrade Button Style

struct ProUpgradeButtonStyle: ButtonStyle {
    @AppStorage("isHapticEnabled") var isHapticEnabled: Bool = true
    private let depth: CGFloat = 4
    
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        
        ZStack {
            // Shadow
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.black.opacity(0.4))
                .offset(y: depth)
            
            // Base
            configuration.label
                .background(
                    LinearGradient(
                        colors: [Color.black, Color(white: 0.08)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(LinearGradient(
                            colors: [Color.white.opacity(0.1), Color.black.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ), lineWidth: 1)
                )
                .offset(y: isPressed ? depth : 0)
        }
        .animation(isPressed ? nil : .spring(response: 0.15, dampingFraction: 0.6), value: isPressed)
        .sensoryFeedback(trigger: isPressed) { _, newValue in
            (isHapticEnabled && newValue) ? .impact(flexibility: .rigid, intensity: 0.8) : nil
        }
    }
}

#Preview {
    let settings = SettingsStore()
    SettingsView()
        .environmentObject(settings)
        .environmentObject(GardenStore())
        .environmentObject(ShopStore())
        .environmentObject(StreakStore())
        .environmentObject(PowerUpStore())
        .environmentObject(TitelStore())
        .environmentObject(AchievementStore(gardenStore: GardenStore(), streakStore: StreakStore()))
        .environmentObject(GartenPfadStore(settings: settings))
        .environmentObject(CharacterStore())
        .environmentObject(InteractiveTourManager())
        .environmentObject(AssessmentStore())
}

struct GrovyShareCardView: View {
    @ObservedObject var settings: SettingsStore
    
    var body: some View {
        VStack(spacing: 32) {
            if let appIcon = UIImage(named: "Splash_Screenicon") ?? UIImage(named: "AppIcon") {
                Image(uiImage: appIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                    .cornerRadius(36)
                    .shadow(color: .black.opacity(0.15), radius: 15, y: 5)
            } else {
                RoundedRectangle(cornerRadius: 36)
                    .fill(Color(hex: "#40E0D0"))
                    .frame(width: 160, height: 160)
                    .overlay(
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.white)
                    )
            }
            
            Text(String(localized: "settings.improve_your_life"))
                .font(.system(size: 42, weight: .black, design: .rounded))
                .foregroundColor(.black)
        }
        .frame(width: 400, height: 400)
        .background(Color.white)
    }
}
