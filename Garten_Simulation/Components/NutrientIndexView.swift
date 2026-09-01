import SwiftUI

struct RingSegment: View {
    var scorePercentage: Double
    var startAngle: Angle
    var endAngle: Angle
    var color: Color
    var lineWidth: CGFloat = 18
    
    var body: some View {
        let totalSpan = endAngle.degrees - startAngle.degrees
        let filledSpan = totalSpan * min(max(scorePercentage, 0.0), 1.0)
        
        ZStack {
            // Blasser Hintergrund
            TrimmedArc(startAngle: startAngle, endAngle: endAngle)
                .stroke(color.opacity(0.25), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            
            // Gefüllter Balken
            TrimmedArc(startAngle: startAngle, endAngle: .degrees(startAngle.degrees + filledSpan))
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
        }
    }
}

struct TrimmedArc: Shape {
    var startAngle: Angle
    var endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        path.addArc(center: center, radius: radius, startAngle: startAngle - .degrees(90), endAngle: endAngle - .degrees(90), clockwise: false)
        return path
    }
}

struct NutrientIndexView: View {
    @StateObject private var manager = NutrientIndexManager()
    @State private var selectedCategory: String? = nil
    
    let vitaminColor = Color.blue
    let mineralColor = Color(red: 0.2, green: 0.8, blue: 0.6)
    let fiberColor = Color(red: 0.98, green: 0.5, blue: 0.4)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            HStack {
                Text(String(localized: "nutrient.index.title", defaultValue: "Nährstoff-Index"))
                    .font(.title2)
                    .bold()
                Spacer()
                Image(systemName: "gearshape.fill")
                    .foregroundColor(.gray)
            }
            
            HStack(spacing: 24) {
                ZStack {
                    RingSegment(scorePercentage: manager.vitaminScore / 100.0, startAngle: .degrees(5), endAngle: .degrees(115), color: vitaminColor)
                        .onTapGesture { selectedCategory = "Vitamine" }
                    
                    RingSegment(scorePercentage: manager.mineralScore / 100.0, startAngle: .degrees(125), endAngle: .degrees(235), color: mineralColor)
                        .onTapGesture { selectedCategory = "Mineralstoffe" }
                    
                    RingSegment(scorePercentage: manager.fiberScore / 100.0, startAngle: .degrees(245), endAngle: .degrees(355), color: fiberColor)
                        .onTapGesture { selectedCategory = "Ballaststoffe" }
                    
                    Text("\(manager.totalScore)")
                        .font(.system(size: 38, weight: .bold))
                }
                .frame(width: 130, height: 130)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(getStatusText(score: manager.totalScore))
                        .font(.system(size: 28, weight: .bold))
                }
            }
            .padding(.vertical, 10)
            
            VStack(alignment: .leading, spacing: 12) {
                LegendRow(color: vitaminColor, title: String(localized: "nutrient.category.vitamins", defaultValue: "Vitamine"), score: Int(manager.vitaminScore)) {
                    selectedCategory = "Vitamine"
                }
                LegendRow(color: mineralColor, title: String(localized: "nutrient.category.minerals", defaultValue: "Mineralstoffe"), score: Int(manager.mineralScore)) {
                    selectedCategory = "Mineralstoffe"
                }
                LegendRow(color: fiberColor, title: String(localized: "nutrient.category.fiber", defaultValue: "Ballaststoffe"), score: Int(manager.fiberScore)) {
                    selectedCategory = "Ballaststoffe"
                }
            }
            
            Divider()
            
            Text(String(localized: "nutrient.index.summary", defaultValue: "Weil du heute reichlich frisches Obst und Gemüse getrackt hast, erreichst du einen hervorragenden Nährstoff-Index von \(manager.totalScore)."))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        .onAppear {
            manager.fetchAllNutrients()
        }
        .sheet(item: $selectedCategory) { category in
            CategoryDetailSheet(categoryName: category, manager: manager)
        }
    }
    
    private func getStatusText(score: Int) -> String {
        switch score {
        case 85...100: return String(localized: "nutrient.status.veryhigh", defaultValue: "Sehr hoch")
        case 65...84: return String(localized: "nutrient.status.good", defaultValue: "Gut")
        case 45...64: return String(localized: "nutrient.status.medium", defaultValue: "Mäßig")
        default: return String(localized: "nutrient.status.low", defaultValue: "Niedrig")
        }
    }
}

struct LegendRow: View {
    var color: Color
    var title: String
    var score: Int
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Circle()
                    .fill(color)
                    .frame(width: 12, height: 12)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Text("\(score)/100")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
        }
    }
}

extension String: Identifiable {
    public var id: String { self }
}

struct CategoryDetailSheet: View {
    let categoryName: String
    @ObservedObject var manager: NutrientIndexManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
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
            .navigationTitle(categoryName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "common.done", defaultValue: "Fertig")) {
                        dismiss()
                    }
                }
            }
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

#Preview {
    NutrientIndexView()
        .padding()
}
