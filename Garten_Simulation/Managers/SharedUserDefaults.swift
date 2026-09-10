import Foundation

struct SharedUserDefaults {
    static let suiteName = "group.com.jannik.grovy"
    
    static var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
    
    static let suite: UserDefaults = {
        if isPreview {
            return .standard
        }
        return UserDefaults(suiteName: suiteName) ?? .standard
    }()
    
    /// Migrates data from local SharedUserDefaults.suite to the shared App Group container.
    /// This ensures users don't lose their data when we switch to App Groups.
    static func migrateIfNeeded() {
        let standard = UserDefaults.standard
        let shared = SharedUserDefaults.suite
        
        // 1. Initial Migration to App Group (V2) - Safe Copy
        let migrationKey = "did_migrate_all_keys_to_app_group_v2"
        if !shared.bool(forKey: migrationKey) {
            let allKeys = standard.dictionaryRepresentation().keys
            for key in allKeys {
                if key.hasPrefix("Apple") || key.hasPrefix("NS") || key.hasPrefix("WebKit") || key.hasPrefix("com.apple") { continue }
                
                // Copy if missing in the new shared suite
                if shared.object(forKey: key) == nil {
                    shared.set(standard.object(forKey: key), forKey: key)
                }
            }
            shared.set(true, forKey: migrationKey)
            shared.synchronize()
            print("✅ V2 Migration to App Group successful.")
        }
    }
    
    /// Erzwingt eine Wiederherstellung aus dem alten lokalen UserDefaults (Überschreibt aktuelle Daten)
    static func forceRecoveryFromLocal() {
        let standard = UserDefaults.standard
        let shared = SharedUserDefaults.suite
        
        let allKeys = standard.dictionaryRepresentation().keys
        for key in allKeys {
            if key.hasPrefix("Apple") || key.hasPrefix("NS") || key.hasPrefix("WebKit") || key.hasPrefix("com.apple") { continue }
            
            // Unconditional overwrite
            if let val = standard.object(forKey: key) {
                shared.set(val, forKey: key)
            }
        }
        shared.synchronize()
        print("🚨 Force Recovery from Local UserDefaults completed.")
    }
}
