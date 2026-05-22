# Onboarding Code Files

## OnboardingCustomPlantView.swift
```swift
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
                    Text(settings.localizedString(for: habit.habitCategory.localizationKey))
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
                
                Section(header: Text(settings.localizedString(for: "shop.category.label"))) {
                    Picker(settings.localizedString(for: "shop.category.label"), selection: $selectedCategory) {
                        ForEach(HabitCategory.allCases, id: \.self) { cat in
                            Label(
                                settings.localizedString(for: cat.localizationKey),
                                systemImage: cat.icon
                            )
                            .tag(cat)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.primary)
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
            
            Text(settings.localizedString(for: category.localizationKey))
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(isSelected ? .primary : .secondary)
        }
        .onTapGesture(perform: action)
    }
}




```

## OnboardingData.swift
```swift
import SwiftUI
import Combine

struct CustomOnboardingPflanze: Identifiable, Codable {
    var id = UUID()
    var name: String
    var sfSymbol: String
    var farbe: String
    var habitCategory: HabitCategory = .lifestyle
}

class OnboardingData: ObservableObject {
    @Published var currentStep: Int = 1
    @Published var gewaehltesZiel: OnboardingZiel? = nil
    @Published var gewaehltePflanzenIDs: [String] = []
    @Published var customPflanzen: [CustomOnboardingPflanze] = []
    @Published var zielFehlt: Bool = false
    @Published var tutorialMuenzen: Int = 0
    @Published var erinnerungsZeiten: [String: Date] = [:]
    @Published var globalXPMultiplier: Double = 1.0
}

```

## OnboardingFertigView.swift
```swift
import SwiftUI

struct OnboardingFertigView: View {
    @EnvironmentObject var data: OnboardingData
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gartenPfadStore: GartenPfadStore
    
    @State private var innerPose: OnboardingIgelPose = .feiert
    
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
                                    .foregroundStyle(AppColors.color(for: custom.farbe))
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
            pflanzen: gardenStore.pflanzen
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
                    category: custom.habitCategory,
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

```

## OnboardingIgelView.swift
```swift
import SwiftUI

struct OnboardingIgelView: View {
    @EnvironmentObject var settings: SettingsStore
    let pose: OnboardingIgelPose
    let sprechblasenText: String

    // Backwards-compat initializer (old API)
    init(text: String, daumenHoch: Bool = false) {
        self.pose = daumenHoch ? .daumenHoch : .neutral
        self.sprechblasenText = text
    }
    
    // Primary initializer (new API)
    init(pose: OnboardingIgelPose, sprechblasenText: String) {
        self.pose = pose
        self.sprechblasenText = sprechblasenText
    }

    private var rotationDegrees: Double {
        switch pose {
        case .daumenHoch: return -8
        case .winkt:      return -6
        default:          return 0
        }
    }

    private var scaleFactor: CGFloat {
        switch pose {
        case .daumenHoch, .feiert: return 1.12
        default:                   return 1.0
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            // MARK: - Sprechblase
            ZStack(alignment: .bottom) {
                // Background bubble
                Text(sprechblasenText)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .frame(maxWidth: 260)
                    .background {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color(UIColor.systemBackground))
                            .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                    }
                
                // Triangle pointer
                Image(systemName: "triangle.fill")
                    .resizable()
                    .frame(width: 12, height: 6)
                    .rotationEffect(.degrees(180))
                    .foregroundStyle(Color(UIColor.systemBackground))
                    .offset(y: 5)
            }
            .padding(.bottom, 6)
            
            // MARK: - Igel
            Image("Powerup-Tier-Freund")
                .resizable()
                .scaledToFit()
                .frame(width: 130, height: 130)
                .rotationEffect(.degrees(rotationDegrees))
                .scaleEffect(scaleFactor)
                .shadow(color: .black.opacity(0.04), radius: 5, y: 3)
                .id("igel_image")
        }
        .padding(.top, -20)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: scaleFactor)
    }
}

// MARK: - Pose Enum used across Onboarding
enum OnboardingIgelPose {
    case neutral
    case erklaert
    case fragt
    case daumenHoch
    case giesst
    case winkt
    case feiert
}

#Preview {
    ZStack {
        Color.appHintergrund.ignoresSafeArea()
        OnboardingIgelView(pose: .daumenHoch, sprechblasenText: "Hallo! Ich bin Igel.")
    }
}

```

