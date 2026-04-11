import SwiftUI

struct OnboardingPflanzenView: View {
    @EnvironmentObject var data: OnboardingData
    @EnvironmentObject var settings: SettingsStore
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var filteredPlants: [Plant] {
        guard let ziel = data.gewaehltesZiel else { return [] }
        return ziel.pflanzenIDs.compactMap { id in
            GameDatabase.allPlants.first { $0.id == id }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            OnboardingIgelView(
                pose: .neutral,
                sprechblasenText: settings.localizedString(for: "onboarding_pflanzen_blase")
            )
            .padding(.top, 20)
            
            Text(settings.localizedString(for: "onboarding_pflanzen_hinweis"))
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.top, 8)
            
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(filteredPlants) { plant in
                        PlantSelectionCard(plant: plant, isSelected: data.gewaehltePflanzenIDs.contains(plant.id)) {
                            toggleSelection(plant.id)
                        }
                    }
                }
                .padding(24)
            }
            
            Spacer()
            
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                withAnimation(.easeInOut(duration: 0.35)) {
                    data.currentStep += 1
                }
            } label: {
                Text(settings.localizedString(for: "onboarding_pflanzen_weiter"))
            }
            .buttonStyle(DuolingoButtonStyle(
                size: .large,
                backgroundColor: Color.blauPrimary,
                shadowColor: Color.blauPrimary.darker(),
                foregroundColor: .white
            ))
            .disabled(data.gewaehltePflanzenIDs.count != 2)
            .opacity(data.gewaehltePflanzenIDs.count == 2 ? 1.0 : 0.6)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    private func toggleSelection(_ id: String) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if data.gewaehltePflanzenIDs.contains(id) {
            data.gewaehltePflanzenIDs.removeAll { $0 == id }
        } else {
            if data.gewaehltePflanzenIDs.count >= 2 {
                data.gewaehltePflanzenIDs.removeFirst()
            }
            data.gewaehltePflanzenIDs.append(id)
        }
    }
}

struct PlantSelectionCard: View {
    let plant: Plant
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject var settings: SettingsStore
    
    var body: some View {
        VStack(spacing: 16) {
            PflanzenButton(
                plant: plant,
                seltenheit: .bronze,
                farbe: isSelected ? Color.gruenPrimary : Color(.systemGray6),
                sekundaerFarbe: isSelected ? Color.gruenPrimary.darker() : Color(.systemGray4),
                groesse: 100,
                alwaysShowFullGrown: true,
                aktion: action
            )
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.green)
                        .background(Circle().fill(.white))
                        .offset(x: 10, y: -10)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            
            VStack(spacing: 4) {
                Text(settings.localizedString(for: plant.habitName))
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text(settings.localizedString(for: plant.localizedName))
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(isSelected ? Color.gruenPrimary.opacity(0.05) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(isSelected ? Color.gruenPrimary.opacity(0.3) : Color.clear, lineWidth: 2)
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

struct SelectionCardButtonStyle: ButtonStyle {
    let isSelected: Bool
    private let depth: CGFloat = 6
    private let cornerRadius: CGFloat = 24

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        
        ZStack(alignment: .top) {
            // Shadow layer / Bottom layer
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(isSelected ? Color.green : Color.black.opacity(0.1))
                .frame(maxHeight: .infinity)
                .offset(y: depth)

            // Top layer (White background)
            configuration.label
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(isSelected ? Color.green : Color.black.opacity(0.12), lineWidth: isSelected ? 3 : 1)
                )
                .offset(y: isPressed ? depth : 0)
        }
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isPressed)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}
