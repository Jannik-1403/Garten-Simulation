import SwiftUI

struct CleaningTaskRowView: View {
    @ObservedObject var manager: CleaningManager
    var task: CleaningTask
    var isFuture: Bool = false
    
    @State private var swipeOffset: CGFloat = 0
    
    private let swipeThreshold: CGFloat = 80
    
    var taskColor: Color { AppColors.color(for: task.colorHex) }
    var taskColorDark: Color { taskColor.darker(by: 0.15) }
    
    // MARK: - Swipe Gesture
    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 20, coordinateSpace: .local)
            .onChanged { value in
                guard value.translation.width > 0 else { return }
                swipeOffset = min(value.translation.width, swipeThreshold * 1.3)
            }
            .onEnded { _ in
                if swipeOffset >= swipeThreshold {
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
    }
    
    // MARK: - Row Content
    private var rowContent: some View {
        let lastCompleted = manager.lastCompletedDate(for: task.id)
        let isOverdue = task.isOverdue(lastCompleted: lastCompleted)
        let due = task.dueDate(lastCompleted: lastCompleted)
        let daysUntilDue = Calendar.current.dateComponents(
            [.day],
            from: Calendar.current.startOfDay(for: Date()),
            to: Calendar.current.startOfDay(for: due)
        ).day ?? 0
        
        return Item3DButton(
            farbe: taskColor,
            sekundaerFarbe: taskColorDark,
            groesse: 64,
            isRectangular: true,
            aktion: nil
        ) {
            HStack(spacing: 12) {
                // Left: Icon column (fixed width)
                VStack(spacing: 4) {
                    Image(systemName: task.iconName)
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                    
                    // Status UNDER the icon
                    if isFuture {
                        Text("in \(daysUntilDue)d")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    } else if isOverdue {
                        Text(String(localized: "cleaning.status.urgent.short", defaultValue: "Fällig!"))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Text(due, format: .dateTime.day().month())
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .frame(width: 48)
                
                // Right: Task name – gets all remaining space
                Text(task.nameKey)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 8)
        }
        .allowsHitTesting(isFuture ? false : true)
    }
    
    // MARK: - Body
    var body: some View {
        if isFuture {
            rowContent
                .opacity(0.6)
        } else {
            ZStack {
                // Green background revealed on swipe
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.green)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.leading, 24),
                        alignment: .leading
                    )
                    .opacity(min(swipeOffset / swipeThreshold, 1.0))
                
                rowContent
                    .offset(x: swipeOffset)
                    .animation(.interactiveSpring(), value: swipeOffset)
            }
            .gesture(swipeGesture)
        }
    }
}

#Preview {
    ZStack {
        Color.appHintergrund.ignoresSafeArea()
        VStack(spacing: 12) {
            CleaningTaskRowView(
                manager: CleaningManager.shared,
                task: CleaningTask(nameKey: "Bett abziehen und Kissen frisch beziehen", iconName: "bed.double.fill", frequencyDays: 7, colorHex: "blauPrimary")
            )
            CleaningTaskRowView(
                manager: CleaningManager.shared,
                task: CleaningTask(nameKey: "Zimmer aufräumen", iconName: "squareshape.split.2x2", frequencyDays: 3, colorHex: "gruenPrimary"),
                isFuture: true
            )
        }
        .padding(.horizontal, 24)
    }
}
