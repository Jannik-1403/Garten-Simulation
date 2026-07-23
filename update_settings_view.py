import re

file_path = 'Garten_Simulation/Views/SettingsView.swift'
with open(file_path, 'r') as f:
    content = f.read()

# 1. Add state variable for recovery alert
if "showRecoveryAlert = false" not in content:
    content = content.replace("@State private var showFinalResetAlert = false", "@State private var showFinalResetAlert = false\n    @State private var showRecoveryAlert = false")

# 2. Add recovery alert modifier
recovery_alert = """
            .alert("Wiederherstellung erfolgreich", isPresented: $showRecoveryAlert) {
                Button(String(localized: "button.ok", defaultValue: "OK"), role: .cancel) {
                    // Quit app or tell user to restart
                    exit(0)
                }
            } message: {
                Text("Deine alten Daten wurden wiederhergestellt. Die App wird nun beendet. Bitte starte sie neu, um die Änderungen zu sehen.")
            }
"""
if "Wiederherstellung erfolgreich" not in content:
    content = content.replace("            .alert(String(localized: \"settings.reset.final.title\"), isPresented: $showFinalResetAlert) {", recovery_alert + "            .alert(String(localized: \"settings.reset.final.title\"), isPresented: $showFinalResetAlert) {")

# 3. Add Recovery Button in Danger Zone
recovery_btn = """                                Button {
                                    SharedUserDefaults.forceRecoveryFromLocal()
                                    showRecoveryAlert = true
                                } label: {
                                    Text(String(localized: "settings.danger.recover_local", defaultValue: "Daten vor Update wiederherstellen"))
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
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
                                .padding(.bottom, 8)
                                
"""
if "Daten vor Update wiederherstellen" not in content:
    content = content.replace("                            settingsSection(title: String(localized: \"settings.section.danger\")) {", "                            settingsSection(title: String(localized: \"settings.section.danger\")) {\n" + recovery_btn)

with open(file_path, 'w') as f:
    f.write(content)
