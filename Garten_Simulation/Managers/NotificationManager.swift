import Foundation
import UserNotifications
import SwiftUI

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    // MARK: - Permission

    @MainActor
    func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        do {
            return try await center.requestAuthorization(options: options)
        } catch {
            return false
        }
    }

    @MainActor
    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }

    // MARK: - Schedule All

    /// Löscht alle geplanten Benachrichtigungen und plant sie neu.
    /// Unterstützt jetzt Wochentag-basierte Schedules mit individuellen Nachrichten.
    func scheduleAll(for habits: [HabitModel]) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        let isNotificationsEnabled = SharedUserDefaults.suite.object(forKey: "isNotificationsEnabled") as? Bool ?? true
        guard isNotificationsEnabled else { return }

        let lang = SharedUserDefaults.suite.string(forKey: "appLanguage") ?? "de"
        let calendar = Calendar.current

        // Bereits verwendete (Wochentag, Stunde, Minute)-Slots → verhindert Doppel-Notifications
        var usedSlots = Set<String>()

        for habit in habits {
            // Pflanzname — LOKALISIERT statt roher Schlüssel
            let rawName = habit.habitName.isEmpty ? habit.name : habit.habitName
            let plantName = AppStrings.get(rawName, language: lang)
            
            // Neues System: ReminderSchedule mit Wochentagen
            if let schedule = habit.reminderSchedule, !schedule.isExpired {
                for weekday in schedule.weekdays where weekday.isEnabled {
                    let hour   = calendar.component(.hour,   from: weekday.time)
                    let minute = calendar.component(.minute, from: weekday.time)
                    let slotKey = "\(weekday.appleWeekday):\(hour):\(minute)"
                    
                    guard !usedSlots.contains(slotKey) else { continue }
                    usedSlots.insert(slotKey)
                    
                    var title = ""
                    var body = ""
                    
                    if let customMsg = weekday.customMessage,
                       !customMsg.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        title = "🌱 \(plantName)"
                        body = customMsg
                    } else {
                        let texts = NotificationTexts.pflanzeErinnerung(pflanzenName: plantName, lang: lang)
                        title = texts.title
                        body = texts.body
                    }
                    
                    let repeats = weekday.repeatMode != .once
                    
                    scheduleWeekday(
                        id: "reminder-\(habit.id)-\(weekday.weekday)",
                        weekday: weekday.appleWeekday,
                        hour: hour,
                        minute: minute,
                        title: title,
                        body: body,
                        repeats: repeats
                    )
                }
            } else if let reminderTime = habit.reminderTime {
                // Legacy-Fallback: altes System ohne Schedule
                let hour   = calendar.component(.hour,   from: reminderTime)
                let minute = calendar.component(.minute, from: reminderTime)
                let slotKey = "legacy:\(hour):\(minute)"
                
                guard !usedSlots.contains(slotKey) else { continue }
                usedSlots.insert(slotKey)
                
                var title = ""
                var body = ""
                
                if let customMsg = habit.customReminderMessage,
                   !customMsg.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    title = "🌱 \(plantName)"
                    body = customMsg
                } else {
                    let texts = NotificationTexts.pflanzeErinnerung(pflanzenName: plantName, lang: lang)
                    title = texts.title
                    body = texts.body
                }
                
                scheduleRepeating(
                    id: "reminder-\(habit.id)",
                    hour: hour,
                    minute: minute,
                    title: title,
                    body: body
                )
            }
        }

        // Globale Abend-Erinnerung (20:00 Uhr)
        // Nur wenn es Pflanzen OHNE individuelle Reminder-Zeit gibt
        let ohneReminder = habits.filter { !$0.hasActiveReminder }
        if !ohneReminder.isEmpty {
            let eveningSlot = "legacy:20:0"
            if !usedSlots.contains(eveningSlot) {
                usedSlots.insert(eveningSlot)
                let count = ohneReminder.count
                let texts = NotificationTexts.abendeErinnerung(anzahlPflanzen: count, lang: lang)
                scheduleRepeating(
                    id: "reminder-evening",
                    hour: 20,
                    minute: 0,
                    title: texts.title,
                    body: texts.body
                )
            }
        }
    }

    // MARK: - Cancel

    func cancelAll(for habit: HabitModel) {
        let center = UNUserNotificationCenter.current()
        // Alle möglichen IDs: Legacy + 7 Wochentage
        var ids = ["reminder-\(habit.id)"]
        for day in 1...7 {
            ids.append("reminder-\(habit.id)-\(day)")
        }
        center.removePendingNotificationRequests(withIdentifiers: ids)
        center.removeDeliveredNotifications(withIdentifiers: ids)
    }

    func rescheduleAfterWatering(habit: HabitModel, allHabits: [HabitModel]) {
        cancelAll(for: habit)
        scheduleAll(for: allHabits)
    }

    // Legacy-Kompatibilität
    func scheduleMorningAndEvening(allHabits: [HabitModel]) {
        scheduleAll(for: allHabits)
    }

    // MARK: - Private Helpers

    /// Plant eine täglich wiederholende Benachrichtigung zur exakten Uhrzeit (Legacy).
    private func scheduleRepeating(id: String, hour: Int, minute: Int, title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body  = body
        content.sound = .default
        content.badge = 1

        var components = DateComponents()
        components.hour   = hour
        components.minute = minute
        components.second = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { _ in }
    }
    
    /// Plant eine Benachrichtigung für einen bestimmten Wochentag zur exakten Uhrzeit.
    private func scheduleWeekday(id: String, weekday: Int, hour: Int, minute: Int,
                                  title: String, body: String, repeats: Bool = true) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body  = body
        content.sound = .default
        content.badge = 1

        var components = DateComponents()
        components.weekday = weekday  // Apple-Format: So=1, Mo=2, ..., Sa=7
        components.hour    = hour
        components.minute  = minute
        components.second  = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: repeats)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { _ in }
    }
}