## OnboardingInteractiveTutorialView.swift
```swift
import SwiftUI

struct OnboardingInteractiveTutorialView: View {
    @EnvironmentObject var data: OnboardingData
    @EnvironmentObject var settings: SettingsStore
    
    @State private var innerPose: OnboardingIgelPose = .giesst
    @State private var gegossen = false
    @State private var ringProgress: CGFloat = 0.0
    @State private var showNext = false
    @State private var plantPosition: CGPoint = .zero
    
    var tutorialPlant: Plant? {
        guard let firstID = data.gewaehltePflanzenIDs.first else {
            return GameDatabase.allPlants.first
        }
        return GameDatabase.allPlants.first { $0.id == firstID }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                OnboardingIgelView(
                    pose: innerPose,
                    sprechblasenText: gegossen ? settings.localizedString(for: "onboarding_tutorial_giessen_erfolg") : settings.localizedString(for: "onboarding_tutorial_giessen_blase")
                )
                .padding(.top, 20)
                
                Spacer()
                
                // Simulated Plant Card (Unified with Garden View)
                if let plant = tutorialPlant {
                    VStack(spacing: 24) {
                        ZStack {
                            // Progress Ring (Garden Style)
                            Circle()
                                .stroke(Color.gray.opacity(0.15), lineWidth: 6)
                                .frame(width: 130, height: 130)
                            
                            Circle()
                                .trim(from: 0, to: ringProgress)
                                .stroke(
                                    Color.gruenPrimary,
                                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                                )
                                .frame(width: 130, height: 130)
                                .rotationEffect(.degrees(-90))
                                .animation(.spring(response: 0.6), value: ringProgress)
                            
                            // Target Glow (Garden Style)
                            Circle()
                                .stroke(Color.gruenPrimary.opacity(gegossen ? 0.6 : 0.0), lineWidth: 10)
                                .frame(width: 145, height: 145)
                                .blur(radius: 5)
                                .animation(.easeOut(duration: 0.3), value: gegossen)
                            
                            PflanzenButton(
                                plant: plant,
                                seltenheit: .bronze,
                                farbe: Color.gruenPrimary,
                                sekundaerFarbe: Color.gruenPrimary.darker(),
                                groesse: 120,
                                alwaysShowFullGrown: true,
                                externerPress: false
                            )
                            .overlay {
                                if gegossen {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 40))
                                        .foregroundStyle(Color.green)
                                        .background(Circle().fill(.white))
                                        .offset(x: 45, y: -45)
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                        }
                        .background(GeometryReader { geo in
                            Color.clear.onAppear {
                                plantPosition = geo.frame(in: .global).center
                            }
                            .onChange(of: geo.frame(in: .global)) { _, newValue in
                                plantPosition = newValue.center
                            }
                        })
                        
                        VStack(spacing: 4) {
                            Text(settings.localizedString(for: plant.localizedName))
                                .font(.system(size: 20, weight: .black, design: .rounded))
                            
                            Text(settings.localizedString(for: "onboarding_tutorial_giessen_test"))
                                .font(.system(.subheadline, design: .rounded, weight: .bold))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                if showNext {
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        withAnimation(.easeInOut(duration: 0.35)) {
                            data.currentStep += 1
                        }
                    } label: {
                        Text(settings.localizedString(for: "onboarding_weiter"))
                    }
                    .buttonStyle(DuolingoButtonStyle(
                        size: .large,
                        backgroundColor: Color.blauPrimary,
                        shadowColor: Color.blauPrimary.darker(),
                        foregroundColor: .white
                    ))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    // Spacer for the button area to keep layout stable
                    Spacer().frame(height: 100)
                }
            }
            
            // Interaction Layer
            if !gegossen && plantPosition != .zero {
                VStack {
                    Spacer()
                    DragToWater(
                        onGiessen: {
                            handleWateringSuccess()
                        },
                        pflanzenPosition: plantPosition,
                        istErledigt: gegossen
                    )
                    .frame(height: 100)
                    .padding(.bottom, 60) // Moved significantly lower
                }
            }
        }
        .animation(.spring(), value: gegossen)
        .animation(.spring(), value: showNext)
    }
    
    private func handleWateringSuccess() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            ringProgress = 1.0
            gegossen = true
            innerPose = .daumenHoch
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation {
                showNext = true
            }
        }
    }
}

extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}

```

