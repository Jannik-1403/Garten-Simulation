import SwiftUI

struct PflanzeDetailSheet: View {
    @ObservedObject var pflanze: HabitModel
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var shopStore: ShopStore
    @EnvironmentObject var powerUpStore: PowerUpStore
    @Environment(\.dismiss) private var dismiss
    var onLoeschen: (() -> Void)? = nil

    @State private var zeigeVerkaufenDialog = false
    @State private var zeigeNotizSheet = false
    @State private var zeigeTimerSheet = false
    @State private var pulsieren = false

    // NEU: States für Dialoge & Bearbeitung
    @State private var noteToEditIndex: Int? = nil
    @State private var noteToDeleteIndex: Int? = nil
    @State private var zeigeTimerAbbrechenDialog = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 28) {
                // MARK: - HERO (Zone 1)
                VStack(spacing: 12) {
                    ZStack {
                        // Hintergrund-Ring (grau)
                        Circle()
                            .stroke(Color.gray.opacity(0.15), lineWidth: 8)
                            .frame(width: 180, height: 180)

                        // Fortschritts-Ring (Seltenheits-Farbe)
                        Circle()
                            .trim(from: 0, to: pflanze.ringFortschritt)
                            .stroke(
                                pflanze.seltenheit.farbe,
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .frame(width: 180, height: 180)
                            .rotationEffect(.degrees(-90))
                            .animation(.spring(response: 0.6), value: pflanze.ringFortschritt)

                        // 3D Pflanze Button
                        if let basePlant = GameDatabase.shared.plant(for: pflanze.plantID) {
                            PflanzenButton(
                                plant: basePlant,
                                seltenheit: pflanze.seltenheit,
                                farbe: pflanze.color,
                                sekundaerFarbe: pflanze.color.darker(),
                                groesse: 140
                            )
                            .scaleEffect(pulsieren ? 1.03 : 1.0)
                            .allowsHitTesting(false)
                        } else {
                            // Fallback if not found
                            PflanzenButton(
                                plant: Plant(id: "fallback", name: "Plant", symbolName: pflanze.symbolName, assetName: nil, symbol: "🌱", symbolColor: pflanze.symbolColor, habitCategories: pflanze.habitCategories, symbolism: ""),
                                seltenheit: pflanze.seltenheit,
                                farbe: pflanze.color,
                                sekundaerFarbe: pflanze.color.darker(),
                                groesse: 140
                            )
                            .scaleEffect(pulsieren ? 1.03 : 1.0)
                            .allowsHitTesting(false)
                        }
                    }

                    Text(settings.showHabitInsteadOfName 
                         ? settings.localizedString(for: pflanze.habitName)
                         : settings.localizedString(for: pflanze.name))
                        .font(.system(size: 34, weight: .bold, design: .rounded))

                    // Vier-Spalten Stats Header (In einer schwebenden Karte)
                    HStack(spacing: 0) {
                        // 1. Streak
                        VStack(spacing: 4) {
                            HStack(spacing: 4) {
                                Image("streak")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 18, height: 18)
                                Text("\(pflanze.streak)")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                            }
                            Text(settings.localizedString(for: "plant.detail.streak").uppercased())
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)

                        Divider().frame(height: 24)

                        // 2. XP
                        VStack(spacing: 4) {
                            HStack(spacing: 4) {
                                Image("XP")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 18, height: 18)
                                Text("\(pflanze.currentXP)")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                            }
                            Text(settings.localizedString(for: "plant.detail.xp").uppercased())
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)

                        Divider().frame(height: 24)

                        // 3. Stufe (Clean Style)
                        HStack(spacing: 4) {
                            Image(systemName: pflanze.stufe.sfSymbol)
                                .font(.system(size: 14, weight: .bold))
                            Text(pflanze.seltenheit.lokalisiertTitel)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .foregroundStyle(pflanze.seltenheit.farbe)
                        .frame(maxWidth: .infinity)

                        Divider().frame(height: 24)

                        // 4. Wasser (Drop)
                        VStack(spacing: 4) {
                            HStack(spacing: 4) {
                                Image("Drop water")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 18, height: 18)
                                Text(pflanze.formattedVolume)
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                            }
                            Text(settings.localizedString(for: "plant.detail.watered").uppercased())
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 4)
                }
                .padding(.top, 24)

                // MARK: - WEEKLY (Zone 2)
                VStack(spacing: 0) {
                    PlantWeeklyStreakView(pflanze: pflanze)
                        .padding(.vertical, 16)
                }
                .background(
                    ZStack {
                        // 3D Shadow
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color.orangeSecondary)
                            .offset(y: 4)
                        
                        // Main Orange Surface
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [.orangePrimary, .orangePrimary.opacity(0.9)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
                )
                .padding(.horizontal, 24)
                .padding(.vertical, 8)

                // MARK: - ACTIONS (Zone 3)
                VStack(spacing: 12) {
                    
                    // Gießen Button (Primary Action)
                    if !pflanze.istBewässert {
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            gardenStore.giessen(pflanze: pflanze, powerUpStore: powerUpStore)
                        } label: {
                            HStack(spacing: 10) {
                                Image("Drop water")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                Text(settings.localizedString(for: "button.water").uppercased())
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 30)
                        }
                        .buttonStyle(DuolingoButtonStyle(
                            size: .large,
                            fillWidth: true,
                            backgroundColor: .blauPrimary,
                            shadowColor: .blauPrimary.darker()
                        ))
                        .padding(.horizontal, 24)
                        .padding(.bottom, 8)
                    }

                    // Notizen Liste
                    ForEach(pflanze.notizen.indices, id: \.self) { index in
                        HStack(spacing: 12) {
                            ZStack {
                                Circle().fill(Color.blauPrimary.opacity(0.1))
                                    .frame(width: 36, height: 36)
                                Image(systemName: "doc.text.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(Color.blauPrimary)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(settings.localizedString(for: "plant.detail.note")) \(index + 1)")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(.secondary)
                                Text(pflanze.notizen[index])
                                    .lineLimit(2)
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                            }
                            
                            Spacer()
                            
                            // Löschen Button (X)
                            Button {
                                noteToDeleteIndex = index
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(Color.red.opacity(0.7))
                            }
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.04), radius: 10, y: 5)
                        )
                        .padding(.horizontal, 24)
                        .padding(.bottom, 4)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            noteToEditIndex = index
                            zeigeNotizSheet = true
                        }
                    }

                    // Timer Vorschau
                    if let timerDate = pflanze.timerDatum, timerDate > Date() {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle().fill(Color.orangePrimary.opacity(0.1))
                                    .frame(width: 36, height: 36)
                                Image(systemName: "bell.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(Color.orangePrimary)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(settings.localizedString(for: "plant.detail.timer.active"))
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundStyle(.secondary)
                                Text("\(timerDate, style: .date) · \(timerDate, style: .time)")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                            }
                            Spacer()
                            Button {
                                zeigeTimerAbbrechenDialog = true
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(Color.red.opacity(0.8))
                            }
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.04), radius: 10, y: 5)
                        )
                        .padding(.horizontal, 24)
                        .padding(.bottom, 8)
                    }

                    // 3D Buttons nebeneinander
                    HStack(spacing: 12) {
                        Button {
                            noteToEditIndex = nil // Markiere als Neuanlage
                            zeigeNotizSheet = true
                        } label: {
                            ZStack {
                                HStack {
                                    Spacer()
                                    Image(systemName: "square.and.pencil")
                                        .font(.system(size: 24))
                                        .foregroundStyle(.white.opacity(0.12))
                                        .offset(x: 35, y: 15)
                                }
                                Text(settings.localizedString(for: "plant.detail.note.add")).textCase(.uppercase)
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 24)
                            .clipped()
                        }
                        .buttonStyle(DuolingoButtonStyle(
                            size: .medium, fillWidth: true,
                            backgroundColor: .blauPrimary, shadowColor: .blauPrimary.darker(), foregroundColor: .white
                        ))

                        Button {
                            zeigeTimerSheet = true
                        } label: {
                            ZStack {
                                HStack {
                                    Spacer()
                                    Image(systemName: "bell.fill")
                                        .font(.system(size: 24))
                                        .foregroundStyle(.white.opacity(0.12))
                                        .offset(x: 35, y: 15)
                                }
                                Text(settings.localizedString(for: "plant.detail.timer")).textCase(.uppercase)
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 24)
                            .clipped()
                        }
                        .buttonStyle(DuolingoButtonStyle(
                            size: .medium, fillWidth: true,
                            backgroundColor: .goldPrimary, shadowColor: .goldPrimary.darker(), foregroundColor: .white
                        ))
                    }
                    .padding(.horizontal, 24)

                    // Verkaufen-Button (Roter Text)
                    Button {
                        zeigeVerkaufenDialog = true
                    } label: {
                        Text(settings.localizedString(for: "plant.detail.sell"))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.red)
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 24)
                }


                Spacer().frame(height: 20)
            }
        }
        .background(
            ZStack {
                Color.white.ignoresSafeArea()
                
                // Subtiler Verlauf im Hintergrund
                LinearGradient(
                    colors: [Color.orangePrimary.opacity(0.05), Color.white],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulsieren = true
            }
        }
        // MARK: - Verkaufen Dialog
        .confirmationDialog(
            settings.localizedString(for: "plant.detail.sell.confirm"),
            isPresented: $zeigeVerkaufenDialog,
            titleVisibility: .visible
        ) {
            let refund = Int(Double(pflanze.basePrice) * 0.5)
            Button("\(settings.localizedString(for: "plant.detail.sell.action")) (+\(refund) Coins)", role: .destructive) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                let sellTitle = settings.showHabitInsteadOfName 
                    ? settings.localizedString(for: pflanze.habitName)
                    : settings.localizedString(for: pflanze.name)
                shopStore.sell(id: pflanze.id, price: pflanze.basePrice, title: sellTitle)
                onLoeschen?()
            }
            Button(settings.localizedString(for: "button.cancel"), role: .cancel) { }
        }
        // MARK: - Notiz Sheet
        .sheet(isPresented: $zeigeNotizSheet) {
            NotizSheetView(pflanze: pflanze, editIndex: noteToEditIndex)
                .environmentObject(gardenStore)
                .environmentObject(settings)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
                .presentationBackground(.ultraThinMaterial)
        }
        // MARK: - Timer Sheet
        .sheet(isPresented: $zeigeTimerSheet) {
            TimerSheetView(pflanze: pflanze)
                .environmentObject(gardenStore)
                .environmentObject(settings)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
                .presentationBackground(.ultraThinMaterial)
        }
        // MARK: - Notiz Löschen Dialog
        .confirmationDialog(
            settings.localizedString(for: "plant.detail.note.delete.confirm"),
            isPresented: Binding(
                get: { noteToDeleteIndex != nil },
                set: { if !$0 { noteToDeleteIndex = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button(settings.localizedString(for: "plant.detail.note.delete.action"), role: .destructive) {
                if let index = noteToDeleteIndex {
                    gardenStore.notizEntfernen(pflanze: pflanze, index: index)
                }
            }
            Button(settings.localizedString(for: "button.cancel"), role: .cancel) { }
        }
        // MARK: - Timer Abbrechen Dialog
        .confirmationDialog(
            settings.localizedString(for: "plant.detail.timer.cancel.confirm"),
            isPresented: $zeigeTimerAbbrechenDialog,
            titleVisibility: .visible
        ) {
            Button(settings.localizedString(for: "plant.detail.timer.cancel.action"), role: .destructive) {
                gardenStore.timerEntfernen(pflanze: pflanze)
            }
            Button(settings.localizedString(for: "button.cancel"), role: .cancel) { }
        }
    }

    

}

// MARK: - Notiz Sheet
struct NotizSheetView: View {
    @ObservedObject var pflanze: HabitModel
    var editIndex: Int? = nil // Wenn nil -> Neuanlage, sonst Index zum Bearbeiten

    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.dismiss) private var dismiss

    @State private var notizText: String = ""

    var isEditing: Bool { editIndex != nil }

    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(settings.localizedString(for: isEditing ? "plant.detail.note.edit" : "plant.detail.note.add"))
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        Text(settings.showHabitInsteadOfName 
                             ? settings.localizedString(for: pflanze.habitName)
                             : settings.localizedString(for: pflanze.name))
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(Color.blauPrimary)
            }
            .padding(.top, 20)

            // Text Editor
            TextEditor(text: $notizText)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .scrollContentBackground(.hidden)
                .padding(16)
                .frame(minHeight: 140)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.primary.opacity(0.04))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                )
                .overlay(alignment: .topLeading) {
                    if notizText.isEmpty {
                        Text(settings.localizedString(for: "plant.detail.note.placeholder"))
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(.tertiary)
                            .padding(20)
                            .allowsHitTesting(false)
                    }
                }

            Spacer()

            // Speichern Button
            Button {
                if let index = editIndex {
                    gardenStore.notizAktualisieren(pflanze: pflanze, index: index, text: notizText)
                } else {
                    gardenStore.notizHinzufuegen(pflanze: pflanze, text: notizText)
                }
                dismiss()
            } label: {
                Text(settings.localizedString(for: isEditing ? "plant.detail.note.save" : "plant.detail.note.add.action"))
            }
            .buttonStyle(DuolingoButtonStyle(
                size: .large,
                fillWidth: true,
                backgroundColor: .blauPrimary,
                shadowColor: .blauPrimary.darker()
            ))
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
        .onAppear {
            if let index = editIndex, index >= 0 && index < pflanze.notizen.count {
                notizText = pflanze.notizen[index]
            }
        }
    }
}

