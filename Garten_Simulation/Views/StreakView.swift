import SwiftUI
// Note: DotLottie needs to be added as a dependency in Xcode for this to compile
import DotLottie

struct StreakView: View {
    @EnvironmentObject var streakStore: StreakStore
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Background - Clean and White
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // 1. Lottie Animation Section
                VStack(spacing: 20) {
                    DotLottieAnimation(
                        url: URL(string: "https://lottie.host/b8842b8d-669c-45fe-a8cb-92cbd20903dc/9KcW3VdzUV.lottie")!,
                        config: DotLottieConfig(autoplay: true, loop: true)
                    ).view()
                    .frame(width: 200, height: 200)
                    .shadow(color: .pink.opacity(0.15), radius: 30)
                    
                    VStack(spacing: 0) {
                        Text("\(streakStore.currentStreak)")
                            .font(.system(size: 80, weight: .heavy, design: .rounded))
                            .foregroundStyle(.pink)
                        
                        Text("days streak")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(.pink)
                    }
                }
                
                // 2. Weekly Progress Section (Liquid Glass)
                VStack(spacing: 24) {
                    weeklyProgressRow
                    
                    Text("you're on fire! 🔥 – time to open your gift and to celebrate 🎉")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .padding(.vertical, 32)
                .frame(maxWidth: .infinity)
                .liquidGlass(opacity: 0.05) // Subtle glass backdrop
                .padding(.horizontal, 24)
                
                Spacer()
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
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    // MARK: - Weekly Progress Views
    private var weeklyProgressRow: some View {
        HStack(spacing: 12) {
            let weekdays = ["M", "T", "W", "T", "F", "S", "S"]
            ForEach(0..<7, id: \.self) { index in
                VStack(spacing: 8) {
                    Text(weekdays[index])
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.secondary)
                    
                    ZStack {
                        let isCompleted = isWeekdayCompleted(index)
                        Circle()
                            .fill(isCompleted ? Color.pink : Color.primary.opacity(0.05))
                            .frame(width: 40, height: 40)
                            .liquidGlass(opacity: isCompleted ? 0 : 0.03)
                        
                        if isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                }
            }
        }
    }
    
    // Logic to map weekdays to actual streak history from StreakStore
    private func isWeekdayCompleted(_ index: Int) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekdayOfToday = calendar.component(.weekday, from: today) // 1=Sun, 2=Mon, ..., 7=Sat
        
        // Convert to our Monday-indexed (0-6) system: Mon=0, Tue=1, ..., Sun=6
        // Swift's weekday: 1=Sun, 2=Mon, 3=Tue, 4=Wed, 5=Thu, 6=Fri, 7=Sat
        let currentDayInOurMapping = (weekdayOfToday + 5) % 7
        
        let daysToSubtract = currentDayInOurMapping - index
        guard let dateToCheck = calendar.date(byAdding: .day, value: -daysToSubtract, to: today) else { return false }
        
        return streakStore.isDateCompleted(dateToCheck)
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
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(borderColor, lineWidth: 0.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.03), radius: 10, x: 0, y: 5)
    }
}

extension View {
    func liquidGlass(opacity: Double = 0.08, borderColor: Color = .primary.opacity(0.1)) -> some View {
        self.modifier(LiquidGlassModifier(opacity: opacity, borderColor: borderColor))
    }
}

#Preview {
    NavigationStack {
        StreakView()
            .environmentObject(StreakStore())
    }
}
