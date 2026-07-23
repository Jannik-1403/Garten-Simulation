import re

file_path = 'Garten_Simulation/Managers/SharedUserDefaults.swift'
with open(file_path, 'r') as f:
    content = f.read()

new_migration = """    static func migrateIfNeeded() {
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
    }"""

# Replace the old migrateIfNeeded function completely
content = re.sub(r'    static func migrateIfNeeded\(\) \{.*?\n    \}', new_migration, content, flags=re.DOTALL)

with open(file_path, 'w') as f:
    f.write(content)
