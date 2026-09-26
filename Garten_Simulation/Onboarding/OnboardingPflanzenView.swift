import SwiftUI

// MARK: - Main View

struct OnboardingPflanzenView: View {
    @Environment(\.horizontalSizeClass) var hSize
    @EnvironmentObject var data: OnboardingData
    @EnvironmentObject var settings: SettingsStore

    @State private var searchText: String = ""
    @FocusState private var searchFocused: Bool
    @State private var showCreationSheet = false
    @State private var creationPrefillName: String = ""

    // All plants filtered (no seeds) and sorted alphabetically by habit name
    private var allPlants: [Plant] {
        GameDatabase.allPlants
            .filter { $0.habitCategory != .seeds }
            .sorted { NSLocalizedString($0.habitName, comment: "") < NSLocalizedString($1.habitName, comment: "") }
    }

    // Plants matching the search query
    private var filteredPlants: [Plant] {
        let q = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return allPlants }
        return allPlants.filter {
            NSLocalizedString($0.habitName, comment: "").lowercased().contains(q) ||
            NSLocalizedString($0.localizedName, comment: "").lowercased().contains(q)
        }
    }

    // Selected plants always appear at the top of the list
    private var sortedPlants: [Plant] {
        let selected = filteredPlants.filter { data.gewaehltePflanzenIDs.contains($0.id) }
        let unselected = filteredPlants.filter { !data.gewaehltePflanzenIDs.contains($0.id) }
        return selected + unselected
    }

    // Selected custom habits (user-created, no plant in DB)
    private var selectedCustomHabits: [(id: String, name: String, icon: String, color: String)] {
        data.gewaehltePflanzenIDs
            .filter { $0.hasPrefix("custom.") }
            .compactMap { id in
                guard let name = data.customHabitNames[id] else { return nil }
                let icon = data.customHabitIcons[id] ?? "leaf.fill"
                let color = data.customHabitColors[id] ?? "green"
                return (id: id, name: name, icon: icon, color: color)
            }
    }

    // Show "create" row only when search has text and no plants match
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
            .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
            .padding(.top, 16)
            .padding(.bottom, 8)

            // List
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 12) {

                    // Selected custom habits (user-created) — always at top
                    ForEach(selectedCustomHabits, id: \.id) { habit in
                        CustomHabitListRow(
                            name: habit.name,
                            icon: habit.icon,
                            color: habit.color,
                            isSelected: true
                        ) {
                            removeCustomHabit(id: habit.id)
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    // Plant rows (selected first)
                    ForEach(sortedPlants) { plant in
                        PlantListRow(
                            plant: plant,
                            isSelected: data.gewaehltePflanzenIDs.contains(plant.id)
                        ) {
                            toggleSelection(plant.id)
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    // "Create custom habit" row — only when no search results
                    if showCreateRow {
                        CreateCustomHabitRow(name: searchText) {
                            creationPrefillName = searchText
                            showCreationSheet = true
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 16)
                .animation(.spring(response: 0.35, dampingFraction: 0.75), value: sortedPlants.map(\.id))
                .animation(.spring(response: 0.35, dampingFraction: 0.75), value: showCreateRow)
                .animation(.spring(response: 0.35, dampingFraction: 0.75), value: selectedCustomHabits.map(\.id))
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
        .onTapGesture { hideKeyboard() }
        .sheet(isPresented: $showCreationSheet) {
            OnboardingHabitCreationSheet(prefillName: creationPrefillName)
                .environmentObject(data)
                .environmentObject(settings)
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
                    // Remove first non-custom selection to replace it
                    if let firstNormal = data.gewaehltePflanzenIDs.first(where: { !$0.hasPrefix("custom.") }) {
                        data.gewaehltePflanzenIDs.removeAll { $0 == firstNormal }
                    } else {
                        data.gewaehltePflanzenIDs.removeFirst()
                    }
                }
                data.gewaehltePflanzenIDs.append(id)
            }
        }
    }

    private func removeCustomHabit(id: String) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        FeedbackManager.shared.playTap()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) {
            data.gewaehltePflanzenIDs.removeAll { $0 == id }
            data.customHabitNames.removeValue(forKey: id)
            data.customHabitIcons.removeValue(forKey: id)
            data.customHabitColors.removeValue(forKey: id)
            data.customHabitCategories.removeValue(forKey: id)
        }
    }
}

