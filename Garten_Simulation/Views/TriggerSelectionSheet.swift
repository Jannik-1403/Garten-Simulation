import SwiftUI

struct TriggerSelectionSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    
    let habitId: String
    
    // Lokaler Zustand für die Auswahl
    @State private var selectedTriggers: Set<String> = []
    
    // Zustand für den Alert
    @State private var showAddAlert: Bool = false
    @State private var newTriggerText: String = ""
    
    // Basis-Auslöser mit Localization Keys
    let baseTriggerKeys = [
        "trigger.boredom",
        "trigger.stress",
        "trigger.sadness",
        "trigger.loneliness",
        "trigger.fatigue",
        "trigger.reward",
        "trigger.social_pressure"
    ]
    
    // Alle Auslöser (Basis + Custom)
    var allTriggers: [(key: String, display: String)] {
        var list: [(key: String, display: String)] = baseTriggerKeys.map { key in
            (key: key, display: settings.localizedString(for: key))
        }
        for custom in gardenStore.savedCustomTriggers {
            if !list.contains(where: { $0.display == custom }) {
                list.append((key: custom, display: custom))
            }
        }
        return list
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.secondarySystemBackground).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(allTriggers, id: \.key) { trigger in
                                Item3DButton(
                                    farbe: .white,
                                    sekundaerFarbe: Color.black.opacity(0.05),
                                    groesse: 60,
                                    isRectangular: true,
                                    aktion: {
                                        if selectedTriggers.contains(trigger.display) {
                                            selectedTriggers.remove(trigger.display)
                                        } else {
                                            selectedTriggers.insert(trigger.display)
                                        }
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    }
                                ) {
                                    HStack {
                                        // Checkbox (Multi-select)
                                        ZStack {
                                            Circle()
                                                .strokeBorder(selectedTriggers.contains(trigger.display) ? Color.gruenPrimary : Color.gray.opacity(0.3), lineWidth: 2)
                                                .frame(width: 24, height: 24)
                                            
                                            if selectedTriggers.contains(trigger.display) {
                                                Circle()
                                                    .fill(Color.gruenPrimary)
                                                    .frame(width: 14, height: 14)
                                            }
                                        }
                                        
                                        Text(trigger.display)
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            .foregroundColor(.primary)
                                            .padding(.leading, 8)
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 100)
                    }
                }
                
                // Unten: Speichern Button
                VStack {
                    Spacer()
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        let selectedArray = Array(selectedTriggers)
                        gardenStore.trackBadHabit(id: habitId, penaltyCoins: 0, triggers: selectedArray)
                        dismiss()
                    } label: {
                        Text(settings.localizedString(for: "trigger.save_button"))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                    }
                    .buttonStyle(DuolingoButtonStyle(
                        size: .large,
                        fillWidth: true,
                        backgroundColor: Color.red,
                        shadowColor: Color(hex: "#C62828"),
                        foregroundColor: .white
                    ))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                    .background(
                        LinearGradient(colors: [Color(UIColor.secondarySystemBackground).opacity(0), Color(UIColor.secondarySystemBackground)], startPoint: .top, endPoint: .bottom)
                            .frame(height: 100)
                            .offset(y: 20)
                    )
                }
            }
            .navigationTitle(settings.localizedString(for: "trigger.selection_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showAddAlert = true
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    LiquidGlassDismissButton {
                        dismiss()
                    }
                }
            }
            .alert(settings.localizedString(for: "trigger.own_trigger"), isPresented: $showAddAlert) {
                TextField(settings.localizedString(for: "trigger.trigger_name"), text: $newTriggerText)
                Button(settings.localizedString(for: "trigger.cancel"), role: .cancel) {
                    newTriggerText = ""
                }
                Button(settings.localizedString(for: "trigger.add")) {
                    let trimmed = newTriggerText.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty {
                        if !gardenStore.savedCustomTriggers.contains(trimmed) {
                            gardenStore.savedCustomTriggers.append(trimmed)
                        }
                        selectedTriggers.insert(trimmed)
                    }
                    newTriggerText = ""
                }
            } message: {
                Text(settings.localizedString(for: "trigger.own_trigger_desc"))
            }
        }
    }
}