## OnboardingPflanzenView.swift
```swift
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
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                Text(settings.localizedString(for: plant.localizedName))
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
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

```

## OnboardingPowerUpDetailSheet.swift
```swift
import SwiftUI

struct OnboardingPowerUpDetailSheet: View {
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.dismiss) private var dismiss
    
    var onUse: () -> Void
    
    // Golden Key details
    private let powerUpID = "powerup.goldener_schluessel"
    
    private var powerUp: PowerUpItem? {
        GameDatabase.allPowerUps.first { $0.id == powerUpID }
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.appHintergrund.ignoresSafeArea()
            
            VStack(spacing: 32) {
                if let item = powerUp {
                    // Hero Icon
                    VStack(spacing: 16) {
                        Image(item.symbolName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 140, height: 140)
                            .shadow(color: item.color.opacity(0.3), radius: 20, x: 0, y: 10)
                            .padding(.top, 60)
                        
                        Text(settings.localizedString(for: item.name))
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .multilineTextAlignment(.center)
                    }
                    
                    // Description
                    Text(settings.localizedString(for: item.description))
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    // Usage Hint
                    if !item.howToUse.isEmpty {
                        VStack(spacing: 8) {
                            Text(settings.localizedString(for: "shop.item.usage").uppercased())
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.tertiary)
                                .tracking(1.5)
                            
                            Text(settings.localizedString(for: item.howToUse))
                                .font(.system(size: 15))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .padding(.top, 8)
                    }
                    
                    Spacer()
                    
                    // USE Button
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        onUse()
                        dismiss()
                    } label: {
                        Text(settings.localizedString(for: "button.use"))
                    }
                    .buttonStyle(DuolingoButtonStyle(
                        size: .large,
                        fillWidth: true,
                        backgroundColor: item.color,
                        shadowColor: item.color.darker(),
                        foregroundColor: .white
                    ))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            
            // X Button
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.secondary)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(.ultraThinMaterial))
            }
            .padding(24)
        }
    }
}

#Preview {
    OnboardingPowerUpDetailSheet(onUse: {})
        .environmentObject(SettingsStore())
}

```

## OnboardingPowerUpTutorialView.swift
```swift
import SwiftUI

struct OnboardingPowerUpTutorialView: View {
    @EnvironmentObject var data: OnboardingData
    @EnvironmentObject var settings: SettingsStore
    
    @State private var innerPose: OnboardingIgelPose = .erklaert
    @State private var itemVerwendet = false
    @State private var showNext = false
    @State private var zeigeDetail = false
    
    // Golden Key details from GameDatabase
    private let powerUpID = "powerup.goldener_schluessel"
    
    var itemDetail: PowerUpItem? {
        GameDatabase.allPowerUps.first(where: { $0.id == powerUpID })
    }
    
    var bubbleText: String {
        if itemVerwendet {
            return settings.localizedString(for: "onboarding_tutorial_powerup_active_success")
        }
        return zeigeDetail ? settings.localizedString(for: "onboarding_tutorial_powerup_detail_hint") : settings.localizedString(for: "onboarding_tutorial_powerup_bubble")
    }
    
    var body: some View {
        VStack(spacing: 0) {
            OnboardingIgelView(
                pose: innerPose,
                sprechblasenText: bubbleText
            )
            .padding(.top, 20)
            
            Spacer()
            
            // Item 3D Button (Gameplay Style)
            if let item = itemDetail {
                VStack(spacing: 24) {
                    Item3DButton(
                        icon: item.symbolName,
                        farbe: item.color,
                        sekundaerFarbe: item.color.darker(),
                        groesse: 120
                    ) {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        zeigeDetail = true
                    }
                    .scaleEffect(itemVerwendet ? 0.8 : 1.0)
                    .opacity(itemVerwendet ? 0.6 : 1.0)
                    .grayscale(itemVerwendet ? 1.0 : 0.0)
                    .animation(.spring(), value: itemVerwendet)
                    
                    if !itemVerwendet {
                        Text(settings.localizedString(for: item.name))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .transition(.opacity)
                    }
                }
            }
            
            Spacer()
            
            if showNext {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    withAnimation(.easeInOut(duration: 0.35)) {
                        data.currentStep += 1
                    }
                } label: {
                    Text(settings.localizedString(for: "onboarding_weiter"))
                }
                .buttonStyle(DuolingoButtonStyle(
                    size: .large,
                    backgroundColor: Color.blauPrimary,
                    shadowColor: Color.blauPrimary.darker(),
                    foregroundColor: .white
                ))
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                Spacer().frame(height: 100)
            }
        }
        .sheet(isPresented: $zeigeDetail) {
            OnboardingPowerUpDetailSheet {
                handleUsage()
            }
        }
        .animation(.spring(), value: itemVerwendet)
    }
    
    private func handleUsage() {
        // Simuliere die Aktivierung im Onboarding-Status
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            itemVerwendet = true
            innerPose = .daumenHoch
            data.globalXPMultiplier = 1.5 // Multiplikator setzen
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation {
                showNext = true
                innerPose = .erklaert
            }
        }
    }
}

#Preview {
    OnboardingPowerUpTutorialView()
        .environmentObject(OnboardingData())
        .environmentObject(SettingsStore())
}

```

