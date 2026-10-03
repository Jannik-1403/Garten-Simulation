import SwiftUI

enum CleaningTaskRowMode {
    case today(isDone: Bool)
    case upcoming(nextDate: Date)
}

struct CleaningTaskRowView: View {
    let task: CleaningTask
    let mode: CleaningTaskRowMode
    let onTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var taskColor: Color { AppColors.color(for: task.colorKey) }
    var taskColorDark: Color { taskColor.darker(by: 0.15) }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon Button
                Item3DButton(
                    farbe: isCompleted ? Color(UIColor.systemGray5) : taskColor,
                    sekundaerFarbe: isCompleted ? Color(UIColor.systemGray4) : taskColorDark,
                    groesse: 56,
                    aktion: onTap
                ) {
                    Image(systemName: isCompleted ? "checkmark" : task.iconName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(isCompleted ? Color.secondary : Color.white)
                }
                .accessibilityHidden(true)

                // Text Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.name)
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(isCompleted ? .secondary : .primary)
                        .strikethrough(isCompleted)
                        .lineLimit(2)
                    
                    switch mode {
                    case .today(let isDone):
                        if isDone {
                            Text(String(localized: "cleaning.status.done", defaultValue: "Erledigt"))
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                        } else {
                            Text(String(localized: "cleaning.status.due", defaultValue: "Heute fällig"))
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)
                        }
                    case .upcoming(let nextDate):
                        Text(nextDate, format: .dateTime.weekday(.wide).day().month())
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
        }
        .buttonStyle(.plain)
        .opacity(isCompleted ? 0.6 : 1.0)
        .contextMenu {
            Button {
                onEdit()
            } label: {
                Label(String(localized: "button.edit", defaultValue: "Bearbeiten"), systemImage: "pencil")
            }
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label(String(localized: "button.delete", defaultValue: "Löschen"), systemImage: "trash")
            }
        }
    }

    private var isCompleted: Bool {
        if case .today(let isDone) = mode {
            return isDone
        }
        return false
    }
}
