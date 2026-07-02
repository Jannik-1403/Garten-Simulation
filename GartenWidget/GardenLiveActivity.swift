import ActivityKit
import WidgetKit
import SwiftUI

struct FocusTimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FocusTimerActivityAttributes.self) { context in
            // Lock Screen UI
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "timer")
                        .foregroundStyle(.orange)
                        .font(.title2)
                    
                    VStack(alignment: .leading) {
                        Text(context.attributes.habitName)
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.black)
                        Text(context.state.title)
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(timerInterval: Date()...context.state.endTime, countsDown: true)
                        .font(.system(.title, design: .monospaced).weight(.black))
                        .foregroundStyle(.orange)
                        .multilineTextAlignment(.trailing)
                }
            }
            .padding()
            .activityBackgroundTint(Color.black.opacity(0.85))
            .activitySystemActionForegroundColor(Color.white)
            // Tap auf Lock Screen → laufenden Fokus-Timer öffnen
            .widgetURL(focusDeepLink(habitId: context.attributes.habitId))

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "timer")
                        .foregroundStyle(.orange)
                        .font(.title2)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timerInterval: Date()...context.state.endTime, countsDown: true)
                        .font(.system(.title3, design: .monospaced).weight(.black))
                        .foregroundStyle(.orange)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack {
                        Text(context.attributes.habitName)
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.black)
                        Text(context.state.title)
                            .font(.system(.footnote, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.bottom, 8)
                }
            } compactLeading: {
                Image(systemName: "timer")
                    .foregroundStyle(.orange)
            } compactTrailing: {
                Text(timerInterval: Date()...context.state.endTime, countsDown: true)
                    .font(.system(size: 12, weight: .black, design: .monospaced))
                    .foregroundStyle(.orange)
            } minimal: {
                Image(systemName: "timer")
                    .foregroundStyle(.orange)
            }
            // Tap auf Dynamic Island → laufenden Fokus-Timer öffnen
            .widgetURL(focusDeepLink(habitId: context.attributes.habitId))
            .keylineTint(Color.orange)
        }
    }

    /// Erzeugt die Deep-Link-URL für den laufenden Fokus-Timer.
    private func focusDeepLink(habitId: String) -> URL {
        URL(string: "grovy://focus?habitId=\(habitId)") ?? URL(string: "grovy://home")!
    }
}
