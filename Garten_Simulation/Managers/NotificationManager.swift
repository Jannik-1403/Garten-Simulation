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
    /// Regel: Maximal EINE Benachrichtigung pro (Stunde:Minute)-Slot.
    func scheduleAll(for habits: [HabitModel]) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        let lang = SharedUserDefaults.suite.string(forKey: "appLanguage") ?? "de"
        let calendar = Calendar.current

        // Bereits verwendete (Stunde, Minute)-Slots → verhindert Doppel-Notifications
        var usedSlots = Set<String>()

        // 1. Individuelle Pflanzen-Erinnerungen (täglich, wiederholend)
        for habit in habits {
            guard let reminderTime = habit.reminderTime else { continue }

            let hour   = calendar.component(.hour,   from: reminderTime)
            let minute = calendar.component(.minute, from: reminderTime)
            let slotKey = "\(hour):\(minute)"

            // Wenn dieser Slot bereits belegt ist → überspringen
            guard !usedSlots.contains(slotKey) else { continue }
            usedSlots.insert(slotKey)

            // Pflanzname
            let plantName = habit.habitName.isEmpty ? habit.name : habit.habitName
            var title = ""
            var body = ""

            if let customMsg = habit.customReminderMessage, !customMsg.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
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

        // 2. Globale Abend-Erinnerung (20:00 Uhr)
        // Nur wenn es Pflanzen OHNE individuelle Reminder-Zeit gibt
        let ohneIndividuellenReminder = habits.filter { $0.reminderTime == nil }
        if !ohneIndividuellenReminder.isEmpty {
            let eveningSlot = "20:00"
            if !usedSlots.contains(eveningSlot) {
                usedSlots.insert(eveningSlot)
                let count = ohneIndividuellenReminder.count
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
        let ids = ["reminder-\(habit.id)"]
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

    /// Plant eine täglich wiederholende Benachrichtigung zur exakten Uhrzeit.
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
}
