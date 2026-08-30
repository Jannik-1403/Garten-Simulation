import SwiftUI

struct CustomPlantCreationView: View {
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.dismiss) var dismiss
    
    @State private var plantName: String = ""
    @State private var habitName: String = ""
    @State private var selectedIcon: String = "leaf.fill"
    @State private var selectedColor: String = "green"
    @State private var selectedCategory: HabitCategory = .fitness
    @State private var isNegative: Bool = false
    @State private var showSeedInfo = false
    @State private var showAllIcons = false
    @State private var newCreatedPlant: HabitModel? = nil
    @State private var selectedGoalWeight: GoalWeight? = nil
    @State private var showGoalLinkInfo = false
    
    private var availableIcons: [String] {
        if isNegative {
            // Get all unique decoration asset symbols from the database
            return Array(Set(GameDatabase.allDecorations.map { $0.sfSymbol })).sorted()
        } else {
            // Get all unique plant asset symbols/names from the database
            return Array(Set(GameDatabase.allPlants.compactMap { $0.assetName ?? $0.symbolName }))
                .filter { $0 != "Samen" }
                .sorted()
        }
    }
    
    private var allIcons: [String] {
        availableIcons
    }
    
    private let availableColors = [
        "green", "mint", "teal", "cyan", "blue", "indigo", 
        "purple", "pink", "red", "orange", "yellow", "brown"
    ]
    
    var isFormValid: Bool {
        let hasYearGoal = GoalStore.shared.activeGoals.contains(where: { $0.type == .year })
        let isGoalWeightValid = isNegative ? true : (!hasYearGoal || selectedGoalWeight != nil)
        
        return !plantName.trimmingCharacters(in: .whitespaces).isEmpty &&
               !habitName.trimmingCharacters(in: .whitespaces).isEmpty &&
               (isNegative || gardenStore.seeds >= 10) &&
               isGoalWeightValid
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
                                Text(plantName.isEmpty ? (isNegative ? String(localized: "plant.create.preview.trash_name") : String(localized: "plant.create.preview.name")) : plantName)
                                    .font(.system(size: 24, weight: .black, design: .rounded))
                                    .foregroundStyle(.primary)
                                
                                Text(habitName.isEmpty ? (isNegative ? String(localized: "plant.create.preview.bad_habit") : String(localized: "plant.create.preview.habit")) : habitName)
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundStyle(.secondary)
                                
                                if !isNegative {
                                    HStack(spacing: 4) {
                                        Image(systemName: selectedCategory.icon)
                                        Text(NSLocalizedString(selectedCategory.localizationKey, comment: ""))
                                    }
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundStyle(.primary)
                                    .padding(.top, 2)
                                }
                            }
                        }
                        .padding(.top, 20)
                        
                        // MARK: - Inputs
                        VStack(spacing: 24) {
                            // Text Input Section
                            VStack(alignment: .leading, spacing: 20) {
                                customTextField(
                                    title: isNegative ? String(localized: "plant.create.field.trash_name") : String(localized: "plant.create.field.plant_name"), 
                                    placeholder: isNegative ? String(localized: "plant.create.placeholder.trash_name") : String(localized: "plant.create.placeholder.plant"), 
                                    text: $plantName
                                )
                                
                                customTextField(
                                    title: isNegative ? String(localized: "plant.create.preview.bad_habit") : String(localized: "plant.create.field.habit_name"), 
                                    placeholder: isNegative ? String(localized: "plant.create.placeholder.bad_habit") : String(localized: "plant.create.placeholder.habit"), 
                                    text: $habitName
                                )
                            }
                            
                            // Bad Habit 3D Toggle Selector
                            VStack(alignment: .leading, spacing: 12) {
                                Text(String(localized: "plant.create.habit_type"))
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .padding(.horizontal, 4)
                                
                                HStack(spacing: 16) {
                                    // Button 1: Gute Angewohnheit
                                    Button {
                                        FeedbackManager.shared.playTap()
                                        isNegative = false
                                        selectedColor = "green"
                                        // Reset to first plant icon
                                        if let firstIcon = GameDatabase.allPlants.compactMap({ $0.assetName ?? $0.symbolName }).sorted().first {
                                            selectedIcon = firstIcon
                                        }
                                    } label: {
                                        HStack {
                                            Image(systemName: "plus.circle.fill")
                                            Text(String(localized: "plant.create.good_habit.short", defaultValue: "Gute"))
                                        }
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                    }
                                    .buttonStyle(Item3DButtonStyle(
                                        farbe: !isNegative ? Color.gruenPrimary : .white,
                                        sekundaerFarbe: !isNegative ? Color.gruenSecondary : Color(hex: "#E5E5EA"),
                                        groesse: 48,
                                        iconSkalierung: 1.0,
                                        shadowDepthFactor: 0.08,
                                        isRectangular: true,
                                        isPermanentlyPressed: !isNegative
                                    ))
                                    
                                    // Button 2: Schlechte Angewohnheit
                                    Button {
                                        FeedbackManager.shared.playTap()
                                        isNegative = true
                                        selectedColor = "red"
                                        // Reset to first decoration/trash icon
                                        if let firstIcon = GameDatabase.allDecorations.map({ $0.sfSymbol }).sorted().first {
                                            selectedIcon = firstIcon
                                        }
                                    } label: {
                                        HStack {
                                            Image(systemName: "minus.circle.fill")
                                            Text(String(localized: "plant.create.bad_habit.short", defaultValue: "Schlechte"))
                                        }
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                    }
                                    .buttonStyle(Item3DButtonStyle(
                                        farbe: isNegative ? Color.red : .white,
                                        sekundaerFarbe: isNegative ? Color.red.darker() : Color(hex: "#E5E5EA"),
                                        groesse: 48,
                                        iconSkalierung: 1.0,
                                        shadowDepthFactor: 0.08,
                                        isRectangular: true,
                                        isPermanentlyPressed: isNegative
                                    ))
                                }
                            }
                            
                            // Category Picker (Only shown when NOT isNegative)
                            if !isNegative {
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
                                                Label(
                                                    NSLocalizedString(cat.localizationKey, comment: ""),
                                                    systemImage: cat.icon
                                                )
                                            }
                                        }
                                    } label: {
                                        ZStack(alignment: .leading) {
                                            // Bottom shadow base layer
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .fill(Color(hex: "#E5E5EA"))
                                                .frame(height: 56)
                                            
                                            // Top white layer shifted upwards
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
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: isNegative ? 6 : 4), spacing: 12) {
                                    ForEach(availableIcons, id: \.self) { icon in
                                        Button {
                                            selectedIcon = icon
                                            FeedbackManager.shared.playTap()
                                        } label: {
                                            ZStack {
                                                Circle()
                                                    .fill(selectedIcon == icon ? uiColor(for: selectedColor).opacity(0.15) : Color.clear)
                                                    .frame(width: isNegative ? 44 : 74)
                                                
                                                if UIImage(named: icon) != nil {
                                                    Image(icon)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: isNegative ? 28 : 70, height: isNegative ? 28 : 70)
                                                        .scaleEffect(isNegative ? 2.2 : 1.0)
                                                } else {
                                                    Image(systemName: icon)
                                                        .font(.system(size: isNegative ? 20 : 40))
                                                        .foregroundStyle(selectedIcon == icon ? uiColor(for: selectedColor) : .secondary)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // Color Picker (Only shown when NOT isNegative)
                            if !isNegative {
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
                        }
                        .padding(.horizontal, 24)
                        
                        if !isNegative && GoalStore.shared.activeGoals.contains(where: { $0.type == .year }) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text(String(localized: "goal.link.title", defaultValue: "Ziel-Beitrag"))
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundStyle(.primary)
                                        
                                    Button {
                                        FeedbackManager.shared.playTap()
                                        showGoalLinkInfo = true
                                    } label: {
                                        Image(systemName: "info.circle")
                                            .foregroundColor(.primary)
                                    }
                                }
                                
                                HStack(spacing: 8) {
                                    ForEach([GoalWeight.massive, .bit, .none], id: \.self) { weight in
                                        let baseColor: Color = weight == .massive ? .green : (weight == .bit ? .orange : .red)
                                        let isSelected = selectedGoalWeight == weight
                                        
                                        Item3DButton(
                                            farbe: isSelected ? baseColor : Color(UIColor.systemGray5),
                                            sekundaerFarbe: isSelected ? baseColor.darker() : Color(UIColor.systemGray4),
                                            groesse: 48,
                                            isRectangular: true,
                                            isPermanentlyPressed: isSelected,
                                            aktion: { selectedGoalWeight = weight }
                                        ) {
                                            Text("\(weight.rawValue) \(String(localized: "common.points.short", defaultValue: "Pkt"))")
                                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                                .foregroundColor(isSelected ? .white : .primary)
                                                .padding(.horizontal, 8)
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 8)
                        }
                        
                        // MARK: - Save Button
                        VStack(spacing: 8) {
                            Button(action: {
                                performSaveAction()
                            }) {
                                Text(String(localized: "button.save_create"))
                            }
                            .buttonStyle(DuolingoButtonStyle(
                                size: .large,
                                fillWidth: true,
                                backgroundColor: isFormValid ? uiColor(for: selectedColor) : .gray.opacity(0.3),
                                shadowColor: isFormValid ? uiColor(for: selectedColor).darker() : .gray.opacity(0.5)
                            ))
                            .disabled(!isFormValid)
                            
                            if !isNegative && gardenStore.seeds < 10 {
                                Text(String(localized: "plant.create.insufficient_seeds"))
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundStyle(.red)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 4)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 10)
                        
                        if !isNegative {
                            Text(String(format: String(localized: "inventory.create_plant.cost_format"), 10))
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                                .padding(.bottom, 40)
                        }
                    }
                }
            }
            .navigationTitle(isNegative ? String(localized: "plant.create.preview.bad_habit") : String(localized: "inventory.create_plant"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    LiquidGlassDismissButton { dismiss() }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSeedInfo = true
                        FeedbackManager.shared.playTap()
                    } label: {
                        Text(verbatim: "\(gardenStore.seeds)")
                            .font(.system(size: 17, weight: .black, design: .rounded))
                            .foregroundStyle(.black)
                    }
                }
            }
            .alert(String(localized: "inventory.seeds.info.title"), isPresented: $showSeedInfo) {
                Button(String(localized: "button.ok"), role: .cancel) { }
            } message: {
                Text(String(format: String(localized: "inventory.seeds.info.body"), gardenStore.seeds))
            }
            .alert(String(localized: "goal.link.info.title", defaultValue: "Punkte & Ziele"), isPresented: $showGoalLinkInfo) {
                Button(String(localized: "button.ok"), role: .cancel) { }
            } message: {
                Text(String(localized: "goal.link.info.message", defaultValue: "Gewohnheiten bringen Punkte für dein 1-Jahresziel.\n\n20 Pkt: Enormer Fokus\n5 Pkt: Leichter Beitrag\n0 Pkt: Hat nichts mit dem Ziel zu tun"))
            }
            .sheet(isPresented: $showAllIcons) {
                AllIconsSheet(selectedIcon: $selectedIcon, selectedColor: uiColor(for: selectedColor), icons: allIcons, isNegative: isNegative)
                    .environmentObject(settings)
            }
            .onAppear {
                // Initialize to first plant icon
                if let firstIcon = GameDatabase.allPlants.compactMap({ $0.assetName ?? $0.symbolName }).sorted().first {
                    selectedIcon = firstIcon
                }
            }
        }
    }
    
    @ViewBuilder
    private func customTextField(title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)
            
            ZStack(alignment: .leading) {
                // Bottom shadow base layer
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(hex: "#E5E5EA"))
                    .frame(height: 52)
                
                // Top white layer shifted upwards
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
        case "gray":    return .gray
        default:        return .green
        }
    }
    
    private func performSaveAction() {
        FeedbackManager.shared.playSuccess()
        let newPlant = gardenStore.addCustomPlant(
            name: plantName, 
            habit: habitName, 
            icon: selectedIcon, 
            color: selectedColor,
            category: selectedCategory,
            isNegative: isNegative
        )
        
        if let newPlant = newPlant, !isNegative, let weight = selectedGoalWeight, let goal = GoalStore.shared.activeGoals.first(where: { $0.type == .year }) {
            GoalStore.shared.linkHabitToGoal(habitId: newPlant.id, goalId: goal.id, weight: weight)
        }
        
        dismiss()
    }
}

struct AllIconsSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var settings: SettingsStore
    @Binding var selectedIcon: String
    let selectedColor: Color
    let icons: [String]
    var isNegative: Bool = false
    
    let columns = [
        GridItem(.adaptive(minimum: 60), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(icons, id: \.self) { icon in
                        Button {
                            selectedIcon = icon
                            FeedbackManager.shared.playTap()
                            dismiss()
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(selectedIcon == icon ? selectedColor.opacity(0.15) : Color.clear)
                                    .frame(width: 54, height: 54)
                                
                                if UIImage(named: icon) != nil {
                                    Image(icon)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 36, height: 36)
                                        .scaleEffect(isNegative ? 2.2 : 1.0)
                                } else {
                                    Image(systemName: icon)
                                        .font(.system(size: 24))
                                        .foregroundStyle(selectedIcon == icon ? selectedColor : .secondary)
                                }
                            }
                        }
                    }
                }
                .padding(24)
            }
            .navigationTitle(String(localized: "plant.create.select_symbol"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "button.ok")) { dismiss() }
                        .fontWeight(.bold)
                        .foregroundStyle(.black)
                }
            }
            .background(Color.appHintergrund.ignoresSafeArea())
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    CustomPlantCreationView()
        .environmentObject(GardenStore())
}
