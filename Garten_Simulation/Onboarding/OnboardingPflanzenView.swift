import SwiftUI

struct OnboardingPflanzenView: View {
    @EnvironmentObject var data: OnboardingData
    @EnvironmentObject var settings: SettingsStore
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    struct PlantCategoryGroup: Identifiable {
        var id: String { category.id }
        let category: OnboardingZiel
        let plants: [Plant]
    }
    
    var groupedPlants: [PlantCategoryGroup] {
        let categoriesToUse = data.gewaehltesZiele.isEmpty ? OnboardingZiel.allCases : data.gewaehltesZiele
        
        var seen = Set<String>()
        var groups: [PlantCategoryGroup] = []
        
        for category in categoriesToUse {
            let categoryPlants = category.pflanzenIDs.compactMap { id in
                GameDatabase.allPlants.first { $0.id == id }
            }.filter { seen.insert($0.id).inserted }
            
            if !categoryPlants.isEmpty {
                groups.append(PlantCategoryGroup(category: category, plants: categoryPlants))
            }
        }
        return groups
    }

    var body: some View {
        VStack(spacing: 0) {
            OnboardingIgelView(
                pose: .neutral,
                sprechblasenText: String(localized: "onboarding_pflanzen_blase")
            )
            .padding(.top, 20)
            
            Text(String(localized: "onboarding_pflanzen_hinweis"))
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.top, 8)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 8) {
                    ForEach(groupedPlants) { group in
                        VStack(alignment: .leading, spacing: 0) {
                            CategoryHeaderView(category: group.category)
                            
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(group.plants) { plant in
                                    PlantSelectionCard(plant: plant, isSelected: data.gewaehltePflanzenIDs.contains(plant.id)) {
                                        toggleSelection(plant.id)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 16)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            
            Spacer()
            
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                FeedbackManager.shared.playTap()
                withAnimation(.easeInOut(duration: 0.35)) {
                    data.currentStep += 1
                }
            } label: {
                Text(String(localized: "onboarding_pflanzen_weiter"))
            }
            .buttonStyle(DuolingoButtonStyle(
                size: .large,
                backgroundColor: Color.blauPrimary,
                shadowColor: Color.blauPrimary.darker(),
                foregroundColor: .white
            ))
            .disabled(data.gewaehltePflanzenIDs.count != 2)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    private func toggleSelection(_ id: String) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        FeedbackManager.shared.playTap()
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
        VStack(spacing: 12) {
            Item3DButton(
                farbe: isSelected ? Color.gruenPrimary : Color(.systemGray6),
                sekundaerFarbe: isSelected ? Color.gruenPrimary.darker() : Color(.systemGray4),
                groesse: 100,
                iconSkalierung: 1.5,
                aktion: action
            ) {
                PlantIconView(plant: plant, seltenheit: .bronze, size: 120, alwaysShowFullGrown: true)
            }
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title)
                        .foregroundStyle(Color.green)
                        .background(Circle().fill(.white))
                        .offset(x: 10, y: -10)
                }
            }
            
            VStack(spacing: 2) {
                Text(NSLocalizedString(plant.habitName, comment: ""))
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(isSelected ? .primary : .secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                Text(NSLocalizedString(plant.localizedName, comment: ""))
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(isSelected ? .secondary : Color(.systemGray3))
                    .multilineTextAlignment(.center)
            }
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
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

struct CategoryHeaderView: View {
    let category: OnboardingZiel
    @EnvironmentObject var settings: SettingsStore
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(category.color.opacity(0.15))
                    .frame(width: 36, height: 36)
                
                Image(systemName: category.iconName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(category.color)
            }
            
            Text(NSLocalizedString(category.labelKey, comment: ""))
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundStyle(.primary)
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
}
