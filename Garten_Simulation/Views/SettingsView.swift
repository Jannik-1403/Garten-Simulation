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
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var showResetAlert = false
    @State private var showBackupSheet = false
    
    private var aktuelleTierStufe: GartenTierStufe {
        GartenTierStufe.fuer(level: gardenStore.gartenStufe)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appHintergrund.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Header (Real Garden Stats)
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.blauPrimary.opacity(0.1))
                                    .frame(width: 80, height: 80)
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 80))
                                    .foregroundStyle(
                                        LinearGradient(colors: [.blauPrimary, .blauPrimary.darker()], startPoint: .top, endPoint: .bottom)
                                    )
                            }
                            
                            VStack(spacing: 4) {
                                Text(settings.localizedString(for: "profile.user.name"))
                                    .font(.system(size: 22, weight: .black, design: .rounded))
                                
                                HStack(spacing: 8) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "star.fill")
                                            .font(.system(size: 10))
                                            .foregroundStyle(.yellow)
                                        Text(aktuelleTierStufe.lokalisiertTitel(settings: settings))
                                            .font(.system(size: 12, weight: .bold, design: .rounded))
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Capsule().fill(aktuelleTierStufe.farbe.opacity(0.15)))
                                    .foregroundStyle(aktuelleTierStufe.farbe)
                                    
                                    HStack(spacing: 4) {
                                        Image(systemName: "bitcoinsign.circle.fill")
                                            .font(.system(size: 10))
                                            .foregroundStyle(Color.coinBlue)
                                        Text(String(format: settings.localizedString(for: "shop.coins_format"), gardenStore.coins))
                                            .font(.system(size: 12, weight: .bold, design: .rounded))
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Capsule().fill(Color.coinBlue.opacity(0.15)))
                                    .foregroundStyle(Color.coinBlue)
                                }
                            }
                        }
                        .padding(.top, 20)
                        
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
                                    
                                    Spacer()
                                    
                                    Picker("", selection: $settings.appLanguage) {
                                        Text(settings.localizedString(for: "settings.language.de")).tag("de")
                                        Text(settings.localizedString(for: "settings.language.en")).tag("en")
                                        Text(settings.localizedString(for: "settings.language.es")).tag("es")
                                        Text(settings.localizedString(for: "settings.language.fr")).tag("fr")
                                        Text(settings.localizedString(for: "settings.language.pt")).tag("pt")
                                    }
                                    .pickerStyle(.menu)
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

                            settingsSection(title: settings.localizedString(for: "settings.section.pfad")) {
                                VStack(spacing: 0) {
                                    NavigationLink {
                                        PfadEinstellungenView()
                                            .environmentObject(settings)
                                            .environmentObject(pfadStore)
                                            .environmentObject(gardenStore)
                                    } label: {
                                        settingRow(
                                            title: settings.localizedString(for: "pfad_einstellungen_titel"),
                                            icon: "map.fill",
                                            color: .blue
                                        )
                                    }
                                    
                                    Divider().padding(.leading, 44)
                                    
                                    Button {
                                        pfadStore.zeigeRitualAnpassen = true
                                    } label: {
                                        settingRow(
                                            title: settings.localizedString(for: "ritual_config_title"),
                                            icon: "link.circle.fill",
                                            color: .goldPrimary
                                        )
                                    }
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
                                        settings.shareApp()
                                    } label: {
                                        settingRow(title: settings.localizedString(for: "settings.share"), icon: "heart.fill", color: .pink)
                                    }
                                }
                            }
                            
                            .padding(.top, 16)

                            // MARK: Developer / Debug Section
                            settingsSection(title: "Developer / Debug 🛠️") {
                                VStack(spacing: 0) {
                                    Button {
                                        gardenStore.debugLevelUp()
                                    } label: {
                                        settingRow(title: "Level Up (+1)", icon: "sparkles", color: .yellow)
                                    }
                                    
                                    Divider().padding(.leading, 44)
                                    
                                    Button {
                                        gardenStore.taeglicherStreakCheck()
                                        FeedbackManager.shared.playSuccess()
                                    } label: {
                                        settingRow(title: "Simulations-Tag (Reset)", icon: "clock.arrow.circlepath", color: .indigo)
                                    }
                                    
                                    Divider().padding(.leading, 44)
                                    
                                    Button {
                                        gardenStore.coinsGutschreiben(amount: 1000, beschreibung: "Debug: Coins erhalten")
                                        FeedbackManager.shared.playCoins()
                                    } label: {
                                        settingRow(title: "1000 Coins hinzufügen", icon: "plus.circle.fill", color: .coinBlue)
                                    }
                                    
                                    Divider().padding(.leading, 44)
                                    
                                    Button {
                                        gardenStore.xpHinzufuegen(amount: 500)
                                        FeedbackManager.shared.playSuccess()
                                    } label: {
                                        settingRow(title: "+500 XP hinzufügen", icon: "star.fill", color: .orange)
                                    }
                                    
                                    Divider().padding(.leading, 44)
                                    
                                    Button {
                                        for p in gardenStore.pflanzen {
                                            p.istBewässert = false
                                        }
                                        FeedbackManager.shared.playTap()
                                    } label: {
                                        settingRow(title: "Alle Pflanzen durstig machen", icon: "Drop water", color: .blue, isAsset: true)
                                    }

                                    Divider().padding(.leading, 44)

                                    Button {
                                        gardenStore.showDailySpinOverlay = true
                                        FeedbackManager.shared.playSuccess()
                                    } label: {
                                        settingRow(title: "Unkraut-Glücksrad testen", icon: "asterisk.circle.fill", color: .orange)
                                    }
                                    
                                    Button {
                                        gardenStore.seeds += 10
                                        FeedbackManager.shared.playSuccess()
                                    } label: {
                                        settingRow(title: "10 Samen hinzufügen", icon: "leaf.arrow.triangle.circlepath", color: .purple)
                                    }
                                    
                                    Divider().padding(.leading, 44)

                                    VStack(spacing: 8) {
                                        Text(settings.localizedString(for: "settings.timeskip_simulation"))
                                            .font(.system(size: 10, weight: .black))
                                            .foregroundStyle(.secondary)
                                            .padding(.top, 8)
                                        
                                        HStack(spacing: 12) {
                                            debugTimeButton(title: "12h", hours: 12)
                                            debugTimeButton(title: "24h", hours: 24)
                                            debugTimeButton(title: "48h", hours: 48)
                                        }
                                        .padding(.bottom, 12)
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }

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

                            #if DEBUG
                            settingsSection(title: "Debug: Titel 👑") {
                                VStack(spacing: 0) {
                                    Button {
                                        // Alle Titel freischalten
                                        for titel in GameDatabase.allTitles {
                                            titelStore.freigeschalteteTitelIDs.insert(titel.id)
                                        }
                                        titelStore.speichernPublic()
                                        FeedbackManager.shared.playSuccess()
                                    } label: {
                                        settingRow(title: "Alle Titel freischalten", icon: "crown.fill", color: .goldPrimary)
                                    }

                                    Divider().padding(.leading, 44)

                                    Button {
                                        // Zurücksetzen (nur Anfänger-Titel)
                                        titelStore.freigeschalteteTitelIDs = ["titel_anfaenger"]
                                        titelStore.aktiverTitelID = "titel_anfaenger"
                                        titelStore.speichernPublic()
                                        FeedbackManager.shared.playError()
                                    } label: {
                                        settingRow(title: "Titel zurücksetzen", icon: "arrow.counterclockwise", color: .red)
                                    }
                                }
                            }
                            #endif
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 40)
                    }
                }
            }
            .alert(settings.localizedString(for: "settings.reset.alert.title"), isPresented: $showResetAlert) {
                Button(settings.localizedString(for: "settings.reset.confirm"), role: .destructive) {
                    gardenStore.resetAllData()
                    shopStore.reset()
                    streakStore.reset()
                    powerUpStore.reset()
                    FeedbackManager.shared.playError()
                    dismiss()
                }
                Button(settings.localizedString(for: "button.cancel"), role: .cancel) { }
            } message: {
                Text(settings.localizedString(for: "settings.reset.alert.message"))
            }
            .navigationTitle(settings.localizedString(for: "settings.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(settings.localizedString(for: "button.done")) {
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
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
}