## OnboardingTutorialWeedView.swift
```swift
import SwiftUI

struct OnboardingTutorialWeedView: View {
    @EnvironmentObject var data: OnboardingData
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    
    @State private var innerPose: OnboardingIgelPose = .erklaert
    @State private var step: WeedTutorialStep = .intro
    @State private var rotation: Double = 0
    @State private var isSpinning = false
    @State private var showNext = false
    
    // UI Layout Config (Matching WheelOfFortuneView exactly)
    private let wheelSize: CGFloat = 310
    
    // Tutorial Layout: many weeds to show the "danger"
    private let tutorialLayout: [OnboardingSegmentKind] = [
        .safe, .weed, .safe, .weed, .gold, .weed,
        .safe, .weed, .safe, .weed, .safe, .weed
    ]
    
    enum WeedTutorialStep {
        case intro, buying, warning, wheel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            OnboardingIgelView(
                pose: innerPose,
                sprechblasenText: bubbleText
            )
            .padding(.top, 20)
            
            Spacer()
            
            ZStack {
                switch step {
                case .intro, .buying:
                    VStack(spacing: 24) {
                        DecorationCard(decoration: GameDatabase.allTrashItems[0])
                            .scaleEffect(1.2)
                            .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
                        
                        if step == .buying {
                            Button {
                                buyDecoration()
                            } label: {
                                Text(settings.localizedString(for: "onboarding_tutorial_weed_decoration_hint"))
                            }
                            .buttonStyle(DuolingoButtonStyle(
                                size: .medium,
                                backgroundColor: .gruenPrimary,
                                shadowColor: .gruenSecondary
                            ))
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    
                case .warning, .wheel:
                    // === THE "REAL" WHEEL ASSEMBLY (Standalone Implementation) ===
                    VStack(spacing: 0) {
                        ZStack {
                            // === 3D BASE LAYER ===
                            Circle()
                                .fill(Color(hex: "#0F1A30"))
                                .frame(width: wheelSize + 38, height: wheelSize + 38)
                            
                            // === 3D TOP LAYER & POINTER ===
                            ZStack {
                                // Main Wheel Top Layer
                                ZStack {
                                    // Dark blue outer ring
                                    Circle()
                                        .fill(Color(hex: "#1A2744"))
                                        .frame(width: wheelSize + 38, height: wheelSize + 38)
                                        .overlay(Circle().stroke(Color.black, lineWidth: 3))
                                    
                                    // Spinning Wheel
                                    OnboardingWheelSlices(layout: tutorialLayout)
                                        .frame(width: wheelSize, height: wheelSize)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.black, lineWidth: 2.5))
                                        .rotationEffect(.degrees(rotation))
                                    
                                    // Rim dots
                                    ForEach(0..<16, id: \.self) { i in
                                        OnboardingWheelRimDot(index: i, totalDots: 16, rimRadius: (wheelSize + 38) / 2.0 - 9.0)
                                    }
                                    
                                    // Center hub
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: "#0F1A30"))
                                            .frame(width: 36, height: 36)
                                        Circle()
                                            .fill(Color(hex: "#1A2744"))
                                            .frame(width: 36, height: 36)
                                            .overlay(Circle().stroke(Color.white.opacity(0.85), lineWidth: 3))
                                            .offset(y: -3)
                                    }
                                }
                                
                                // Pointer at top
                                ZStack {
                                    OnboardingWheelTrianglePointer()
                                        .fill(Color(hex: "#C8960C"))
                                        .frame(width: 28, height: 34)
                                    OnboardingWheelTrianglePointer()
                                        .fill(Color(hex: "#FFD700"))
                                        .frame(width: 28, height: 34)
                                        .overlay(OnboardingWheelTrianglePointer().stroke(Color.black, lineWidth: 2))
                                        .offset(y: -3)
                                }
                                .offset(y: -((wheelSize + 38) / 2) + 2)
                            }
                            .offset(y: -6)
                        }
                        .frame(width: wheelSize + 38, height: wheelSize + 38 + 6)
                        .scaleEffect(step == .wheel ? 1.0 : 0.85)
                        .opacity(step == .wheel ? 1.0 : 0.6)
                        .animation(.spring(), value: step)
                        
                        if step == .warning {
                            Button {
                                showWheelDemo()
                            } label: {
                                Text(settings.localizedString(for: "onboarding_weiter"))
                            }
                            .buttonStyle(DuolingoButtonStyle(size: .medium))
                            .padding(.top, 40)
                        }
                    }
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                }
            }
            .frame(maxHeight: .infinity)
            
            Spacer()
            
            if showNext {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    withAnimation(.easeInOut(duration: 0.35)) {
                        data.currentStep += 1
                    }
                } label: {
                    Text(settings.localizedString(for: "onboarding_weiter"))
                }
                .buttonStyle(DuolingoButtonStyle(
                    size: .large,
                    backgroundColor: Color.blauPrimary,
                    shadowColor: Color.blauPrimary.darker(),
                    foregroundColor: .white
                ))
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            } else {
                Spacer().frame(height: 100)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation { step = .buying }
            }
        }
    }
    
    private var bubbleText: String {
        switch step {
        case .intro: return settings.localizedString(for: "onboarding_tutorial_4_text")
        case .buying: return settings.localizedString(for: "onboarding_tutorial_weed_decoration_hint")
        case .warning: return settings.localizedString(for: "onboarding_tutorial_interactive_weed_bubble")
        case .wheel: return settings.localizedString(for: "onboarding_tutorial_interactive_weed_warning")
        }
    }
    
    private func buyDecoration() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        withAnimation(.spring()) {
            step = .warning
            innerPose = .erklaert
        }
    }
    
    private func showWheelDemo() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        withAnimation(.spring()) {
            step = .wheel
            innerPose = .fragt
        }
        
        let fullSpins = 3.0 * 360.0
        let targetRotation = rotation + fullSpins + 180 
        
        withAnimation(.timingCurve(0.15, 0.85, 0.35, 1.0, duration: 3.5)) {
            rotation = targetRotation
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            withAnimation {
                showNext = true
                innerPose = .erklaert
            }
        }
    }
}

// MARK: - Local Onboarding Wheel Components (Copied from WheelOfFortuneView)

enum OnboardingSegmentKind: Equatable {
    case weed, safe, gold
}

struct OnboardingWheelSlices: View {
    let layout: [OnboardingSegmentKind]

    var body: some View {
        GeometryReader { geo in
            let rect = geo.frame(in: .local)
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let radius = min(rect.width, rect.height) / 2
            let count = max(layout.count, 1)
            let segDeg = 360.0 / Double(count)

            ZStack {
                ForEach(0..<count, id: \.self) { i in
                    let kind = i < layout.count ? layout[i] : .safe
                    let startDeg = -90.0 + Double(i) * segDeg
                    let endDeg   = startDeg + segDeg
                    let midDeg   = startDeg + segDeg / 2
                    let midRad   = midDeg * .pi / 180
                    let iconR = radius * 0.62
                    
                    let color = colorFor(kind)

                    Path { path in
                        path.move(to: center)
                        path.addArc(center: center, radius: radius,
                                    startAngle: .degrees(startDeg),
                                    endAngle: .degrees(endDeg),
                                    clockwise: false)
                        path.closeSubpath()
                    }
                    .fill(color)

                    Path { path in
                        path.move(to: center)
                        path.addArc(center: center, radius: radius,
                                    startAngle: .degrees(startDeg),
                                    endAngle: .degrees(endDeg),
                                    clockwise: false)
                        path.closeSubpath()
                    }
                    .stroke(Color.black.opacity(0.4), lineWidth: 2)

                    OnboardingWheelSegmentIcon(kind: kind)
                        .rotationEffect(.degrees(midDeg + 90))
                        .position(
                            x: center.x + CGFloat(cos(midRad)) * iconR,
                            y: center.y + CGFloat(sin(midRad)) * iconR
                        )
                }
            }
        }
    }
    
    func colorFor(_ kind: OnboardingSegmentKind) -> Color {
        switch kind {
        case .safe: return Color.gruenPrimary
        case .weed: return Color.rotPrimary
        case .gold: return Color.coinBlue
        }
    }
}

struct OnboardingWheelSegmentIcon: View {
    let kind: OnboardingSegmentKind

    var body: some View {
        switch kind {
        case .gold:
            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
        case .weed:
            Image(systemName: "ant.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
        case .safe:
            Image(systemName: "leaf.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
        }
    }
}

struct OnboardingWheelRimDot: View {
    let index: Int
    let totalDots: Int
    let rimRadius: CGFloat

    var body: some View {
        let angle = Double(index) * (360.0 / Double(totalDots)) * .pi / 180.0 - .pi / 2.0
        let dx = CGFloat(cos(angle)) * rimRadius
        let dy = CGFloat(sin(angle)) * rimRadius
        RoundedRectangle(cornerRadius: 3)
            .fill(Color.white.opacity(0.85))
            .frame(width: 8, height: 8)
            .offset(x: dx, y: dy)
    }
}

struct OnboardingWheelTrianglePointer: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

```

