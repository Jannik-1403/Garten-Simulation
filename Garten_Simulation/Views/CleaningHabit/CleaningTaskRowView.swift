import SwiftUI

struct CleaningTaskRowView: View {
    @ObservedObject var manager: CleaningManager
    var task: CleaningTask
    
    var body: some View {
        let lastCompleted = manager.lastCompletedDate(for: task.id)
        let isOverdue = task.isOverdue(lastCompleted: lastCompleted)
        let due = task.dueDate(lastCompleted: lastCompleted)
        let daysUntilDue = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: due)).day ?? 0
        
        VStack(alignment: .leading, spacing: 12) {
            // Task Name
            Text(String(localized: String.LocalizationValue(task.nameKey)))
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack {
                // Done / Reset Button
                Item3DButton(icon: "checkmark", farbe: Color.green, sekundaerFarbe: Color(UIColor.systemGreen).opacity(0.5), groesse: 36) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        manager.completeTask(task)
                    }
                }
                
                Spacer()
                
                // Status / Due Date
                VStack(alignment: .trailing, spacing: 2) {
                    if isOverdue {
                        Text(String(localized: "cleaning.status.overdue", defaultValue: "Überfällig!"))
                            .font(.caption)
                            .foregroundColor(.red)
                            .bold()
                    } else if daysUntilDue == 0 {
                        Text(String(localized: "cleaning.status.today", defaultValue: "Heute fällig"))
                            .font(.caption)
                            .foregroundColor(.orange)
                            .bold()
                    } else {
                        Text(String(localized: "cleaning.status.dueIn", defaultValue: "Fällig in %@ Tagen", table: nil).replacingOccurrences(of: "%@", with: "\(daysUntilDue)"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(due, format: .dateTime.day().month().year())
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        CleaningTaskRowView(
            manager: CleaningManager.shared,
            task: CleaningTask(nameKey: "cleaning.task.bed", iconName: "bed.double.fill", frequencyDays: 7)
        )
        .padding()
    }
}
