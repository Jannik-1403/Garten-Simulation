import SwiftUI
import Combine

struct KombinierterStrangNode: View {
    let tag: PfadStrangTag
    let strang: PfadStrang
    let groesse: CGFloat
    let istHeute: Bool
    let istVerschmolzen: Bool
    let progress: Double
    
    // NEU: Für Verschmelzungen (mehrere Habits auf einem Button)
    var partnerStraenge: [PfadStrang] = []
    var action: (() -> Void)? = nil
    
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    
    @State private var showTimePicker = false
    @State private var tempTime = Date()

    private var alleStraenge: [PfadStrang] {
        [strang] + partnerStraenge
    }

    private var gemischteFarbe: Color {
        guard !alleStraenge.isEmpty else { return Color(hex: strang.farbe) }
        var result = Color(hex: alleStraenge[0].farbe)
        for i in 1..<alleStraenge.count {
            result = Color.mix(result, with: Color(hex: alleStraenge[i].farbe), pct: 1.0 / Double(i + 1))
        }
        return result
    }

    private var obereFarbe: Color {
        guard strang.istAktiv else { return Color(uiColor: .systemGray4) }
        if tag.istErledigt            { return Color(hex: "#58CC02") }
        if istHeute                   { return Color.blauPrimary }
        if tag.istVerschmelzungsPunkt { return Color.goldPrimary }
        if istVerschmolzen || !partnerStraenge.isEmpty { return gemischteFarbe }
        return Color(hex: strang.farbe)
    }

    private var untereFarbe: Color {
        obereFarbe.darker(by: 0.15)
    }

    private var scale: CGFloat {
        let base: CGFloat = tag.istMeilenstein ? 1.05 : 0.85
        let grow: CGFloat = 0.25
        return base + (grow * CGFloat(progress))
    }

    private var displayedName: String {
        let names = alleStraenge.compactMap { s -> String? in
            if let habit = gardenStore.pflanzen.first(where: { $0.plantID == s.pflanzenID }) {
                return habit.habitName.isEmpty ? settings.localizedString(for: habit.name) : habit.habitName
            }
            return settings.localizedString(for: s.pflanzenName)
        }
        
        if names.isEmpty { return "" }
        if names.count == 1 { return names[0] }
        return names.joined(separator: " & ")
    }

    private var scheduledTime: String {
        // Nutze die Zeit des Haupt-Strangs, falls vorhanden
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
                if tag.istMeilenstein {
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .blur(radius: groesse * 0.2)
                        .scaleEffect(1.2)
                }
                
                // Main Pedestal Button (Back to status-colored for 90-day path)
                Item3DButton(
                    farbe: obereFarbe,
                    sekundaerFarbe: untereFarbe,
                    groesse: groesse * scale,
                    aktion: action
                ) {
                    nodeInhalt
                }
            }
            
            // Labels (Consistent with SingleHabitNode)
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
                    
                    // Combined Habit Name
                    Text(displayedName.uppercased())
                        .font(.system(size: groesse * 0.22, weight: .black, design: .rounded)) // Larger Font
                        .foregroundColor(Color.black.opacity(0.7)) // Slightly darker for contrast
                        .lineLimit(2)
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
    private var nodeInhalt: some View {
        ZStack {
            if alleStraenge.count > 1 {
                // Mehrere Icons bei Verschmelzung
                mergedIconsView
            } else {
                // Einzelnes Icon
                singleIconView(for: strang)
            }

            // Status-Indikatoren
            overlayIndicators
        }
    }

    @ViewBuilder
    private var mergedIconsView: some View {
        let n = min(alleStraenge.count, 4) // Max 4 Icons anzeigen
        let subGroesse = groesse * (n > 2 ? 0.35 : 0.45)
        
        // Raster-Layout für Merged Icons
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                iconImage(for: alleStraenge[0], size: subGroesse)
                if n > 1 { iconImage(for: alleStraenge[1], size: subGroesse) }
            }
            if n > 2 {
                HStack(spacing: 4) {
                    iconImage(for: alleStraenge[2], size: subGroesse)
                    if n > 3 { iconImage(for: alleStraenge[3], size: subGroesse) }
                }
            }
        }
    }

    @ViewBuilder
    private func singleIconView(for s: PfadStrang) -> some View {
        iconImage(for: s, size: groesse * 0.7)
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
    private var overlayIndicators: some View {
        let s = groesse * scale
        VStack {
            Spacer()
            HStack {
                Spacer()
                if !strang.istAktiv {
                    miniBadge(icon: "lock.fill", color: .gray, nodeSize: s)
                } else if tag.istErledigt {
                    miniBadge(icon: "checkmark", color: Color(hex: "#58CC02"), nodeSize: s)
                } else if tag.istMeilenstein {
                    let mColor = getMilestoneColor()
                    miniBadge(icon: "trophy.fill", color: mColor, nodeSize: s)
                } else if tag.istVerschmelzungsPunkt {
                    miniBadge(icon: "link", color: Color.goldPrimary, nodeSize: s)
                }
            }
        }
        .padding(s * 0.1)
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
    private func miniBadge(icon: String, color: Color, nodeSize: CGFloat) -> some View {
        Image(systemName: icon)
            .font(.system(size: nodeSize * 0.22, weight: .bold))
            .foregroundColor(.white)
            .frame(width: nodeSize * 0.28, height: nodeSize * 0.28)
            .background(color, in: Circle())
            .shadow(radius: 1)
    }
}
