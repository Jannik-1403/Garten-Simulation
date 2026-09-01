import SwiftUI
import HealthKit

struct CalorieCalculationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var hm = HealthManager.shared
    @EnvironmentObject var gardenStore: GardenStore
    
    // Local states for text fields
    @State private var weightStr = ""
    @State private var heightStr = ""
    @State private var ageStr = ""
    @State private var sexSelection = 0
    @State private var showTargetSheet = false
    

    private var recommendedEnergy: Double? {
        let weight = hm.activeWeight?.value ?? (hm.manualWeight > 0 ? hm.manualWeight : nil)
        let height = hm.activeHeight?.value ?? (hm.manualHeight > 0 ? hm.manualHeight : nil)
        let age = hm.activeAge?.value ?? (hm.manualAge > 0 ? hm.manualAge : nil)
        let sex = hm.activeSex?.value ?? (hm.manualSex > 0 ? hm.manualSex : nil)
        let bodyFat = hm.manualBodyFat > 0 ? hm.manualBodyFat : nil
        
        guard let rec = MacroCalculator.calculateRecommendation(
            weightKg: weight,
            heightCm: height,
            ageYears: age,
            biologicalSex: sex,
            weightGoalType: hm.weightGoalType,
            weightGoalTargetKg: hm.weightGoalTargetKg,
            weightGoalDateInterval: hm.weightGoalDateInterval,
            bodyFatPercentage: bodyFat
        ) else {
            return nil
        }
        
        return rec.energy
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Header Card
                    VStack(spacing: 12) {
                        Text(String(localized: "calorie.calc.title", defaultValue: "Dein Kalorienbedarf"))
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                        
                        if let energy = recommendedEnergy {
                            Text("\(Int(energy)) kcal")
                                .font(.system(size: 48, weight: .black, design: .rounded))
                                .foregroundStyle(Color.red.darker())
                            
                            Text(String(localized: "calorie.calc.desc.success.new", defaultValue: "Dieser Wert wird basierend auf deinen Körperdaten und deinem Ziel berechnet."))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        } else {
                            Text("??? kcal")
                                .font(.system(size: 48, weight: .black, design: .rounded))
                                .foregroundStyle(.gray)
                            
                            Text(String(localized: "calorie.calc.desc.missing", defaultValue: "Es fehlen Körperdaten, um deinen genauen Kalorienbedarf zu berechnen. Bitte ergänze sie unten."))
                                .font(.subheadline)
                                .foregroundColor(.orange)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
                    
                    // Body Data Inputs
                    VStack(spacing: 16) {
                        // WEIGHT
                        dataRow(
                            title: String(localized: "calorie.calc.weight", defaultValue: "Gewicht"),
                            unit: "kg",
                            hkValue: hm.latestBodyMass,
                            manualBinding: $weightStr,
                            isNumber: true
                        )
                        
                        // HEIGHT
                        dataRow(
                            title: String(localized: "calorie.calc.height", defaultValue: "Körpergröße"),
                            unit: "cm",
                            hkValue: hm.latestHeight,
                            manualBinding: $heightStr,
                            isNumber: true
                        )
                        
                        // AGE
                        let hkAge = hm.age != nil && hm.age! > 0 && hm.age != hm.manualAge ? hm.age : nil
                        dataRow(
                            title: String(localized: "calorie.calc.age", defaultValue: "Alter"),
                            unit: String(localized: "calorie.calc.years", defaultValue: "Jahre"),
                            hkValue: hkAge.map { Double($0) },
                            manualBinding: $ageStr,
                            isNumber: true
                        )
                        
                        // BODY FAT
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(String(localized: "calorie.calc.bodyfat", defaultValue: "Körperfettanteil"))
                                    .font(.headline)
                                Spacer()
                                if let cf = hm.calculatedBodyFat {
                                    Text(String(format: "%.1f %%", cf))
                                        .font(.title2.bold())
                                        .foregroundColor(Color.green.darker())
                                } else {
                                    Text("-")
                                        .font(.title2.bold())
                                        .foregroundColor(.secondary)
                                }
                            }
                            if hm.calculatedBodyFat != nil {
                                Text(String(localized: "calorie.calc.bodyfat_linked", defaultValue: "Wird automatisch über deinen Taillenumfang (Krafttraining) und dein Gewicht berechnet."))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else {
                                Text(String(localized: "calorie.calc.bodyfat_missing", defaultValue: "Erfasse deinen Taillenumfang im Krafttraining-Ziel, um den Körperfettanteil automatisch zu berechnen."))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                        
                        // SEX
                        let hkSex = hm.biologicalSex?.biologicalSex
                        let hasHkSex = hkSex != nil && hkSex != .notSet
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(String(localized: "calorie.calc.sex", defaultValue: "Geschlecht"))
                                    .font(.headline)
                                Spacer()
                                if hasHkSex {
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(.red)
                                } else {
                                    Image(systemName: "leaf.fill")
                                        .foregroundColor(.green)
                                }
                            }
                            
                            if hasHkSex {
                                let label = hkSex == .female ? String(localized: "sex.female", defaultValue: "Weiblich") : String(localized: "sex.male", defaultValue: "Männlich")
                                Text(label)
                                    .font(.title2.bold())
                                    .padding(.vertical, 8)
                            } else {
                                Picker("", selection: $sexSelection) {
                                    Text(String(localized: "sex.none", defaultValue: "Auswählen")).tag(0)
                                    Text(String(localized: "sex.female", defaultValue: "Weiblich")).tag(1)
                                    Text(String(localized: "sex.male", defaultValue: "Männlich")).tag(2)
                                }
                                .pickerStyle(.segmented)
                                .onChange(of: sexSelection) { _, newValue in
                                    hm.manualSex = newValue
                                }
                            }
                        }
                        .padding()
                        .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
                        
                        // WEIGHT GOAL UI
                        VStack(alignment: .leading, spacing: 16) {
                            Text(String(localized: "calorie.calc.goal.title", defaultValue: "Mein Ziel"))
                                .font(.headline)
                            
                            if hm.weightGoalType != 0 {
                                HStack {
                                    Text(hm.weightGoalType == 1 ? String(localized: "calorie.calc.goal.lose", defaultValue: "Abnehmen") : String(localized: "calorie.calc.goal.gain", defaultValue: "Zunehmen"))
                                        .font(.subheadline.bold())
                                    Spacer()
                                    Text(String(format: "%.1f kg", hm.weightGoalTargetKg))
                                        .font(.title3.bold())
                                }
                                
                                HStack {
                                    Text(String(localized: "calorie.calc.goal.target_date", defaultValue: "Ziel-Datum"))
                                        .font(.subheadline.bold())
                                    Spacer()
                                    Text(Date(timeIntervalSince1970: hm.weightGoalDateInterval), format: .dateTime.day().month().year())
                                        .font(.title3.bold())
                                }
                                
                                let currentW = hm.activeWeight?.value ?? (hm.manualWeight > 0 ? hm.manualWeight : 0)
                                if currentW > 0 && hm.weightGoalTargetKg > 0 && hm.weightGoalDateInterval > 0 {
                                    let days = max(1, Calendar.current.dateComponents([.day], from: Date(), to: Date(timeIntervalSince1970: hm.weightGoalDateInterval)).day ?? 1)
                                    let diff = abs(currentW - hm.weightGoalTargetKg)
                                    let weeklyPace = (diff / Double(days)) * 7.0
                                    
                                    HStack {
                                        Image(systemName: "speedometer")
                                            .foregroundColor(weeklyPace > 1.0 ? .red : .green)
                                        Text(String(localized: "calorie.calc.goal.pace", defaultValue: "Tempo: ~\(String(format: "%.2f", weeklyPace)) kg / Woche"))
                                            .font(.subheadline.bold())
                                            .foregroundColor(weeklyPace > 1.0 ? .red : .green)
                                    }
                                    .padding(.top, 4)
                                }
                                
                                Text(String(localized: "calorie.calc.goal.info", defaultValue: "Deine täglichen Kalorien und Makros werden automatisch basierend auf deinem Ziel-Datum angepasst."))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 8)
                            }
                            Item3DButton(
                                farbe: Color.red.darker(),
                                sekundaerFarbe: Color.red.darker().darker(),
                                groesse: 44,
                                isRectangular: true,
                                aktion: {
                                    showTargetSheet = true
                                }
                            ) {
                                Text(String(localized: "calorie.calc.goal.edit_btn", defaultValue: "Ziel ändern"))
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                            .padding(.top, 8)
                            .disabled(linkedHabit == nil)
                        }
                        .padding()
                        .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
                        .sheet(isPresented: $showTargetSheet, onDismiss: {
                            loadManualInputs()
                            hm.recalculateGoals()
                        }) {
                            if let habit = linkedHabit {
                                WeightTargetEditView(pflanze: habit)
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle(String(localized: "calorie.calc.nav", defaultValue: "Daten & Kalorien"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "common.done", defaultValue: "Fertig")) {
                        saveManualInputs()
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
            .onAppear {
                loadManualInputs()
            }
        }
    }
    
    @ViewBuilder
    private func dataRow(title: String, unit: String, hkValue: Double?, manualBinding: Binding<String>, isNumber: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                if hkValue != nil {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                } else {
                    Image(systemName: "leaf.fill")
                        .foregroundColor(.green)
                }
            }
            
            if let val = hkValue {
                HStack(alignment: .firstTextBaseline) {
                    Text(String(format: "%.1f", val).replacingOccurrences(of: ".0", with: ""))
                        .font(.title2.bold())
                    Text(unit)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            } else {
                HStack {
                    TextField("0", text: manualBinding)
                        .keyboardType(isNumber ? .decimalPad : .default)
                        .font(.title2.bold())
                        .onChange(of: manualBinding.wrappedValue) { _, _ in
                            saveManualInputs()
                        }
                    Text(unit)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
                .overlay(Rectangle().frame(height: 1).foregroundColor(Color(UIColor.separator)), alignment: .bottom)
            }
        }
        .padding()
        .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
    }
    
    private var linkedHabit: HabitModel? {
        gardenStore.activeHabits.first(where: { $0.effectiveHealthMetric == .strengthTraining && $0.targetWeight != nil && $0.targetWeightDate != nil })
    }
    
    private func loadManualInputs() {
        if let linked = linkedHabit, let targetW = linked.targetWeight, let targetD = linked.targetWeightDate {
            let currentW = hm.activeWeight?.value ?? 70.0
            hm.weightGoalType = currentW > targetW ? 1 : 2
            hm.weightGoalTargetKg = targetW
            hm.weightGoalDateInterval = targetD.timeIntervalSince1970
        }
        
        if hm.manualWeight > 0 { weightStr = String(format: "%.1f", hm.manualWeight).replacingOccurrences(of: ".0", with: "") }
        if hm.manualHeight > 0 { heightStr = String(format: "%.1f", hm.manualHeight).replacingOccurrences(of: ".0", with: "") }
        if hm.manualAge > 0 { ageStr = "\(hm.manualAge)" }
        sexSelection = hm.manualSex
    }
    
    private func saveManualInputs() {
        if let w = Double(weightStr.replacingOccurrences(of: ",", with: ".")) { hm.manualWeight = w }
        if let h = Double(heightStr.replacingOccurrences(of: ",", with: ".")) { hm.manualHeight = h }
        if let a = Int(ageStr) { hm.manualAge = a }
        
        hm.manualBodyFat = 0.0 // Ensure manual is cleared if it was set before
        
        hm.recalculateGoals()
    }
}
