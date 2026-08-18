import Foundation
import UserNotifications
import SwiftUI

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
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
        let calendar = Calendar.current
        
        // 1. Read routines to find overridden habits and schedule routine reminders
        var overriddenHabitIDs = Set<String>()
        let customRoutinesData = SharedUserDefaults.suite.data(forKey: "customRoutinesData") ?? Data()
        if let decodedRoutines = try? JSONDecoder().decode([RoutineUIData].self, from: customRoutinesData) {
            for routine in decodedRoutines {
                if routine.reminderSchedule != nil || routine.reminderTime != nil {
                    // Collect overridden habits
                    if routine.overrideIndividualReminders {
                        for habit in habits {
                            if routine.contains(habit: habit) {
                                overriddenHabitIDs.insert(habit.id)
                            }
                        }
                    }
                    
                    // Schedule Routine
                    let routineName = NSLocalizedString(routine.titleKey, comment: "")
                    
                    if let schedule = routine.reminderSchedule, !schedule.isExpired {
                        for weekday in schedule.weekdays where weekday.isEnabled {
                            let hour   = calendar.component(.hour,   from: weekday.time)
                            let minute = calendar.component(.minute, from: weekday.time)
                            let title = String(localized: "Zeit für Routine: \(routineName)")
                            let body = weekday.customMessage ?? String(localized: "notification.routine.start", defaultValue: "Starte jetzt deine Routine und verdiene Fokus-Punkte!")
                            let repeats = weekday.repeatMode != .once
                            
                            scheduleWeekday(
                                id: "routine-\(routine.id)-\(weekday.weekday)",
                                weekday: weekday.appleWeekday,
                                hour: hour,
                                minute: minute,
                                title: title,
                                body: body,
                                repeats: repeats
                            )
                        }
                    } else if let reminderTime = routine.reminderTime {
                        let hour   = calendar.component(.hour,   from: reminderTime)
                        let minute = calendar.component(.minute, from: reminderTime)
                        let title = String(localized: "Zeit für Routine: \(routineName)")
                        let body = String(localized: "notification.routine.start", defaultValue: "Starte jetzt deine Routine und verdiene Fokus-Punkte!")
                        
                        scheduleRepeating(
                            id: "routine-\(routine.id)",
                            hour: hour,
                            minute: minute,
                            title: title,
                            body: body
                        )
                    }
                }
            }
        }

        // 2. Schedule individual habits
        for habit in habits {
            // Überspringen, falls durch Routine überschrieben
            if overriddenHabitIDs.contains(habit.id) { continue }
            
            // Pflanzname — LOKALISIERT statt roher Schlüssel
            let rawName = habit.habitName.isEmpty ? habit.name : habit.habitName
            let plantName = NSLocalizedString(rawName, comment: "")
            
            // Neues System: ReminderSchedule mit Wochentagen
            if let schedule = habit.reminderSchedule, !schedule.isExpired {
                for weekday in schedule.weekdays where weekday.isEnabled {
                    let hour   = calendar.component(.hour,   from: weekday.time)
                    let minute = calendar.component(.minute, from: weekday.time)
                    
                    var title = ""
                    var body = ""
                    
                    if let customMsg = weekday.customMessage,
                       !customMsg.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        title = "\(plantName)"
                        body = customMsg
                    } else {
                        let texts = NotificationTexts.pflanzeErinnerung(pflanzenName: plantName)
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
                
                var title = ""
                var body = ""
                
                if let customMsg = habit.customReminderMessage,
                   !customMsg.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    title = "\(plantName)"
                    body = customMsg
                } else {
                    let texts = NotificationTexts.pflanzeErinnerung(pflanzenName: plantName)
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
