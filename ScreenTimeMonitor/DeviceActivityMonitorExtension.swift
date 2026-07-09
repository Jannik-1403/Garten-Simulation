import DeviceActivity
import Foundation
import ManagedSettings

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    // Die App Group deines Projekts
    let sharedDefaults = UserDefaults(suiteName: "group.com.jannik.grovy")
    let store = ManagedSettingsStore()
    
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        // Der Tag hat begonnen. Wir setzen den Fehler-Tracker auf "False"
        sharedDefaults?.set(false, forKey: "screenTimeLimitExceededToday")
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        // Intervall ist zu Ende
    }
    
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        
        // Das vom Nutzer eingestellte Limit (z.B. 2 Stunden) wurde genau in diesem Moment überschritten!
        // Wir speichern das im App Group UserDefaults, damit die Haupt-App es beim nächsten
        // taeglicherStreakCheck() (um Mitternacht) auslesen und die "Schlechte Gewohnheit" auslösen kann.
        sharedDefaults?.set(true, forKey: "screenTimeLimitExceededToday")
        
        // Optional: Du könntest hier auch direkt einen Shield (Blocker) aktivieren
        // store.shield.applications = ...
    }
    
    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
    }
    
    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
    }
    
    override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventWillReachThresholdWarning(event, activity: activity)
    }
}

