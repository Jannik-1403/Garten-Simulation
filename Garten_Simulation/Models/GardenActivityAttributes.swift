import ActivityKit
import Foundation

struct FocusTimerActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var endTime: Date
        var title: String
    }

    var habitName: String
    var habitId: String
}
