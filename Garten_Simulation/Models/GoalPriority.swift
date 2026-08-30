import SwiftUI

enum GoalPriority: String, CaseIterable, Equatable, Codable {
    case low
    case medium
    case high
    
    var displayName: String {
        switch self {
        case .low: return String(localized: "priority.low", defaultValue: "Kann warten")
        case .medium: return String(localized: "priority.medium", defaultValue: "Sollte bald")
        case .high: return String(localized: "priority.high", defaultValue: "Muss heute")
        }
    }
    
    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .orangePrimary
        case .high: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .low: return "cup.and.saucer.fill"
        case .medium: return "calendar"
        case .high: return "bolt.fill"
        }
    }
    
    var sortValue: Int {
        switch self {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        }
    }
    
    mutating func next() {
        switch self {
        case .high: self = .medium
        case .medium: self = .low
        case .low: self = .high
        }
    }
}