## OnboardingView.swift
```swift
import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var garden: GardenStore
    
    @StateObject var data = OnboardingData()
    
    private let totalSteps = 8
    
    var body: some View {
        ZStack {
            Color.appHintergrund.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header: Back & Progress
                HStack(spacing: 16) {
                    if data.currentStep > 1 && data.currentStep < totalSteps {
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                data.currentStep -= 1
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Spacer().frame(width: 24)
                    }
                    
                    // Progressive Bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 12)
                            
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.blauPrimary, .blauPrimary.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * CGFloat(data.currentStep) / CGFloat(totalSteps), height: 12)
                        }
                    }
                    .frame(height: 12)
                    
                    Spacer().frame(width: 24)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                // Content
                ZStack {
                    switch data.currentStep {
                    case 1:
                        OnboardingWillkommenView()
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                        
                    case 2:
                        OnboardingZielView()
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                        
                    case 3:
                        Group {
                            if data.gewaehltesZiel != nil {
                                OnboardingPflanzenView()
                            } else {
                                OnboardingCustomPlantView()
                            }
                        }
                        .transition(AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                        
                    case 4:
                        OnboardingInteractiveTutorialView()
                        .onAppear {
                            Task {
                                _ = await NotificationManager.shared.requestPermission()
                            }
                        }
                        .transition(AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                        
                    case 5:
                        OnboardingZeitView()
                        .transition(AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                        
                    case 6:
                        OnboardingPowerUpTutorialView()
                        .transition(AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                        
                    case 7:
                        OnboardingTutorialWeedView()
                        .transition(AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                        
                    case 8:
                        OnboardingFertigView()
                        .transition(AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                        
                    default:
                        EmptyView()
                    }
                }
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: data.currentStep)
            }
            .environmentObject(data)
        }
    }
}

```

