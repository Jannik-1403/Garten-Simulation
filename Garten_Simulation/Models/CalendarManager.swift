import Foundation
import EventKit
import SwiftUI
import Combine

@MainActor
class CalendarManager: ObservableObject {
    static let shared = CalendarManager()
    private let eventStore = EKEventStore()
    
    @Published var isAuthorized: Bool = false
    @Published var todaysEvents: [EKEvent] = []
    
    private init() {
        checkAuthorizationStatus()
    }
    
    func checkAuthorizationStatus() {
        let status = EKEventStore.authorizationStatus(for: .event)
        switch status {
        case .authorized, .fullAccess:
            isAuthorized = true
        default:
            isAuthorized = false
        }
    }
    
    func requestAccess() async {
        do {
            if #available(iOS 17.0, *) {
                let granted = try await eventStore.requestFullAccessToEvents()
                self.isAuthorized = granted
                if granted {
                    self.fetchTodaysEvents()
                }
            } else {
                let granted = try await eventStore.requestAccess(to: .event)
                self.isAuthorized = granted
                if granted {
                    self.fetchTodaysEvents()
                }
            }
        } catch {
            print("Fehler beim Anfordern des Kalender-Zugriffs: \(error.localizedDescription)")
            self.isAuthorized = false
        }
    }
    
    func fetchTodaysEvents() {
        guard isAuthorized else { return }
        
        let calendars = eventStore.calendars(for: .event)
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        // Holen wir die Termine für die nächsten 3 Tage
        let endOfRange = Calendar.current.date(byAdding: .day, value: 3, to: startOfDay)!
        
        let predicate = eventStore.predicateForEvents(withStart: startOfDay, end: endOfRange, calendars: calendars)
        
        var events = eventStore.events(matching: predicate)
        
        // Filter out all-day events if preferred, or just sort them
        events.sort { (e1, e2) -> Bool in
            return e1.startDate < e2.startDate
        }
        
        // Only keep events that haven't ended yet
        self.todaysEvents = events.filter { $0.endDate > now }
    }
}
