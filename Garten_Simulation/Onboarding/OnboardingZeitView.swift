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
        }
        return nil
    }
    
    var currentPlantName: String {
        if !data.gewaehltePflanzenIDs.isEmpty {
            let id = data.gewaehltePflanzenIDs[currentIndex]
            let plant = GameDatabase.allPlants.first { $0.id == id }
            return settings.localizedString(for: plant?.localizedName ?? "")
        }
        return ""
    }
    
    var totalPlants: Int {
        data.gewaehltePflanzenIDs.count
    }

    var body: some View {
        VStack(spacing: 0) {
            OnboardingIgelView(
                pose: .fragt,
                sprechblasenText: String(format: settings.localizedString(for: "onboarding_zeit_blase_personal"), currentPlantName)
            )
            .padding(.top, 20)
            
            Spacer()
            
            // Clean Apple-like Card
            VStack(spacing: 0) {
                // Header of the card (Plant info)
                HStack(spacing: 16) {
                    if !data.gewaehltePflanzenIDs.isEmpty {
                        let id = data.gewaehltePflanzenIDs[currentIndex]
                        if let plant = GameDatabase.allPlants.first(where: { $0.id == id }) {
                            PlantIconView(plant: plant, seltenheit: .bronze, size: 44, alwaysShowFullGrown: true)
                        }
                    }
                    
                    Text(currentPlantName)
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                Divider()
                    .padding(.leading, 80) // Aligned with the text start
                
                // Content of the card (Time picker)
                HStack {
                    Text(settings.localizedString(for: "onboarding_zeit_picker_label")) // e.g. "Erinnerung"
                        .font(.system(size: 17, weight: .regular))
                    Spacer()
                    DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        // Using default style which is the nice compact gray button on iOS 14+
                        // .datePickerStyle(.compact) is default
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal, 24)
            .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
            
            Spacer()
            
            // Step Indicator
            Text(String(format: settings.localizedString(for: "onboarding_zeit_progress"), currentIndex + 1, totalPlants))
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.bottom, 12)
            
            VStack(spacing: 12) {
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
                
                Button {
                    skipAndNext()
                } label: {
                    Text(settings.localizedString(for: "onboarding_zeit_skip"))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 8)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 30)
        }
    }
    
    private func saveAndNext() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        if let id = currentPlantId {
            data.erinnerungsZeiten[id] = selectedTime
        }
        
        moveToNextStep()
    }
    
    private func skipAndNext() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        if let id = currentPlantId {
            data.erinnerungsZeiten[id] = nil
        }
        
        moveToNextStep()
    }
    
    private func moveToNextStep() {
        if currentIndex < totalPlants - 1 {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                currentIndex += 1
            }
        } else {
            // Request Notification Permissions if at least one plant has a reminder set
            let hasReminders = !data.erinnerungsZeiten.isEmpty
            if hasReminders {
                requestNotificationPermissions()
            }
            
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

