import SwiftUI

struct OnboardingCustomPlantView: View {
    @EnvironmentObject var data: OnboardingData
    @EnvironmentObject var settings: SettingsStore
    @State private var showingAddSheet = false
    @State private var customPflanzen: [CustomOnboardingPflanze] = []
    
    var body: some View {
        VStack(spacing: 0) {
            OnboardingIgelView(
                pose: .erklaert,
                sprechblasenText: String(localized: "onboarding_custom_blase")
            )
            .padding(.top, 20)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    ForEach(customPflanzen) { habit in
                        CustomHabitCard(habit: habit) {
                            withAnimation(.spring()) {
                                customPflanzen.removeAll { $0.id == habit.id }
                            }
                        }
                    }
                    
                    if customPflanzen.count < 2 {
                        Button {
                            showingAddSheet = true
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text(String(localized: "onboarding_custom_add"))
                            }
                        }
                        .buttonStyle(DuolingoButtonStyle(
                            size: .large,
                            backgroundColor: Color.secondary.opacity(0.1),
                            shadowColor: Color.secondary.opacity(0.2),
                            foregroundColor: .primary
                        ))
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
                Text(String(localized: "onboarding_pflanzen_weiter"))
            }
            .buttonStyle(DuolingoButtonStyle(
                size: .large,
                backgroundColor: Color.blauPrimary,
                shadowColor: Color.blauPrimary.darker(),
                foregroundColor: .white
            ))
            .disabled(customPflanzen.isEmpty)
            .opacity(customPflanzen.isEmpty ? 0.6 : 1.0)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .sheet(isPresented: $showingAddSheet) {
            AddCustomHabitSheet { newHabit in
                customPflanzen.append(newHabit)
                showingAddSheet = false
            }
            .environmentObject(settings)
        }
    }
}

struct CustomHabitCard: View {
    let habit: CustomOnboardingPflanze
    let onDelete: () -> Void
    @EnvironmentObject var settings: SettingsStore
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: habit.sfSymbol)
                .font(.system(size: 24))
                .foregroundStyle(.primary)
                .frame(width: 50, height: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.system(.body, design: .rounded, weight: .bold))
                
                HStack(spacing: 4) {
                    Image(systemName: habit.habitCategory.icon)
                        .font(.system(size: 10, weight: .bold))
                    Text(NSLocalizedString(habit.habitCategory.localizationKey, comment: ""))
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                }
                .foregroundStyle(.primary)
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary.opacity(0.5))
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.black.opacity(0.08))
                .offset(y: 4)
        )
    }
}

struct AddCustomHabitSheet: View {
    let onAdd: (CustomOnboardingPflanze) -> Void
    @EnvironmentObject var settings: SettingsStore
    
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var selectedSymbol = "figure.walk"
    @State private var selectedColor = "green"
    @State private var selectedCategory: HabitCategory = .fitness
    
    private let symbols = ["figure.walk", "book", "fork.knife", "moon", "heart", "brain.head.profile", "music.note", "paintbrush", "bicycle", "leaf", "flame", "drop"]
    private let colors = ["green", "blue", "orange", "purple", "red", "yellow"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(String(localized: "onboarding_custom_name"))) {
                    TextField(String(localized: "onboarding_custom_placeholder"), text: $name)
                }
                
                Section(header: Text(String(localized: "onboarding_custom_icon"))) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(symbols, id: \.self) { symbol in
                                SymbolCircle(
                                    symbol: symbol,
                                    isSelected: selectedSymbol == symbol,
                                    action: { selectedSymbol = symbol }
                                )
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section(header: Text(String(localized: "onboarding_custom_color"))) {
                    HStack(spacing: 15) {
                        ForEach(colors, id: \.self) { color in
                            ColorCircle(
                                colorName: color,
                                isSelected: selectedColor == color,
                                action: { selectedColor = color }
                            )
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text(String(localized: "shop.category.label"))) {
                    Picker(String(localized: "shop.category.label"), selection: $selectedCategory) {
                        ForEach(HabitCategory.allCases.filter { $0 != .seeds }, id: \.self) { cat in
                            Label(
                                NSLocalizedString(cat.localizationKey, comment: ""),
                                systemImage: cat.icon
                            )
                            .tag(cat)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.primary)
                }
            }
            .navigationTitle(String(localized: "onboarding_custom_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "common.cancel")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "common.add")) {
                        let new = CustomOnboardingPflanze(
                            name: name, 
                            sfSymbol: selectedSymbol, 
                            farbe: selectedColor,
                            habitCategory: selectedCategory
                        )
                        onAdd(new)
                    }
                    .disabled(name.isEmpty)
                    .fontWeight(.bold)
                }
            }
        }
    }
}

// MARK: - Subviews for Sheet
struct SymbolCircle: View {
    let symbol: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Image(systemName: symbol)
            .font(.title2)
            .padding(10)
            .background(isSelected ? Color.blauPrimary.opacity(0.2) : Color.clear)
            .clipShape(Circle())
            .overlay(Circle().stroke(isSelected ? Color.blauPrimary : Color.clear, lineWidth: 2))
            .onTapGesture(perform: action)
    }
}

struct ColorCircle: View {
    let colorName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Circle()
            .fill(AppColors.color(for: colorName))
            .frame(width: 30, height: 30)
            .overlay(Circle().stroke(isSelected ? Color.primary : Color.clear, lineWidth: 2))
            .onTapGesture(perform: action)
    }
}

struct CategoryCircle: View {
    let category: HabitCategory
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject var settings: SettingsStore
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(isSelected ? category.color.opacity(0.2) : Color.clear)
                    .frame(width: 44, height: 44)
                
                Image(systemName: category.icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(isSelected ? category.color : .secondary)
            }
            .overlay(Circle().stroke(isSelected ? category.color : Color.clear, lineWidth: 2))
            
            Text(NSLocalizedString(category.localizationKey, comment: ""))
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(isSelected ? .primary : .secondary)
        }
        .onTapGesture(perform: action)
    }
}



