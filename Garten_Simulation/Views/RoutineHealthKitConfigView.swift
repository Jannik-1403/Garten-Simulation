import SwiftUI

struct RoutineHealthKitConfigView: View {
    @Binding var selectedType: HealthKitType?
    @Binding var goal: Double?
    
    @StateObject private var healthManager = HealthKitManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(String(localized: "health.config.title", defaultValue: "Apple Health Verknüpfung"))
                .font(.headline)
            
            if !healthManager.isAuthorized {
                Button(action: {
                    healthManager.requestAuthorization { _ in }
                }) {
                    HStack {
                        Image(systemName: "heart.text.square.fill")
                        Text(String(localized: "health.config.authorize", defaultValue: "Health Zugriff erlauben"))
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(10)
                }
            } else {
                Picker(String(localized: "health.config.type", defaultValue: "Typ auswählen"), selection: $selectedType) {
                    Text(String(localized: "common.none", defaultValue: "Keine")).tag(HealthKitType?(nil))
                    ForEach(HealthKitType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(HealthKitType?(type))
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                if let type = selectedType {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(String(localized: "health.config.goal", defaultValue: "Tagesziel:"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            TextField("10000", value: $goal, format: .number)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            if type == .steps {
                                Text(String(localized: "health.type.steps", defaultValue: "Schritte"))
                            } else if type == .water {
                                Text(String(localized: "health.type.water.unit", defaultValue: "ml"))
                            } else if type == .sleep {
                                Text(String(localized: "health.type.sleep.unit", defaultValue: "Std"))
                            }
                        }
                    }
                }
                
                Text(String(localized: "health.config.description", defaultValue: "Deine Pflanze wird automatisch gegossen, sobald du dieses Ziel in Apple Health erreichst."))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    RoutineHealthKitConfigView(selectedType: .constant(.steps), goal: .constant(10000))
        .padding()
}
