import SwiftUI

struct RadarChartView: View {
    let habits: [HabitModel]
    let selectedPeriod: StatsPeriod
    
    @EnvironmentObject var settings: SettingsStore
    
    @State private var selectedCategory: HabitCategory? = nil
    
    private let size: CGFloat = 280
    private let gridLevels = 6
    
    private var categories: [HabitCategory] {
        HabitCategory.allCases
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background tap to close popup
            if selectedCategory != nil {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3)) {
                            selectedCategory = nil
                        }
                    }
                    .zIndex(5)
            }
            
            VStack(spacing: 20) {
                ZStack {
                    let center = CGPoint(x: size / 2, y: size / 2)
                    let radius = size * 0.4
                    
                    // 1. Hexagonal Grid
                    radarGrid(center: center, radius: radius)
                    
                    // 2. Axes
                    radarAxes(center: center, radius: radius)
                    
                    // 3. Previous Period Data (Gray)
                    let prevValues = calculateValues(forPreviousPeriod: true)
                    RadarPolygonShape(categories: categories, values: prevValues, radius: radius, center: center)
                        .fill(Color.gray.opacity(0.2))
                    RadarPolygonShape(categories: categories, values: prevValues, radius: radius, center: center)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1.5)
                    
                    // 4. Current Period Data (Blue)
                    let currentValues = calculateValues(forPreviousPeriod: false)
                    RadarPolygonShape(categories: categories, values: currentValues, radius: radius, center: center)
                        .fill(Color.blauPrimary.opacity(0.35))
                    RadarPolygonShape(categories: categories, values: currentValues, radius: radius, center: center)
                        .stroke(Color.blauPrimary, lineWidth: 2)
                    
                    // 5. Category Icons
                    radarIcons(center: center, radius: radius)
                }
                .frame(width: size, height: size)
                .padding(.top, 40) // Give space for the fixed popup
                
                // 6. Legend
                HStack(spacing: 20) {
                    legendItem(label: NSLocalizedString("statistik_legend_aktuell", comment: ""), color: .blauPrimary)
                    legendItem(label: NSLocalizedString("statistik_legend_vorherig", comment: ""), color: .gray)
                }
            }
            
            // 7. Category Popup (Fixed at top)
            if let selected = selectedCategory {
                categoryPopup(for: selected)
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
                    .padding(.top, -10)
                    .zIndex(100)
            }
        }
    }
    
    // MARK: - Components
    
    @ViewBuilder
    private func categoryPopup(for category: HabitCategory) -> some View {
        let stats = getStats(for: category)
        
        VStack(spacing: 6) {
            Text(settings.localizedString(for: category.localizationKey))
                .font(.system(size: 15, weight: .bold, design: .rounded))
            
            Divider()
            
            Text("\(Int((stats.percentage * 100).rounded()))%")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(Color.blauPrimary)
            
            Text(NSLocalizedString("statistik_popup_erreicht", comment: "").uppercased())
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
            
            Divider()
            
            HStack {
                Label("\(stats.habitsCount) \(NSLocalizedString("statistik_popup_gewohnheiten", comment: ""))", systemImage: "leaf.fill")
                Spacer()
                Label("\(stats.waterings) \(NSLocalizedString("statistik_popup_giessungen", comment: ""))", systemImage: "drop.fill")
            }
            .font(.system(size: 10, weight: .medium, design: .rounded))
            .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(width: 180)
        .background(.regularMaterial)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.15), radius: 8)
    }
    
    @ViewBuilder
    private func radarGrid(center: CGPoint, radius: CGFloat) -> some View {
        let gridValues: [CGFloat] = [0.2, 0.4, 0.6, 0.8, 1.0]
        ForEach(gridValues, id: \.self) { value in
            let r = radius * value
            radarPath(radius: r, center: center)
                .stroke(Color.gray.opacity(0.15), lineWidth: 0.5)
        }
    }
    
    @ViewBuilder
    private func radarAxes(center: CGPoint, radius: CGFloat) -> some View {
        ForEach(0..<categories.count, id: \.self) { i in
            let angle = CGFloat(i) * (2 * .pi / CGFloat(categories.count)) - .pi / 2
            let endPoint = CGPoint(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            )
            Path { path in
                path.move(to: center)
                path.addLine(to: endPoint)
            }
            .stroke(Color.gray.opacity(0.15), lineWidth: 0.5)
        }
    }
    
    @ViewBuilder
    private func radarIcons(center: CGPoint, radius: CGFloat) -> some View {
        ForEach(0..<categories.count, id: \.self) { i in
            let category = categories[i]
            let angle = CGFloat(i) * (2 * .pi / CGFloat(categories.count)) - .pi / 2
            let iconRadius = radius * 1.25
            let point = CGPoint(
                x: center.x + iconRadius * cos(angle),
                y: center.y + iconRadius * sin(angle)
            )
            
            Item3DButton(
                farbe: category.color,
                sekundaerFarbe: category.color.opacity(0.7), // Using opacity as a proxy for darker() if not available
                groesse: 36,
                aktion: {
                    withAnimation(.spring(response: 0.3)) {
                        if selectedCategory == category {
                            selectedCategory = nil
                        } else {
                            selectedCategory = category
                        }
                    }
                }
            ) {
                Image(systemName: category.icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
            }
            .position(point)
        }
    }
    
    private func legendItem(label: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Helper Methods
    
    private func getStats(for category: HabitCategory) -> (percentage: Double, habitsCount: Int, waterings: Int) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let days = selectedPeriod.days
        let startDate = calendar.date(byAdding: .day, value: -days, to: today)!
        
        let catHabits = habits.filter { $0.habitCategory == category }
        let habitsCount = catHabits.count
        let totalWaterings = catHabits.reduce(0) { $0 + $1.wateringDates.filter { $0 >= startDate && $0 < today }.count }
        
        let maxPossible = Double(max(1, habitsCount * days))
        let percentage = Double(totalWaterings) / maxPossible
        
        return (min(1.0, percentage), habitsCount, totalWaterings)
    }
    
    private func calculateValues(forPreviousPeriod: Bool) -> [HabitCategory: Double] {
        var results: [HabitCategory: Double] = [:]
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let days = selectedPeriod.days
        let startDate: Date
        let endDate: Date
        
        if forPreviousPeriod {
            startDate = calendar.date(byAdding: .day, value: -days * 2, to: today)!
            endDate = calendar.date(byAdding: .day, value: -days, to: today)!
        } else {
            startDate = calendar.date(byAdding: .day, value: -days, to: today)!
            endDate = today
        }
        
        for category in categories {
            let catHabits = habits.filter { $0.habitCategory == category }
            if catHabits.isEmpty {
                results[category] = 0.0
                continue
            }
            
            let totalWaterings = catHabits.reduce(0) { $0 + $1.wateringDates.filter { $0 >= startDate && $0 < endDate }.count }
            let maxWaterings = Double(catHabits.count * days)
            results[category] = min(1.0, Double(totalWaterings) / maxWaterings)
        }
        
        return results
    }
    
    private func radarPath(radius: CGFloat, center: CGPoint) -> Path {
        var path = Path()
        for index in 0..<categories.count {
            let angle = CGFloat(index) * (2 * .pi / CGFloat(categories.count)) - .pi / 2
            let point = CGPoint(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            )
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}

struct RadarPolygonShape: Shape {
    let categories: [HabitCategory]
    let values: [HabitCategory: Double]
    let radius: CGFloat
    let center: CGPoint
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let count = categories.count
        guard count > 0 else { return path }
        
        for i in 0..<count {
            let category = categories[i]
            let value = values[category] ?? 0
            let angle = CGFloat(i) * (2 * .pi / CGFloat(count)) - .pi / 2
            let point = CGPoint(
                x: center.x + cos(angle) * radius * CGFloat(value),
                y: center.y + sin(angle) * radius * CGFloat(value)
            )
            
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}

struct RadarChartShareImage: View {
    let habits: [HabitModel]
    let selectedPeriod: StatsPeriod
    let username: String
    let theme: ShareImageTheme
    var vibrantColor: Color = .blauPrimary
    
    @EnvironmentObject var settings: SettingsStore

    var body: some View {
        StatShareImage(
            title: settings.localizedString(for: "statistik_life_balance"),
            subtitle: periodLabel,
            username: username,
            height: 620,
            theme: theme,
            vibrantColor: vibrantColor
        ) {
            RadarChartView(habits: habits, selectedPeriod: selectedPeriod)
                .frame(width: 320, height: 320)
                .padding(20)
                .frame(maxWidth: .infinity)
        }
    }

    private var periodLabel: String {
        switch selectedPeriod {
        case .week:   return settings.localizedString(for: "statistik_share_letzte_woche")
        case .month:  return settings.localizedString(for: "statistik_share_letzter_monat")
        case .year:   return settings.localizedString(for: "statistik_share_letztes_jahr")
        }
    }
}
