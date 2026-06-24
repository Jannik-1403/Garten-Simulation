import re

# 1. Update StatsHelper.swift
file_path_stats = "Garten_Simulation/Models/StatsHelper.swift"
with open(file_path_stats, "r", encoding="utf-8") as f:
    stats_content = f.read()

trigger_counts_methods = """
    static func getTriggerCounts(from badHabitExecutions: [String: [BadHabitExecution]], days: Int) -> [(key: String, value: Int)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let startDate: Date
        if days == 0 {
            startDate = .distantPast // Assume 0 means all time if not handled, or just pass Int.max
        } else {
            startDate = calendar.date(byAdding: .day, value: -days, to: today) ?? .distantPast
        }
        
        var triggerCounts: [String: Int] = [:]
        for list in badHabitExecutions.values {
            for execution in list {
                if execution.date >= startDate {
                    if let triggers = execution.triggers {
                        for t in triggers {
                            triggerCounts[t, default: 0] += 1
                        }
                    }
                }
            }
        }
        return triggerCounts.sorted { $0.value > $1.value }
    }
"""

if "getTriggerCounts" not in stats_content:
    stats_content = stats_content.replace("class StatsHelper {", "class StatsHelper {" + trigger_counts_methods)
    with open(file_path_stats, "w", encoding="utf-8") as f:
        f.write(stats_content)

# 2. Update ProfilComponents.swift
file_path_profil = "Garten_Simulation/Views/Profile/ProfilComponents.swift"
with open(file_path_profil, "r", encoding="utf-8") as f:
    content = f.read()

# Replace triggers in ShareCard views where it loops imperatively
bad_trigger_share_card = """            case .triggers:
                let calendar = Calendar.current
                let today = calendar.startOfDay(for: Date())
                let startDate = period == .allTime ? .distantPast : (calendar.date(byAdding: .day, value: -period.days, to: today) ?? .distantPast)
                
                var triggerCounts: [String: Int] = [:]
                for list in gardenStore.badHabitExecutions.values {
                    for execution in list {
                        if execution.date >= startDate {
                            if let triggers = execution.triggers {
                                for t in triggers {
                                    triggerCounts[t, default: 0] += 1
                                }
                            }
                        }
                    }
                }
                let sortedTriggers = triggerCounts.sorted { $0.value > $1.value }"""

good_trigger_share_card = """            case .triggers:
                let sortedTriggers = StatsHelper.getTriggerCounts(from: gardenStore.badHabitExecutions, days: period == .allTime ? 0 : period.days)"""

content = content.replace(bad_trigger_share_card, good_trigger_share_card)

# Add triggersContent missing implementation
triggers_content_code = """
    private var triggersContent: some View {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let startDate: Date
        if selectedPeriod == .allTime {
            startDate = .distantPast
        } else {
            startDate = calendar.date(byAdding: .day, value: -selectedPeriod.days, to: today) ?? .distantPast
        }
        
        var triggerCounts: [String: Int] = [:]
        for (habitId, list) in gardenStore.badHabitExecutions {
            if selectedTriggerHabitId == "all" || habitId == selectedTriggerHabitId {
                for execution in list {
                    if execution.date >= startDate {
                        if let triggers = execution.triggers {
                            for t in triggers {
                                triggerCounts[t, default: 0] += 1
                            }
                        }
                    }
                }
            }
        }
        
        let sortedTriggers = triggerCounts.sorted { $0.value > $1.value }
        
        return VStack(spacing: 16) {
            if sortedTriggers.isEmpty {
                ContentUnavailableView(
                    settings.localizedString(for: "trigger.no_triggers"),
                    systemImage: "bolt.trianglebadge.exclamationmark.fill",
                    description: Text("")
                )
                .padding(.top, 40)
            } else {
                ForEach(sortedTriggers, id: \\.key) { item in
                    HStack {
                        Text(item.key)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(.primary)
                        Spacer()
                        Text("\\(item.value)x")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
        }
    }
"""

if "private var triggersContent: some View {" not in content:
    # insert before "struct SharePreviewSheet: View {"
    content = content.replace("struct SharePreviewSheet: View {", triggers_content_code + "\n\nstruct SharePreviewSheet: View {")

with open(file_path_profil, "w", encoding="utf-8") as f:
    f.write(content)

print("Done")
