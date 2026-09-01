import SwiftUI

struct RingSegment: View {
struct ConcentricRing: View {
    var scorePercentage: Double
    var color: Color
    var lineWidth: CGFloat = 18
    
    var body: some View {
        ZStack {
            // Blasser Hintergrund
            Circle()
                .stroke(color.opacity(0.25), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            
            // Gefüllter Balken
            Circle()
                .trim(from: 0, to: CGFloat(min(max(scorePercentage, 0.0), 1.0)))
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
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
        VStack(alignment: .leading, spacing: 24) {
            
            // Oben: Großes Chart und Text darunter
            VStack(alignment: .center, spacing: 16) {
                ZStack {
                    // Outer Ring (Vitamine)
                    ConcentricRing(scorePercentage: manager.vitaminScore / 100.0, color: vitaminColor, lineWidth: 18)
                        .padding(0)
                        .background(Circle().stroke(Color.white.opacity(0.001), lineWidth: 18).padding(0).onTapGesture { selectedCategory = "Vitamine" })
                    
                    // Middle Ring (Mineralstoffe)
                    ConcentricRing(scorePercentage: manager.mineralScore / 100.0, color: mineralColor, lineWidth: 18)
                        .padding(24)
                        .background(Circle().stroke(Color.white.opacity(0.001), lineWidth: 18).padding(24).onTapGesture { selectedCategory = "Mineralstoffe" })
                    
                    // Inner Ring (Ballaststoffe)
                    ConcentricRing(scorePercentage: manager.fiberScore / 100.0, color: fiberColor, lineWidth: 18)
                        .padding(48)
                        .background(Circle().stroke(Color.white.opacity(0.001), lineWidth: 18).padding(48).onTapGesture { selectedCategory = "Ballaststoffe" })
                    
                    Text("\(manager.totalScore)")
                        .font(.system(size: 42, weight: .bold))
                }
                .frame(width: 210, height: 210)
                
                Text(getStatusText(score: manager.totalScore))
                    .font(.system(size: 32, weight: .bold))
            }
            .frame(maxWidth: .infinity)
            
            Divider()
            
            // Legende (ohne Subtitles)
            VStack(alignment: .leading, spacing: 16) {
                LegendRow(
                    color: vitaminColor, 
                    title: String(localized: "nutrient.category.vitamins", defaultValue: "Vitamine"), 
                    score: Int(manager.vitaminScore)
                ) {
                    selectedCategory = "Vitamine"
                }
                
                Divider()
                
                LegendRow(
                    color: mineralColor, 
                    title: String(localized: "nutrient.category.minerals", defaultValue: "Mineralstoffe"), 
                    score: Int(manager.mineralScore)
                ) {
                    selectedCategory = "Mineralstoffe"
                }
                
                Divider()
                
                LegendRow(
                    color: fiberColor, 
                    title: String(localized: "nutrient.category.fiber", defaultValue: "Ballaststoffe"), 
                    score: Int(manager.fiberScore)
                ) {
                    selectedCategory = "Ballaststoffe"
                }
            }
        }
        .padding(24)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(UIColor.systemGray4))
                    .offset(y: 8)
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(.systemBackground))
            }
        )
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
            HStack(alignment: .center) {
                Circle()
                    .fill(color)
                    .frame(width: 16, height: 16)
                Text(title)
                    .font(.title3)
                    .bold()
                    .foregroundColor(.primary)
                Spacer()
                Text("\(score)/100")
                    .font(.title3)
                    .bold()
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
                Section {
                    Button(action: {
                        manager.injectTestData(for: categoryName)
                    }) {
                        Text("Testdaten laden")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    HStack {
                        Spacer()
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 16)
                            
                            if getCategoryScore() > 0 {
                                Circle()
                                    .trim(from: 0, to: CGFloat(getCategoryScore() / 100.0))
                                    .stroke(getCategoryColor(), style: StrokeStyle(lineWidth: 16, lineCap: .round))
                                    .rotationEffect(.degrees(-90))
                                
                                Text("\(Int(getCategoryScore()))")
                                    .font(.system(size: 36, weight: .bold))
                            } else {
                                Text(String(localized: "nutrient.nodata", defaultValue: "Noch keine\nDaten"))
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .frame(width: 120, height: 120)
                        .padding(.vertical, 16)
                        Spacer()
                    }
                }
                
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
    
    private func getCategoryScore() -> Double {
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
