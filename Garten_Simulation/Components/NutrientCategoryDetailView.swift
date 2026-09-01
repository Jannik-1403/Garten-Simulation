import SwiftUI

struct NutrientCategoryDetailView: View {
    let categoryName: String
    @ObservedObject var manager: NutrientIndexManager
    @State private var showSettings = false
    @State private var selectedHistoryIndex: Int = 6 // Index of today in the history array (7 days ago to today)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Segmented Donut Chart
                SegmentedRingChart(categoryName: categoryName, items: activeItems)
                    .frame(height: 240)
                    .padding(.top, 24)
                    .padding(.bottom, 16)
                    
                if !activeItems.isEmpty {
                    NutrientHistoryChart(
                        manager: manager, 
                        categoryName: categoryName,
                        selectedIndex: $selectedHistoryIndex
                    )
                    .padding(.horizontal, 24)
                }
                Button(action: {
                    manager.injectTestData(for: categoryName)
                }) {
                    Text("Testdaten generieren")
                        .font(.subheadline)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationTitle(categoryName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showSettings = true
                }) {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            NavigationView {
                List {
                    if categoryName == "Vitamine" {
                        ForEach($manager.vitamins) { $item in
                            NutrientEditRow(item: $item) { manager.saveSettings() }
                        }
                    } else if categoryName == "Mineralstoffe" {
                        ForEach($manager.minerals) { $item in
                            NutrientEditRow(item: $item) { manager.saveSettings() }
                        }
                    } else if categoryName == "Ballaststoffe" {
                        NutrientEditRow(item: $manager.fiber) { manager.saveSettings() }
                    }
                }
                .navigationTitle(String(localized: "nutrient.settings", defaultValue: "Einstellungen"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(String(localized: "common.done", defaultValue: "Fertig")) {
                            showSettings = false
                        }
                    }
                }
            }
        }
    }
    
    private var activeItems: [NutrientItem] {
        var items: [NutrientItem] = []
        switch categoryName {
        case "Vitamine": items = manager.vitamins.filter { $0.isEnabled }
        case "Mineralstoffe": items = manager.minerals.filter { $0.isEnabled }
        case "Ballaststoffe": items = manager.fiber.isEnabled ? [manager.fiber] : []
        default: break
        }
        
        // Mock historical data interaction
        if selectedHistoryIndex != 6 {
            let daysAgo = 6 - selectedHistoryIndex
            items = items.map { item in
                var modified = item
                let variation = Double(daysAgo * 7 % 30) - 15.0 // Fake variation
                modified.currentValue = max(0, item.currentValue * (1.0 + variation / 100.0))
                return modified
            }
        }
        
        return items
    }
    
    private func getColor(for index: Int, total: Int) -> Color {
        if categoryName == "Vitamine" {
            // Blue shades
            let hue = 0.55 + (Double(index) * 0.05)
            return Color(hue: hue, saturation: 0.8, brightness: 0.9)
        } else if categoryName == "Mineralstoffe" {
            // Green shades
            let hue = 0.25 + (Double(index) * 0.05)
            return Color(hue: hue, saturation: 0.8, brightness: 0.8)
        } else {
            // Fiber
            return Color(red: 0.98, green: 0.5, blue: 0.4)
        }
    }
}

struct SegmentedRingChart: View {
    let categoryName: String
    let items: [NutrientItem]
    
    var body: some View {
        ZStack {
            if items.isEmpty {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 30)
                Text(String(localized: "nutrient.no_data", defaultValue: "Keine Daten"))
                    .font(.headline)
                    .foregroundColor(.secondary)
            } else {
                let segmentAngle = 360.0 / Double(items.count)
                let gapAngle = items.count > 1 ? 16.0 : 0.0
                
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    let startDegrees = Double(index) * segmentAngle + (gapAngle / 2)
                    let endDegrees = Double(index + 1) * segmentAngle - (gapAngle / 2)
                    let color = getColor(for: index, total: items.count)
                    
                    let maxLineWidth: CGFloat = 30
                    let fillRatio = max(min(item.score / 100.0, 1.0), 0.01)
                    let filledDegrees = startDegrees + ((endDegrees - startDegrees) * fillRatio)
                    
                    // Background Arc (full width, very transparent)
                    SegmentArc(startAngle: .degrees(startDegrees), endAngle: .degrees(endDegrees))
                        .stroke(color.opacity(0.2), style: StrokeStyle(lineWidth: maxLineWidth, lineCap: .round))
                    
                    // Filled Arc (grows circumferentially)
                    SegmentArc(startAngle: .degrees(startDegrees), endAngle: .degrees(filledDegrees))
                        .stroke(color, style: StrokeStyle(lineWidth: maxLineWidth, lineCap: .round))
                }
                
                // Average Score in center
                VStack {
                    Text("\(Int(averageScore))")
                        .font(.system(size: 48, weight: .bold))
                }
            }
        }
        .padding(16) // Room for stroke
    }
    
    private var averageScore: Double {
        guard !items.isEmpty else { return 0 }
        return items.reduce(0.0) { $0 + $1.score } / Double(items.count)
    }
    
    private func getColor(for index: Int, total: Int) -> Color {
        if categoryName == "Vitamine" {
            let hue = 0.55 + (Double(index) * 0.05)
            return Color(hue: hue, saturation: 0.8, brightness: 0.9)
        } else if categoryName == "Mineralstoffe" {
            let hue = 0.25 + (Double(index) * 0.05)
            return Color(hue: hue, saturation: 0.8, brightness: 0.8)
        } else {
            return Color(red: 0.98, green: 0.5, blue: 0.4)
        }
    }
}