// MARK: - Plant List Row (Item3DButton-Stil)

struct PlantListRow: View {
    @Environment(\.horizontalSizeClass) var hSize
    let plant: Plant
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Item3DButton(
            farbe: .white,
            sekundaerFarbe: isSelected ? Color.gruenPrimary.opacity(0.5) : Color(UIColor.systemGray5),
            groesse: 72,
            shadowDepthFactor: 0.07,
            isRectangular: true,
            isPermanentlyPressed: false,
            aktion: action
        ) {
            HStack(spacing: 16) {
                // Plant icon
                PlantIconView(plant: plant, seltenheit: .bronze, size: 52, alwaysShowFullGrown: true)
                    .frame(width: 52, height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                // Labels
                VStack(alignment: .leading, spacing: 2) {
                    Text(NSLocalizedString(plant.habitName, comment: ""))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                        .lineLimit(2)

                    Text(NSLocalizedString(plant.localizedName, comment: ""))
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Checkmark circle
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.gruenPrimary : Color(UIColor.systemGray5))
                        .frame(width: 28, height: 28)
                        .overlay(
                            Circle()
                                .stroke(isSelected ? Color.gruenPrimary.darker() : Color(UIColor.systemGray4), lineWidth: 2)
                        )

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(.white)
                    }
                }
                .animation(.spring(response: 0.25, dampingFraction: 0.65), value: isSelected)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }
}

// MARK: - Custom Habit List Row (user-created, always selected)

struct CustomHabitListRow: View {
    let name: String
    let icon: String
    let color: String
    let isSelected: Bool
    let onRemove: () -> Void

    private var uiColor: Color {
        switch color {
        case "green":   return .green
        case "mint":    return .mint
        case "teal":    return .teal
        case "cyan":    return .cyan
        case "yellow":  return .yellow
        case "orange":  return .orange
        case "red":     return .red
        case "pink":    return .pink
        case "purple":  return .purple
        case "blue":    return .blue
        case "indigo":  return .indigo
        case "brown":   return .brown
        default:        return .green
        }
    }

    var body: some View {
        Item3DButton(
            farbe: .white,
            sekundaerFarbe: Color.gruenPrimary.opacity(0.5),
            groesse: 72,
            shadowDepthFactor: 0.07,
            isRectangular: true,
            isPermanentlyPressed: false,
            aktion: {}
        ) {
            HStack(spacing: 16) {
                // Mimic PlantIconView style
                PflanzenButton(
                    plant: nil,
                    seltenheit: .bronze,
                    farbe: uiColor,
                    sekundaerFarbe: uiColor.darker(),
                    groesse: 52,
                    fallbackIcon: icon
                )
                .allowsHitTesting(false)
                .frame(width: 52, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                        .lineLimit(2)

                    Text(String(localized: "onboarding.habit.create.subtitle", defaultValue: "Eigene Gewohnheit"))
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Remove button
                Button(action: onRemove) {
                    ZStack {
                        Circle()
                            .fill(Color.gruenPrimary)
                            .frame(width: 28, height: 28)
                            .overlay(Circle().stroke(Color.gruenPrimary.darker(), lineWidth: 2))

                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(.white)
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }
}

// MARK: - Create Custom Habit Row

struct CreateCustomHabitRow: View {
    let name: String
    let action: () -> Void

    var body: some View {
        Item3DButton(
            farbe: .white,
            sekundaerFarbe: Color(UIColor.systemGray5),
            groesse: 72,
            shadowDepthFactor: 0.07,
            isRectangular: true,
            isPermanentlyPressed: false,
            aktion: action
        ) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(UIColor.systemGray6))
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
            .padding(.vertical, 10)
        }
    }
}

// MARK: - Kept for backward compatibility

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
                .overlay(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(isSelected ? Color.green : Color.black.opacity(0.12), lineWidth: isSelected ? 3 : 1))
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
