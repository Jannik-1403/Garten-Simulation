import re

filepath = "Garten_Simulation/Views/Profile/AutoBackupListView.swift"
with open(filepath, "r") as f:
    content = f.read()

# Replace BackupRowView struct definition and usages
content = content.replace("struct BackupRowView: View {\n    let url: URL", "struct BackupRowView: View {\n    let url: URL\n    let localeIdentifier: String")

# Add locale to strings in BackupRowView
content = content.replace('String(localized: "backup.auto.name_prefix", defaultValue: "Backup")', 'String(localized: "backup.auto.name_prefix", defaultValue: "Backup", locale: Locale(identifier: localeIdentifier))')
content = content.replace('String(localized: "common.delete", defaultValue: "Löschen")', 'String(localized: "common.delete", defaultValue: "Löschen", locale: Locale(identifier: localeIdentifier))')
content = content.replace('Text(date.formatted(date: .abbreviated, time: .shortened))', 'Text(date.formatted(Date.FormatStyle(date: .abbreviated, time: .shortened, locale: Locale(identifier: localeIdentifier))))')

# Fix instantiation of BackupRowView
content = content.replace(
'''                            BackupRowView(
                                url: url,''',
'''                            BackupRowView(
                                url: url,
                                localeIdentifier: settingsStore.appLanguage,'''
)

# Fix other strings in AutoBackupListView
content = content.replace('String(localized: "backup.auto.no_backups", defaultValue: "Keine automatischen Backups gefunden.")', 'String(localized: "backup.auto.no_backups", defaultValue: "Keine automatischen Backups gefunden.", locale: Locale(identifier: settingsStore.appLanguage))')
content = content.replace('String(localized: "backup.auto.view_backups", defaultValue: "Auto-Backups")', 'String(localized: "backup.auto.view_backups", defaultValue: "Auto-Backups", locale: Locale(identifier: settingsStore.appLanguage))')
content = content.replace('String(localized: "backup.auto.picker.title", defaultValue: "Intervall auswählen")', 'String(localized: "backup.auto.picker.title", defaultValue: "Intervall auswählen", locale: Locale(identifier: settingsStore.appLanguage))')
content = content.replace('String(localized: "backup_import_bestaetigung_titel", defaultValue: "Backup wiederherstellen?")', 'String(localized: "backup_import_bestaetigung_titel", defaultValue: "Backup wiederherstellen?", locale: Locale(identifier: settingsStore.appLanguage))')
content = content.replace('String(localized: "backup_import_bestaetigung_ja", defaultValue: "Wiederherstellen")', 'String(localized: "backup_import_bestaetigung_ja", defaultValue: "Wiederherstellen", locale: Locale(identifier: settingsStore.appLanguage))')
content = content.replace('String(localized: "button.cancel", defaultValue: "Abbrechen")', 'String(localized: "button.cancel", defaultValue: "Abbrechen", locale: Locale(identifier: settingsStore.appLanguage))')
content = content.replace('String(localized: "backup_import_bestaetigung_text", defaultValue: "Dein aktueller Fortschritt wird komplett überschrieben.")', 'String(localized: "backup_import_bestaetigung_text", defaultValue: "Dein aktueller Fortschritt wird komplett überschrieben.", locale: Locale(identifier: settingsStore.appLanguage))')


with open(filepath, "w") as f:
    f.write(content)
print("Updated AutoBackupListView.swift")