## OnboardingWillkommenView.swift
```swift
import SwiftUI

struct OnboardingWillkommenView: View {
    @EnvironmentObject var data: OnboardingData
    @EnvironmentObject var settings: SettingsStore
    @State private var showContent = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            if showContent {
                OnboardingIgelView(
                    pose: .winkt,
                    sprechblasenText: settings.localizedString(for: "onboarding_willkommen_blase")
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                
                VStack(spacing: 8) {
                    Text(settings.localizedString(for: "onboarding_willkommen_titel"))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.primary)
                    
                    Text(settings.localizedString(for: "onboarding_willkommen_untertitel"))
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .padding(.top, 40)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            Spacer()
            
            if showContent {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    withAnimation(.easeInOut(duration: 0.35)) {
                        data.currentStep += 1
                    }
                } label: {
                    Text(settings.localizedString(for: "onboarding_los_gehts"))
                }
                .buttonStyle(DuolingoButtonStyle(
                    size: .large,
                    backgroundColor: Color.blauPrimary,
                    shadowColor: Color.blauPrimary.darker(),
                    foregroundColor: .white
                ))
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                showContent = true
            }
        }
    }
}

```

## OnboardingZeitView.swift
```swift
import SwiftUI
import UserNotifications

struct OnboardingZeitView: View {
    @EnvironmentObject var data: OnboardingData
    @EnvironmentObject var settings: SettingsStore
    @State private var currentIndex = 0
    @State private var selectedTime = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
    
    var currentPlantId: String? {
        if !data.gewaehltePflanzenIDs.isEmpty {
            return data.gewaehltePflanzenIDs[currentIndex]
        } else if !data.customPflanzen.isEmpty {
            return data.customPflanzen[currentIndex].id.uuidString
        }
        return nil
    }
    
    var currentPlantName: String {
        if !data.gewaehltePflanzenIDs.isEmpty {
            let id = data.gewaehltePflanzenIDs[currentIndex]
            let plant = GameDatabase.allPlants.first { $0.id == id }
            return settings.localizedString(for: plant?.localizedName ?? "")
        } else if !data.customPflanzen.isEmpty {
            return data.customPflanzen[currentIndex].name
        }
        return ""
    }
    
    var totalPlants: Int {
        !data.gewaehltePflanzenIDs.isEmpty ? data.gewaehltePflanzenIDs.count : data.customPflanzen.count
    }

    var body: some View {
        VStack(spacing: 0) {
            OnboardingIgelView(
                pose: .fragt,
                sprechblasenText: String(format: settings.localizedString(for: "onboarding_zeit_blase_personal"), currentPlantName)
            )
            .padding(.top, 20)
            
            Spacer()
            
            VStack(spacing: 24) {
                // Mini Plant Card (No Emojis)
                HStack(spacing: 16) {
                    if !data.gewaehltePflanzenIDs.isEmpty {
                        let id = data.gewaehltePflanzenIDs[currentIndex]
                        if let plant = GameDatabase.allPlants.first(where: { $0.id == id }) {
                            PlantIconView(plant: plant, seltenheit: .bronze, size: 48, alwaysShowFullGrown: true)
                        }
                    } else {
                        Image(systemName: data.customPflanzen[currentIndex].sfSymbol)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(AppColors.color(for: data.customPflanzen[currentIndex].farbe))
                    }
                    
                    Text(currentPlantName)
                        .font(.system(.title3, design: .rounded, weight: .black))
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(Color(.systemBackground))
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
                
                DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
            
            // Step Indicator
            Text(String(format: settings.localizedString(for: "onboarding_zeit_progress"), currentIndex + 1, totalPlants))
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.bottom, 12)
            
            Button {
                saveAndNext()
            } label: {
                Text(settings.localizedString(for: "onboarding_zeit_weiter"))
            }
            .buttonStyle(DuolingoButtonStyle(
                size: .large,
                backgroundColor: Color.blauPrimary,
                shadowColor: Color.blauPrimary.darker(),
                foregroundColor: .white
            ))
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
    
    private func saveAndNext() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        if let id = currentPlantId {
            data.erinnerungsZeiten[id] = selectedTime
        }
        
        if currentIndex < totalPlants - 1 {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                currentIndex += 1
            }
        } else {
            // Request Notification Permissions directly from Apple before moving to next step
            requestNotificationPermissions()
            
            withAnimation(.easeInOut(duration: 0.35)) {
                data.currentStep += 1
            }
        }
    }
    
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("Notifications allowed")
                } else if let error = error {
                    print("Notification error: \(error.localizedDescription)")
                }
            }
        }
    }
}

```

