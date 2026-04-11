import SwiftUI

struct OnboardingFertigView: View {
    @EnvironmentObject var data: OnboardingData
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gartenPfadStore: GartenPfadStore
    
    @State private var innerPose: IgelPose = .feiert
    
    var body: some View {
        VStack(spacing: 0) {
            OnboardingIgelView(
                pose: innerPose,
                sprechblasenText: settings.localizedString(for: "onboarding_fertig_blase")
            )
            .padding(.top, 20)
            
            Spacer()
            
            VStack(spacing: 30) {
                Text(settings.localizedString(for: "onboarding_fertig_titel"))
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundStyle(Color.goldPrimary)
                
                // Summary Card
                VStack(spacing: 20) {
                    // Plants
                    HStack(spacing: 20) {
                        if !data.gewaehltePflanzenIDs.isEmpty {
                            ForEach(data.gewaehltePflanzenIDs, id: \.self) { id in
                                let plant = GameDatabase.allPlants.first { $0.id == id }
                                Text(plant?.symbol ?? "🌱")
                                    .font(.system(size: 50))
                            }
                        } else {
                            ForEach(data.customPflanzen) { custom in
                                Image(systemName: custom.sfSymbol)
                                    .font(.system(size: 50))
                                    .foregroundStyle(Color.fromHex(custom.farbe))
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Coins Bonus
                    HStack(spacing: 12) {
                        Image("coin")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                        Text(settings.localizedString(for: "onboarding_fertig_startcoins"))
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
                Text(settings.localizedString(for: "onboarding_fertig_button"))
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
        
        // Start Path
        gartenPfadStore.pfadStarten(
            ziel: data.gewaehltesZiel?.rawValue ?? "gesund",
            pflanzeEins: data.gewaehltePflanzenIDs.first ?? "plant.apfelbaum",
            pflanzeZwei: data.gewaehltePflanzenIDs.count > 1 ? data.gewaehltePflanzenIDs[1] : (data.gewaehltePflanzenIDs.first ?? "plant.zitronenbaum")
        )
        
        withAnimation {
            settings.ausgewaehltesZiel = data.gewaehltesZiel?.rawValue ?? "gesund"
            settings.onboardingAbgeschlossen = true
        }
    }
    
    private func onboardingAbschliessen() {
        // 1. Pflanzen anlegen
        if data.zielFehlt {
            for custom in data.customPflanzen {
                gardenStore.pflanzeHinzufuegenCustom(
                    name: custom.name,
                    habit: custom.name, // Using name as habit name for custom
                    icon: custom.sfSymbol,
                    color: custom.farbe,
                    reminderTime: data.erinnerungsZeiten[custom.id.uuidString]
                )
            }
        } else {
            for plantID in data.gewaehltePflanzenIDs {
                let time = data.erinnerungsZeiten[plantID]
                gardenStore.pflanzeHinzufuegenAusOnboarding(plantID: plantID, reminderTime: time)
            }
        }
        
        // 2. Start-Setup (Coins etc)
        gardenStore.onboardingSetup()
        
        // 3. Power-Up Übernahme (Goldener Schlüssel)
        if data.globalXPMultiplier > 1.0 {
            if let key = GameDatabase.allPowerUps.first(where: { $0.id == "powerup.goldener_schluessel" }) {
                gardenStore.applyPowerUp(key)
            }
        }
    }
}