// MARK: - Timer Sheet
struct TimerSheetView: View {
    @ObservedObject var pflanze: HabitModel
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.dismiss) private var dismiss

    @State private var ausgewaehltesDatum: Date = Date().addingTimeInterval(3600) // +1h default

    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(settings.localizedString(for: "plant.detail.timer"))
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        Text(settings.showHabitInsteadOfName 
                             ? settings.localizedString(for: pflanze.habitName)
                             : settings.localizedString(for: pflanze.name))
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "bell.badge")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(Color.orangePrimary)
            }
            .padding(.top, 20)

            // DatePicker
            DatePicker(
                "",
                selection: $ausgewaehltesDatum,
                in: Date()...,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.wheel)
            .labelsHidden()

            Spacer()

            // Aktiven Timer löschen (wenn vorhanden)
            if let existing = pflanze.timerDatum, existing > Date() {
                Button {
                    gardenStore.timerEntfernen(pflanze: pflanze)
                    dismiss()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "trash")
                            .font(.system(size: 14, weight: .bold))
                        Text(settings.localizedString(for: "plant.detail.timer.delete"))
                    }
                }
                .buttonStyle(DuolingoButtonStyle(
                    size: .medium,
                    fillWidth: true,
                    backgroundColor: .rotPrimary,
                    shadowColor: .rotPrimary.darker()
                ))
            }

            // Timer setzen Button
            Button {
                Task {
                    await NotificationManager.shared.requestPermission()
                    gardenStore.timerSetzen(pflanze: pflanze, datum: ausgewaehltesDatum)
                    dismiss()
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "bell.badge")
                        .font(.system(size: 14, weight: .bold))
                    Text(settings.localizedString(for: "plant.detail.timer.set"))
                }
            }
            .buttonStyle(DuolingoButtonStyle(
                size: .large,
                fillWidth: true,
                backgroundColor: .orangePrimary,
                shadowColor: .orangePrimary.darker()
            ))
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
        .onAppear {
            if let existing = pflanze.timerDatum, existing > Date() {
                ausgewaehltesDatum = existing
            }
        }
    }
}