## OnboardingZielModel.swift
```swift
import Foundation
import SwiftUI

enum OnboardingZiel: String, CaseIterable, Identifiable {
    case gesund, produktiv, mental, fit, lernen
    
    var id: String { self.rawValue }
    
    var localizationKey: String {
        "onboarding_ziel_\(self.rawValue)"
    }
    
    var emoji: String {
        switch self {
        case .gesund:    return "🍏"
        case .produktiv: return "🎯"
        case .mental:    return "🧘"
        case .fit:       return "🏃"
        case .lernen:    return "📚"
        }
    }
    
    var labelKey: String {
        "onboarding_ziel_\(self.rawValue)_label"
    }
    
    var iconName: String {
        switch self {
        case .gesund:    return "fork.knife"
        case .produktiv: return "target"
        case .mental:    return "brain.head.profile"
        case .fit:       return "figure.run"
        case .lernen:    return "book.closed"
        }
    }
    
    var color: Color {
        switch self {
        case .gesund:    return Color(red: 0.2, green: 0.84, blue: 0.53) // Vibrant Mint/Green
        case .produktiv: return Color(red: 0.11, green: 0.55, blue: 0.96) // Deep Sky Blue
        case .mental:    return Color(red: 0.64, green: 0.45, blue: 1.0) // Soft Radiant Purple
        case .fit:       return Color(red: 1.0, green: 0.44, blue: 0.26) // Vivid Coral/Orange
        case .lernen:    return Color(red: 0.36, green: 0.39, blue: 0.94) // Intelligent Indigo
        }
    }
    
    var pflanzenIDs: [String] {
        switch self {
        case .gesund:    return ["plant.apfelbaum", "plant.zitronenbaum", "plant.erdbeerpflanze", "plant.weinrebe", "plant.minzpflanze"]
        case .produktiv: return ["plant.bambus", "plant.weizenfeld", "plant.kirschbaum", "plant.mandelbaum", "plant.apfelbaum"]
        case .mental:    return ["plant.lotus", "plant.lavendel", "plant.klee", "plant.aloe_vera", "plant.sonnenblume"]
        case .fit:       return ["plant.wildgras", "plant.kaktus", "plant.efeu", "plant.bambus", "plant.sonnenblume"]
        case .lernen:    return ["plant.weizenfeld", "plant.mandelbaum", "plant.minzpflanze", "plant.lotus", "plant.bambus"]
        }
    }
}

```

