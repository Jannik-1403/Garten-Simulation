import Foundation

struct CleaningTask: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var nameKey: String
    var iconName: String
    var frequencyDays: Int
    var createdAt: Date = Date()
    var isActive: Bool = true // Falls der Nutzer ihn löscht, setzen wir ihn auf inaktiv oder löschen ihn direkt
    
    // Berechnet die Fälligkeit in Kombination mit den Logs
    func dueDate(lastCompleted: Date?) -> Date {
        guard let last = lastCompleted else {
            return Date() // Sofort fällig, wenn noch nie gemacht
        }
        return Calendar.current.date(byAdding: .day, value: frequencyDays, to: last) ?? Date()
    }
    
    func isOverdue(lastCompleted: Date?) -> Bool {
        let due = dueDate(lastCompleted: lastCompleted)
        return Date() >= due
    }
}
