import SwiftUI

/// Vereinfachte Custom-Habit-Erstellung für das Onboarding.
/// Basiert auf CustomPlantCreationView, aber ohne Samen-Kosten, ohne Bad-Habit-Toggle
/// und ohne Goal-Link. Der User gibt nur Gewohnheitsname + Icon + Kategorie ein.
struct OnboardingHabitCreationSheet: View {
    @EnvironmentObject var data: OnboardingData
    @Environment(\.dismiss) var dismiss

    let prefillName: String

    @State private var habitName: String = ""
    @State private var selectedIcon: String = ""
    @State private var selectedColor: String = "green"
    @State private var selectedCategory: HabitCategory = .lifestyle
    @FocusState private var habitNameFocused: Bool

    private var availableIcons: [String] {
        Array(Set(GameDatabase.allPlants.compactMap { $0.assetName ?? $0.symbolName }))
            .filter { $0 != "Samen" }
            .sorted()
    }

    private let availableColors = [
        "green", "mint", "teal", "cyan", "blue", "indigo",
        "purple", "pink", "red", "orange", "yellow", "brown"
    ]

    private var isFormValid: Bool {
        !habitName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {

                        // MARK: - Preview
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(uiColor(for: selectedColor).opacity(0.15))
                                    .frame(width: 100, height: 100)

                                if !selectedIcon.isEmpty {
                                    if UIImage(named: selectedIcon) != nil {
                                        Image(selectedIcon)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 72, height: 72)
                                    } else {
                                        Image(systemName: selectedIcon)
                                            .font(.system(size: 40))
                                            .foregroundStyle(uiColor(for: selectedColor))
                                    }
                                } else {
                                    Image(systemName: "leaf.fill")
                                        .font(.system(size: 40))
                                        .foregroundStyle(uiColor(for: selectedColor).opacity(0.5))
                                }
                            }
                            .item3DContainer(
                                farbe: Color(UIColor.systemBackground),
                                sekundaerFarbe: Color(UIColor.systemGray5)
                            )

                            Text(habitName.isEmpty
                                 ? String(localized: "onboarding.habit.create.habitname.placeholder", defaultValue: "z. B. Gitarre spielen")
                                 : habitName)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(habitName.isEmpty ? .secondary : .primary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)

                        // MARK: - Habit Name Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text(String(localized: "onboarding.habit.create.habitname.label", defaultValue: "Gewohnheitsname"))
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 4)

                            HStack {
                                TextField(
                                    String(localized: "onboarding.habit.create.habitname.placeholder", defaultValue: "z. B. Gitarre spielen"),
                                    text: $habitName
                                )
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .focused($habitNameFocused)
                                .autocorrectionDisabled()

                                if !habitName.isEmpty {
                                    Button { habitName = "" } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .item3DContainer(
                                farbe: Color(UIColor.systemBackground),
                                sekundaerFarbe: Color(UIColor.systemGray5)
                            )
                        }
                        .padding(.horizontal, 24)

                        // MARK: - Category Picker
                        VStack(alignment: .leading, spacing: 12) {
                            Text(String(localized: "shop.category.label"))
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 4)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(HabitCategory.allCases.filter { $0 != .seeds }, id: \.self) { cat in
                                        Button {
                                            selectedCategory = cat
                                            FeedbackManager.shared.playTap()
                                        } label: {
                                            HStack(spacing: 6) {
                                                Image(systemName: cat.icon)
                                                    .font(.system(size: 13, weight: .bold))
                                                Text(NSLocalizedString(cat.localizationKey, comment: ""))
                                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                            }
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 10)
                                        }
                                        .buttonStyle(Item3DButtonStyle(
                                            farbe: selectedCategory == cat ? cat.color : Color(UIColor.systemBackground),
                                            sekundaerFarbe: selectedCategory == cat ? cat.color.darker() : Color(UIColor.systemGray5),
                                            groesse: 44,
                                            shadowDepthFactor: 0.1,
                                            isRectangular: true,
                                            isPermanentlyPressed: selectedCategory == cat
                                        ))
                                        .foregroundStyle(selectedCategory == cat ? .white : .primary)
                                    }
                                }
                                .padding(.horizontal, 24)
                                .padding(.bottom, 6)
                            }
                        }

                        // MARK: - Icon Picker
                        VStack(alignment: .leading, spacing: 12) {
                            Text(String(localized: "plant.create.select_symbol"))
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 4)

                            LazyVGrid(
                                columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4),
                                spacing: 10
                            ) {
                                ForEach(availableIcons, id: \.self) { icon in
                                    Button {
                                        selectedIcon = icon
                                        FeedbackManager.shared.playTap()
                                    } label: {
                                        ZStack {
                                            if UIImage(named: icon) != nil {
                                                Image(icon)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 52, height: 52)
                                            } else {
                                                Image(systemName: icon)
                                                    .font(.system(size: 28))
                                                    .foregroundStyle(selectedIcon == icon ? uiColor(for: selectedColor) : .secondary)
                                            }
                                        }
                                        .frame(width: 70, height: 70)
                                    }
                                    .buttonStyle(Item3DButtonStyle(
                                        farbe: selectedIcon == icon ? uiColor(for: selectedColor).opacity(0.15) : Color(UIColor.systemBackground),
                                        sekundaerFarbe: selectedIcon == icon ? uiColor(for: selectedColor).opacity(0.3) : Color(UIColor.systemGray5),
                                        groesse: 70,
                                        shadowDepthFactor: 0.07,
                                        isPermanentlyPressed: selectedIcon == icon
                                    ))
                                }
                            }
                            .padding(.horizontal, 24)
                        }

                        // MARK: - Save Button
                        Item3DButton(
                            farbe: isFormValid ? Color.gruenPrimary : Color(UIColor.systemGray4),
                            sekundaerFarbe: isFormValid ? Color.gruenPrimary.darker() : Color(UIColor.systemGray5),
                            groesse: 54,
                            isRectangular: true,
                            isDisabled: !isFormValid,
                            aktion: { saveAndDismiss() }
                        ) {
                            Text(String(localized: "onboarding.habit.create.save", defaultValue: "Gewohnheit hinzufügen"))
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundColor(isFormValid ? .white : .secondary)
                                .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle(String(localized: "onboarding.habit.create.title", defaultValue: "Eigene Gewohnheit erstellen"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "common.cancel")) { dismiss() }
                }
            }
            .onAppear {
                habitName = prefillName
                if let first = availableIcons.first { selectedIcon = first }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    habitNameFocused = true
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Helpers

    private func saveAndDismiss() {
        let trimmed = habitName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        FeedbackManager.shared.playSuccess()

        let customID = "custom.\(UUID().uuidString)"
        withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) {
            if data.gewaehltePflanzenIDs.count >= 2 {
                data.gewaehltePflanzenIDs.removeFirst()
            }
            data.gewaehltePflanzenIDs.append(customID)
            data.customHabitNames[customID] = trimmed
            data.customHabitIcons[customID] = selectedIcon
            data.customHabitColors[customID] = selectedColor
            data.customHabitCategories[customID] = selectedCategory
        }
        dismiss()
    }

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
}
