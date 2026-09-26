import SwiftUI
import TelemetryDeck

/// Onboarding-Version der CustomPlantCreationView.
/// Erstellt eine "gute" Gewohnheit.
struct OnboardingHabitCreationSheet: View {
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var data: OnboardingData
    @Environment(\.dismiss) var dismiss

    let prefillName: String

    @State private var plantName: String = ""
    @State private var habitName: String = ""
    @State private var selectedIcon: String = "leaf.fill"
    @State private var selectedColor: String = "green"
    @State private var selectedCategory: HabitCategory = .fitness
    @State private var showSeedInfo = false
    @State private var showAllIcons = false

    private var availableIcons: [String] {
        return Array(Set(GameDatabase.allPlants.compactMap { $0.assetName ?? $0.symbolName }))
            .filter { $0 != "Samen" }
            .sorted()
    }

    private let availableColors = [
        "green", "mint", "teal", "cyan", "blue", "indigo",
        "purple", "pink", "red", "orange", "yellow", "brown"
    ]

    var isFormValid: Bool {
        !plantName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !habitName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appHintergrund.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {

                        // MARK: - Preview Section
                        VStack(spacing: 16) {
                            PflanzenButton(
                                plant: nil,
                                seltenheit: .bronze,
                                farbe: uiColor(for: selectedColor),
                                sekundaerFarbe: uiColor(for: selectedColor).darker(),
                                groesse: 120,
                                fallbackIcon: selectedIcon
                            )
                            .allowsHitTesting(false)

                            VStack(spacing: 4) {
                                Text(plantName.isEmpty
                                     ? String(localized: "plant.create.preview.name")
                                     : plantName)
                                    .font(.system(size: 24, weight: .black, design: .rounded))
                                    .foregroundStyle(.primary)

                                Text(habitName.isEmpty
                                     ? String(localized: "plant.create.preview.habit")
                                     : habitName)
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundStyle(.secondary)

                                HStack(spacing: 4) {
                                    Image(systemName: selectedCategory.icon)
                                    Text(NSLocalizedString(selectedCategory.localizationKey, comment: ""))
                                }
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)
                                .padding(.top, 2)
                            }
                        }
                        .padding(.top, 20)

                        // MARK: - Inputs
                        VStack(spacing: 24) {
                            VStack(alignment: .leading, spacing: 20) {
                                customTextField(
                                    title: String(localized: "plant.create.field.plant_name"),
                                    placeholder: String(localized: "plant.create.placeholder.plant"),
                                    text: $plantName
                                )

                                customTextField(
                                    title: String(localized: "plant.create.field.habit_name"),
                                    placeholder: String(localized: "plant.create.placeholder.habit"),
                                    text: $habitName
                                )
                            }

                            // Category Picker
                            VStack(alignment: .leading, spacing: 12) {
                                Text(String(localized: "shop.category.label"))
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .padding(.horizontal, 4)

                                Menu {
                                    ForEach(HabitCategory.allCases.filter { $0 != .seeds }, id: \.self) { cat in
                                        Button {
                                            selectedCategory = cat
                                            FeedbackManager.shared.playTap()
                                        } label: {
                                            Label(NSLocalizedString(cat.localizationKey, comment: ""), systemImage: cat.icon)
                                        }
                                    }
                                } label: {
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .fill(Color(hex: "#E5E5EA"))
                                            .frame(height: 56)

                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .fill(Color.white)
                                            .frame(height: 56)
                                            .overlay(
                                                HStack {
                                                    Image(systemName: selectedCategory.icon)
                                                        .font(.system(size: 20, weight: .bold))
                                                        .foregroundStyle(.primary)
                                                        .frame(width: 32, height: 32)

                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text(NSLocalizedString(selectedCategory.localizationKey, comment: ""))
                                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                                            .foregroundStyle(.primary)
                                                        Text(String(localized: "category.selection_hint"))
                                                            .font(.system(size: 12))
                                                            .foregroundStyle(.secondary)
                                                    }

                                                    Spacer()

                                                    Image(systemName: "chevron.up.chevron.down")
                                                        .font(.system(size: 14, weight: .bold))
                                                        .foregroundStyle(.secondary)
                                                }
                                                .padding(.horizontal, 16)
                                            )
                                            .offset(y: -4)
                                    }
                                    .frame(height: 60)
                                }
                                .tint(.primary)
                            }

                            // Icon Picker
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text(String(localized: "plant.create.select_symbol"))
                                        .font(.system(size: 16, weight: .bold, design: .rounded))

                                    Spacer()

