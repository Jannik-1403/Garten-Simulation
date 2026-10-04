import Foundation
import Combine

struct ManualDaySnapshot: Codable, Identifiable {
    var id: String // yyyy-MM-dd
    var date: Date
    var habitProgress: [String: Double] // PlantID (String) -> Progress (0.0 - 1.0 or target-based)
    var journalEntries: [String: [GratitudeJournalEntry]] // PlantID -> Entries
    var completedTodos: [String: [String]] // PlantID -> Array of completed Todo IDs
    var schemaVersion: Int = 1
}

class SnapshotStore: ObservableObject {
    static let shared = SnapshotStore()
    
    @Published var snapshots: [String: ManualDaySnapshot] = [:]
    
    private let fileURL: URL
    
    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = docs.appendingPathComponent("ManualSnapshots.json")
        loadSnapshots()
    }
    
    private func loadSnapshots() {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([String: ManualDaySnapshot].self, from: data) {
            self.snapshots = decoded
        }
    }
    
    func saveSnapshots() {
        if let encoded = try? JSONEncoder().encode(snapshots) {
            try? encoded.write(to: fileURL)
        }
    }
    
    func getSnapshot(for date: Date) -> ManualDaySnapshot? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let key = formatter.string(from: date)
        return snapshots[key]
    }
    
    func runBackfillIfNeeded(gardenStore: GardenStore) {
        let backfillKey = "SnapshotBackfillCompleted_v1"
        if UserDefaults.standard.bool(forKey: backfillKey) { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let ninetyDaysAgo = calendar.date(byAdding: .day, value: -90, to: today) else { return }
        
        var dateIterator = ninetyDaysAgo
        while dateIterator < today {
            let key = formatter.string(from: dateIterator)
            var snapshot = ManualDaySnapshot(id: key, date: dateIterator, habitProgress: [:], journalEntries: [:], completedTodos: [:])
            
            for plant in gardenStore.plants {
                let pid = plant.plantID.uuidString
                
                // 1. Progress
                if plant.effectiveHealthMetric == nil {
                    // Check history for that day
                    if let hist = plant.intradayProgressHistory.filter({ calendar.isDate($0.timestamp, inSameDayAs: dateIterator) }).last {
                        snapshot.habitProgress[pid] = hist.progress
                    }
                }
                
                // 2. Journal Entries
                let entries = plant.journalEntries.filter { calendar.isDate($0.timestamp, inSameDayAs: dateIterator) }
                if !entries.isEmpty {
                    snapshot.journalEntries[pid] = entries
                }
            }
            
            if !snapshot.habitProgress.isEmpty || !snapshot.journalEntries.isEmpty {
                snapshots[key] = snapshot
            }
            
            dateIterator = calendar.date(byAdding: .day, value: 1, to: dateIterator)!
        }
        
        saveSnapshots()
        UserDefaults.standard.set(true, forKey: backfillKey)
    }
    
    func captureSnapshot(for date: Date, gardenStore: GardenStore) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let key = formatter.string(from: date)
        
        let calendar = Calendar.current
        var snapshot = snapshots[key] ?? ManualDaySnapshot(id: key, date: calendar.startOfDay(for: date), habitProgress: [:], journalEntries: [:], completedTodos: [:])
        
        for plant in gardenStore.plants {
            let pid = plant.plantID.uuidString
            
            if plant.effectiveHealthMetric == nil {
                if calendar.isDateInToday(date) {
                    let prog = plant.trackingMode == .counter ? Double(plant.counterProgress) / max(Double(plant.counterTarget), 1.0) : plant.sliderProgress
                    snapshot.habitProgress[pid] = prog
                } else {
                    if let hist = plant.intradayProgressHistory.filter({ calendar.isDate($0.timestamp, inSameDayAs: date) }).last {
                        snapshot.habitProgress[pid] = hist.progress
                    }
                }
            }
            
            let entries = plant.journalEntries.filter { calendar.isDate($0.timestamp, inSameDayAs: date) }
            if !entries.isEmpty {
                snapshot.journalEntries[pid] = entries
            }
            
            let completedTodoIds = plant.todos.filter { $0.isCompleted }.map { $0.id.uuidString }
            if !completedTodoIds.isEmpty {
                snapshot.completedTodos[pid] = completedTodoIds
            }
        }
        
        snapshots[key] = snapshot
        saveSnapshots()
    }
}
