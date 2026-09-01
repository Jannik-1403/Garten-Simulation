import SwiftUI
import HealthKit

struct PlantProgressCalculator {
    // Wandelt Gramm Ballaststoffe in Portionen um (Max. 5 Portionen)
    static func calculatePortions(from fiberGrams: Double) -> Int {
        let portions = Int(fiberGrams / 5.0)
        return min(max(portions, 0), 5) // Wert zwischen 0 und 5
    }
    
    // Prozentualer Fortschritt für Ladebalken / Ringe
    static func calculateProgress(from fiberGrams: Double, targetGrams: Double = 25.0) -> Double {
        return min(fiberGrams / targetGrams, 1.0)
    }
}

struct ObstGemueseHealthCard: View {
    @ObservedObject var healthManager = HealthManager.shared
    
    // Für den manuellen Check-in an Tagen, wo Yazio keine Daten liefert
    @AppStorage("manualFruitVegPortions") private var manualPortions: Int = 0
    @AppStorage("manualFruitVegDate") private var manualDate: String = ""
    
    var fiberGrams: Double {
        healthManager.todaysFiber
    }
    
    var calciumMg: Double {
        healthManager.todaysCalcium
    }
    
    // Berechnet die echten Portionen aus Health + manuell hinzugefügten
    var currentPortions: Int {
        let dateString = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        let manual = (manualDate == dateString) ? manualPortions : 0
        
        let healthPortions = PlantProgressCalculator.calculatePortions(from: fiberGrams)
        return min(healthPortions + manual, 5) // Maximal 5 Portionen
    }
    
    var body: some View {
        VStack(spacing: 16) {
            if healthManager.isAuthorized {
                VStack(spacing: 16) {
                    HStack {
                        Text(String(localized: "habit.fruit_veg.title", defaultValue: "Deine Obst & Gemüse Pflanze"))
                            .font(.title3)
                            .bold()
                        Spacer()
                    }
                    
                    // Live-Werte aus Apple Health (plus evtl. manuelle Portionen)
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(String(localized: "habit.fruit_veg.tracked", defaultValue: "Getrackte Ballaststoffe heute: \(fiberGrams, specifier: "%.1f")g"))
                                .font(.headline)
                            Spacer()
                        }
                        
                        Text(String(localized: "habit.fruit_veg.portions_text", defaultValue: "Entspricht ca. \(currentPortions) von 5 Portionen"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // 5-am-Tag Visualisierung mit Blättern
                    HStack(spacing: 8) {
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: index <= currentPortions ? "leaf.fill" : "leaf")
                                .foregroundColor(index <= currentPortions ? .green : .gray.opacity(0.4))
                                .font(.title)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    // Dynamischer Bewertungstipp
                    Text(getTip(for: currentPortions))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Quick-Check-in Button (Fallback für 0 getrackte Ballaststoffe)
                    if fiberGrams == 0 && currentPortions < 5 {
                        Item3DPillButton(
                            farbe: .blauPrimary,
                            sekundaerFarbe: .blauPrimary.darker(),
                            groesse: 44,
                            aktion: {
                                addManualPortion()
                            }
                        ) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text(String(localized: "habit.fruit_veg.quick_add", defaultValue: "Händisch eintragen: +1 Portion"))
                            }
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.white)
                        }
                        .padding(.top, 8)
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
        .onAppear {
            if healthManager.isAuthorized {
                // Update triggers
                healthManager.fetchFiber()
                healthManager.fetchCalcium()
            }
        }
    }
    
    // Bewertung & Tipps basierend auf den Daten
    private func getTip(for portions: Int) -> String {
        switch portions {
        case 0...1:
            return String(localized: "habit.fruit_veg.tip.low", defaultValue: "Tipp: Bisher wenig Ballaststoffe. Schneide dir einen Apfel auf oder iss eine Handvoll Beeren.")
        case 2...3:
            return String(localized: "habit.fruit_veg.tip.medium", defaultValue: "Guter Start! Füge deinem Abendessen etwas Gemüse wie Paprika, Brokkoli oder Linsen hinzu.")
        case 4...5:
            return String(localized: "habit.fruit_veg.tip.high", defaultValue: "Stark! Du hast dein Ziel für heute erreicht. Deine Pflanze blüht voll auf!")
        default:
            return ""
        }
    }
    
    private func addManualPortion() {
        let dateString = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        if manualDate != dateString {
            manualDate = dateString
            manualPortions = 0
        }
        if manualPortions < 5 {
            manualPortions += 1
        }
    }
}

#Preview {
    ObstGemueseHealthCard()
        .padding()
}
