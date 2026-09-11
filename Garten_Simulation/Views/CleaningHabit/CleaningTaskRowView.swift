import SwiftUI

struct CleaningTaskRowView: View {
    @ObservedObject var manager: CleaningManager
    var task: CleaningTask
    var isFuture: Bool = false // Wenn true, kein Swipe möglich
    
    @State private var swipeOffset: CGFloat = 0
    @State private var isDragging = false
    @State private var didComplete = false
    
    private let swipeThreshold: CGFloat = 80
    
    var taskColor: Color { AppColors.color(for: task.colorHex) }
    var taskColorDark: Color { taskColor.darker(by: 0.15) }
    
    var body: some View {
        let lastCompleted = manager.lastCompletedDate(for: task.id)
        let isOverdue = task.isOverdue(lastCompleted: lastCompleted)
        let due = task.dueDate(lastCompleted: lastCompleted)
        let daysUntilDue = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: due)).day ?? 0
        
        ZStack {
            // Green background revealed on swipe
            if !isFuture {
                HStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.green)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.leading, 24),
                            alignment: .leading
                        )
                }
                .opacity(min(swipeOffset / swipeThreshold, 1.0))
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: swipeOffset)
            }
            
            // Main row card
            HStack(spacing: 14) {
                // Left: colored 3D icon button
                Item3DButton(
                    farbe: taskColor,
                    sekundaerFarbe: taskColorDark,
                    groesse: 52,
                    aktion: nil
                ) {
                    Image(systemName: task.iconName)
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
                .allowsHitTesting(false)
                
                // Middle: Name
                VStack(alignment: .leading, spacing: 2) {
                    Text(task.nameKey)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Right: Status
                VStack(alignment: .trailing, spacing: 3) {
                    if isFuture {
                        Text(String(localized: "cleaning.status.dueIn", defaultValue: "Fällig in %@ Tagen", table: nil).replacingOccurrences(of: "%@", with: "\(daysUntilDue)"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else if isOverdue {
                        Text(String(localized: "cleaning.status.urgent", defaultValue: "Termin verpasst!"))
                            .font(.caption)
                            .bold()
                            .foregroundColor(.red)
                    } else {
                        Text(String(localized: "cleaning.status.today", defaultValue: "Heute fällig"))
                            .font(.caption)
                            .bold()
                            .foregroundColor(.orange)
                    }
                    Text(due, format: .dateTime.day().month())
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(UIColor.systemBackground))
                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.black.opacity(0.12), lineWidth: 1))
            )
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(UIColor.systemGray5))
                    .offset(y: 4)
            )
            .padding(.bottom, 4)
            .offset(x: isFuture ? 0 : swipeOffset)
            .animation(.spring(response: 0.35, dampingFraction: 0.75), value: swipeOffset)
        }
        .gesture(
            isFuture ? nil : DragGesture(minimumDistance: 20, coordinateSpace: .local)
                .onChanged { value in
                    guard value.translation.width > 0 else { return } // nur nach rechts
                    withAnimation(.interactiveSpring()) {
                        swipeOffset = min(value.translation.width, swipeThreshold * 1.3)
                    }
                }
                .onEnded { value in
                    if swipeOffset >= swipeThreshold {
                        // Complete!
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            swipeOffset = UIScreen.main.bounds.width
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            manager.completeTask(task)
                            swipeOffset = 0
                        }
                    } else {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            swipeOffset = 0
                        }
                    }
                }
        )
    }
}

#Preview {
    ZStack {
        Color.appHintergrund.ignoresSafeArea()
        VStack(spacing: 16) {
            CleaningTaskRowView(
                manager: CleaningManager.shared,
                task: CleaningTask(nameKey: "Bett abziehen", iconName: "bed.double.fill", frequencyDays: 7, colorHex: "blauPrimary")
            )
            CleaningTaskRowView(
                manager: CleaningManager.shared,
                task: CleaningTask(nameKey: "Zimmer", iconName: "squareshape.split.2x2", frequencyDays: 3, colorHex: "gruenPrimary"),
                isFuture: true
            )
        }
        .padding()
    }
}