// MARK: - StatLabelView
struct StatLabelView: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(iconColor)
            Text(value)
                .font(.system(size: 32, weight: .bold))
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
                .tracking(1.2)
        }
    }
}

// MARK: - PlantWeeklyStreakView
struct PlantWeeklyStreakView: View {
    @ObservedObject var pflanze: HabitModel
    private let calendar = Calendar.current
    
    var body: some View {
        HStack(spacing: 0) {
            let weekdays = ["M", "D", "M", "D", "F", "S", "S"] // Mo, Di, Mi, Do, Fr, Sa, So
            ForEach(0..<7, id: \.self) { index in
                VStack(spacing: 8) {
                    Text(weekdays[index])
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white.opacity(0.8))
                    
                    let dayXP = getXP(for: index)
                    
                    ZStack {
                        // Schatten/Tiefe (nur wenn aktiv)
                        if dayXP > 0 {
                            Circle()
                                .fill(Color.white.opacity(0.3))
                                .frame(width: 38, height: 38)
                                .offset(y: 3)
                        }
                        
                        // Haupt-Bubble
                        Circle()
                            .fill(dayXP > 0 ? Color.white : Color.white.opacity(0.15))
                            .frame(width: 38, height: 38)
            
                        if dayXP > 0 {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Color.orangePrimary)
                        }
                    }
                    .frame(width: 38, height: 41) // Platz für Schatten reservieren
                    
                    Text(dayXP > 0 ? "+\(dayXP) XP" : " ")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundStyle(dayXP > 0 ? .white : .clear)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 8)
    }
    
    private func getXP(for index: Int) -> Int {
        let today = calendar.startOfDay(for: Date())
        
        // Calendar weekday: Sun=1, Mon=2, Tue=3, Wed=4, Thu=5, Fri=6, Sat=7
        let currentWeekday = calendar.component(.weekday, from: today)
        
        // Convert to Mon=0, Tue=1, ..., Sun=6
        var normalizedToday = currentWeekday - 2
        if normalizedToday < 0 { normalizedToday = 6 } 
        
        let daysToSubtract = normalizedToday - index
        guard let targetDate = calendar.date(byAdding: .day, value: -daysToSubtract, to: today) else { return 0 }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let key = formatter.string(from: targetDate)
        
        return pflanze.xpHistory[key] ?? 0
    }
}
