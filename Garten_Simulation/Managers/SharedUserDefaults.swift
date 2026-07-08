import Foundation

struct SharedUserDefaults {
    static let suiteName = "group.com.jannik.grovy"
    
    static let suite: UserDefaults = UserDefaults(suiteName: suiteName) ?? .standard
    
    /// Migrates data from local SharedUserDefaults.suite to the shared App Group container.
    /// This ensures users don't lose their data when we switch to App Groups.
    static func migrateIfNeeded() {
        let standard = UserDefaults.standard
        let shared = SharedUserDefaults.suite
        
        // 1. Initial Migration to App Group
        let migrationKey = "did_migrate_to_app_group"
        if !shared.bool(forKey: migrationKey) {
            let keysToMigrate = [
                "garden_plants", "stats_coins", "stats_gesamt_xp", "stats_leben",
                "stats_gluecksrad_drehungen", "stats_gesamt_gekaufte_items_count",
                "stats_gesamt_gegossen", "stats_tage_aktiv", "stats_gesamt_verdient",
                "stats_gesamt_ausgegeben", "last_spin_timestamp_double", "last_spin_timestamp",
                "pending_daily_spin", "is_weed_active", "daily_quests_completed_since_weed",
                "stats_seeds", "active_powerups_garden", "garden_decorations",
                "appLanguage", "isHapticEnabled", "isNotificationsEnabled", "showHabitInsteadOfName",
                "onboarding_abgeschlossen", "streak_completed_dates", "streak_best_streak", "streak_last_shown"
            ]
            
            for key in keysToMigrate {
                if let value = standard.object(forKey: key) {
                    shared.set(value, forKey: key)
                }
            }
            shared.set(true, forKey: migrationKey)
        }
        
        // Neu: customRoutinesData migrieren (falls noch nicht passiert)
        let routineMigrationKey = "did_migrate_routines_to_app_group"
        if !shared.bool(forKey: routineMigrationKey) {
            if let value = standard.object(forKey: "customRoutinesData") {
                shared.set(value, forKey: "customRoutinesData")
            }
            shared.set(true, forKey: routineMigrationKey)
        }
        
        shared.synchronize()
        print("✅ Migration to App Group successful.")
    }
}
