import ActivityKit
import Foundation

struct FocusTimerActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var endTime: Date
        var title: String
        var musicName: String?
        var tasks: [String]?
        var isProUser: Bool
        var isRoutine: Bool?
    }

    var habitName: String
    var habitId: String
}
