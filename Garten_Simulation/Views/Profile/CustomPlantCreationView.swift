import SwiftUI

struct CustomPlantCreationView: View {
    @EnvironmentObject var gardenStore: GardenStore
    @Environment(\.dismiss) var dismiss
    
    @State private var plantName: String = ""
    @State private var habitName: String = ""
    @State private var selectedIcon: String = "leaf.fill"
    @State private var selectedColor: String = "green"
    
    private let availableIcons = [
        "leaf.fill", "tree.fill", "flower.fill", "star.fill", 
        "heart.fill", "bolt.fill", "sun.max.fill", "moon.fill", 
        "sparkles", "drop.fill", "camera.macro", "flame.fill"
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
                            ZStack {
                                Circle()
                                    .fill(uiColor(for: selectedColor).opacity(0.15))
                                    .frame(width: 120, height: 120)
                                
                                Image(systemName: selectedIcon)
                                    .font(.system(size: 60))
                                    .foregroundStyle(uiColor(for: selectedColor))
                                    .shadow(color: uiColor(for: selectedColor).opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                            
                            VStack(spacing: 4) {
                                Text(plantName.isEmpty ? "Deine Pflanze" : plantName)
                                    .font(.system(size: 24, weight: .black, design: .rounded))
                                    .foregroundStyle(.primary)
                                
                                Text(habitName.isEmpty ? "Deine Gewohnheit" : habitName)
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
                                    title: "Name der Pflanze", 
                                    placeholder: "z.B. Glücksblatt", 
                                    text: $plantName
                                )
                                
                                customTextField(
                                    title: "Name der Gewohnheit", 
                                    placeholder: "z.B. Täglich lesen", 
                                    text: $habitName
                                )
                            }
                            
                            // Icon Picker
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Symbol wählen")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .padding(.horizontal, 4)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                                    ForEach(availableIcons, id: \.self) { icon in
                                        Button {
                                            selectedIcon = icon
                                            FeedbackManager.shared.playTap()
                                        } label: {
                                            ZStack {
                                                Circle()
                                                    .fill(selectedIcon == icon ? Color.primary.opacity(0.1) : Color.clear)
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
                                Text("Farbe wählen")
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
                                                
                                                if selectedColor == color {
                                                    Circle()
                                                        .stroke(Color.primary, lineWidth: 2)
                                                        .frame(width: 42, height: 42)
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
                            Text("Speichern & Erstellen")
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
                        
                        Text("Kosten: 10 Samen")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Pflanze kreieren")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Abbrechen") { dismiss() }
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
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

#Preview {
    CustomPlantCreationView()
        .environmentObject(GardenStore())
}
