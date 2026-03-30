import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appHintergrund.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Header (Mini)
                        VStack(spacing: 8) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(Color.blauPrimary)
                            Text("Jannik Schill")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                            Text("jannik.schill@example.com")
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 20)
                        
                        // Sections
                        VStack(spacing: 32) {
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
                                    }
                                    .pickerStyle(.menu)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                            }

                            settingsSection(title: settings.localizedString(for: "settings.section.general")) {
                                VStack(spacing: 0) {
                                    settingToggle(title: settings.localizedString(for: "settings.audio"), icon: "speaker.wave.2.fill", color: .blue, isOn: $settings.isSoundEnabled)
                                    Divider().padding(.leading, 44)
                                    settingToggle(title: settings.localizedString(for: "settings.haptic"), icon: "hand.tap.fill", color: .purple, isOn: $settings.isHapticEnabled)
                                    Divider().padding(.leading, 44)
                                    settingToggle(title: settings.localizedString(for: "settings.notifications"), icon: "bell.fill", color: .red, isOn: $settings.isNotificationsEnabled)
                                }
                            }
                            
                            settingsSection(title: settings.localizedString(for: "settings.section.privacy")) {
                                VStack(spacing: 0) {
                                    settingLink(title: settings.localizedString(for: "settings.privacy_settings"), description: settings.localizedString(for: "settings.privacy.desc"), icon: "lock.shield.fill", color: .green)
                                    Divider().padding(.leading, 44)
                                    settingLink(title: settings.localizedString(for: "settings.terms"), description: settings.localizedString(for: "settings.terms.desc"), icon: "doc.text.fill", color: .gray)
                                    Divider().padding(.leading, 44)
                                    NavigationLink(destination: SettingsDetailView(title: settings.localizedString(for: "settings.export"), description: settings.localizedString(for: "settings.export.desc"), actionTitle: settings.localizedString(for: "settings.export.action"), icon: "square.and.arrow.up.fill", iconColor: .orange, action: { settings.exportData() })) {
                                        settingRow(title: settings.localizedString(for: "settings.export"), icon: "square.and.arrow.up.fill", color: .orange)
                                    }
                                    Divider().padding(.leading, 44)
                                    NavigationLink(destination: SettingsDetailView(title: settings.localizedString(for: "settings.import"), description: settings.localizedString(for: "settings.import.desc"), actionTitle: settings.localizedString(for: "settings.import.action"), icon: "square.and.arrow.down.fill", iconColor: .blue, action: { settings.importData() })) {
                                        settingRow(title: settings.localizedString(for: "settings.import"), icon: "square.and.arrow.down.fill", color: .blue)
                                    }
                                }
                            }
                            
                            settingsSection(title: settings.localizedString(for: "settings.section.support")) {
                                VStack(spacing: 0) {
                                    NavigationLink(destination: SettingsDetailView(title: settings.localizedString(for: "settings.restore"), description: settings.localizedString(for: "settings.restore.desc"), actionTitle: settings.localizedString(for: "settings.restore.action"), icon: "arrow.clockwise.circle.fill", iconColor: .goldPrimary, action: { settings.restorePurchases() })) {
                                        settingRow(title: settings.localizedString(for: "settings.restore"), icon: "arrow.clockwise.circle.fill", color: .goldPrimary)
                                    }
                                    Divider().padding(.leading, 44)
                                    NavigationLink(destination: SettingsDetailView(title: settings.localizedString(for: "settings.contact"), description: settings.localizedString(for: "settings.contact.desc"), actionTitle: settings.localizedString(for: "settings.contact.action"), icon: "questionmark.circle.fill", iconColor: .blauPrimary, action: { settings.contactSupport() })) {
                                        settingRow(title: settings.localizedString(for: "settings.contact"), icon: "questionmark.circle.fill", color: .blauPrimary)
                                    }
                                    Divider().padding(.leading, 44)
                                    NavigationLink(destination: SettingsDetailView(title: settings.localizedString(for: "settings.share"), description: settings.localizedString(for: "settings.share.desc"), actionTitle: settings.localizedString(for: "settings.share.action"), icon: "heart.fill", iconColor: .pink, action: { settings.shareApp() })) {
                                        settingRow(title: settings.localizedString(for: "settings.share"), icon: "heart.fill", color: .pink)
                                    }
                                }
                            }
                            
                            // Danger Zone
                            VStack(spacing: 12) {
                                NavigationLink(destination: SettingsDetailView(title: settings.localizedString(for: "settings.delete_account"), description: settings.localizedString(for: "settings.delete_warning"), actionTitle: settings.localizedString(for: "settings.delete_account"), icon: "trash.fill", iconColor: .red, isDestructive: true, action: { settings.deleteAccount() })) {
                                    Text(settings.localizedString(for: "settings.delete_account"))
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white)
                                        .frame(height: 54)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.red)
                                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                }
                                .buttonStyle(DangerButtonStyle())
                                
                                Text(settings.localizedString(for: "settings.delete_warning"))
                                    .font(.system(size: 11))
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.top, 16)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle(settings.localizedString(for: "settings.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(settings.localizedString(for: "settings.done")) {
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                }
            }
            .tint(.primary)
            .foregroundStyle(.primary)
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
                .tint(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private func settingLink(title: String, description: String, icon: String, color: Color) -> some View {
        NavigationLink(destination: SettingsDetailView(
            title: title,
            description: description,
            actionTitle: settings.localizedString(for: "settings.understood"),
            icon: icon,
            iconColor: color,
            action: {})) {
            settingRow(title: title, icon: icon, color: color)
        }
    }
    
    private func settingRow(title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.white)
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
    SettingsView().environmentObject(SettingsStore())
}
