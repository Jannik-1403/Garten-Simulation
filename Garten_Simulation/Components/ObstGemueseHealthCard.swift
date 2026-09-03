import SwiftUI
import HealthKit

struct ObstGemueseHealthCard: View {
    @ObservedObject var healthManager = HealthManager.shared
    
    // Fiber (Ballaststoffe) -> 5 Portionen am Tag ca. 30g Ballaststoffe, oder laut Prompt ca. 8g für 2-3 Portionen
    var fiberGrams: Double {
        healthManager.todaysFiber
    }
    
    // Calcium (Kalzium)
    var calciumMg: Double {
        healthManager.todaysCalcium
    }
    
    // Portionen-Approximation: 1 Portion ≈ 3g Ballaststoffe
    var portions: Int {
        let p = Int(fiberGrams / 3.0)
        return min(p, 5) // max 5 portionen für Anzeige
    }
    
    var body: some View {
        VStack(spacing: 16) {
            if healthManager.isAuthorized {
                // Daten-Anzeige
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "leaf.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                        Text(String(localized: "habit.fruit_veg.title", defaultValue: "Obst & Gemüse"))
                            .font(.headline)
                            .bold()
                        Spacer()
                    }
                    
                    HStack {
                        // Ballaststoffe
                        VStack(alignment: .leading) {
                            Text(String(localized: "health.metric.fiber", defaultValue: "Ballaststoffe"))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(verbatim: "\(String(format: "%.1f", fiberGrams)) g")
                                .font(.title3)
                                .bold()
                        }
                        
                        Spacer()
                        
                        // Kalzium
                        VStack(alignment: .trailing) {
                            Text(String(localized: "health.metric.calcium", defaultValue: "Kalzium"))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(verbatim: "\(String(format: "%.0f", calciumMg)) mg")
                                .font(.title3)
                                .bold()
                        }
                    }
                    
                    // 5-am-Tag Visualisierung
                    HStack(spacing: 8) {
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: index <= portions ? "apple.logo" : "circle.dashed")
                                .foregroundColor(index <= portions ? .green : .gray.opacity(0.5))
                                .font(.title2)
                        }
                    }
                    .padding(.vertical, 8)
                    
                    if fiberGrams < 10 {
                        Text(String(localized: "habit.fruit_veg.tip", defaultValue: "Tipp: Füge deiner nächsten Mahlzeit eine Handvoll Beeren, einen Apfel oder Gemüsesticks als Snack hinzu."))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
                
            } else {
                // Button für Apple Health Verbindung
                VStack(spacing: 12) {
                    Text(String(localized: "habit.fruit_veg.connect_title", defaultValue: "Obst & Gemüse tracken"))
                        .font(.headline)
                        .bold()
                    
                    Text(String(localized: "habit.fruit_veg.connect_desc", defaultValue: "Verbinde Apple Health, um Ballaststoffe und Kalzium aus deiner Ernährung auszulesen."))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Item3DPillButton(
                        farbe: .green,
                        sekundaerFarbe: .green.opacity(0.8),
                        groesse: 50,
                        aktion: {
                            healthManager.requestAuthorization()
                        }
                    ) {
                        HStack {
                            Image(systemName: "heart.text.square.fill")
                            Text(String(localized: "habit.fruit_veg.connect_btn", defaultValue: "Mit Apple Health verbinden"))
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
}

#Preview {
    ObstGemueseHealthCard()
        .padding()
}
