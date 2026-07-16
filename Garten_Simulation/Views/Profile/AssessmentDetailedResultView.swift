import SwiftUI

struct AssessmentDetailedResultView: View {
    let result: DetailedAssessmentResult
    let color: Color
    @EnvironmentObject var gardenStore: GardenStore
    
    var body: some View {
        VStack(spacing: 24) {
            // Reality Check Card
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title3)
                        .foregroundColor(.red)
                    Text(String(localized: "assessment.roadmap.reality_check", defaultValue: "Reality Check"))
                        .font(.headline)
                        .foregroundColor(.red)
                    Spacer()
                }
                
                Text(String(localized: "assessment.roadmap.tough_love", defaultValue: "Die harte Wahrheit:"))
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text(String(localized: String.LocalizationValue(result.worstParameterTextKey)))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .background(Color.red.opacity(0.1))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
            )
            
            // Step-by-Step Roadmap
            VStack(alignment: .leading, spacing: 20) {
                ForEach(Array(result.actionSteps.enumerated()), id: \.offset) { index, step in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top, spacing: 16) {
                            // Circle Number
                            ZStack {
                                Circle()
                                    .fill(color.opacity(0.2))
                                    .frame(width: 32, height: 32)
                                Text("\(index + 1)")
                                    .font(.headline)
                                    .foregroundColor(color)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(String(localized: String.LocalizationValue(step.phaseTitleKey)))
                                    .font(.headline)
                                
                                // Load habits for this step
                                ForEach(step.recommendedPlantIDs, id: \.self) { plantID in
                                    if let plant = GameDatabase.allPlants.first(where: { $0.id == plantID }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: plant.symbolName)
                                                .foregroundColor(AppColors.color(for: plant.symbolColor))
                                                .frame(width: 20)
                                            Text(String(localized: String.LocalizationValue(plant.localizedName)))
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            Spacer()
                                            
                                            // Add Button
                                            Button(action: {
                                                addHabit(plant: plant)
                                            }) {
                                                Text(gardenStore.pflanzen.contains(where: { $0.plantID == plant.id }) ? String(localized: "assessment.roadmap.habit_added", defaultValue: "Hinzugefügt!") : String(localized: "assessment.roadmap.add_habit", defaultValue: "Challenge annehmen"))
                                                    .font(.caption)
                                                    .fontWeight(.bold)
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 6)
                                                    .background(gardenStore.pflanzen.contains(where: { $0.plantID == plant.id }) ? Color.green.opacity(0.2) : color.opacity(0.2))
                                                    .foregroundColor(gardenStore.pflanzen.contains(where: { $0.plantID == plant.id }) ? .green : color)
                                                    .cornerRadius(12)
                                            }
                                            .disabled(gardenStore.pflanzen.contains(where: { $0.plantID == plant.id }))
                                        }
                                        .padding(.top, 4)
                                    }
                                }
                            }
                        }
                    }
                    
                    if index < result.actionSteps.count - 1 {
                        Divider()
                            .padding(.leading, 48)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .padding(.horizontal)
    }
    
    private func addHabit(plant: Plant) {
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        let payload = ShopDetailPayload.from(plant: plant)
        gardenStore.pflanzHinzufuegen(shopItem: payload, isFree: true)
    }
}
