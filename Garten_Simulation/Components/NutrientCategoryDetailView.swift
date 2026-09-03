import SwiftUI

struct NutrientCategoryDetailView: View {
    let categoryName: String
    @ObservedObject var manager: NutrientIndexManager
    @State private var showSettings = false
    @State private var selectedHistoryIndex: Int = 6 // Index of today in the history array (7 days ago to today)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Progress List instead of Ring Chart
                NutrientProgressList(categoryName: categoryName, items: activeItems)
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
                    Section {
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
                    } footer: {
                        Text(String(localized: "nutrient.settings.dge_info", defaultValue: "Die Ziele basieren auf den Empfehlungen der DGE (Deutsche Gesellschaft für Ernährung)."))
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
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

struct NutrientProgressList: View {
    let categoryName: String
    let items: [NutrientItem]
    
    var body: some View {
        VStack(spacing: 16) {
            if items.isEmpty {
                Text(String(localized: "nutrient.no_data", defaultValue: "Keine Daten"))
                    .font(.headline)
                    .foregroundColor(.secondary)
            } else {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    let color = getColor(for: index, total: items.count)
                    let fillRatio = max(min(item.score / 100.0, 1.0), 0.0)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(item.name)
                                .font(.subheadline)
                                .bold()
                            Spacer()
                            Text(verbatim: "\(String(format: "%.1f", item.currentValue)) / \(String(format: "%.1f", item.targetDGE)) \(item.unitString)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(color.opacity(0.2))
                                    .frame(height: 12)
                                
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(color)
                                    .frame(width: max(0, geo.size.width * CGFloat(fillRatio)), height: 12)
                            }
                        }
                        .frame(height: 12)
                    }
                }
            }
        }
        .padding()
        .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
        .padding(.horizontal, 24)
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
            VStack(spacing: 8) {
                Text(getSelectedDateString())
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Picker("Zeitraum", selection: $timeRange) {
                    Text(String(localized: "time.week", defaultValue: "Woche")).tag(0)
                    Text(String(localized: "time.month", defaultValue: "Monat")).tag(1)
                    Text(String(localized: "time.year", defaultValue: "Jahr")).tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .onChange(of: timeRange) { _, _ in
                selectedIndex = itemCount - 1
            }
            
            // Combined HStack for bars and labels — guarantees perfect alignment
            HStack(alignment: .bottom, spacing: barSpacing) {
                ForEach(0..<itemCount, id: \.self) { i in
                    let isSelected = i == selectedIndex
                    let dayScore = (i == itemCount - 1) ? getCurrentScore() : getMockScore(forDaysAgo: (itemCount - 1) - i)
                    let fillRatio = CGFloat(max(min(dayScore / 100.0, 1.0), 0.0))
                    
                    VStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(isSelected ? getCategoryColor() : Color(UIColor.systemGray4))
                            .frame(height: max(100 * fillRatio, 4))
                        
                        ZStack {
                            if shouldShowLabel(for: i) {
                                Text(getLabel(index: i))
                                    .font(.system(size: 8))
                                    .foregroundColor(isSelected ? .primary : .secondary)
                                    .lineLimit(1)
                                    .fixedSize(horizontal: true, vertical: false)
                            }
                        }
                        .frame(height: 12)
                    }
                    .frame(maxWidth: .infinity, alignment: .bottom)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedIndex = i
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, minHeight: 120, alignment: .bottom)
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
            // Show label every 7 days for month view to avoid crowding
            return index % 7 == 0 || index == 29
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
            formatter.dateFormat = "MMMMM"
            return formatter.string(from: monthDate)
        }
    }
    
    private func getSelectedDateString() -> String {
        let ago = (itemCount - 1) - selectedIndex
        if timeRange == 2 {
            let monthDate = Calendar.current.date(byAdding: .month, value: -ago, to: Date()) ?? Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: monthDate)
        } else {
            let date = Calendar.current.date(byAdding: .day, value: -ago, to: Date()) ?? Date()
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
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