                                    Button {
                                        showAllIcons = true
                                        FeedbackManager.shared.playTap()
                                    } label: {
                                        Image(systemName: "ellipsis")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(.black)
                                            .padding(8)
                                            .background(Circle().fill(Color.secondary.opacity(0.1)))
                                    }
                                }
                                .padding(.horizontal, 4)

                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                                    ForEach(availableIcons, id: \.self) { icon in
                                        Button {
                                            selectedIcon = icon
                                            FeedbackManager.shared.playTap()
                                        } label: {
                                            ZStack {
                                                Circle()
                                                    .fill(selectedIcon == icon ? uiColor(for: selectedColor).opacity(0.15) : Color.clear)
                                                    .frame(width: 74)

                                                if UIImage(named: icon) != nil {
                                                    Image(icon)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 70, height: 70)
                                                } else {
                                                    Image(systemName: icon)
                                                        .font(.system(size: 40))
                                                        .foregroundStyle(selectedIcon == icon ? uiColor(for: selectedColor) : .secondary)
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // Color Picker
                            VStack(alignment: .leading, spacing: 12) {
                                Text(String(localized: "plant.create.select_color"))
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .padding(.horizontal, 4)

                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                                    ForEach(availableColors, id: \.self) { color in
                                        Button {
                                            selectedColor = color
                                            FeedbackManager.shared.playTap()
                                        } label: {
                                            ZStack {
                                                Circle()
                                                    .fill(uiColor(for: color))
                                                    .frame(width: 34, height: 34)
                                                    .shadow(color: selectedColor == color ? uiColor(for: color).opacity(0.6) : .clear, radius: 8)

                                                if selectedColor == color {
                                                    Circle()
                                                        .stroke(uiColor(for: color), lineWidth: 3)
                                                        .frame(width: 44, height: 44)
                                                        .opacity(0.8)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)

                        // MARK: - Save Button
                        VStack(spacing: 8) {
                            Button(action: { performSaveAction() }) {
                                Text(String(localized: "onboarding.habit.create.save", defaultValue: "Gewohnheit hinzufügen"))
                            }
                            .buttonStyle(DuolingoButtonStyle(
                                size: .large,
                                fillWidth: true,
                                backgroundColor: isFormValid ? uiColor(for: selectedColor) : .gray.opacity(0.3),
                                shadowColor: isFormValid ? uiColor(for: selectedColor).darker() : .gray.opacity(0.5)
                            ))
                            .disabled(!isFormValid)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 10)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle(String(localized: "onboarding.habit.create.title", defaultValue: "Eigene Gewohnheit"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "common.cancel")) { dismiss() }
                }
            }
            .sheet(isPresented: $showAllIcons) {
                AllIconsSheet(
                    selectedIcon: $selectedIcon,
                    selectedColor: uiColor(for: selectedColor),
                    icons: availableIcons,
                    isNegative: false
                )
                .environmentObject(settings)
            }
            .onAppear {
                habitName = prefillName
                if let firstIcon = GameDatabase.allPlants.compactMap({ $0.assetName ?? $0.symbolName }).sorted().first {
                    selectedIcon = firstIcon
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Subviews

    @ViewBuilder
    private func customTextField(title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(hex: "#E5E5EA"))
                    .frame(height: 52)

                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white)
                    .frame(height: 52)
                    .overlay(
                        TextField(placeholder, text: text)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .padding(.horizontal, 16)
                    )
                    .offset(y: -4)
            }
            .frame(height: 56)
        }
    }

    // MARK: - Helpers

    private func uiColor(for name: String) -> Color {
        switch name {
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

    private func performSaveAction() {
        let trimmedPlant = plantName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedHabit = habitName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedPlant.isEmpty, !trimmedHabit.isEmpty else { return }

        FeedbackManager.shared.playSuccess()

        let customID = "custom.\(UUID().uuidString)"
        withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) {
            if data.gewaehltePflanzenIDs.count >= 2 {
                // Remove first non-custom selection to replace it
                if let firstNormal = data.gewaehltePflanzenIDs.first(where: { !$0.hasPrefix("custom.") }) {
                    data.gewaehltePflanzenIDs.removeAll { $0 == firstNormal }
                } else {
                    data.gewaehltePflanzenIDs.removeFirst()
                }
            }
            data.gewaehltePflanzenIDs.append(customID)
            data.customHabitNames[customID] = trimmedHabit
            data.customHabitIcons[customID] = selectedIcon
            data.customHabitColors[customID] = selectedColor
            data.customHabitCategories[customID] = selectedCategory
        }

        Task {
            TelemetryDeck.signal("onboarding_custom_habit_created", parameters: ["habit_name": trimmedHabit])
        }

        dismiss()
    }
}
