import SwiftUI
import UniformTypeIdentifiers
import SwiftData

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
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var showResetAlert = false
    @State private var showFinalResetAlert = false
    @State private var showBackupSheet = false
    
    private var aktuelleTierStufe: GartenTierStufe {
        GartenTierStufe.fuer(level: gardenStore.gartenStufe)
    }
    
    var body: some View {
        ZStack {
                Color.appHintergrund.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {

                        // Sections
                        VStack(spacing: 32) {
                            settingsSection(title: settings.localizedString(for: "settings.section.profile")) {
                                VStack(spacing: 0) {
                                    NavigationLink {
                                        StatisticsDashboard()
                                            .environmentObject(settings)
                                            .environmentObject(gardenStore)
                                            .environmentObject(streakStore)
                                    } label: {
                                        settingRow(
                                            title: settings.localizedString(for: "settings.stats_button"),
                                            icon: "chart.bar.fill",
                                            color: .purple
                                        )
                                    }
                                    
                                    Divider().padding(.leading, 44)
                                    
                                    Button {
                                        settings.onboardingAbgeschlossen = false
                                        FeedbackManager.shared.playSuccess()
                                        dismiss()
                                    } label: {
                                        settingRow(
                                            title: settings.localizedString(for: "settings.onboarding.repeat"),
                                            icon: "arrow.counterclockwise.circle.fill",
                                            color: .orange
                                        )
                                    }
                                }
                            }

                            settingsSection(title: settings.localizedString(for: "settings.section.personalization")) {
                                HStack(spacing: 12) {
                                    Image(systemName: "globe")
                                        .foregroundStyle(.white)
                                        .frame(width: 28, height: 28)
                                        .background(Circle().fill(Color.blue))
                                    
                                    Text(settings.localizedString(for: "settings.language"))
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                    
                                    Spacer()
                                    
                                    Picker("", selection: $settings.appLanguage) {
                                        Text(settings.localizedString(for: "settings.language.de")).tag("de")
                                        Text(settings.localizedString(for: "settings.language.en")).tag("en")
                                        Text(settings.localizedString(for: "settings.language.es")).tag("es")
                                        Text(settings.localizedString(for: "settings.language.fr")).tag("fr")
                                        Text(settings.localizedString(for: "settings.language.it")).tag("it")
                                        Text(settings.localizedString(for: "settings.language.pt")).tag("pt")
                                        Text(settings.localizedString(for: "settings.language.ja")).tag("ja")
                                        Text(settings.localizedString(for: "settings.language.ko")).tag("ko")
                                        Text(settings.localizedString(for: "settings.language.nl")).tag("nl")
                                        Text(settings.localizedString(for: "settings.language.pl")).tag("pl")
                                        Text(settings.localizedString(for: "settings.language.tr")).tag("tr")
                                    }
                                    .pickerStyle(.menu)
                                    .fixedSize(horizontal: true, vertical: false)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                            }


                            settingsSection(title: settings.localizedString(for: "settings.section.general")) {
                                VStack(spacing: 0) {
                                    settingToggle(title: settings.localizedString(for: "settings.haptic"), icon: "hand.tap.fill", color: .blauPrimary, isOn: $settings.isHapticEnabled)
                                    Divider().padding(.leading, 44)
                                    settingToggle(title: settings.localizedString(for: "settings.notifications"), icon: "bell.fill", color: .red, isOn: $settings.isNotificationsEnabled)
                                }
                            }
                            
                            settingsSection(title: settings.localizedString(for: "settings.section.display")) {
                                VStack(alignment: .leading, spacing: 12) {
                                    settingToggle(title: settings.localizedString(for: "settings.display.mode"), icon: "square.text.square.fill", color: .purple, isOn: $settings.showHabitInsteadOfName)
                                    
                                    Text(settings.localizedString(for: "settings.display.mode.desc"))
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal, 16)
                                        .padding(.bottom, 12)
                                }
                            }

                            
                            settingsSection(title: settings.localizedString(for: "settings.section.privacy")) {
                                VStack(spacing: 0) {
                                    settingLink(title: settings.localizedString(for: "settings.privacy_settings"), description: settings.localizedString(for: "settings.privacy.desc"), icon: "lock.shield.fill", color: .green)
                                    Divider().padding(.leading, 44)
                                    settingLink(title: settings.localizedString(for: "settings.terms"), description: settings.localizedString(for: "settings.terms.desc"), icon: "doc.text.fill", color: .gray)
                                    Divider().padding(.leading, 44)
                                    
                                    // Backup & Import
                                    Button {
                                        showBackupSheet = true
                                    } label: {
                                        settingRow(
                                            title: settings.localizedString(for: "backup_profil_button"),
                                            icon: "arrow.up.arrow.down.circle.fill",
                                            color: .blue
                                        )
                                    }
                                }
                            }
                            
                            settingsSection(title: settings.localizedString(for: "settings.section.support")) {
                                VStack(spacing: 0) {
                                    Button {
                                        settings.contactSupport()
                                    } label: {
                                        settingRow(title: settings.localizedString(for: "settings.contact"), icon: "message.fill", color: .blauPrimary)
                                    }
                                    
                                    Divider().padding(.leading, 44)
                                    
                                    Button {
                                        let viewToRender = GrovyShareCardView(settings: settings).environmentObject(settings)
                                        let renderer = ImageRenderer(content: viewToRender)
                                        renderer.scale = UIScreen.main.scale
                                        if let image = renderer.uiImage {
                                            settings.shareApp(image: image)
                                        } else {
                                            settings.shareApp()
                                        }
                                    } label: {
                                        settingRow(title: settings.localizedString(for: "settings.share"), icon: "heart.fill", color: .pink)
                                    }
                                }
                            }
                            
                            .padding(.top, 16)

                            // MARK: - Danger Zone
                            settingsSection(title: settings.localizedString(for: "settings.section.danger")) {
                                Button {
                                    showResetAlert = true
                                } label: {
                                    Text(settings.localizedString(for: "settings.reset.title"))
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                }
                                .buttonStyle(DangerButtonStyle())
                            }
                            .padding(.top, 16)

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
                        .padding(.horizontal, 16)
                        .padding(.bottom, 40)
                    }
                }
            }
            .alert(settings.localizedString(for: "settings.reset.alert.title"), isPresented: $showResetAlert) {
                Button(settings.localizedString(for: "settings.reset.confirm"), role: .destructive) {
                    showFinalResetAlert = true
                }
                Button(settings.localizedString(for: "button.cancel"), role: .cancel) { }
            } message: {
                Text(settings.localizedString(for: "settings.reset.alert.message"))
            }
            .alert(settings.localizedString(for: "settings.reset.final.title"), isPresented: $showFinalResetAlert) {
                Button(settings.localizedString(for: "settings.reset.confirm"), role: .destructive) {
                    gardenStore.resetAllData()
                    shopStore.reset()
                    streakStore.reset()
                    powerUpStore.reset()
                    characterStore.reset()
                    achievementStore.reset()
                    titelStore.reset()
                    pfadStore.pfadZuruecksetzen(settings: settings, gardenStore: gardenStore)
                    settings.onboardingAbgeschlossen = false
                    FeedbackManager.shared.playError()
                    dismiss()
                }
                Button(settings.localizedString(for: "button.cancel"), role: .cancel) { }
            } message: {
                Text(settings.localizedString(for: "settings.reset.final.message"))
            }
            .onChange(of: settings.isNotificationsEnabled) { newValue in
                if newValue {
                    NotificationManager.shared.scheduleAll(for: gardenStore.pflanzen)
                } else {
                    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .black))
                            .foregroundStyle(.primary)
                    }
                }
            }
            .tint(.primary)
            .foregroundStyle(.primary)
            .sheet(isPresented: $showBackupSheet) {
                ExportImportView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
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
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(Circle().fill(color))
            
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(Color.gruenPrimary)
                .onChange(of: isOn.wrappedValue) {
                    if isOn.wrappedValue {
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
            actionTitle: settings.localizedString(for: "settings.understood"),
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
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                } else {
                    Image(systemName: icon)
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                }
            }
            .frame(width: 28, height: 28)
            .background(Circle().fill(color))
            
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
            
            Text("Improve your life")
                .font(.system(size: 42, weight: .black, design: .rounded))
                .foregroundColor(.black)
        }
        .frame(width: 400, height: 400)
        .background(Color.white)
    }
}
