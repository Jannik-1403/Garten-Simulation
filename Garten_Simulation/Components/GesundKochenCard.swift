import SwiftUI
import HealthKit

struct GesundKochenCard: View {
    @ObservedObject var healthManager = HealthManager.shared
    
    var body: some View {
        VStack(spacing: 16) {
            if healthManager.isAuthorized {
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                            .font(.title2)
                        Text(String(localized: "habit.cook.title", defaultValue: "Gesund kochen"))
                            .font(.headline)
                            .bold()
                        Spacer()
                    }
                    
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            MacroView(
                                title: String(localized: "health.metric.energy", defaultValue: "Kalorien"),
                                value: healthManager.todaysEnergy,
                                unit: "kcal",
                                color: .orange
                            )
                            MacroView(
                                title: String(localized: "health.metric.protein", defaultValue: "Protein"),
                                value: healthManager.todaysProtein,
                                unit: "g",
                                color: .red
                            )
                        }
                        HStack(spacing: 12) {
                            MacroView(
                                title: String(localized: "health.metric.carbs", defaultValue: "Kohlenhydrate"),
                                value: healthManager.todaysCarbohydrates,
                                unit: "g",
                                color: .green
                            )
                            MacroView(
                                title: String(localized: "health.metric.fat", defaultValue: "Fette"),
                                value: healthManager.todaysFat,
                                unit: "g",
                                color: .yellow
                            )
                        }
                    }
                }
                .padding()
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
}

struct MacroView: View {
    var title: String
    var value: Double
    var unit: String
    var color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(value, specifier: "%.0f")")
                    .font(.title3)
                    .bold()
                    .foregroundColor(color)
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
    }
}
