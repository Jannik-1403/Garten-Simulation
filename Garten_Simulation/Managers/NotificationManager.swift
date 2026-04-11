import Foundation
import UserNotifications
import SwiftUI
import Combine

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private init() {}
    
    // MARK: - Types
    private enum TriggerType {
        case triggerA, triggerB, triggerC, triggerD, triggerE
    }
    
    private struct NotificationCandidate {
        let id: String
        var time: Date
        let type: TriggerType
        var habit: HabitModel? = nil
        var count: Int = 0
    }
    
    // MARK: - Public API
    
    func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        do {
            let success = try await center.requestAuthorization(options: options)
            return success
        } catch {
            return false
        }
    }
    
    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }
    
    func scheduleAll(for habits: [HabitModel]) {
        // Zuerst alle bestehenden Anfragen löschen
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let now = Date()
        let calendar = Calendar.current
        var candidates: [NotificationCandidate] = []
        
        // 1. Trigger A & B (Pflanzspezifisch)
        for habit in habits {
            // Nur wenn heute noch nicht gegossen
            guard !habit.istBewässert, let lastWatered = habit.letzteBewaesserung else { continue }
            
            // Trigger A: 18h nach letztem Gießen
            let aTime = lastWatered.addingTimeInterval(18 * 3600)
            if aTime > now {
                candidates.append(NotificationCandidate(
                    id: "triggerA-\(habit.id)",
                    time: aTime,
                    type: .triggerA,
                    habit: habit
                ))
            }
            
            // Trigger B: 22h nach letztem Gießen, nur wenn Streak >= 3
            if habit.streak >= 3 {
                let bTime = lastWatered.addingTimeInterval(22 * 3600)
                if bTime > now {
                    candidates.append(NotificationCandidate(
                        id: "triggerB-\(habit.id)",
                        time: bTime,
                        type: .triggerB,
                        habit: habit
                    ))
                }
            }
        }
        
        // 2. Trigger C: Morgen-Motivation (8:00 Uhr)
        // Nur wenn gestern ALLE gegossen wurden
        if wasYesterdayPerfect() {
            var cTime = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: now) ?? now
            if cTime < now {
                cTime = calendar.date(byAdding: .day, value: 1, to: cTime) ?? cTime
            }
            
            // Streak für Motivation finden (höchster Streak oder Gesamt-Streak)
            let maxStreak = habits.map { $0.streak }.max() ?? 0
            candidates.append(NotificationCandidate(
                id: "triggerC",
                time: cTime,
                type: .triggerC,
                count: maxStreak
            ))
        }
        
        // 3. Trigger D: Stiller Abend (20:00 Uhr)
        // Nur wenn heute noch NICHT alle gegossen wurden
        let unwateredCount = habits.filter { !$0.istBewässert }.count
        if unwateredCount > 0 {
            var dTime = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: now) ?? now
            if dTime < now {
                dTime = calendar.date(byAdding: .day, value: 1, to: dTime) ?? dTime
            }
            candidates.append(NotificationCandidate(
                id: "triggerD",
                time: dTime,
                type: .triggerD,
                count: unwateredCount
            ))
        }
        
        // 4. Trigger E: Individuelle Erinnerung (Pflanzenspezifisch)
        for habit in habits {
            // Nur wenn heute noch nicht gegossen und eine Zeit gesetzt ist
            guard !habit.istBewässert, let reminderTime = habit.reminderTime else { continue }
            
            let reminderComponents = calendar.dateComponents([.hour, .minute], from: reminderTime)
            var scheduledTime = calendar.date(bySettingHour: reminderComponents.hour ?? 8, 
                                             minute: reminderComponents.minute ?? 0, 
                                             second: 0, of: now) ?? now
            
            if scheduledTime < now {
                scheduledTime = calendar.date(byAdding: .day, value: 1, to: scheduledTime) ?? scheduledTime
            }
            
            candidates.append(NotificationCandidate(
                id: "triggerE-\(habit.id)",
                time: scheduledTime,
                type: .triggerE,
                habit: habit
            ))
        }
        
        // 4. Constraints anwenden & Planen
        let processed = processCandidates(candidates)
        
        for candidate in processed {
            addNotificationRequest(for: candidate)
        }
    }
    
    func cancelAll(for habit: HabitModel) {
        let ids = ["triggerA-\(habit.id)", "triggerB-\(habit.id)"]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ids)
    }
    
    func rescheduleAfterWatering(habit: HabitModel, allHabits: [HabitModel]) {
        // Sofort canceln
        cancelAll(for: habit)
        // Und alles neu planen (damit Trigger D etc. aktualisiert wird)
        scheduleAll(for: allHabits)
    }
    
    func scheduleMorningAndEvening(allHabits: [HabitModel]) {
        // Spezifisch für C & D, aber wir nutzen einfach scheduleAll für Konsistenz
        scheduleAll(for: allHabits)
    }
    
    // MARK: - Private Logic
    
    private func wasYesterdayPerfect() -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else { return false }
        
        if let timestamps = UserDefaults.standard.array(forKey: "streak_completed_dates") as? [TimeInterval] {
            let dates = Set(timestamps.map { calendar.startOfDay(for: Date(timeIntervalSince1970: $0)) })
            return dates.contains(yesterday)
        }
        return false
    }
    
    private func processCandidates(_ candidates: [NotificationCandidate]) -> [NotificationCandidate] {
        let calendar = Calendar.current
        var results: [NotificationCandidate] = []
        var dayCounts: [String: Int] = [:]
        
        // 1. Sortieren nach Zeit
        let sorted = candidates.sorted { $0.time < $1.time }
        
        for var candidate in sorted {
            // 2. Silent Window Check (22:00 - 07:00)
            let hour = calendar.component(.hour, from: candidate.time)
            
            if hour >= 22 || hour < 7 {
                if candidate.type == .triggerB {
                    // Trigger B verschieben auf 7:00 am nächsten Morgen
                    var nextMorning = calendar.date(bySettingHour: 7, minute: 0, second: 0, of: candidate.time) ?? candidate.time
                    if calendar.component(.hour, from: candidate.time) >= 22 {
                        nextMorning = calendar.date(byAdding: .day, value: 1, to: nextMorning) ?? nextMorning
                    }
                    candidate.time = nextMorning
                } else {
                    // Andere (A, C, D) in der Nacht ignorieren
                    continue
                }
            }
            
            // 3. Max 2 pro Tag Constraint
            let dayKey = getDayKey(for: candidate.time)
            let currentCount = dayCounts[dayKey, default: 0]
            
            if currentCount < 2 {
                results.append(candidate)
                dayCounts[dayKey] = currentCount + 1
            }
            
            // Limit: Nicht zu weit in die Zukunft planen (z.B. max 10 insgesamt)
            if results.count >= 15 { break }
        }
        
        return results
    }
    
    private func getDayKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func addNotificationRequest(for candidate: NotificationCandidate) {
        let content = UNMutableNotificationContent()
        content.sound = candidate.type == .triggerB ? UNNotificationSound.defaultCritical : .default
        
        let texts: (title: String, body: String)
        
        let lang = UserDefaults.standard.string(forKey: "appLanguage") ?? "de"
        
        switch candidate.type {
        case .triggerA:
            let name = candidate.habit?.habitName ?? candidate.habit?.name ?? "Pflanze"
            let h = Int(candidate.time.timeIntervalSince(candidate.habit?.letzteBewaesserung ?? Date()) / 3600)
            texts = NotificationTexts.wartet(pflanzenName: name, stunden: h, lang: lang)
            
        case .triggerB:
            let name = candidate.habit?.habitName ?? candidate.habit?.name ?? "Pflanze"
            texts = NotificationTexts.streakGefahr(pflanzenName: name, streak: candidate.habit?.streak ?? 0, lang: lang)
            
        case .triggerC:
            texts = NotificationTexts.morgenMotivation(streak: candidate.count, lang: lang)
            
        case .triggerD:
            texts = NotificationTexts.stillerAbend(anzahlUngegossen: candidate.count, lang: lang)
            
        case .triggerE:
            let name = candidate.habit?.habitName ?? candidate.habit?.name ?? "Pflanze"
            // Wir nutzen hier vorerst den TriggerA Text oder einen leicht angepassten
            texts = NotificationTexts.wartet(pflanzenName: name, stunden: 0, lang: lang)
        }
        
        content.title = texts.title
        content.body = texts.body
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: candidate.time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: candidate.id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                // print("❌ Error scheduling notification \(candidate.id): \(error.localizedDescription)")
            }
        }
    }
}
