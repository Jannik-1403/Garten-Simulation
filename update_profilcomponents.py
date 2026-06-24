import re

file_path = "Garten_Simulation/Views/Profile/ProfilComponents.swift"
with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

# 1. Add selectedTriggerHabitId to StatDetailFullscreenView
state_pattern = r'(@State private var pendingShareType: StatisticsDashboard\.ShareCardType\? = nil)'
state_replacement = r'\1\n    @State private var selectedTriggerHabitId: String = "all"'
content = re.sub(state_pattern, state_replacement, content)

# 2. Add triggersContent variable
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

# Find where to insert triggersContent (after focusContent)
# Need to find focusContent and append after it. Let's just append right before "// MARK: - SharePreviewSheet" or at the end of StatDetailFullscreenView
end_of_stat_detail_pattern = r'(    // MARK: - Helper Methods\n\s*private func getBarHeight)'
# Wait, let's just insert it before `private func themeNameKey` ? No, `themeNameKey` is in `SharePreviewSheet`.
# Where is `focusContent`? Let's check.
