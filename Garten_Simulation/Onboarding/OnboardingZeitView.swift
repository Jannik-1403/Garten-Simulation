import SwiftUI
import UserNotifications

struct OnboardingZeitView: View {
    @EnvironmentObject var data: OnboardingData
    @EnvironmentObject var settings: SettingsStore
    @State private var currentIndex = 0
    @State private var selectedTime = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
    
    var currentPlantId: String? {
        if !data.gewaehltePflanzenIDs.isEmpty {
            return data.gewaehltePflanzenIDs[currentIndex]
        } else if !data.customPflanzen.isEmpty {
            return data.customPflanzen[currentIndex].id.uuidString
        }
        return nil
    }
    
    var currentPlantName: String {
        if !data.gewaehltePflanzenIDs.isEmpty {
            let id = data.gewaehltePflanzenIDs[currentIndex]
            let plant = GameDatabase.allPlants.first { $0.id == id }
            return settings.localizedString(for: plant?.localizedName ?? "")
        } else if !data.customPflanzen.isEmpty {
            return data.customPflanzen[currentIndex].name
        }
        return ""
    }
    
    var totalPlants: Int {
        !data.gewaehltePflanzenIDs.isEmpty ? data.gewaehltePflanzenIDs.count : data.customPflanzen.count
    }

    var body: some View {
        VStack(spacing: 0) {
            OnboardingIgelView(
                pose: .fragt,
                sprechblasenText: String(format: settings.localizedString(for: "onboarding_zeit_blase_personal"), currentPlantName)
            )
            .padding(.top, 20)
            
            Spacer()
            
            VStack(spacing: 24) {
                // Mini Plant Card (No Emojis)
                HStack(spacing: 16) {
                    if !data.gewaehltePflanzenIDs.isEmpty {
                        let id = data.gewaehltePflanzenIDs[currentIndex]
                        if let plant = GameDatabase.allPlants.first(where: { $0.id == id }) {
                            PlantIconView(plant: plant, seltenheit: .bronze, size: 48, alwaysShowFullGrown: true)
                        }
                    } else {
                        Image(systemName: data.customPflanzen[currentIndex].sfSymbol)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(AppColors.color(for: data.customPflanzen[currentIndex].farbe))
                    }
                    
                    Text(currentPlantName)
                        .font(.system(.title3, design: .rounded, weight: .black))
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(Color(.systemBackground))
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
                
                DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
            
            // Step Indicator
            Text(String(format: settings.localizedString(for: "onboarding_zeit_progress"), currentIndex + 1, totalPlants))
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.bottom, 12)
            
            Button {
                saveAndNext()
            } label: {
                Text(settings.localizedString(for: "onboarding_zeit_weiter"))
            }
            .buttonStyle(DuolingoButtonStyle(
                size: .large,
                backgroundColor: Color.blauPrimary,
                shadowColor: Color.blauPrimary.darker(),
                foregroundColor: .white
            ))
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
    
    private func saveAndNext() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        if let id = currentPlantId {
            data.erinnerungsZeiten[id] = selectedTime
        }
        
        if currentIndex < totalPlants - 1 {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                currentIndex += 1
            }
        } else {
            // Request Notification Permissions directly from Apple before moving to next step
            requestNotificationPermissions()
            
            withAnimation(.easeInOut(duration: 0.35)) {
                data.currentStep += 1
            }
        }
    }
    
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("Notifications allowed")
                } else if let error = error {
                    print("Notification error: \(error.localizedDescription)")
                }
            }
        }
    }
}
