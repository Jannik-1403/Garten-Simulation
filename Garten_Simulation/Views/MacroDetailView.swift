import SwiftUI

struct MacroDetailView: View {
    var category: String
    @ObservedObject var healthManager = HealthManager.shared
    
    // Goals
    @AppStorage("goal_energy") private var goalEnergy: Double = 2000.0
    @AppStorage("goal_protein") private var goalProtein: Double = 100.0
    @AppStorage("goal_carbs") private var goalCarbs: Double = 250.0
    @AppStorage("goal_fat") private var goalFat: Double = 70.0
    
    @State private var tempGoal: Double = 0.0
    
    var currentValue: Double {
        switch category {
        case "energy": return healthManager.todaysEnergy
        case "protein": return healthManager.todaysProtein
        case "carbs": return healthManager.todaysCarbohydrates
        case "fat": return healthManager.todaysFat
        default: return 0
        }
    }
    
    var unit: String {
        category == "energy" ? "kcal" : "g"
    }
    
    var titleLocalizedString: String {
        switch category {
        case "energy": return String(localized: "health.metric.energy", defaultValue: "Kalorien")
        case "protein": return String(localized: "health.metric.protein", defaultValue: "Protein")
        case "carbs": return String(localized: "health.metric.carbs", defaultValue: "Kohlenhydrate")
        case "fat": return String(localized: "health.metric.fat", defaultValue: "Fette")
        default: return ""
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Main Info
                VStack(spacing: 8) {
                    Text("\(Int(currentValue)) / \(Int(tempGoal)) \(unit)")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.primary)
                    
                    ProgressView(value: min(currentValue, tempGoal), total: max(tempGoal, 1))
                        .progressViewStyle(LinearProgressViewStyle(tint: colorForCategory))
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                        .padding(.vertical, 8)
                }
                .padding(24)
                .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
                
                // Set Goal
                VStack(alignment: .leading, spacing: 16) {
                    Text(String(localized: "macro.goal.set", defaultValue: "Tagesziel anpassen"))
                        .font(.headline)
                    
                    HStack {
                        Item3DButton(
                            farbe: Color(UIColor.systemGray4),
                            sekundaerFarbe: Color(UIColor.systemGray5),
                            groesse: 44,
                            isRectangular: false,
                            aktion: { adjustGoal(by: category == "energy" ? -10 : -1) }
                        ) {
                            Image(systemName: "minus")
                                .font(.title3.bold())
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        Text("\(Int(tempGoal)) \(unit)")
                            .font(.title2.bold())
                        
                        Spacer()
                        
                        Item3DButton(
                            farbe: colorForCategory,
                            sekundaerFarbe: colorForCategory.opacity(0.8),
                            groesse: 44,
                            isRectangular: false,
                            aktion: { adjustGoal(by: category == "energy" ? 10 : 1) }
                        ) {
                            Image(systemName: "plus")
                                .font(.title3.bold())
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(24)
                .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
                
                recommendationSection
                
                // Detailed Fats
                if category == "fat" {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(String(localized: "macro.fat.details", defaultValue: "Fett Details"))
                            .font(.headline)
                        
                        detailRow(title: String(localized: "macro.fat.sat", defaultValue: "Gesättigte Fettsäuren"), value: healthManager.todaysFatSaturated)
                        Divider()
                        detailRow(title: String(localized: "macro.fat.mono", defaultValue: "Einfach ungesättigte Fetts."), value: healthManager.todaysFatMonounsaturated)
                        Divider()
                        detailRow(title: String(localized: "macro.fat.poly", defaultValue: "Mehrfach ungesättigte Fetts."), value: healthManager.todaysFatPolyunsaturated)
                    }
                    .padding(24)
                    .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
                }
            }
            .padding()
        }
        .background(Color(UIColor.secondarySystemBackground).ignoresSafeArea())
        .navigationTitle(titleLocalizedString)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadGoal()
        }
    }
    
    private var colorForCategory: Color {
        switch category {
        case "energy": return healthManager.todaysEnergy < goalEnergy ? Color.red.darker() : Color.green.darker()
        case "protein": return .orange
        case "carbs": return .red
        case "fat": return .yellow
        default: return .gray
        }
    }
    
    private func detailRow(title: String, value: Double) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(verbatim: "\(String(format: "%.1f", value)) g")
                .bold()
        }
    }
    
    private func loadGoal() {
        switch category {
        case "energy": tempGoal = goalEnergy
        case "protein": tempGoal = goalProtein
        case "carbs": tempGoal = goalCarbs
        case "fat": tempGoal = goalFat
        default: break
        }
    }
    
    private func adjustGoal(by amount: Double) {
        tempGoal = max(amount > 0 ? tempGoal + amount : tempGoal + amount, 0)
        switch category {
        case "energy": goalEnergy = tempGoal
        case "protein": goalProtein = tempGoal
        case "carbs": goalCarbs = tempGoal
        case "fat": goalFat = tempGoal
        default: break
        }
    }
    
    private func saveGoal(value: Double) {
        tempGoal = value
        switch category {
        case "energy": goalEnergy = tempGoal
        case "protein": goalProtein = tempGoal
        case "carbs": goalCarbs = tempGoal
        case "fat": goalFat = tempGoal
        default: break
        }
    }
    
    private func recommendedValue(from rec: MacroRecommendation) -> Double {
        switch category {
        case "energy": return rec.energy
        case "protein": return rec.protein
        case "carbs": return rec.carbs
        case "fat": return rec.fat
        default: return 0
        }
    }
    
    @ViewBuilder
    private var recommendationSection: some View {
        let recommendation = MacroCalculator.calculateRecommendation(
            weightKg: healthManager.activeWeight?.value,
            heightCm: healthManager.activeHeight?.value,
            ageYears: healthManager.activeAge?.value,
            biologicalSex: healthManager.activeSex?.value,
            weightGoalType: healthManager.weightGoalType,
            weightGoalTargetKg: healthManager.weightGoalTargetKg,
            weightGoalDateInterval: healthManager.weightGoalDateInterval
        )
        
        VStack(alignment: .leading, spacing: 16) {
            Text(String(localized: "macro.recommendation.title", defaultValue: "App Empfehlung"))
                .font(.headline)
            
            if let rec = recommendation {
                let recValue = recommendedValue(from: rec)
                
                Text(String(localized: "macro.recommendation.desc", defaultValue: "Basierend auf deinen Körperdaten (Größe, Gewicht, Alter) empfehlen wir dir dieses Tagesziel."))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack {
                    Text("\(Int(recValue)) \(unit)")
                        .font(.title2.bold())
                    
                    Spacer()
                    
                    Item3DButton(
                        farbe: colorForCategory,
                        sekundaerFarbe: colorForCategory.opacity(0.8),
                        groesse: 44,
                        isRectangular: true,
                        aktion: {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            saveGoal(value: recValue)
                        }
                    ) {
                        Text(String(localized: "macro.recommendation.apply", defaultValue: "Übernehmen"))
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                    }
                }
            } else {
                Text(String(localized: "macro.recommendation.missing.new", defaultValue: "Es fehlen einige Körperdaten, um dir eine genaue Empfehlung zu geben. Bitte ergänze sie in der Übersicht."))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(24)
        .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
    }
}
