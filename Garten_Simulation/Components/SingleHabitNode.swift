import SwiftUI
import Combine

struct SingleHabitNode: View {
    let tag: PfadStrangTag
    let strang: PfadStrang
    let groesse: CGFloat
    let istHeute: Bool
    let progress: Double
    var action: (() -> Void)? = nil
    
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore

    private var displayedName: String {
        // 1. Versuche die aktive Gewohnheit des Nutzers zu finden
        if let habit = gardenStore.pflanzen.first(where: { $0.plantID == strang.pflanzenID }) {
            return settings.localizedString(for: habit.displayedHabitName)
        }
        
        // 2. Fallback: Datenbank-Abgleich für spezifischen Namen (z.B. Meditieren)
        if let plant = GameDatabase.allPlants.first(where: { $0.id.lowercased() == strang.pflanzenID.lowercased() }) {
            // Erst den Gewohnheits-Namen versuchen (z.B. habit.meditieren)
            if !plant.habitName.isEmpty {
                return settings.localizedString(for: plant.habitName)
            }
            // Wenn der fehlt, die Kategorie (z.B. category.mental)
            if let catKey = plant.habitCategories.first?.localizationKey {
                return settings.localizedString(for: catKey)
            }
        }
        
        // 3. Letzter Fallback (sollte eigentlich nie erreicht werden)
        return settings.localizedString(for: strang.pflanzenName)
    }

    private var obereFarbe: Color {
        guard strang.istAktiv else { return Color(uiColor: .systemGray4) }
        if istHeute                   { return Color.blauPrimary }
        if tag.istVerschmelzungsPunkt { return Color.goldPrimary }
        return Color(hex: "#7FA68E") // Calm Sage Green
    }

    private var untereFarbe: Color {
        obereFarbe.darker(by: 0.15)
    }

    @State private var pulseScale: CGFloat = 1.0
    @State private var showTimePicker = false
    @State private var tempTime = Date()
    
    private var scale: CGFloat {
        let base: CGFloat = tag.istMeilenstein ? 1.05 : 0.85
        let grow: CGFloat = 0.2
        return base + (grow * CGFloat(tag.istErledigt ? 1.0 : progress))
    }

    private var scheduledTime: String {
        if let habit = gardenStore.pflanzen.first(where: { $0.plantID == strang.pflanzenID }),
           let reminder = habit.reminderTime {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: reminder)
        }
        