struct SegmentArc: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var radiusOffset: CGFloat = 0
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = (min(rect.width, rect.height) / 2) + radiusOffset
        path.addArc(center: center, radius: radius, startAngle: startAngle - .degrees(90), endAngle: endAngle - .degrees(90), clockwise: false)
        return path
    }
}

struct NutrientEditRow: View {
    @Binding var item: NutrientItem
    var onSave: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Toggle(isOn: Binding(
                get: { item.isEnabled },
                set: { newValue in
                    item.isEnabled = newValue
                    onSave()
                }
            )) {
                HStack {
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                            .frame(width: 30, height: 30)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(item.score / 100.0))
                            .stroke(Color.blue, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .frame(width: 30, height: 30)
                            .rotationEffect(.degrees(-90))
                    }
                    Text(item.name).bold()
                }
            }
            
            if item.isEnabled {
                HStack {
                    Text(String(localized: "nutrient.target", defaultValue: "Tagesziel:"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    TextField("Ziel", value: Binding(
                        get: { item.targetDGE },
                        set: { newValue in
                            item.targetDGE = max(newValue, 0.1)
                            onSave()
                        }
                    ), format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                        .padding(4)
                        .background(Color(.tertiarySystemFill))
                        .cornerRadius(6)
                    Text(item.unitString)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct NutrientHistoryChart: View {
    @ObservedObject var manager: NutrientIndexManager
    let categoryName: String
    @Binding var selectedIndex: Int
    @State private var timeRange: Int = 0 // 0: Woche, 1: Monat, 2: Jahr
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Picker("Zeitraum", selection: $timeRange) {
                Text(String(localized: "time.week", defaultValue: "Woche")).tag(0)
                Text(String(localized: "time.month", defaultValue: "Monat")).tag(1)
                Text(String(localized: "time.year", defaultValue: "Jahr")).tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .onChange(of: timeRange) { _ in
                selectedIndex = itemCount - 1
            }
            
            HStack(alignment: .bottom, spacing: barSpacing) {
                ForEach(0..<itemCount, id: \.self) { i in
                    let isSelected = i == selectedIndex
                    let dayScore = (i == itemCount - 1) ? getCurrentScore() : getMockScore(forDaysAgo: (itemCount - 1) - i)
                    
                    VStack(spacing: 8) {
                        GeometryReader { geometry in
                            VStack {
                                Spacer()
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(isSelected ? getCategoryColor() : Color(UIColor.systemGray4))
                                    .frame(height: max(geometry.size.height * CGFloat(dayScore / 100.0), 4))
                            }
                        }
                        .frame(height: 100)
                        
                        if shouldShowLabel(for: i) {
                            Text(getLabel(index: i))
                                .font(.system(size: 8))
                                .foregroundColor(isSelected ? .primary : .secondary)
                                .bold(isSelected)
                                .lineLimit(1)
                        } else {
                            Text(" ")
                                .font(.system(size: 8))
                        }
                    }
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedIndex = i
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
    }
    
    private var itemCount: Int {
        switch timeRange {
        case 0: return 7
        case 1: return 30
        case 2: return 12
        default: return 7
        }
    }
    
    private var barSpacing: CGFloat {
        switch timeRange {
        case 0: return 8
        case 1: return 2
        case 2: return 6
        default: return 8
        }
    }
    
    private func shouldShowLabel(for index: Int) -> Bool {
        if timeRange == 1 {
            // Show label every 5 days for month view to avoid crowding
            return index % 5 == 0 || index == 29
        }
        return true
    }
    
    private func getLabel(index: Int) -> String {
        let ago = (itemCount - 1) - index
        let date = Calendar.current.date(byAdding: .day, value: -ago, to: Date()) ?? Date()
        
        let formatter = DateFormatter()
        if timeRange == 0 {
            formatter.dateFormat = "EE"
            return formatter.string(from: date)
        } else if timeRange == 1 {
            formatter.dateFormat = "d."
            return formatter.string(from: date)
        } else {
            let monthDate = Calendar.current.date(byAdding: .month, value: -ago, to: Date()) ?? Date()
            formatter.dateFormat = "MMM"
            return formatter.string(from: monthDate)
        }
    }
    private func getCurrentScore() -> Double {
        switch categoryName {
        case "Vitamine": return manager.vitaminScore
        case "Mineralstoffe": return manager.mineralScore
        case "Ballaststoffe": return manager.fiberScore
        default: return 0
        }
    }
    
    private func getCategoryColor() -> Color {
        switch categoryName {
        case "Vitamine": return .blue
        case "Mineralstoffe": return Color(red: 0.2, green: 0.8, blue: 0.6)
        case "Ballaststoffe": return Color(red: 0.98, green: 0.5, blue: 0.4)
        default: return .gray
        }
    }
    
    private func getMockScore(forDaysAgo: Int) -> Double {
        // Generates a semi-random but stable score for past days based on current score
        let base = getCurrentScore()
        let variation = Double(forDaysAgo * 7 % 30) - 15.0
        return max(min(base + variation, 100), 0)
    }
    
    private func getWeekday(daysAgo: Int) -> String {
        let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "EE"
        return formatter.string(from: date)
    }
}
