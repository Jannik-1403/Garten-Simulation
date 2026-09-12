import SwiftUI

struct CleaningTaskRowView: View {
    @ObservedObject var manager: CleaningManager
    var task: CleaningTask
    var isFuture: Bool = false
    
    // Slider-to-Complete (identisch zu PflanzenCard)
    @State private var dragWidth: CGFloat = 0.0
    @State private var isDragging: Bool = false
    @State private var cardWidth: CGFloat = 300
    
    var taskColor: Color { AppColors.color(for: task.colorHex) }
    var taskColorDark: Color { taskColor.darker(by: 0.15) }
    
    private var maxDragWidth: CGFloat { max(50, cardWidth - 80) }
    
    private var dragProgress: CGFloat {
        isDragging ? min(1.0, max(0.0, dragWidth / maxDragWidth)) : 0.0
    }
    
    var body: some View {
        let lastCompleted = manager.lastCompletedDate(for: task.id)
        let isOverdue = task.isOverdue(lastCompleted: lastCompleted)  // strictly > today
        let due = task.dueDate(lastCompleted: lastCompleted)
        let today = Calendar.current.startOfDay(for: Date())
        let daysUntilDue = Calendar.current.dateComponents(
            [.day],
            from: today,
            to: Calendar.current.startOfDay(for: due)
        ).day ?? 0
        
        let cardContent = HStack(spacing: 16) {
            // Left: colored 3D icon button
            Item3DButton(
                farbe: taskColor,
                sekundaerFarbe: taskColorDark,
                groesse: 56,
                aktion: nil
            ) {
                Image(systemName: task.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
            .allowsHitTesting(false)
            
            // Right: Name + status
            VStack(alignment: .leading, spacing: 4) {
                Text(task.nameKey)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Group {
                    if isOverdue {
                        // Strictly past (yesterday or earlier)
                        Text(String(localized: "cleaning.status.urgent", defaultValue: "Termin verpasst!"))
                            .foregroundColor(.red)
                    } else if daysUntilDue == 0 {
                        // Today
                        Text(String(localized: "cleaning.status.today", defaultValue: "Heute fällig"))
                            .foregroundColor(.orange)
                    } else {
                        // Future
                        Text(due, format: .dateTime.weekday(.short).day().month())
                            .foregroundColor(.secondary)
                    }
                }
                .font(.system(size: 12, weight: .bold, design: .rounded))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 14)
        .background(
            GeometryReader { proxy in
                Color.clear
                    .onAppear { cardWidth = proxy.size.width }
                    .onChange(of: proxy.size.width) { _, new in cardWidth = new }
            }
        )
        
        // All tasks (due & future) use the same style and can be completed
        Button { } label: { cardContent }
            .buttonStyle(CleaningCardButtonStyle(progress: dragProgress))
            .highPriorityGesture(
                DragGesture(minimumDistance: 20)
                    .onChanged { value in
                        guard value.translation.width > 0 else { return }
                        if !isDragging { isDragging = true }
                        dragWidth = value.translation.width
                    }
                    .onEnded { _ in
                        isDragging = false
                        let finalProgress = min(1.0, max(0.0, dragWidth / maxDragWidth))
                        if finalProgress >= 1.0 {
                            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                            withAnimation(.easeOut(duration: 0.2)) { dragWidth = 0 }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                manager.completeTask(task)
                            }
                        } else {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                dragWidth = 0
                            }
                        }
                    }
            )
    }
}

// MARK: - Button Style (same as PflanzenCardHorizontalButtonStyle)
struct CleaningCardButtonStyle: ButtonStyle {
    var progress: CGFloat = 0
    
    private let depth: CGFloat = 5
    private let cornerRadius: CGFloat = 20
    
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color(white: 0.7))
                .padding(.horizontal, 1)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 80)
            
            configuration.label
                .frame(maxWidth: .infinity)
                .frame(minHeight: 80)
                .background(
                    GeometryReader { proxy in
                        ZStack(alignment: .leading) {
                            Color.white
                            if progress > 0 {
                                Color.gruenPrimary.opacity(0.3)
                                    .frame(width: proxy.size.width * progress)
                            }
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.black.opacity(0.12), lineWidth: 1.2)
                )
                .offset(y: isPressed ? 0 : -depth)
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.22, dampingFraction: 0.5), value: isPressed)
    }
}

#Preview {
    ZStack {
        Color.appHintergrund.ignoresSafeArea()
        VStack(spacing: 12) {
            CleaningTaskRowView(
                manager: CleaningManager.shared,
                task: CleaningTask(nameKey: "Bett abziehen", iconName: "bed.double.fill", frequencyDays: 7, colorHex: "blauPrimary")
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
