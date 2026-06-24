import re

file_path = "Garten_Simulation/Views/Profile/ProfilComponents.swift"
with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

# 1. Update StatDetail enum
content = content.replace("case activity, balance, xp, coins, milestones, focus", "case activity, balance, xp, coins, milestones, focus, triggers")

# 2. Update ShareCardType enum
content = content.replace("case coins\n        case focus", "case coins\n        case focus\n        case triggers")

# 3. Update triggerStatisticsCard to add Share and Expand buttons
old_trigger_header = """            HStack {
                Label("Häufigste Auslöser", systemImage: "bolt.trianglebadge.exclamationmark.fill")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.red)
                Spacer()
            }"""
new_trigger_header = """            HStack {
                Label(settings.localizedString(for: "trigger.title"), systemImage: "bolt.trianglebadge.exclamationmark.fill")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.red)
                Spacer()
                
                HStack(spacing: 8) {
                    Button(action: { initiateShare(.triggers) }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.black)
                            .padding(8)
                    }
                    
                    Button {
                        expandedStat = .triggers
                    } label: {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.black)
                            .padding(8)
                    }
                }
            }"""
content = content.replace(old_trigger_header, new_trigger_header)

# 4. Add selectedTriggerHabitId to StatDetailFullscreenView
state_pattern = r'(@State private var pendingShareType: StatisticsDashboard\.ShareCardType\? = nil)'
state_replacement = r'\1\n    @State private var selectedTriggerHabitId: String = "all"'
content = re.sub(state_pattern, state_replacement, content, count=1)

# 5. Modify Picker in StatDetailFullscreenView
old_picker = """                    Picker("", selection: $selectedPeriod) {
                        ForEach(StatsPeriod.allCases, id: \.self) { period in
                            Text(settings.localizedString(for: period.localizationKey))
                                .tag(period)
                        }
                    }
                    .pickerStyle(.segmented)"""
new_picker = """                    if detail == .triggers {
                        Picker("", selection: $selectedTriggerHabitId) {
                            Text(settings.localizedString(for: "trigger.all_habits")).tag("all")
                            ForEach(gardenStore.pflanzen, id: \.id) { habit in
                                Text(settings.localizedString(for: habit.name)).tag(habit.id)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(.horizontal, 16)
                    } else {
                        Picker("", selection: $selectedPeriod) {
                            ForEach(StatsPeriod.allCases, id: \.self) { period in
                                Text(settings.localizedString(for: period.localizationKey))
                                    .tag(period)
                            }
                        }
                        .pickerStyle(.segmented)
                    }"""
content = content.replace(old_picker, new_picker, 1)

# 6. Update initiateShare inside StatDetailFullscreenView
old_initiate = "case .focus: pendingShareType = .focus"
new_initiate = "case .focus: pendingShareType = .focus\n        case .triggers: pendingShareType = .triggers"
content = content.replace(old_initiate, new_initiate, 1)

# 7. Update content ViewBuilder switch
old_content_switch = """            case .focus:
                focusContent"""
new_content_switch = """            case .focus:
                focusContent
            case .triggers:
                triggersContent"""
content = content.replace(old_content_switch, new_content_switch, 1)

# 8. Update title switch
old_title_switch = """        case .focus: return settings.localizedString(for: "Fokus-Score")"""
new_title_switch = """        case .focus: return settings.localizedString(for: "Fokus-Score")
        case .triggers: return settings.localizedString(for: "trigger.title")"""
content = content.replace(old_title_switch, new_title_switch, 1)

# 9. Add triggersContent variable
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
                ForEach(sortedTriggers, id: \.key) { item in
                    HStack {
                        Text(item.key)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(.primary)
                        Spacer()
                        Text("\(item.value)x")
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

# Insert right after focusContent
focus_content_end = """                        }
                        .frame(height: 150)
                    }
                    .padding(20)
                    .background(Color(UIColor.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
        }
    }"""
content = content.replace(focus_content_end, focus_content_end + "\n" + triggers_content_code, 1)

# 10. Add .triggers to previewCard inside SharePreviewSheet
trigger_share_card = """            case .triggers:
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
                let sortedTriggers = triggerCounts.sorted { $0.value > $1.value }
                
                StatShareImage(
                    title: settings.localizedString(for: "trigger.title"),
                    subtitle: periodLabel,
                    username: username,
                    height: 520,
                    theme: theme,
                    vibrantColor: .red
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        if sortedTriggers.isEmpty {
                            Text(settings.localizedString(for: "trigger.no_triggers"))
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(theme == .vibrant ? .white.opacity(0.8) : .secondary)
                        } else {
                            ForEach(sortedTriggers.prefix(5), id: \.key) { item in
                                HStack {
                                    Text(item.key)
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundStyle(theme == .vibrant ? .white : .primary)
                                    Spacer()
                                    Text("\(item.value)x")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundStyle(theme == .vibrant ? .white.opacity(0.8) : .secondary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(theme == .vibrant ? Color.white.opacity(0.2) : Color.secondary.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                        }
                    }
                    .padding(16)
                }
"""

old_preview_case_focus = """            case .focus:
                let history = StatsHelper.getFocusHistory(from: gardenStore.focusSessions, days: period.days)"""
content = content.replace(old_preview_case_focus, trigger_share_card + "\n" + old_preview_case_focus, 1)

# 11. Add .triggers to renderView inside SharePreviewSheet
old_render_case_focus = """            case .focus:
                let history = StatsHelper.getFocusHistory(from: gardenStore.focusSessions, days: period.days)"""
# Replace the second occurrence of `case .focus`
focus_occurrences = content.split(old_render_case_focus)
if len(focus_occurrences) >= 3:
    content = focus_occurrences[0] + old_render_case_focus + focus_occurrences[1] + trigger_share_card + "\n" + old_render_case_focus + focus_occurrences[2]

with open(file_path, "w", encoding="utf-8") as f:
    f.write(content)

print("Applied ProfilComponents updates successfully.")
