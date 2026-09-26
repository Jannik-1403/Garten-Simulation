import SwiftUI

// MARK: - Main View

struct OnboardingPflanzenView: View {
    @Environment(\.horizontalSizeClass) var hSize
    @EnvironmentObject var data: OnboardingData
    @EnvironmentObject var settings: SettingsStore

    @State private var searchText: String = ""
    @FocusState private var searchFocused: Bool

    // All plants sorted alphabetically by localized habit name
    private var allPlants: [Plant] {
        GameDatabase.allPlants.sorted {
            NSLocalizedString($0.habitName, comment: "") < NSLocalizedString($1.habitName, comment: "")
        }
    }

    private var filteredPlants: [Plant] {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return allPlants }
        let q = searchText.lowercased()
        return allPlants.filter {
            NSLocalizedString($0.habitName, comment: "").lowercased().contains(q) ||
            NSLocalizedString($0.localizedName, comment: "").lowercased().contains(q)
        }
    }

    // True if no plant matches the current search query
    private var showCreateRow: Bool {
        let q = searchText.trimmingCharacters(in: .whitespaces)
        return !q.isEmpty && filteredPlants.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            // Mascot
            OnboardingIgelView(
                pose: data.gewaehltePflanzenIDs.count == 2 ? .daumenHoch : .erklaert,
                sprechblasenText: String(localized: "onboarding_pflanzen_blase")
            )
            .padding(.top, 20)

            // Counter badge
            HStack(spacing: 6) {
                ForEach(0..<2, id: \.self) { i in
                    Circle()
                        .fill(i < data.gewaehltePflanzenIDs.count ? Color.gruenPrimary : Color(UIColor.systemGray4))
                        .frame(width: 10, height: 10)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: data.gewaehltePflanzenIDs.count)
                }
                Text("\(data.gewaehltePflanzenIDs.count)/2 " + String(localized: "onboarding.habit.counter.suffix", defaultValue: "ausgewählt"))
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 6)

            // Search bar
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 16, weight: .semibold))

                TextField(
                    String(localized: "onboarding.habit.search.placeholder", defaultValue: "Gewohnheit suchen…"),
                    text: $searchText
                )
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .focused($searchFocused)
                .autocorrectionDisabled()

                if !searchText.isEmpty {
                    Button {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                            searchText = ""
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 16))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
            .padding(.top, 16)
            .padding(.bottom, 8)

            // List
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 10) {
                    ForEach(filteredPlants) { plant in
                        PlantListRow(
                            plant: plant,
                            isSelected: data.gewaehltePflanzenIDs.contains(plant.id)
                        ) {
                            toggleSelection(plant.id)
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    if showCreateRow {
                        CreateCustomHabitRow(name: searchText) {
                            createCustomHabit(name: searchText)
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .animation(.spring(response: 0.35, dampingFraction: 0.75), value: filteredPlants.map(\.id))
                .animation(.spring(response: 0.35, dampingFraction: 0.75), value: showCreateRow)
                .padding(.vertical, 4)
            }

            Spacer(minLength: 0)

            // Continue button
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                FeedbackManager.shared.playTap()
                searchFocused = false
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
            .padding(.bottom, 40)
            .padding(.top, 12)
        }
        .frame(maxWidth: 650)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .onTapGesture {
            hideKeyboard()
        }
    }

    // MARK: - Helpers

    private func toggleSelection(_ id: String) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        FeedbackManager.shared.playTap()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) {
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

    private func createCustomHabit(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        FeedbackManager.shared.playTap()
        // Create a synthetic plant ID for this custom habit
        let customID = "custom.\(UUID().uuidString)"
        // Store the custom habit name in OnboardingData for later processing
        withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) {
            if data.gewaehltePflanzenIDs.count >= 2 {
                data.gewaehltePflanzenIDs.removeFirst()
            }
            data.gewaehltePflanzenIDs.append(customID)
            // Save the name so GardenStore can create the real habit
            data.customHabitNames[customID] = trimmed
            searchText = ""
        }
    }
}

// MARK: - Plant List Row

struct PlantListRow: View {
    @Environment(\.horizontalSizeClass) var hSize
    let plant: Plant
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // Plant icon
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(isSelected ? Color.gruenPrimary.opacity(0.15) : Color(UIColor.systemGray6))
                        .frame(width: 52, height: 52)

                    PlantIconView(plant: plant, seltenheit: .bronze, size: 60, alwaysShowFullGrown: true)
                        .frame(width: 52, height: 52)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(isSelected ? Color.gruenPrimary : Color.clear, lineWidth: 2)
                )

                // Labels
                VStack(alignment: .leading, spacing: 2) {
                    Text(NSLocalizedString(plant.habitName, comment: ""))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(isSelected ? .primary : .primary)

                    Text(NSLocalizedString(plant.localizedName, comment: ""))
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Checkmark
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.gruenPrimary : Color(UIColor.systemGray5))
                        .frame(width: 26, height: 26)

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .black))
                            .foregroundStyle(.white)
                    }
                }
                .animation(.spring(response: 0.25, dampingFraction: 0.65), value: isSelected)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlantRowButtonStyle(isSelected: isSelected))
    }
}

// MARK: - Create Custom Habit Row

struct CreateCustomHabitRow: View {
    let name: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // Plus icon
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.blauPrimary.opacity(0.12))
                        .frame(width: 52, height: 52)

                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color.blauPrimary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Text(String(localized: "onboarding.habit.create.subtitle", defaultValue: "Eigene Gewohnheit erstellen"))
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.blauPrimary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlantRowButtonStyle(isSelected: false, accentColor: Color.blauPrimary.opacity(0.08)))
    }
}

// MARK: - Row Button Style (3D Liquid Look)

struct PlantRowButtonStyle: ButtonStyle {
    let isSelected: Bool
    var accentColor: Color = Color(UIColor.systemBackground)
    private let depth: CGFloat = 5
    private let cornerRadius: CGFloat = 20

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed

        ZStack(alignment: .top) {
            // Shadow layer
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(isSelected ? Color.gruenPrimary.opacity(0.35) : Color.black.opacity(0.07))
                .offset(y: depth)

            // Top card
            configuration.label
                .background(isSelected ? Color.gruenPrimary.opacity(0.08) : accentColor)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(isSelected ? Color.gruenPrimary.opacity(0.4) : Color.black.opacity(0.07), lineWidth: 1.5)
                )
                .offset(y: pressed ? depth : 0)
        }
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: pressed)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// Kept for backward compat (still referenced from OnboardingView if needed)
struct SelectionCardButtonStyle: ButtonStyle {
    let isSelected: Bool
    private let depth: CGFloat = 6
    private let cornerRadius: CGFloat = 24

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed

        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(isSelected ? Color.green : Color.black.opacity(0.1))
                .frame(maxHeight: .infinity)
                .offset(y: depth)

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
    @Environment(\.horizontalSizeClass) var hSize
    let category: OnboardingZiel
    @EnvironmentObject var settings: SettingsStore

    var body: some View {
        let isIPad = hSize == .regular

        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(category.color.opacity(0.15))
                    .frame(width: isIPad ? 48 : 36, height: isIPad ? 48 : 36)

                Image(systemName: category.iconName)
                    .font(.system(size: isIPad ? 22 : 16, weight: .bold))
                    .foregroundStyle(category.color)
            }

            Text(NSLocalizedString(category.labelKey, comment: ""))
                .font(.system(size: isIPad ? 28 : 20, weight: .black, design: .rounded))
                .foregroundStyle(.primary)

            Spacer()
        }
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
}
