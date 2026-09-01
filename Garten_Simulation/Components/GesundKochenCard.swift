import SwiftUI
import HealthKit

struct GesundKochenCard: View {
    @ObservedObject var healthManager = HealthManager.shared
    @AppStorage("hasConfirmedHealthyMeal") private var hasConfirmedHealthyMeal: Bool = false
    
    // Einfache Metrik für Kalorien als Indikator
    var energyKcal: Double {
        healthManager.todaysEnergy
    }
    
    // Hybrid Ansatz: Hat der User eine Hauptmahlzeit eingetragen?
    var hasMajorMeal: Bool {
        energyKcal > 350
    }
    
    var body: some View {
        VStack(spacing: 16) {
            if healthManager.isAuthorized {
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                            .font(.title2)
                        Text(String(localized: "habit.cook.title", defaultValue: "Gesund kochen"))
                            .font(.headline)
                            .bold()
                        Spacer()
                    }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text(String(localized: "health.metric.energy", defaultValue: "Getrackte Kalorien"))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("\(energyKcal, specifier: "%.0f") kcal")
                                .font(.title3)
                                .bold()
                        }
                        Spacer()
                    }
                    
                    if hasMajorMeal {
                        if hasConfirmedHealthyMeal {
                            HStack {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.green)
                                Text(String(localized: "habit.cook.confirmed", defaultValue: "Gesunde Mahlzeit bestätigt!"))
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundColor(.green)
                            }
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                        } else {
                            VStack(spacing: 8) {
                                Text(String(localized: "habit.cook.question", defaultValue: "Mahlzeit getrackt! War sie frisch gekocht?"))
                                    .font(.subheadline)
                                    .multilineTextAlignment(.center)
                                
                                HStack {
                                    Item3DButton(
                                        farbe: .green,
                                        sekundaerFarbe: .green.opacity(0.8),
                                        groesse: 44,
                                        isRectangular: true,
                                        aktion: { hasConfirmedHealthyMeal = true }
                                    ) {
                                        Text(String(localized: "common.yes", defaultValue: "Ja"))
                                            .bold()
                                            .foregroundColor(.white)
                                    }
                                    
                                    Item3DButton(
                                        farbe: .red,
                                        sekundaerFarbe: .red.opacity(0.8),
                                        groesse: 44,
                                        isRectangular: true,
                                        aktion: { /* Ignorieren */ }
                                    ) {
                                        Text(String(localized: "common.no", defaultValue: "Nein"))
                                            .bold()
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                        }
                    } else {
                        Text(String(localized: "habit.cook.tip", defaultValue: "Noch keine große Mahlzeit getrackt (>350 kcal)."))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
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
