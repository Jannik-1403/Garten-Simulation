import SwiftUI

struct CleaningTaskRowView: View {
    @ObservedObject var manager: CleaningManager
    var task: CleaningTask
    
    var body: some View {
        let lastCompleted = manager.lastCompletedDate(for: task.id)
        let isOverdue = task.isOverdue(lastCompleted: lastCompleted)
        let due = task.dueDate(lastCompleted: lastCompleted)
        let daysUntilDue = Calendar.current.dateComponents([.day], from: Date(), to: due).day ?? 0
        
        HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isOverdue ? Color.red.opacity(0.2) : Color.green.opacity(0.2))
                    .frame(width: 56, height: 56)
                
                Image(systemName: task.iconName)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(isOverdue ? .red : .green)
                    .shadow(color: isOverdue ? .red.opacity(0.5) : .green.opacity(0.5), radius: 5, x: 0, y: 3)
            }
            
            // Text Info
            VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: String.LocalizationValue(task.nameKey)))
                    .font(.headline)
                    .foregroundColor(.white)
                
                if isOverdue {
                    Text(String(localized: "cleaning.status.overdue", defaultValue: "Überfällig!"))
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .bold()
                } else {
                    if daysUntilDue == 0 {
                        Text(String(localized: "cleaning.status.today", defaultValue: "Heute fällig"))
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    } else {
                        Text(String(localized: "cleaning.status.dueIn", defaultValue: "Fällig in %@ Tagen", table: nil).replacingOccurrences(of: "%@", with: "\(daysUntilDue)"))
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            
            Spacer()
            
            // Checkmark / Complete Button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    manager.completeTask(task)
                }
            }) {
                ZStack {
                    Circle()
                        .fill(isOverdue ? Color.red : Color.green)
                        .frame(width: 44, height: 44)
                        .shadow(color: (isOverdue ? Color.red : Color.green).opacity(0.4), radius: 5, x: 0, y: 3)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
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