        let startHour = 7
        let minutesPerStep = 90
        let totalMinutes = startHour * 60 + (strang.reihenfolgeIndex) * minutesPerStep
        let hour = totalMinutes / 60
        let minute = totalMinutes % 60
        return String(format: "%02d:%02d", hour, minute)
    }

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                // Main Pedestal Button (Stays pressed when done)
                Item3DButton(
                    farbe: obereFarbe,
                    sekundaerFarbe: untereFarbe,
                    groesse: groesse * scale,
                    isPermanentlyPressed: tag.istErledigt,
                    aktion: action
                ) {
                    ZStack {
                        iconImage(for: strang, size: groesse * 0.6 * scale)
                        overlayIndicators(size: groesse * scale)
                    }
                }
                .opacity(tag.istErledigt ? 0.6 : 1.0)
            }
            
            // Labels
            if strang.istAktiv {
                VStack(spacing: 4) { // Increased distance
                    // Time Badge
                    Button {
                        if let habit = gardenStore.pflanzen.first(where: { $0.plantID == strang.pflanzenID }) {
                            tempTime = habit.reminderTime ?? Date()
                            showTimePicker = true
                        }
                    } label: {
                        Text(scheduledTime)
                            .font(.system(size: groesse * 0.22, weight: .black, design: .rounded)) // Larger Font
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.black.opacity(0.35), in: Capsule())
                            .shadow(color: .black.opacity(0.1), radius: 2)
                    }
                    .buttonStyle(.plain)
                    
                    // Habit Name
                    Text(displayedName.uppercased())
                        .font(.system(size: groesse * 0.22, weight: .black, design: .rounded)) // Larger Font
                        .foregroundColor(Color.black.opacity(0.7)) // Slightly darker for contrast
                        .lineLimit(1)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.4)
                        .frame(maxWidth: groesse * 2.2) 
                }
                .offset(y: 5) // Shifted down
            }
        }
        .sheet(isPresented: $showTimePicker) {
            timePickerSheet
        }
    }

    @ViewBuilder
    private var timePickerSheet: some View {
        if let habit = gardenStore.pflanzen.first(where: { $0.plantID == strang.pflanzenID }) {
            NavigationStack {
                VStack(spacing: 20) {
                    Text(settings.localizedString(for: habit.displayedHabitName))
                        .font(.headline)
                        .padding(.top)
                    
                    DatePicker(
                        settings.localizedString(for: "time_picker.label"),
                        selection: $tempTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    
                    Spacer()
                }
                .navigationTitle(settings.localizedString(for: "time_picker.title"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(settings.localizedString(for: "common.cancel")) { showTimePicker = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button(settings.localizedString(for: "common.save")) {
                            habit.reminderTime = tempTime
                            gardenStore.savePlants()
                            gardenStore.objectWillChange.send()
                            // Update daily notifications
                            NotificationManager.shared.scheduleAll(for: gardenStore.pflanzen)
                            showTimePicker = false
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }

    @ViewBuilder
    private func iconImage(for s: PfadStrang, size: CGFloat) -> some View {
        let assetName = GameDatabase.allPlants.first(where: { $0.id == s.pflanzenID })?.assetName
        Group {
            if let asset = assetName {
                Image(asset)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: s.pflanzenSymbol)
                    .font(.system(size: size * 0.6, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .frame(width: size, height: size)
        .brightness(s.istAktiv ? 0 : -0.1)
        .opacity(s.istAktiv ? 1.0 : 0.6)
    }

    @ViewBuilder
    private func overlayIndicators(size: CGFloat) -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                if !strang.istAktiv {
                    miniBadge(icon: "lock.fill", color: .gray, sSize: size)
                } else if tag.istErledigt {
                    miniBadge(icon: "checkmark", color: Color(hex: "#58CC02"), sSize: size)
                } else if tag.istMeilenstein {
                    let mColor = getMilestoneColor()
                    miniBadge(icon: "trophy.fill", color: mColor, sSize: size)
                } else if tag.istVerschmelzungsPunkt {
                    miniBadge(icon: "link", color: Color.goldPrimary, sSize: size)
                }
            }
        }
        .padding(size * 0.1)
    }

    private func getMilestoneShadowColor() -> Color {
        let tagNr = tag.tagNummer
        if tagNr >= 80 { return Color(hex: "#B9F2FF") } // Diamond
        if tagNr >= 45 { return .goldPrimary }         // Gold
        if tagNr >= 20 { return Color(hex: "#C0C0C0") } // Silver
        return Color(hex: "#CC8E51")                   // Bronze (Vibrant)
    }

    private func getMilestoneColor() -> Color {
        let tagNr = tag.tagNummer
        if tagNr >= 80 { return Color(hex: "#B9F2FF") } // Diamond
        if tagNr >= 45 { return .orange }             // Gold
        if tagNr >= 20 { return Color(hex: "#C0C0C0") } // Silver
        return Color(hex: "#CD7F32")                   // Bronze
    }

    @ViewBuilder
    private func miniBadge(icon: String, color: Color, sSize: CGFloat) -> some View {
        Image(systemName: icon)
            .font(.system(size: sSize * 0.22, weight: .bold))
            .foregroundColor(.white)
            .frame(width: sSize * 0.28, height: sSize * 0.28)
            .background(color, in: Circle())
            .shadow(radius: 1)
    }
}
