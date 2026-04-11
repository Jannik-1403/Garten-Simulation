import SwiftUI

struct OnboardingCustomPlantView: View {
    @EnvironmentObject var data: OnboardingData
    @EnvironmentObject var settings: SettingsStore
    @State private var showingAddSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            OnboardingIgelView(
                pose: .erklaert,
                sprechblasenText: settings.localizedString(for: "onboarding_custom_blase")
            )
            .padding(.top, 20)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    ForEach(data.customPflanzen) { habit in
                        CustomHabitCard(habit: habit) {
                            withAnimation(.spring()) {
                                data.customPflanzen.removeAll { $0.id == habit.id }
                            }
                        }
                    }
                    
                    if data.customPflanzen.count < 2 {
                        Button {
                            showingAddSheet = true
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text(settings.localizedString(for: "onboarding_custom_add"))
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
                Text(settings.localizedString(for: "onboarding_pflanzen_weiter"))
            }
            .buttonStyle(DuolingoButtonStyle(
                size: .large,
                backgroundColor: Color.blauPrimary,
                shadowColor: Color.blauPrimary.darker(),
                foregroundColor: .white
            ))
            .disabled(data.customPflanzen.isEmpty)
            .opacity(data.customPflanzen.isEmpty ? 0.6 : 1.0)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .sheet(isPresented: $showingAddSheet) {
            AddCustomHabitSheet { newHabit in
                data.customPflanzen.append(newHabit)
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
            ZStack {
                Circle()
                    .fill(Color.fromHex(habit.farbe).opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: habit.sfSymbol)
                    .font(.system(size: 24))
                    .foregroundStyle(Color.fromHex(habit.farbe))
            }
            
            Text(habit.name)
                .font(.system(.body, design: .rounded, weight: .bold))
            
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
    
    private let symbols = ["figure.walk", "book", "fork.knife", "moon", "heart", "brain.head.profile", "music.note", "paintbrush", "bicycle", "leaf", "flame", "drop"]
    private let colors = ["green", "blue", "orange", "purple", "red", "yellow"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(settings.localizedString(for: "onboarding_custom_name"))) {
                    TextField(settings.localizedString(for: "onboarding_custom_placeholder"), text: $name)
                }
                
                Section(header: Text(settings.localizedString(for: "onboarding_custom_icon"))) {
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
                
                Section(header: Text(settings.localizedString(for: "onboarding_custom_color"))) {
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
            }
            .navigationTitle(settings.localizedString(for: "onboarding_custom_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(settings.localizedString(for: "common.cancel")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(settings.localizedString(for: "common.add")) {
                        let new = CustomOnboardingPflanze(name: name, sfSymbol: selectedSymbol, farbe: selectedColor)
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

// Helper to bridge AppColors
extension Color {
    static func fromHex(_ name: String) -> Color {
        AppColors.color(for: name)
    }
}
