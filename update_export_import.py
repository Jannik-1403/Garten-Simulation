import re

file_path = 'Garten_Simulation/Views/Profile/ExportImportView.swift'
with open(file_path, 'r') as f:
    content = f.read()

# Add auto-backup section below Import button
auto_backup_ui = """
                            
                            Divider().padding(.vertical, 16)
                            
                            // MARK: Auto Backup Settings
                            VStack(alignment: .leading, spacing: 10) {
                                Text(String(localized: "backup.auto.title", defaultValue: "Automatisches Backup"))
                                    .font(.headline)
                                    .padding(.horizontal, 8)
                                
                                Picker("", selection: $settingsStore.autoBackupInterval) {
                                    ForEach(AutoBackupInterval.allCases) { interval in
                                        Text(interval.localizedName).tag(interval)
                                    }
                                }
                                .pickerStyle(.menu)
                                .padding()
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .cornerRadius(12)
                                
                                NavigationLink(destination: AutoBackupListView()) {
                                    HStack {
                                        Image(systemName: "clock.arrow.circlepath")
                                        Text(String(localized: "backup.auto.view_backups", defaultValue: "Auto-Backups verwalten"))
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                    }
                                    .foregroundColor(.primary)
                                    .padding()
                                    .background(Color(UIColor.secondarySystemGroupedBackground))
                                    .cornerRadius(12)
                                }
                            }
"""
if "Automatisches Backup" not in content:
    content = content.replace("                        .padding(.horizontal, 20)", "                        .padding(.horizontal, 20)\n" + auto_backup_ui)

with open(file_path, 'w') as f:
    f.write(content)
