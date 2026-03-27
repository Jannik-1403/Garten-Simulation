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
                            settingsSection(title: "Allgemein") {
                                VStack(spacing: 0) {
                                    settingToggle(title: "Audio & Sounds", icon: "speaker.wave.2.fill", color: .blue, isOn: $settings.isSoundEnabled)
                                    Divider().padding(.leading, 44)
                                    settingToggle(title: "Haptik Feedback", icon: "hand.tap.fill", color: .purple, isOn: $settings.isHapticEnabled)
                                    Divider().padding(.leading, 44)
                                    settingToggle(title: "Benachrichtigungen", icon: "bell.fill", color: .red, isOn: $settings.isNotificationsEnabled)
                                }
                            }
                            
                            settingsSection(title: "Datenschutz & Sicherheit") {
                                VStack(spacing: 0) {
                                    settingLink(title: "Datenschutz-Einstellungen", icon: "lock.shield.fill", color: .green)
                                    Divider().padding(.leading, 44)
                                    settingLink(title: "Nutzungsbedingungen", icon: "doc.text.fill", color: .gray)
                                    Divider().padding(.leading, 44)
                                    NavigationLink(destination: SettingsDetailView(title: "Daten exportieren", description: "Möchten Sie alle Ihre Daten exportieren? Sie erhalten eine Datei mit allen Ihren Pflanzen und Fortschritten.", actionTitle: "Export starten", icon: "square.and.arrow.up.fill", iconColor: .orange, action: { settings.exportData() })) {
                                        settingRow(title: "Daten exportieren", icon: "square.and.arrow.up.fill", color: .orange)
                                    }
                                    Divider().padding(.leading, 44)
                                    NavigationLink(destination: SettingsDetailView(title: "Daten importieren", description: "Möchten Sie Daten importieren? Dies überschreibt Ihre aktuellen Fortschritte.", actionTitle: "Import starten", icon: "square.and.arrow.down.fill", iconColor: .blue, action: { settings.importData() })) {
                                        settingRow(title: "Daten importieren", icon: "square.and.arrow.down.fill", color: .blue)
                                    }
                                }
                            }
                            
                            settingsSection(title: "Unterstützung") {
                                VStack(spacing: 0) {
                                    NavigationLink(destination: SettingsDetailView(title: "Käufe wiederherstellen", description: "Haben Sie bereits Käufe getätigt? Hier können Sie diese auf diesem Gerät wiederherstellen.", actionTitle: "Wiederherstellen", icon: "arrow.clockwise.circle.fill", iconColor: .goldPrimary, action: { settings.restorePurchases() })) {
                                        settingRow(title: "Käufe wiederherstellen", icon: "arrow.clockwise.circle.fill", color: .goldPrimary)
                                    }
                                    Divider().padding(.leading, 44)
                                    NavigationLink(destination: SettingsDetailView(title: "Support kontaktieren", description: "Haben Sie Fragen oder Probleme? Unser Support-Team hilft Ihnen gerne weiter.", actionTitle: "Support öffnen", icon: "questionmark.circle.fill", iconColor: .blauPrimary, action: { settings.contactSupport() })) {
                                        settingRow(title: "Support kontaktieren", icon: "questionmark.circle.fill", color: .blauPrimary)
                                    }
                                    Divider().padding(.leading, 44)
                                    NavigationLink(destination: SettingsDetailView(title: "App weiterempfehlen", description: "Gefällt Ihnen die Garten-Simulation? Teilen Sie sie mit Ihren Freunden!", actionTitle: "App teilen", icon: "heart.fill", iconColor: .pink, action: { settings.shareApp() })) {
                                        settingRow(title: "App weiterempfehlen", icon: "heart.fill", color: .pink)
                                    }
                                }
                            }
                            
                            // Danger Zone
                            VStack(spacing: 12) {
                                NavigationLink(destination: SettingsDetailView(title: "Account löschen", description: "Möchten Sie Ihren Account wirklich löschen? Alle Daten werden unwiderruflich entfernt.", actionTitle: "ACCOUNT LÖSCHEN", icon: "trash.fill", iconColor: .red, isDestructive: true, action: { settings.deleteAccount() })) {
                                    Text("ACCOUNT LÖSCHEN")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white)
                                        .frame(height: 54)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.red)
                                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                }
                                .buttonStyle(DangerButtonStyle())
                                
                                Text("Diese Aktion kann nicht rückgängig gemacht werden.")
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
            .navigationTitle("Einstellungen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fertig") {
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
    
    private func settingLink(title: String, icon: String, color: Color) -> some View {
        NavigationLink(destination: SettingsDetailView(
            title: title,
            description: "Hier findest du alle Informationen zu den \(title).",
            actionTitle: "Verstanden",
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
