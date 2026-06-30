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
        if let habit = gardenStore.pflanzen.first(where: { $0.id == strang.pflanzenID }) {
            return NSLocalizedString(habit.displayedHabitName, comment: "")
        }
        
        // 2. Fallback: Datenbank-Abgleich für spezifischen Namen (z.B. Meditieren)
        if let plant = GameDatabase.allPlants.first(where: { $0.id.lowercased() == strang.pflanzenID.lowercased() }) {
            // Erst den Gewohnheits-Namen versuchen (z.B. habit.meditieren)
            if !plant.habitName.isEmpty {
                return NSLocalizedString(plant.habitName, comment: "")
            }
            // Wenn der fehlt, die Kategorie (z.B. category.mental)
            return NSLocalizedString(plant.habitCategory.localizationKey, comment: "")
        }
        
        // 3. Letzter Fallback (sollte eigentlich nie erreicht werden)
        return NSLocalizedString(strang.pflanzenName, comment: "")
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
        if let habit = gardenStore.pflanzen.first(where: { $0.id == strang.pflanzenID }),
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
                // Background Circle for the Day Number
                Circle()
                    .fill(obereFarbe.opacity(0.15))
                    .frame(width: groesse * 1.1, height: groesse * 1.1)
                
                VStack(spacing: 8) {
                    // 1. Task Name (What to do)
                    Text(displayedName.uppercased())
                        .font(.system(size: groesse * 0.2, weight: .black, design: .rounded))
                        .foregroundColor(Color.black.opacity(0.8))
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .frame(width: groesse * 1.5)
                    
                    // 2. Day Number ("The One")
                    ZStack {
                        Circle()
                            .fill(obereFarbe)
                            .frame(width: groesse * 0.6, height: groesse * 0.6)
                            .shadow(color: obereFarbe.opacity(0.3), radius: 10, y: 5)
                        
                        Text("\(tag.tagNummer)")
                            .font(.system(size: groesse * 0.28, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    // 3. Progress Bar (Balken)
                    VStack(spacing: 4) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color.black.opacity(0.1))
                                Capsule()
                                    .fill(obereFarbe)
                                    .frame(width: geo.size.width * CGFloat(tag.tagNummer) / 90.0)
                            }
                        }
                        .frame(width: groesse * 1.2, height: 6)
                        
                        Text(verbatim: "\(Int((Double(tag.tagNummer) / 90.0) * 100))%")
                            .font(.system(size: groesse * 0.16, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    action?()
                }
                .opacity(tag.istErledigt ? 0.6 : 1.0)
            }
            .offset(y: 10)
        }
        .sheet(isPresented: $showTimePicker) {
            timePickerSheet
        }
    }

    @ViewBuilder
    private var timePickerSheet: some View {
        if let habit = gardenStore.pflanzen.first(where: { $0.id == strang.pflanzenID }) {
            NavigationStack {
                VStack(spacing: 20) {
                    Text(NSLocalizedString(habit.displayedHabitName, comment: ""))
                        .font(.headline)
                        .padding(.top)
                    
                    DatePicker(
                        String(localized: "time_picker.label"),
                        selection: $tempTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    
                    Spacer()
                }
                .navigationTitle(String(localized: "time_picker.title"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(String(localized: "common.cancel")) { showTimePicker = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button(String(localized: "common.save")) {
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
        // FIXED: Use s.pflanzenID to find the plant asset
        let plant = GameDatabase.allPlants.first(where: { $0.id == s.pflanzenID })
        let assetName = plant?.assetName
        
        ZStack {
            // 1. Die Pflanze als Haupt-Icon
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
            .frame(width: size * 0.8, height: size * 0.8)
            .offset(y: -size * 0.05)
            
            // 2. Der Igel (Ersatz/Freund) als kleiner Overlay-Begleiter
            if !tag.igelAsset.isEmpty {
                Image(tag.igelAsset)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size * 0.5, height: size * 0.5)
                    .offset(x: size * 0.25, y: size * 0.2)
                    .shadow(color: .black.opacity(0.15), radius: 2, x: 1, y: 1)
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
