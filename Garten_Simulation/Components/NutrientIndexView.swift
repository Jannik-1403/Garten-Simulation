import SwiftUI

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
    @ObservedObject private var manager = NutrientIndexManager.shared
    var onUnlink: (() -> Void)? = nil
    
    let vitaminColor = Color.blue
    let mineralColor = Color(red: 0.2, green: 0.8, blue: 0.6)
    let fiberColor = Color(red: 0.98, green: 0.5, blue: 0.4)
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 24) {
            
            // Oben: Großes Chart und Text darunter
            VStack(alignment: .center, spacing: 16) {
                ZStack {
                    ForEach(Array(activeCategories.enumerated()), id: \.element.name) { index, cat in
                        let paddingAmount = CGFloat(index * 24)
                        NavigationLink(destination: NutrientCategoryDetailView(categoryName: cat.name, manager: manager)) {
                            ConcentricRing(scorePercentage: cat.score / 100.0, color: cat.color, lineWidth: 18)
                                .padding(paddingAmount)
                                .background(
                                    Circle()
                                        .stroke(Color.white.opacity(0.001), lineWidth: 18)
                                        .padding(paddingAmount)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Text("\(manager.totalScore)")
                        .font(.system(size: 42, weight: .bold))
                        .allowsHitTesting(false)
                }
                .frame(width: 210, height: 210)
                
                Text(getStatusText(score: manager.totalScore))
                    .font(.system(size: 32, weight: .bold))
            }
            .frame(maxWidth: .infinity)
            
            Divider()
            
            // Legende (immer alle drei Kategorien anzeigen)
            VStack(alignment: .leading, spacing: 16) {
                let legendCats = [
                    ("Vitamine", vitaminColor, manager.vitaminScore),
                    ("Mineralstoffe", mineralColor, manager.mineralScore),
                    ("Ballaststoffe", fiberColor, manager.fiberScore)
                ]
                
                ForEach(Array(legendCats.enumerated()), id: \.element.0) { index, cat in
                    NavigationLink(destination: NutrientCategoryDetailView(categoryName: cat.0, manager: manager)) {
                        HStack(alignment: .center) {
                            Circle()
                                .fill(cat.1)
                                .frame(width: 16, height: 16)
                            Text(getLocalizedCategoryName(for: cat.0))
                                .font(.title3)
                                .bold()
                                .foregroundColor(.primary)
                            Spacer()
                            Text("\(Int(cat.2))/100")
                                .font(.title3)
                                .bold()
                                .foregroundColor(.primary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    if index < legendCats.count - 1 {
                        Divider()
                    }
                }
            }
            .padding(24)
            
            if let onUnlink = onUnlink {
                Item3DButton(
                    farbe: .red,
                    sekundaerFarbe: Color.red.opacity(0.7),
                    groesse: 36,
                    isRectangular: false,
                    aktion: {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        onUnlink()
                    }
                ) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                }
                .padding(.top, 10)
                .padding(.trailing, 10)
            }
        }
        .onAppear {
            manager.fetchAllNutrients()
        }
    }
    
    private var activeCategories: [(name: String, color: Color, score: Double)] {
        var cats: [(name: String, color: Color, score: Double)] = []
        if manager.hasActiveVitamins { cats.append(("Vitamine", vitaminColor, manager.vitaminScore)) }
        if manager.hasActiveMinerals { cats.append(("Mineralstoffe", mineralColor, manager.mineralScore)) }
        if manager.hasActiveFiber { cats.append(("Ballaststoffe", fiberColor, manager.fiberScore)) }
        return cats
    }
    
    private func getLocalizedCategoryName(for name: String) -> String {
        switch name {
        case "Vitamine": return String(localized: "nutrient.category.vitamins", defaultValue: "Vitamine")
        case "Mineralstoffe": return String(localized: "nutrient.category.minerals", defaultValue: "Mineralstoffe")
        case "Ballaststoffe": return String(localized: "nutrient.category.fiber", defaultValue: "Ballaststoffe")
        default: return name
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



#Preview {
    NutrientIndexView()
        .padding()
}
