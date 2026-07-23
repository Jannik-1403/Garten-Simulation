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
        ScrollView {
            VStack(spacing: 24) {
                // MARK: Intervall Auswahl
                IntervalPickerView(selection: $settingsStore.autoBackupInterval)
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                
                // MARK: Backups Liste
                if backups.isEmpty {
                    Text(String(localized: "backup.auto.no_backups", defaultValue: "Keine automatischen Backups gefunden."))
                        .foregroundStyle(.secondary)
                        .padding(.top, 40)
                } else {
                    VStack(spacing: 16) {
                        ForEach(backups, id: \.self) { url in
                            BackupRowView(
                                url: url,
                                selectedBackup: $selectedBackup,
                                showImportConfirm: $showImportConfirm,
                                onDelete: { deleteBackup(url: url) }
                            )
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
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
    private func deleteBackup(url: URL) {
        let fileManager = FileManager.default
        try? fileManager.removeItem(at: url)
        loadBackups()
    }
    
    private func importBackup() {
        guard let url = selectedBackup else { return }
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
        } catch {
            print("Import failed: \(error)")
        }
    }

    private func getCreationDate(for url: URL) -> Date? {
        return try? url.resourceValues(forKeys: [.creationDateKey]).creationDate
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

struct BackupRowView: View {
    let url: URL
    @Binding var selectedBackup: URL?
    @Binding var showImportConfirm: Bool
    var onDelete: () -> Void
    
    var body: some View {
        Button(action: {
            selectedBackup = url
            showImportConfirm = true
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(localized: "backup.auto.name_prefix", defaultValue: "Backup"))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    if let date = try? url.resourceValues(forKeys: [.creationDateKey]).creationDate {
                        Text(date.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                Spacer()
                Image(systemName: "arrow.down.doc.fill")
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
        }
        .buttonStyle(Item3DButtonStyle(
            farbe: .gruenPrimary,
            sekundaerFarbe: .gruenSecondary,
            groesse: 60,
            shadowDepthFactor: 0.1,
            isRectangular: true
        ))
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label(String(localized: "common.delete", defaultValue: "Löschen"), systemImage: "trash")
            }
        }
    }
}

struct IntervalPickerView: View {
    @Binding var selection: AutoBackupInterval
    
    var body: some View {
        HStack {
            Text(String(localized: "backup.auto.title", defaultValue: "Intervall:"))
                .font(.headline)
                .foregroundStyle(.white)
            Spacer()
            Picker(String(localized: "backup.auto.picker.title", defaultValue: "Intervall auswählen"), selection: $selection) {
                ForEach(AutoBackupInterval.allCases, id: \.self) { interval in
                    Text(interval.localizedName).tag(interval)
                }
            }
            .pickerStyle(.menu)
            .tint(.white)
        }
    }
}
