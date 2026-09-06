import SwiftUI

struct WeightTargetEditView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var gardenStore: GardenStore
    
    var pflanze: HabitModel?
    
    @State private var targetInput: String = ""
    @State private var targetDateInput: Date = Date()
    @State private var targetInputMode: Int = 0 // 0 = Date, 1 = Pace
    @State private var paceInput: String = "0.5"
    
    private var currentValue: Double? {
        if let pflanze = pflanze, !pflanze.manualWeightEntries.isEmpty {
            return pflanze.manualWeightEntries.max(by: { $0.timestamp < $1.timestamp })?.progress
        }
        return HealthManager.shared.activeWeight?.value
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(String(localized: "body.tracking.target_weight_title", defaultValue: "Zielgewicht"))) {
                    HStack {
                        TextField("0", text: $targetInput)
                            .keyboardType(.decimalPad)
                        Text("kg")
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section(header: Text(String(localized: "body.tracking.target_date_title", defaultValue: "Zieldatum"))) {
                    Picker("", selection: $targetInputMode) {
                        Text(String(localized: "body.tracking.target_mode_date", defaultValue: "Datum")).tag(0)
                        Text(String(localized: "body.tracking.target_mode_pace", defaultValue: "Tempo (Woche)")).tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.bottom, 4)
                    
                    if targetInputMode == 0 {
                        DatePicker(
                            String(localized: "body.tracking.target_date", defaultValue: "Erreichen bis"),
                            selection: $targetDateInput,
                            in: Date()...,
                            displayedComponents: .date
                        )
                        .environment(\.locale, SettingsStore.shared.appLocale)
                    } else {
                        HStack {
                            Text(String(localized: "body.tracking.target_pace", defaultValue: "kg pro Woche:"))
                            Spacer()
                            TextField("", text: $paceInput, prompt: Text(verbatim: "0.5"))
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                        }
                        
                        if let pace = Double(paceInput.replacingOccurrences(of: ",", with: ".")), pace > 0, let targetW = Double(targetInput.replacingOccurrences(of: ",", with: ".")) {
                            let currentW = currentValue ?? 0
                            if currentW > 0 {
                                let diff = abs(currentW - targetW)
                                let weeks = diff / pace
                                let days = weeks * 7.0
                                let calculatedDate = Calendar.current.date(byAdding: .day, value: Int(days), to: Date()) ?? Date()
                                
                                HStack {
                                    Text(String(localized: "body.tracking.target_calc_date", defaultValue: "Berechnetes Datum:"))
                                    Spacer()
                                    Text(calculatedDate, format: .dateTime.day().month().year())
                                        .foregroundStyle(.secondary)
                                }
                                .font(.caption)
                                .padding(.top, 4)
                            }
                        }
                    }
                }
                
                if pflanze?.targetWeight != nil || HealthManager.shared.weightGoalTargetKg > 0 {
                    Section {
                        Button(role: .destructive) {
                            if let pflanze = pflanze {
                                pflanze.targetWeight = nil
                                pflanze.targetWeightDate = nil
                                gardenStore.savePlants()
                            }
                            HealthManager.shared.weightGoalTargetKg = 0
                            HealthManager.shared.weightGoalDateInterval = 0
                            HealthManager.shared.weightGoalType = 0
                            HealthManager.shared.recalculateGoals()
                            dismiss()
                        } label: {
                            Text(String(localized: "body.tracking.delete_target", defaultValue: "Ziel löschen"))
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
            }
            .navigationTitle(String(localized: "body.tracking.target_title", defaultValue: "Ziel"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(String(localized: "button.cancel", defaultValue: "Abbrechen")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "common.save", defaultValue: "Speichern")) {
                        let w = Double(targetInput.replacingOccurrences(of: ",", with: ".")) ?? 0
                        if w > 0 {
                            var finalDate = targetDateInput
                            if targetInputMode == 1, let pace = Double(paceInput.replacingOccurrences(of: ",", with: ".")), pace > 0 {
                                let currentW = currentValue ?? 0
                                if currentW > 0 {
                                    let diff = abs(currentW - w)
                                    let days = (diff / pace) * 7.0
                                    finalDate = Calendar.current.date(byAdding: .day, value: Int(days), to: Date()) ?? targetDateInput
                                }
                            }
                            
                            if let pflanze = pflanze {
                                pflanze.targetWeight = w
                                pflanze.targetWeightDate = finalDate
                                gardenStore.savePlants()
                            }
                            
                            // Auto-Update calories globally if this is the target weight
                            HealthManager.shared.weightGoalTargetKg = w
                            HealthManager.shared.weightGoalDateInterval = finalDate.timeIntervalSince1970
                            let currentW = HealthManager.shared.activeWeight?.value ?? 0
                            HealthManager.shared.weightGoalType = currentW > w ? 1 : (currentW < w ? 2 : 0)
                            HealthManager.shared.recalculateGoals()
                        }
                        dismiss()
                    }
                    .bold()
                }
            }
            .onAppear {
                if let pflanze = pflanze, let t = pflanze.targetWeight {
                    targetInput = String(format: "%.1f", t)
                } else if HealthManager.shared.weightGoalTargetKg > 0 {
                    targetInput = String(format: "%.1f", HealthManager.shared.weightGoalTargetKg)
                }
                
                if let pflanze = pflanze, let d = pflanze.targetWeightDate {
                    targetDateInput = d
                } else if HealthManager.shared.weightGoalDateInterval > 0 {
                    targetDateInput = Date(timeIntervalSince1970: HealthManager.shared.weightGoalDateInterval)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
