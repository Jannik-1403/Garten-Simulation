import ActivityKit
import WidgetKit
import SwiftUI

struct FocusTimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FocusTimerActivityAttributes.self) { context in
            // Lock Screen UI
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(context.attributes.habitName)
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.black)
                            .foregroundColor(.white)
                        Text(context.state.title)
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    if context.state.isRoutine == true {
                        Text(timerInterval: context.state.endTime...context.state.endTime.addingTimeInterval(86400), countsDown: false)
                            .font(.system(.title, design: .monospaced).weight(.black))
                            .foregroundStyle(.orange)
                            .multilineTextAlignment(.trailing)
                    } else {
                        Text(timerInterval: Date()...context.state.endTime, countsDown: true)
                            .font(.system(.title, design: .monospaced).weight(.black))
                            .foregroundStyle(.orange)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                if context.state.isProUser, let music = context.state.musicName {
                    HStack {
                        Text(String(localized: "focus.live_activity.music", defaultValue: "Musik:"))
                            .font(.system(.caption, design: .rounded).weight(.bold))
                            .foregroundColor(.white.opacity(0.8))
                        Text(music)
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                
                if let tasks = context.state.tasks, !tasks.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(localized: "focus.live_activity.tasks", defaultValue: "Aufgaben:"))
                            .font(.system(.caption, design: .rounded).weight(.bold))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.top, 4)
                        
                        ForEach(tasks.prefix(3), id: \.self) { task in
                            Text("• \(task)")
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(.white)
                                .lineLimit(1)
                        }
                        if tasks.count > 3 {
                            Text(String(localized: "focus.live_activity.more_tasks", defaultValue: "+ %lld weitere", options: String.LocalizationOptions(replacements: [tasks.count - 3])))
                                .font(.system(.caption2, design: .rounded))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
            }
            .environment(\.locale, Locale(identifier: SharedUserDefaults.suite.string(forKey: "appLanguage") ?? "de"))
            .padding()
            .activityBackgroundTint(Color.black.opacity(0.85))
            .activitySystemActionForegroundColor(Color.white)
            // Tap auf Lock Screen → laufenden Fokus-Timer öffnen
            .widgetURL(focusDeepLink(habitId: context.attributes.habitId))

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.attributes.habitName.prefix(1))
                        .font(.title2.weight(.black))
                        .foregroundStyle(.orange)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if context.state.isRoutine == true {
                        Text(timerInterval: context.state.endTime...context.state.endTime.addingTimeInterval(86400), countsDown: false)
                            .font(.system(.title3, design: .monospaced).weight(.black))
                            .foregroundStyle(.orange)
                    } else {
                        Text(timerInterval: Date()...context.state.endTime, countsDown: true)
                            .font(.system(.title3, design: .monospaced).weight(.black))
                            .foregroundStyle(.orange)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.attributes.habitName)
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.black)
                        Text(context.state.title)
                            .font(.system(.footnote, design: .rounded))
                            .foregroundStyle(.secondary)
                        
                        if context.state.isProUser, let music = context.state.musicName {
                            Text(music)
                                .font(.system(.caption2, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.bottom, 8)
                }
            } compactLeading: {
                Text(context.attributes.habitName.prefix(1))
                    .font(.body.weight(.black))
                    .foregroundStyle(.orange)
            } compactTrailing: {
                if context.state.isRoutine == true {
                    Text(timerInterval: context.state.endTime...context.state.endTime.addingTimeInterval(86400), countsDown: false)
                        .font(.system(size: 12, weight: .black, design: .monospaced))
                        .foregroundStyle(.orange)
                } else {
                    Text(timerInterval: Date()...context.state.endTime, countsDown: true)
                        .font(.system(size: 12, weight: .black, design: .monospaced))
                        .foregroundStyle(.orange)
                }
            } minimal: {
                if context.state.isRoutine == true {
                    Text(timerInterval: context.state.endTime...context.state.endTime.addingTimeInterval(86400), countsDown: false)
                        .font(.system(size: 12, weight: .black, design: .monospaced))
                        .foregroundStyle(.orange)
                } else {
                    Text(timerInterval: Date()...context.state.endTime, countsDown: true)
                        .font(.system(size: 12, weight: .black, design: .monospaced))
                        .foregroundStyle(.orange)
                }
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
