import Foundation

enum GameConstants {

    // MARK: Belohnungen pro Gießvorgang
    static let coinsProGiessen: Int = 10
    static let xpProGiessen: Int = 20

    // MARK: XP-Schwellen für Pflanzen-Seltenheit
    // Bronze ist der Startzustand (0 XP)
    static let xpFuerSilber: Int  = 50
    static let xpFuerGold: Int    = 150
    static let xpFuerDiamant: Int = 300

    // MARK: Streak
    static let streakTimerStunden: Double = 24  // Timer-Fenster in Stunden

    // MARK: Onboarding
    static let startCoins: Int = 1000
    static let gratisPflanzenAnzahl: Int = 2

    // MARK: - Lokalisierung — Key-Präfix
    // Alle UI-Texte kommen aus Localizable.strings, nie hardcoden
    
    // MARK: - PflanzenStufe XP Schwellen
    static func xpSchwelle(fuer stufe: PflanzenStufe) -> Int {
        switch stufe {
        case .bronze1: return 0
        case .bronze2: return 20
        case .bronze3: return 40
        case .silber1: return 60
        case .silber2: return 90
        case .silber3: return 120
        case .gold1:   return 160
        case .gold2:   return 200
        case .gold3:   return 250
        case .diamant1: return 300
        case .diamant2: return 375
        case .diamant3: return 450
        }
    }

    // NEU: Schwellenwerte für das globale Garten-Level (viel größere Abstände)
    static func xpSchwelleGarten(fuer stufe: PflanzenStufe) -> Int {
        switch stufe {
        case .bronze1:  return 0
        case .bronze2:  return 100
        case .bronze3:  return 250
        case .silber1:  return 500
        case .silber2:  return 800
        case .silber3:  return 1200
        case .gold1:    return 1800
        case .gold2:    return 2500
        case .gold3:    return 3500
        case .diamant1: return 5000
        case .diamant2: return 7000
        case .diamant3: return 10000
        }
    }
}

import UserNotifications

/// Verwaltet lokale Benachrichtigungen für Pflanzen-Timer
final class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    // MARK: - Permission
    func requestPermission(completion: @escaping (Bool) -> Void = { _ in }) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    // MARK: - Schedule
    func scheduleReminder(plantId: String, plantName: String, date: Date) {
        let content = UNMutableNotificationContent()
        
        let lang = UserDefaults.standard.string(forKey: "appLanguage") ?? "de"
        content.title = lang == "de" ? "🌱 Pflanzen-Erinnerung" : "🌱 Plant Reminder"
        content.body = lang == "de"
            ? "Zeit, dich um \(plantName) zu kümmern!"
            : "Time to take care of \(plantName)!"
        content.sound = .default
        content.userInfo = ["plantId": plantId]
        
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "plant-timer-\(plantId)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Notification Error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Cancel
    func cancelReminder(plantId: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["plant-timer-\(plantId)"]
        )
    }
}

