import SwiftUI
import HealthKit

struct GesundKochenCard: View {
    @ObservedObject var healthManager = HealthManager.shared
    var onUnlink: (() -> Void)? = nil
    
    let energyColor = Color.orange
    let proteinColor = Color.red
    let carbsColor = Color.green
    let fatColor = Color.yellow
    
    var energyScore: Double { healthManager.todaysEnergy / 2000.0 }
    var proteinScore: Double { healthManager.todaysProtein / 100.0 }
    var carbsScore: Double { healthManager.todaysCarbohydrates / 250.0 }
    var fatScore: Double { healthManager.todaysFat / 70.0 }
    
    var totalScore: Int {
        let e = min(energyScore, 1.0)
        let p = min(proteinScore, 1.0)
        let c = min(carbsScore, 1.0)
        let f = min(fatScore, 1.0)
        return Int((e + p + c + f) / 4.0 * 100)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            if healthManager.isAuthorized {
                ZStack(alignment: .topTrailing) {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // Oben: Großes Chart und Text darunter
                        VStack(alignment: .center, spacing: 16) {
                            ZStack {
                                let categories = [
                                    (color: energyColor, score: energyScore),
                                    (color: proteinColor, score: proteinScore),
                                    (color: carbsColor, score: carbsScore),
                                    (color: fatColor, score: fatScore)
                                ]
                                
                                ForEach(Array(categories.enumerated()), id: \.offset) { index, cat in
                                    let paddingAmount = CGFloat(index * 24)
                                    ConcentricRing(scorePercentage: cat.score, color: cat.color, lineWidth: 18)
                                        .padding(paddingAmount)
                                        .background(
                                            Circle()
                                                .stroke(Color.white.opacity(0.001), lineWidth: 18)
                                                .padding(paddingAmount)
                                        )
                                }
                                
                                Text("\(totalScore)")
                                    .font(.system(size: 42, weight: .bold))
                                    .allowsHitTesting(false)
                            }
                            .frame(width: 250, height: 250)
                            
                            Text(getStatusText(score: totalScore))
                                .font(.system(size: 32, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        
                        Divider()
                        
                        // Legende
                        VStack(alignment: .leading, spacing: 16) {
                            let legendCats = [
                                (title: String(localized: "health.metric.energy", defaultValue: "Kalorien"), color: energyColor, val: healthManager.todaysEnergy, target: 2000.0, unit: "kcal"),
                                (title: String(localized: "health.metric.protein", defaultValue: "Protein"), color: proteinColor, val: healthManager.todaysProtein, target: 100.0, unit: "g"),
                                (title: String(localized: "health.metric.carbs", defaultValue: "Kohlenhydrate"), color: carbsColor, val: healthManager.todaysCarbohydrates, target: 250.0, unit: "g"),
                                (title: String(localized: "health.metric.fat", defaultValue: "Fette"), color: fatColor, val: healthManager.todaysFat, target: 70.0, unit: "g")
                            ]
                            
                            ForEach(Array(legendCats.enumerated()), id: \.element.title) { index, cat in
                                HStack(alignment: .center) {
                                    Circle()
                                        .fill(cat.color)
                                        .frame(width: 16, height: 16)
                                    Text(cat.title)
                                        .font(.title3)
                                        .bold()
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text("\(Int(cat.val)) / \(Int(cat.target)) \(cat.unit)")
                                        .font(.title3)
                                        .bold()
                                        .foregroundColor(.primary)
                                }
                                
                                if index < legendCats.count - 1 {
                                    Divider()
                                }
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
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
                
            } else {
                VStack(spacing: 12) {
                    Text(String(localized: "habit.cook.connect_title", defaultValue: "Kochen tracken"))
                        .font(.headline)
                        .bold()
                    
                    Text(String(localized: "habit.cook.connect_desc", defaultValue: "Verbinde Apple Health, um Mahlzeiten automatisch zu erkennen."))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Item3DPillButton(
                        farbe: .orange,
                        sekundaerFarbe: .orange.opacity(0.8),
                        groesse: 50,
                        aktion: {
                            healthManager.requestAuthorization()
                        }
                    ) {
                        HStack {
                            Image(systemName: "heart.text.square.fill")
                            Text(String(localized: "habit.cook.connect_btn", defaultValue: "Mit Apple Health verbinden"))
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                    }
                    .padding(.top, 8)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
            }
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
