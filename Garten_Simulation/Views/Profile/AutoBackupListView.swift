import SwiftUI

struct AutoBackupListView: View {
    @State private var backups: [URL] = []
    @State private var showImportConfirm = false
    @State private var selectedBackup: URL? = nil
    @State private var isLoading = false
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var shopStore: ShopStore
    @EnvironmentObject var achievementStore: AchievementStore
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var streakStore: StreakStore
    @EnvironmentObject var assessmentStore: AssessmentStore
    
    var body: some View {
        List {
            if backups.isEmpty {
                Text(String(localized: "backup.auto.no_backups", defaultValue: "Keine automatischen Backups gefunden."))
                    .foregroundStyle(.secondary)
            } else {
                ForEach(backups, id: \.self) { url in
                    Button(action: {
                        selectedBackup = url
                        showImportConfirm = true
                    }) {
                        VStack(alignment: .leading) {
                            Text(url.lastPathComponent)
                                .font(.headline)
                            if let date = try? url.resourceValues(forKeys: [.creationDateKey]).creationDate {
                                Text(date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
                .onDelete(perform: deleteBackup)
            }
        }
        .navigationTitle(String(localized: "backup.auto.view_backups", defaultValue: "Auto-Backups"))
        .onAppear {
            loadBackups()
        }
        .alert(String(localized: "backup_import_bestaetigung_titel", defaultValue: "Backup wiederherstellen?"), isPresented: $showImportConfirm) {
            Button(String(localized: "backup_import_bestaetigung_ja", defaultValue: "Wiederherstellen"), role: .destructive) {
                if let url = selectedBackup {
                    performImport(url)
                }
            }
            Button(String(localized: "button.cancel", defaultValue: "Abbrechen"), role: .cancel) {
                selectedBackup = nil
            }
        } message: {
            Text(String(localized: "backup_import_bestaetigung_text", defaultValue: "Dein aktueller Fortschritt wird komplett überschrieben."))
        }
        .overlay {
            if isLoading {
                Color.black.opacity(0.3).ignoresSafeArea()
                ProgressView().scaleEffect(1.5).padding(40).background(.ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
    }
    
    private func loadBackups() {
        backups = AutoBackupManager.shared.getAvailableBackups()
    }
    
    private func deleteBackup(at offsets: IndexSet) {
        let fileManager = FileManager.default
        for index in offsets {
            let url = backups[index]
            try? fileManager.removeItem(at: url)
        }
        loadBackups()
    }
    
    private func performImport(_ url: URL) {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            do {
                try DataExportImportManager.shared.importieren(
                    von: url,
                    gardenStore: gardenStore,
                    shopStore: shopStore,
                    achievementStore: achievementStore,
                    settingsStore: settingsStore,
                    streakStore: streakStore,
                    assessmentStore: assessmentStore
                )
                isLoading = false
                dismiss()
            } catch {
                isLoading = false
                print("Import failed: \(error)")
            }
        }
    }
}
