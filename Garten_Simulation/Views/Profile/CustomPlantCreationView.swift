import SwiftUI

struct CustomPlantCreationView: View {
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.dismiss) var dismiss
    
    @State private var plantName: String = ""
    @State private var habitName: String = ""
    @State private var selectedIcon: String = "leaf.fill"
    @State private var selectedColor: String = "green"
    @State private var showSeedInfo = false
    @State private var showAllIcons = false
    
    private let availableIcons = [
        "leaf.fill", "tree.fill", "sun.max.fill", "star.fill", 
        "heart.fill", "bolt.fill", "moon.fill", "sparkles", 
        "drop.fill", "flame.fill", "camera.macro", "house.fill"
    ]
    
    private let allIcons = [
        "leaf.fill", "tree.fill", "flower.fill", "star.fill", "heart.fill", "bolt.fill", "sun.max.fill", "moon.fill",
        "sparkles", "drop.fill", "camera.macro", "flame.fill", "bicycle", "figure.walk", "figure.run", "figure.strengthtraining.traditional",
        "book.fill", "pencil", "music.note", "theatermasks.fill", "cup.and.saucer.fill", "mug.fill", "wineglass.fill", "fork.knife",
        "bed.double.fill", "zzz", "alarm.fill", "timer", "brain.head.profile", "lightbulb.fill", "checklist", "briefcase.fill",
        "house.fill", "cart.fill", "creditcard.fill", "gift.fill", "gamecontroller.fill", "dice.fill", "puzzlepiece.fill", "balloon.fill",
        "camera.fill", "headphones", "mic.fill", "paintpalette.fill", "hammer.fill", "wrench.fill", "scissors", "bandage.fill",
        "pills.fill", "cross.case.fill", "thermometer.medium", "drop.triangle.fill", "wind", "cloud.fill", "umbrella.fill", "beach.umbrella.fill"
    ]
    
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
                                Text(plantName.isEmpty ? settings.localizedString(for: "plant.create.preview.name") : plantName)
                                    .font(.system(size: 24, weight: .black, design: .rounded))
                                    .foregroundStyle(.primary)
                                
                                Text(habitName.isEmpty ? settings.localizedString(for: "plant.create.preview.habit") : habitName)
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.top, 20)
                        
                        // MARK: - Inputs
                        VStack(spacing: 24) {
                            // Text Input Section
                            VStack(alignment: .leading, spacing: 20) {
                                customTextField(
                                    title: settings.localizedString(for: "plant.create.field.plant_name"), 
                                    placeholder: settings.localizedString(for: "plant.create.placeholder.plant"), 
                                    text: $plantName
                                )
                                
                                customTextField(
                                    title: settings.localizedString(for: "plant.create.field.habit_name"), 
                                    placeholder: settings.localizedString(for: "plant.create.placeholder.habit"), 
                                    text: $habitName
                                )
                            }
                            
                            // Icon Picker
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text(settings.localizedString(for: "plant.create.select_symbol"))
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
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                                    ForEach(availableIcons, id: \.self) { icon in
                                        Button {
                                            selectedIcon = icon
                                            FeedbackManager.shared.playTap()
                                        } label: {
                                            ZStack {
                                                Circle()
                                                    .fill(selectedIcon == icon ? uiColor(for: selectedColor).opacity(0.15) : Color.clear)
                                                    .frame(width: 44, height: 44)
                                                
                                                Image(systemName: icon)
                                                    .font(.system(size: 20))
                                                    .foregroundStyle(selectedIcon == icon ? uiColor(for: selectedColor) : .secondary)
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // Color Picker
                            VStack(alignment: .leading, spacing: 12) {
                                Text(settings.localizedString(for: "plant.create.select_color"))
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
                        Button(action: {
                            FeedbackManager.shared.playSuccess()
                            gardenStore.addCustomPlant(
                                name: plantName, 
                                habit: habitName, 
                                icon: selectedIcon, 
                                color: selectedColor
                            )
                            dismiss()
                        }) {
                            Text(settings.localizedString(for: "button.save_create"))
                        }
                        .buttonStyle(DuolingoButtonStyle(
                            size: .large,
                            fillWidth: true,
                            backgroundColor: isFormValid ? uiColor(for: selectedColor) : .gray.opacity(0.3),
                            shadowColor: isFormValid ? uiColor(for: selectedColor).darker() : .gray.opacity(0.5)
                        ))
                        .disabled(!isFormValid)
                        .padding(.horizontal, 24)
                        .padding(.top, 10)
                        
                        Text(String(format: settings.localizedString(for: "inventory.create_plant.cost_format"), 10))
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle(settings.localizedString(for: "inventory.create_plant"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(settings.localizedString(for: "button.cancel")) { dismiss() }
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.black)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSeedInfo = true
                        FeedbackManager.shared.playTap()
                    } label: {
                        Text("\(gardenStore.seeds)")
                            .font(.system(size: 17, weight: .black, design: .rounded))
                            .foregroundStyle(.black)
                    }
                }
            }
            .alert(settings.localizedString(for: "inventory.seeds.info.title"), isPresented: $showSeedInfo) {
                Button(settings.localizedString(for: "button.ok"), role: .cancel) { }
            } message: {
                Text(String(format: settings.localizedString(for: "inventory.seeds.info.body"), gardenStore.seeds))
            }
            .sheet(isPresented: $showAllIcons) {
                AllIconsSheet(selectedIcon: $selectedIcon, selectedColor: uiColor(for: selectedColor), icons: allIcons)
                    .environmentObject(settings)
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
            
            TextField(placeholder, text: text)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(UIColor.secondarySystemGroupedBackground))
                        .shadow(color: .black.opacity(0.04), radius: 5, x: 0, y: 2)
                )
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
}

struct AllIconsSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var settings: SettingsStore
    @Binding var selectedIcon: String
    let selectedColor: Color
    let icons: [String]
    
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
                                
                                Image(systemName: icon)
                                    .font(.system(size: 24))
                                    .foregroundStyle(selectedIcon == icon ? selectedColor : .secondary)
                            }
                        }
                    }
                }
                .padding(24)
            }
            .navigationTitle(settings.localizedString(for: "plant.create.select_symbol"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(settings.localizedString(for: "button.ok")) { dismiss() }
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
