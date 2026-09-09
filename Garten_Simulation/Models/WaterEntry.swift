import Foundation
import HealthKit

struct WaterEntry: Identifiable, Equatable {
    let id = UUID()
    let amountMl: Double
    let date: Date
    let source: String // e.g. "Garten_Simulation", "Apple Health", etc.
    let isManualAppEntry: Bool
}
