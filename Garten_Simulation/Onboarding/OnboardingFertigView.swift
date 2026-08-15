import SwiftUI

struct OnboardingFertigView: View {
    @EnvironmentObject var data: OnboardingData
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore

    
    @State private var innerPose: OnboardingIgelPose = .feiert
    
    var body: some View {
        VStack(spacing: 0) {
            OnboardingIgelView(
                pose: innerPose,
                sprechblasenText: String(localized: "onboarding_fertig_blase")
            )
            .padding(.top, 20)
            
            Spacer()
            
            VStack(spacing: 30) {
                Text(String(localized: "onboarding_fertig_titel"))
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundStyle(Color.goldPrimary)
                
                // Summary Card
                VStack(spacing: 20) {
                    // Plants
                    HStack(spacing: 20) {
                        ForEach(data.gewaehltePflanzenIDs, id: \.self) { id in
                            let plant = GameDatabase.allPlants.first { $0.id == id }
                            Text(plant?.symbol ?? "")
                                .font(.system(size: 50))
                        }
                    }
                    
                    Divider()
                    
                    // Coins Bonus
                    HStack(spacing: 12) {
                        Image("coin")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                        Text(String(localized: "onboarding_fertig_startcoins"))
                            .font(.system(.headline, design: .rounded))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.yellow.opacity(0.1))
                    .clipShape(Capsule())
                }
                .padding(32)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(Color.black.opacity(0.08), lineWidth: 1)
                )
                .background(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(Color.black.opacity(0.1))
                        .offset(y: 8)
                )
                .padding(.horizontal, 24)
            }
            
            Spacer()
            
            Button {
                finish()
            } label: {
                Text(String(localized: "onboarding_fertig_button"))
            }
            .buttonStyle(DuolingoButtonStyle(
                size: .large,
                backgroundColor: Color.goldPrimary,
                shadowColor: Color.goldPrimary.darker(),
                foregroundColor: .white
            ))
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
    
    private func finish() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        
        onboardingAbschliessen()
        

        
        withAnimation {
            settings.ausgewaehltesZiel = data.customZiel.isEmpty ? "gesund" : data.customZiel
            settings.onboardingAbgeschlossen = true
        }
    }
    
    private func onboardingAbschliessen() {
        for plantID in data.gewaehltePflanzenIDs {
            let time = data.erinnerungsZeiten[plantID]
            gardenStore.pflanzeHinzufuegenAusOnboarding(plantID: plantID, reminderTime: time)
        }
        gardenStore.onboardingSetup()
    }
}
