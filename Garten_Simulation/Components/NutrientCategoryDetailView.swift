import SwiftUI

struct NutrientCategoryDetailView: View {
    let categoryName: String
    @ObservedObject var manager: NutrientIndexManager
    @State private var showSettings = false
    @State private var isListExpanded = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Segmented Donut Chart
                SegmentedRingChart(categoryName: categoryName, items: activeItems)
                    .frame(height: 240)
                    .padding(.top, 24)
                    .padding(.bottom, 16)
                    
                if !activeItems.isEmpty {
                    NutrientHistoryChart(manager: manager, categoryName: categoryName)
                        .padding(.horizontal, 24)
                }
                
                // Details List
                VStack(spacing: 16) {
                    if activeItems.isEmpty {
                        Text(String(localized: "nutrient.detail.no_active", defaultValue: "Keine Nährstoffe aktiviert."))
                            .foregroundColor(.secondary)
                    } else {
                        DisclosureGroup(isExpanded: $isListExpanded) {
                            VStack(spacing: 12) {
                                ForEach(Array(activeItems.enumerated()), id: \.element.id) { index, item in
                                    HStack {
                                        Circle()
                                            .fill(getColor(for: index, total: activeItems.count))
                                            .frame(width: 12, height: 12)
                                        
                                        Text(item.name)
                                            .font(.headline)
                                        
                                        Spacer()
                                        
                                        VStack(alignment: .trailing) {
                                            Text("\(Int(item.score))/100")
                                                .font(.headline)
                                            Text("\(item.currentValue, specifier: "%.1f") / \(item.targetDGE, specifier: "%.1f") \(item.unitString)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding()
                                    .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
                                }
                            }
                            .padding(.top, 12)
                        } label: {
                            Text(String(localized: "nutrient.detail.list_title", defaultValue: "Details & Werte"))
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
                    }
                }
                .padding(.horizontal, 24)
                
                // Info Text DGE
                Text(String(localized: "nutrient.dge.info", defaultValue: "Die empfohlenen Tagesziele basieren auf den Referenzwerten der Deutschen Gesellschaft für Ernährung (DGE). Die Werte werden automatisch über Apple Health synchronisiert."))
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 24)
                
                // Test Data Button
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
        switch categoryName {
        case "Vitamine": return manager.vitamins.filter { $0.isEnabled }
        case "Mineralstoffe": return manager.minerals.filter { $0.isEnabled }
        case "Ballaststoffe": return manager.fiber.isEnabled ? [manager.fiber] : []
        default: return []
        }
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
                
                Text(String(localized: "nutrient.nodata", defaultValue: "Noch keine\nDaten"))
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                let segmentAngle = 360.0 / Double(items.count)
                let gapAngle = 0.0 // No gaps anymore
                
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    let startDegrees = Double(index) * segmentAngle + (gapAngle / 2)
                    let endDegrees = Double(index + 1) * segmentAngle - (gapAngle / 2)
                    let color = getColor(for: index, total: items.count)
                    
                    let maxLineWidth: CGFloat = 30
                    let fillWidth = maxLineWidth * CGFloat(max(min(item.score / 100.0, 1.0), 0.01))
                    let radiusOffset = (fillWidth - maxLineWidth) / 2
                    
                    // Background Arc (full width, very transparent)
                    SegmentArc(startAngle: .degrees(startDegrees), endAngle: .degrees(endDegrees))
                        .stroke(color.opacity(0.15), style: StrokeStyle(lineWidth: maxLineWidth, lineCap: .butt))
                    
                    // Filled Arc (grows from inside to outside)
                    SegmentArc(startAngle: .degrees(startDegrees), endAngle: .degrees(endDegrees), radiusOffset: radiusOffset)
                        .stroke(color, style: StrokeStyle(lineWidth: fillWidth, lineCap: .butt))
                }
                
                // Average Score in center
                VStack {
                    Text("\(Int(averageScore))")
                        .font(.system(size: 48, weight: .bold))
                    Text(String(localized: "nutrient.total", defaultValue: "Gesamt"))
                        .font(.caption)
                        .foregroundColor(.secondary)
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "nutrient.history.title", defaultValue: "Letzte 7 Tage"))
                .font(.headline)
            
            HStack(alignment: .bottom, spacing: 8) {
                // Mock History Data (should ideally come from manager, but for now we generate deterministic mock data if none exists)
                ForEach(0..<7, id: \.self) { i in
                    let isToday = i == 6
                    let dayScore = isToday ? getCurrentScore() : getMockScore(forDaysAgo: 6 - i)
                    
                    VStack(spacing: 8) {
                        GeometryReader { geometry in
                            VStack {
                                Spacer()
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(isToday ? getCategoryColor() : Color(UIColor.systemGray4))
                                    .frame(height: max(geometry.size.height * CGFloat(dayScore / 100.0), 4))
                            }
                        }
                        .frame(height: 100)
                        
                        Text(getWeekday(daysAgo: 6 - i))
                            .font(.caption2)
                            .foregroundColor(isToday ? .primary : .secondary)
                            .bold(isToday)
                    }
                }
            }
        }
        .padding()
        .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
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
