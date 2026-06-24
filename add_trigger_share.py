import re

file_path = "Garten_Simulation/Views/Profile/ProfilComponents.swift"
with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

trigger_case = """            case .triggers:
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
                            ForEach(sortedTriggers.prefix(5), id: \\.key) { item in
                                HStack {
                                    Text(item.key)
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundStyle(theme == .vibrant ? .white : .primary)
                                    Spacer()
                                    Text("\\(item.value)x")
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

pattern = r'(                        \.frame\(height: 120\)\n                    }\n                    \.padding\(16\)\n                })'

# Insert case .triggers before `} // end of switch`
content = re.sub(pattern, r'\1\n' + trigger_case, content)

with open(file_path, "w", encoding="utf-8") as f:
    f.write(content)

print("Updated ProfilComponents.swift")
