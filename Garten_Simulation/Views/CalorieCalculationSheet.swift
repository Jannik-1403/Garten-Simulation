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
    

    private var tdee: Double? {
        let weight = hm.activeWeight?.value ?? (hm.manualWeight > 0 ? hm.manualWeight : nil)
        let height = hm.activeHeight?.value ?? (hm.manualHeight > 0 ? hm.manualHeight : nil)
        let age = hm.activeAge?.value ?? (hm.manualAge > 0 ? hm.manualAge : nil)
        let sex = hm.activeSex?.value ?? (hm.manualSex > 0 ? hm.manualSex : nil)
        
        guard let w = weight, let h = height, let a = age, let s = sex else {
            return nil
        }
        
        // Mifflin-St. Jeor
        var bmr = (10.0 * w) + (6.25 * h) - (5.0 * Double(a))
        if s == 2 { // Male
            bmr += 5
        } else { // Female
            bmr -= 161
        }
        
        return bmr * 1.55 // moderate activity multiplier
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Header Card
                    VStack(spacing: 12) {
                        Text(String(localized: "calorie.calc.title", defaultValue: "Dein Kalorienbedarf"))
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                        
                        if let tdee = tdee {
                            Text("\(Int(tdee)) kcal")
                                .font(.system(size: 48, weight: .black, design: .rounded))
                                .foregroundStyle(Color.red.darker())
                            
                            Text(String(localized: "calorie.calc.desc.success", defaultValue: "Dieser Wert (TDEE) wird basierend auf der Mifflin-St. Jeor Formel und deinen Körperdaten berechnet."))
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
                            
                            if let linked = linkedHabit, let targetW = linked.targetWeight, let targetD = linked.targetWeightDate {
                                HStack {
                                    Image(systemName: "link")
                                        .foregroundColor(.green)
                                    Text(String(localized: "calorie.calc.goal.linked", defaultValue: "Dein Ziel wurde automatisch von deinem Krafttraining übernommen."))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.bottom, 8)
                                
                                HStack {
                                    Text(String(localized: "calorie.calc.goal.target_weight", defaultValue: "Ziel-Gewicht"))
                                        .font(.subheadline.bold())
                                    Spacer()
                                    Text(String(format: "%.1f kg", targetW))
                                        .font(.title3.bold())
                                }
                                
                                HStack {
                                    Text(String(localized: "calorie.calc.goal.target_date", defaultValue: "Ziel-Datum"))
                                        .font(.subheadline.bold())
                                    Spacer()
                                    Text(targetD, format: .dateTime.day().month().year())
                                        .font(.title3.bold())
                                }
                                
                            } else {
                                Picker("", selection: $hm.weightGoalType) {
                                    Text(String(localized: "calorie.calc.goal.maintain", defaultValue: "Gewicht halten")).tag(0)
                                    Text(String(localized: "calorie.calc.goal.lose", defaultValue: "Abnehmen")).tag(1)
                                    Text(String(localized: "calorie.calc.goal.gain", defaultValue: "Zunehmen")).tag(2)
                                }
                                .pickerStyle(.segmented)
                                
                                if hm.weightGoalType != 0 {
                                    HStack {
                                        Text(String(localized: "calorie.calc.goal.target_weight", defaultValue: "Ziel-Gewicht"))
                                            .font(.subheadline.bold())
                                        Spacer()
                                        TextField("0", value: $hm.weightGoalTargetKg, format: .number)
                                            .keyboardType(.decimalPad)
                                            .multilineTextAlignment(.trailing)
                                            .font(.title3.bold())
                                            .frame(width: 80)
                                        Text("kg")
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    HStack {
                                        Text(String(localized: "calorie.calc.goal.target_date", defaultValue: "Ziel-Datum"))
                                            .font(.subheadline.bold())
                                        Spacer()
                                        DatePicker("", selection: Binding(
                                            get: { Date(timeIntervalSince1970: hm.weightGoalDateInterval > 0 ? hm.weightGoalDateInterval : Date().timeIntervalSince1970 + 86400*30) },
                                            set: { hm.weightGoalDateInterval = $0.timeIntervalSince1970 }
                                        ), displayedComponents: .date)
                                    }
                                    
                                    Text(String(localized: "calorie.calc.goal.info", defaultValue: "Deine täglichen Kalorien und Makros werden automatisch basierend auf deinem Ziel-Datum angepasst."))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.top, 8)
                                }
                            }
                        }
                        .padding()
                        .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
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
        
        // Auto-update macro goals based on calculation
        let weight = hm.activeWeight?.value ?? (hm.manualWeight > 0 ? hm.manualWeight : nil)
        let height = hm.activeHeight?.value ?? (hm.manualHeight > 0 ? hm.manualHeight : nil)
        let age = hm.activeAge?.value ?? (hm.manualAge > 0 ? hm.manualAge : nil)
        let sex = hm.activeSex?.value ?? (hm.manualSex > 0 ? hm.manualSex : nil)
        
        if let rec = MacroCalculator.calculateRecommendation(
            weightKg: weight,
            heightCm: height,
            ageYears: age,
            biologicalSex: sex,
            weightGoalType: hm.weightGoalType,
            weightGoalTargetKg: hm.weightGoalTargetKg,
            weightGoalDateInterval: hm.weightGoalDateInterval
        ) {
            UserDefaults.standard.set(rec.energy, forKey: "goal_energy")
            UserDefaults.standard.set(rec.protein, forKey: "goal_protein")
            UserDefaults.standard.set(rec.carbs, forKey: "goal_carbs")
            UserDefaults.standard.set(rec.fat, forKey: "goal_fat")
        }
    }
}