## OnboardingZielView.swift
```swift
import SwiftUI

struct OnboardingZielView: View {
    @EnvironmentObject var data: OnboardingData
    @EnvironmentObject var settings: SettingsStore
    @State private var innerPose: OnboardingIgelPose = .fragt

    var body: some View {
        VStack(spacing: 0) {
            OnboardingIgelView(
                pose: innerPose,
                sprechblasenText: settings.localizedString(for: "onboarding_ziel_blase")
            )
            .padding(.top, 20)
            
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 24) {
                    ForEach(OnboardingZiel.allCases) { ziel in
                        VStack(spacing: 12) {
                            Item3DButton(
                                icon: ziel.iconName,
                                farbe: ziel.color,
                                sekundaerFarbe: ziel.color.darker(),
                                groesse: 100,
                                aktion: {
                                    selectZiel(ziel)
                                }
                            )
                            .overlay(alignment: .topTrailing) {
                                if data.gewaehltesZiel == ziel {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.green)
                                        .background(Circle().fill(.white))
                                        .font(.title)
                                        .offset(x: 10, y: -10)
                                }
                            }
                            
                            Text(settings.localizedString(for: ziel.labelKey))
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .multilineTextAlignment(.center)
                                .foregroundStyle(data.gewaehltesZiel == ziel ? .primary : .secondary)
                        }
                        .scaleEffect(data.gewaehltesZiel == ziel ? 1.05 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: data.gewaehltesZiel)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                
                Button {
                    selectZielMissing()
                } label: {
                    Text(settings.localizedString(for: "onboarding_ziel_fehlt"))
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 24)
                .padding(.bottom, 20)
            }
            
            // Fixed Bottom Button
            if data.gewaehltesZiel != nil || data.zielFehlt {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    withAnimation(.easeInOut(duration: 0.35)) {
                        data.currentStep += 1
                    }
                } label: {
                    Text(settings.localizedString(for: "onboarding_weiter"))
                }
                .buttonStyle(DuolingoButtonStyle(
                    size: .large,
                    backgroundColor: Color.blauPrimary,
                    shadowColor: Color.blauPrimary.darker(),
                    foregroundColor: .white
                ))
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    private func selectZiel(_ ziel: OnboardingZiel) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        withAnimation(.spring()) {
            data.gewaehltesZiel = ziel
            data.zielFehlt = false
            innerPose = .daumenHoch
        }
    }

    private func selectZielMissing() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation {
            data.gewaehltesZiel = nil
            data.zielFehlt = true
            innerPose = .fragt
        }
    }
}

```

