import SwiftUI
import DotLottie

struct StreakView: View {
    @EnvironmentObject var streakStore: StreakStore
    @Environment(\.dismiss) var dismiss
    
    @State private var showFullCalendar = false
    @State private var currentMonth: Date = Date()
    private let calendar = Calendar.current
    
    var body: some View {
        ZStack {
            // Background - Clean and White
            Color.white.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // 1. Lottie Animation Section
                    VStack(spacing: 16) {
                        DotLottieAnimation(
                            webURL: "https://lottie.host/b8842b8d-669c-45fe-a8cb-92cbd20903dc/9KcW3VdzUV.lottie",
                            config: .init(autoplay: true, loop: true, speed: 0.7) // Even slower as requested
                        ).view()
                        .frame(width: 200, height: 200)
                        .shadow(color: .orange.opacity(0.15), radius: 30)
                        
                        VStack(spacing: 0) {
                            Text("\(streakStore.currentStreak)")
                                .font(.system(size: 80, weight: .heavy, design: .rounded))
                                .foregroundStyle(.orange)
                            
                            Text("days streak")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundStyle(.orange)
                        }
                    }
                    .padding(.top, 40)
                    
                    // 2. Weekly & Monthly Progress Section
                    VStack(spacing: 24) {
                        // Header for Card
                        HStack {
                            Text(showFullCalendar ? monthYearString(from: currentMonth) : "Wochenübersicht")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            if showFullCalendar {
                                // Month Navigation
                                HStack(spacing: 16) {
                                    Button(action: { changeMonth(by: -1) }) {
                                        Image(systemName: "chevron.left")
                                            .font(.system(size: 14, weight: .bold))
                                    }
                                    Button(action: { changeMonth(by: 1) }) {
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .bold))
                                    }
                                }
                                .foregroundStyle(.orange)
                            }
                            
                            Button(action: { withAnimation(.spring()) { showFullCalendar.toggle() } }) {
                                HStack(spacing: 4) {
                                    Text(showFullCalendar ? "Weniger" : "Siehe mehr")
                                    Image(systemName: showFullCalendar ? "chevron.up" : "chevron.right")
                                }
                            }
                            .buttonStyle(Streak3DButtonStyle(color: .orange, isSmall: true))
                        }
                        .padding(.horizontal, 4)
                        
                        if showFullCalendar {
                            monthlyCalendarGrid
                                .transition(.asymmetric(insertion: .push(from: .bottom).combined(with: .opacity), removal: .push(from: .top).combined(with: .opacity)))
                        } else {
                            weeklyProgressRow
                                .transition(.opacity)
                        }
                    }
                    .padding(24)
                    .liquidGlass(opacity: 0.05)
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.secondary)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Streak")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    // MARK: - Weekly Progress
    private var weeklyProgressRow: some View {
        HStack(spacing: 10) {
            let weekdays = ["M", "T", "W", "T", "F", "S", "S"]
            ForEach(0..<7, id: \.self) { index in
                VStack(spacing: 12) {
                    Text(weekdays[index])
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.secondary)
                    
                    Button(action: {}) {
                        ZStack {
                            let isCompleted = isWeekdayCompleted(index)
                            if isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .frame(width: 40, height: 40)
                    }
                    .buttonStyle(Streak3DButtonStyle(color: isWeekdayCompleted(index) ? .orange : Color.primary.opacity(0.1), isCircle: true))
                    .disabled(true)
                }
            }
        }
    }
    
    // MARK: - Monthly Calendar Grid
    private var monthlyCalendarGrid: some View {
        VStack(spacing: 15) {
            // Day Labels
            HStack(spacing: 0) {
                let days = ["M", "D", "M", "D", "F", "S", "S"]
                ForEach(days, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            let days = generateDaysInMonth(for: currentMonth)
            let rows = days.chunked(into: 7)
            
            VStack(spacing: 10) {
                ForEach(rows.indices, id: \.self) { rowIndex in
                    HStack(spacing: 10) {
                        ForEach(rows[rowIndex], id: \.self) { date in
                            if let date = date {
                                let isCompleted = streakStore.isDateCompleted(date)
                                Button(action: {}) {
                                    Text("\(calendar.component(.day, from: date))")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(isCompleted ? .white : .secondary)
                                        .frame(width: 32, height: 32)
                                }
                                .buttonStyle(Streak3DButtonStyle(color: isCompleted ? .orange : Color.primary.opacity(0.05), isCircle: true))
                                .disabled(true)
                                .frame(maxWidth: .infinity)
                            } else {
                                Color.clear.frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func isWeekdayCompleted(_ index: Int) -> Bool {
        let today = calendar.startOfDay(for: Date())
        let weekdayOfToday = calendar.component(.weekday, from: today)
        let currentDayInOurMapping = (weekdayOfToday + 5) % 7
        let daysToSubtract = currentDayInOurMapping - index
        guard let dateToCheck = calendar.date(byAdding: .day, value: -daysToSubtract, to: today) else { return false }
        return streakStore.isDateCompleted(dateToCheck)
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) {
            withAnimation { currentMonth = newMonth }
        }
    }
    
    private func generateDaysInMonth(for date: Date) -> [Date?] {
        let range = calendar.range(of: .day, in: .month, for: date)!
        let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        var weekday = calendar.component(.weekday, from: firstOfMonth) - 2 // Adjust for Monday start
        if weekday < 0 { weekday = 6 }
        
        var days: [Date?] = Array(repeating: nil, count: weekday)
        for day in 1...range.count {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(date)
            }
        }
        while days.count % 7 != 0 { days.append(nil) }
        return days
    }
}

// MARK: - 3D Button Style
struct Streak3DButtonStyle: ButtonStyle {
    var color: Color
    var isSmall: Bool = false
    var isCircle: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        let shadowDepth: CGFloat = isSmall ? 2 : 4
        
        configuration.label
            .padding(.horizontal, isCircle ? 0 : (isSmall ? 12 : 20))
            .padding(.vertical, isCircle ? 0 : (isSmall ? 6 : 12))
            .background(
                Group {
                    if isCircle {
                        Circle()
                            .fill(color)
                            .shadow(color: color.darker(), radius: 0, y: pressed ? 0 : shadowDepth)
                    } else {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(color)
                            .shadow(color: color.darker(), radius: 0, y: pressed ? 0 : shadowDepth)
                    }
                }
            )
            .offset(y: pressed ? shadowDepth : 0)
            .animation(.interactiveSpring(), value: pressed)
    }
}

// MARK: - Liquid Glass UI Support
struct LiquidGlassModifier: ViewModifier {
    var opacity: Double = 0.08
    var borderColor: Color = .primary.opacity(0.1)
    
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .background(Color.white.opacity(opacity))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous) // Using 12 to match StreakButtonStyle
                    .stroke(borderColor, lineWidth: 0.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(color: .black.opacity(0.03), radius: 10, x: 0, y: 5)
    }
}

extension View {
    func liquidGlass(opacity: Double = 0.08, borderColor: Color = .primary.opacity(0.1)) -> some View {
        self.modifier(LiquidGlassModifier(opacity: opacity, borderColor: borderColor))
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

#Preview {
    NavigationStack {
        StreakView()
            .environmentObject(StreakStore())
    }
}
