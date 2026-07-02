import Foundation

struct ActiveFocusSessionState: Codable {
    let habitId: String
    let remainingSeconds: Int
    let selectedMinutes: Int
    let sessionGoals: [FocusGoal]
    let state: FocusSessionState
    let isStrictMode: Bool
    let isTimerRunning: Bool
}
