import Foundation
import Combine

class AutoBackupManager {
    static let shared = AutoBackupManager()
    
    private init() {}
    
    func checkAndPerformBackup(
        interval: AutoBackupInterval,
        gardenStore: GardenStore,
        shopStore: ShopStore,
        achievementStore: AchievementStore,
        settingsStore: SettingsStore,
        streakStore: StreakStore,
        assessmentStore: AssessmentStore
    ) {
        guard interval != .never else { return }
        
        let lastBackupKey = "last_auto_backup_timestamp"
        let lastBackupInterval = SharedUserDefaults.suite.double(forKey: lastBackupKey)
        let now = Date().timeIntervalSince1970
        
        var shouldBackup = false
        
        switch interval {
        case .onSave:
            shouldBackup = true // Assuming we debounce this at the call site or run it manually
        case .daily:
            if now - lastBackupInterval > 86400 { shouldBackup = true }
        case .weekly:
            if now - lastBackupInterval > 604800 { shouldBackup = true }
        case .monthly:
            if now - lastBackupInterval > 2592000 { shouldBackup = true }
        case .never:
            break
        }
        
        if shouldBackup {
            performBackup(
                gardenStore: gardenStore,
                shopStore: shopStore,
                achievementStore: achievementStore,
                settingsStore: settingsStore,
                streakStore: streakStore,
                assessmentStore: assessmentStore
            )
            SharedUserDefaults.suite.set(now, forKey: lastBackupKey)
        }
    }
    
    func performBackup(
        gardenStore: GardenStore,
        shopStore: ShopStore,
        achievementStore: AchievementStore,
        settingsStore: SettingsStore,
        streakStore: StreakStore,
        assessmentStore: AssessmentStore
    ) {
        Task {
            do {
                let tempURL = try await MainActor.run {
                    try DataExportImportManager.shared.exportieren(
                        gardenStore: gardenStore,
                        shopStore: shopStore,
                        achievementStore: achievementStore,
                        settingsStore: settingsStore,
                        streakStore: streakStore,
                        assessmentStore: assessmentStore
                    )
                }
                
                // Save it to a persistent local backup directory
                let fileManager = FileManager.default
                guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
                
                let backupDirectory = documentsURL.appendingPathComponent("AutoBackups")
                if !fileManager.fileExists(atPath: backupDirectory.path) {
                    try fileManager.createDirectory(at: backupDirectory, withIntermediateDirectories: true, attributes: nil)
                }
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
                let dateString = formatter.string(from: Date())
                let backupURL = backupDirectory.appendingPathComponent("Backup_\(dateString).gartensave")
                
                try fileManager.copyItem(at: tempURL, to: backupURL)
                
                // Keep only last 5 backups
                cleanUpOldBackups(in: backupDirectory)
                
                print("✅ Auto-Backup successful: \(backupURL.lastPathComponent)")
            } catch {
                print("❌ Auto-Backup failed: \(error.localizedDescription)")
            }
        }
    }
    
    private func cleanUpOldBackups(in directory: URL) {
        let fileManager = FileManager.default
        do {
            let files = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles)
            let sortedFiles = try files.sorted {
                let date1 = try $0.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
                let date2 = try $1.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
                return date1 > date2 // Newest first
            }
            
            if sortedFiles.count > 5 {
                for i in 5..<sortedFiles.count {
                    try fileManager.removeItem(at: sortedFiles[i])
                }
            }
        } catch {
            print("Failed to clean up old backups: \(error.localizedDescription)")
        }
    }
    
    func getAvailableBackups() -> [URL] {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return [] }
        let backupDirectory = documentsURL.appendingPathComponent("AutoBackups")
        
        do {
            let files = try fileManager.contentsOfDirectory(at: backupDirectory, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles)
            return try files.sorted {
                let date1 = try $0.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
                let date2 = try $1.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
                return date1 > date2
            }
        } catch {
            return []
        }
    }
}
