import SwiftUI

struct PflanzeDetailSheet: View {
    @ObservedObject var pflanze: HabitModel
    let wetterEvent: WetterEvent
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var shopStore: ShopStore
    @EnvironmentObject var powerUpStore: PowerUpStore
    @EnvironmentObject var pfadStore: GartenPfadStore
    @EnvironmentObject var streakStore: StreakStore
    @EnvironmentObject var interactiveTourManager: InteractiveTourManager
    @Environment(\.dismiss) private var dismiss
    var onLoeschen: (() -> Void)? = nil

    @State private var zeigeVerkaufenDialog = false
    @State private var zeigeFocusSession = false
    @State private var zeigeNotizSheet = false
    @State private var zeigeTimerSheet = false
    @State private var zeigeTimerEditSheet = false
    @State private var pulsieren = false
    @State private var zeigeTimerAbbrechenDialog = false
    @State private var noteToEditIndex: Int? = nil
    @State private var noteToDeleteIndex: Int? = nil
    @State private var ausgewaehlterEffekt: PflanzenEffekt? = nil
    @State private var selectedTab: DetailTab = .uebersicht
    @State private var pfadBereit: Bool = false
    
    @AppStorage("customRoutinesData") private var customRoutinesData: Data = Data()
    
    private var parentRoutineWithReminder: RoutineUIData? {
        guard let routines = try? JSONDecoder().decode([RoutineUIData].self, from: customRoutinesData) else { return nil }
        return routines.first(where: { routine in
            routine.contains(habit: pflanze) && (routine.reminderSchedule != nil || routine.reminderTime != nil)
        })
    }


    enum DetailTab: String, CaseIterable {
        case uebersicht
        case verlauf
    }

    private var activeStateID: String {
        "\(pflanze.id)-\(pflanze.wiederbelebtAm?.description ?? "none")"
    }

    private var aktiveEffekte: [PflanzenEffekt] {
        var effekte: [PflanzenEffekt] = []

        // 1. Status-Effekte (Stable ID)
        if pflanze.isPenaltyActive {
            let expiration = pflanze.wiederbelebtAm?.addingTimeInterval(Double(pflanze.strafTage) * 24 * 3600)
            effekte.append(PflanzenEffekt(
                id: UUID(uuidString: "77777777-7777-7777-7777-000000000001")!,
                typ: .status,
                ikonQuelle: .asset("Schildkröte"),
                titel: settings.localizedString(for: "effekt.erholung.titel"),
                beschreibung: settings.localizedString(for: "effekt.erholung.beschreibung"),
                expiresAt: expiration
            ))
        }

        // 2. Wetter (Stable ID)
        let endOfDay = Calendar.current.startOfDay(for: Date().addingTimeInterval(86400))
        effekte.append(PflanzenEffekt(
            id: UUID(uuidString: "88888888-8888-8888-8888-000000000002")!,
            typ: .wetter,
            ikonQuelle: .asset(wetterEvent.customIconName),
            titel: wetterEvent.titel,
            beschreibung: wetterEvent.untertitel,
            expiresAt: endOfDay
        ))

        // 3. Power-Ups (Stable ID from Activity ID)
        for aktiv in gardenStore.activePowerUps where aktiv.isActive {
            if aktiv.targetPlantId == nil || aktiv.targetPlantId == pflanze.id {
                if let base = GameDatabase.allPowerUps.first(where: { $0.id == aktiv.powerUpId }) {
                    effekte.append(PflanzenEffekt(
                        id: aktiv.id, // Nutze die stabile ID des Power-Ups!
                        typ: .powerUp,
                        ikonQuelle: .asset(base.symbolName),
                        titel: settings.localizedString(for: base.name),
                        beschreibung: settings.localizedString(for: base.description),
                        expiresAt: aktiv.expiresAt
                    ))
                }
            }
        }

        return Array(effekte)
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 28) {
                    // MARK: - HERO (Zone 1)
                    if selectedTab == .uebersicht {
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
                                        plant: Plant(id: "fallback", name: settings.localizedString(for: "common.plant_fallback"), symbolName: pflanze.symbolName, assetName: nil, symbol: "🌱", symbolColor: pflanze.symbolColor, habitCategory: pflanze.habitCategory, symbolism: ""),
                                        seltenheit: pflanze.seltenheit,
                                        farbe: pflanze.color,
                                        sekundaerFarbe: pflanze.color.darker(),
                                        groesse: 140
                                    )
                                    .scaleEffect(pulsieren ? 1.03 : 1.0)
                                    .allowsHitTesting(false)
                                }
                            }
                            .scaleEffect(min(1.0, ScreenSize.width / 390)) // Scale down on smaller iPhones
    
                            Text(settings.showHabitInsteadOfName ? settings.localizedString(for: pflanze.displayedHabitName) : settings.localizedString(for: pflanze.name))
                                .font(.system(size: 36, weight: .black, design: .rounded))
                                .minimumScaleFactor(0.5)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
    
                            Text(settings.localizedString(for: pflanze.habitCategory.localizationKey))
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                                .textCase(.uppercase)
                                .tracking(1.5)
    
                            // Vier-Spalten Stats Header (In einer schwebenden Karte)
                            ViewThatFits(in: .horizontal) {
                                statsRow
                                ScrollView(.horizontal, showsIndicators: false) {
                                    statsRow.frame(minWidth: 400)
                                }
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
    
                            // NEU: Pflanzen-Effekte (Wetter, Power-Ups, Penalties)
                            if !aktiveEffekte.isEmpty {
                                HStack(spacing: 12) {
                                    ForEach(aktiveEffekte) { effekt in
                                        EffektIkonButton(effekt: effekt, size: 28, iconSkalierung: effekt.typ == .wetter ? 1.5 : 1.0) {
                                            ausgewaehlterEffekt = effekt
                                        }
                                    }
                                }
                                .padding(.top, 16)
                                .padding(.bottom, 4)
                                .id(activeStateID)
                            }
                        }
                        .padding(.top, 40)
                    }

                // MARK: - TAB PICKER & CONTENT
                Section {
                    if selectedTab == .uebersicht {
                    streakCardView
                        .tourAnchor(.plantStreak)
                        .id("streakCard")

                // MARK: - ACTIONS (Zone 3)
                VStack(spacing: 12) {
                    

                    // Notizen Liste
                    ForEach(pflanze.notizen.indices, id: \.self) { index in
                        NoteRowView(
                            pflanze: pflanze,
                            index: index,
                            onTap: {
                                noteToEditIndex = index
                                zeigeNotizSheet = true
                            },
                            onDelete: {
                                noteToDeleteIndex = index
                            },
                            deleteConfirmShowing: Binding(
                                get: { noteToDeleteIndex == index },
                                set: { if !$0 { noteToDeleteIndex = nil } }
                            ),
                            onConfirmDelete: {
                                gardenStore.notizEntfernen(pflanze: pflanze, index: index)
                                noteToDeleteIndex = nil
                            },
                            onCancelDelete: {
                                noteToDeleteIndex = nil
                            }
                        )
                        .padding(.horizontal, 24)
                        .padding(.bottom, 4)
                    }
                    

                    // Own Timer Row (always show if active, so user can edit non-overridden days)
                    if pflanze.hasActiveReminder {
                        TimerRowView(
                            pflanze: pflanze,
                            onTap: { zeigeTimerEditSheet = true },
                            onDelete: { zeigeTimerAbbrechenDialog = true },
                            deleteConfirmShowing: $zeigeTimerAbbrechenDialog,
                            onConfirmDelete: { gardenStore.timerEntfernen(pflanze: pflanze) }
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

                    // Focus Session Button
                    Item3DButton(
                        farbe: .orangePrimary,
                        sekundaerFarbe: .orangePrimary.darker(),
                        groesse: 50,
                        isRectangular: true,
                        aktion: { zeigeFocusSession = true }
                    ) {
                        ZStack {
                            HStack {
                                Spacer()
                                Image(systemName: "timer")
                                    .font(.system(size: 32))
                                    .foregroundStyle(.white.opacity(0.12))
                                    .offset(x: 35, y: 15)
                            }
                            Text(settings.localizedString(for: "Fokus-Session starten")).textCase(.uppercase)
                                .font(.system(size: 16, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .clipped()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .tourAnchor(.focusTimer)
                    .id(TourStep.focusTimer)



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

                } // end uebersicht tab

                if selectedTab == .verlauf {
                    if pflanze.plantID.hasPrefix("custom_") || GameDatabase.shared.plant(for: pflanze.plantID) == nil {
                        HabitVerlaufView(pflanze: pflanze)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 8)
                    } else {
                        IsometricPathView(habit: pflanze)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(IsometricGrassBackground())
                            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                            .tourAnchor(.plantPath)
                    }
                }
                } header: {
                    if !(pflanze.plantID.hasPrefix("custom_") || GameDatabase.shared.plant(for: pflanze.plantID) == nil) {
                        Picker("", selection: $selectedTab) {
                            Text(settings.localizedString(for: "tab.uebersicht")).tag(DetailTab.uebersicht)
                            Text(settings.localizedString(for: "tab.verlauf")).tag(DetailTab.verlauf)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                        .background(Color(UIColor.secondarySystemBackground))
                    }
                } // End of Section
            }
            } // End of ScrollView
            .onChange(of: interactiveTourManager.currentStep) { _, newStep in
                withAnimation(.spring()) {
                    if newStep == .focusTimer {
                        proxy.scrollTo(TourStep.focusTimer, anchor: .bottom)
                    } else if newStep == .plantStreak {
                        proxy.scrollTo("streakCard", anchor: .top)
                    } else if newStep == .plantPath {
                        selectedTab = .verlauf
                    }
                }
            }
            } // End of ScrollViewReader
        }
        .navigationTitle(settings.showHabitInsteadOfName ? settings.localizedString(for: pflanze.displayedHabitName) : settings.localizedString(for: pflanze.name))
        .navigationBarTitleDisplayMode(.inline)
        .standardNavigationX()
        .background(Color(UIColor.secondarySystemBackground))
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
                .presentationBackground(Color(UIColor.systemBackground))
        }
        // MARK: - Timer Create Sheet
        .sheet(isPresented: $zeigeTimerSheet) {
            TimerCreateSheetView(pflanze: pflanze)
                .environmentObject(gardenStore)
                .environmentObject(settings)
                .presentationDetents([.fraction(0.4)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
                .presentationBackground(Color(UIColor.systemBackground))
        }
        // MARK: - Timer Edit Sheet
        .fullScreenCover(isPresented: $zeigeTimerEditSheet) {
            NavigationStack {
                TimerEditSheetView(pflanze: pflanze)
                    .environmentObject(gardenStore)
                    .environmentObject(settings)
            }
        }

        // MARK: - Notiz Bearbeiten: Direkt Sheet öffnen (kein Dialog mehr)
        .onChange(of: noteToEditIndex) { _, newIndex in
            if newIndex != nil {
                zeigeNotizSheet = true
            }
        }

        // MARK: - Effekt Detail Sheet
        .sheet(item: $ausgewaehlterEffekt) { effekt in
            EffektDetailSheet(effekt: effekt)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $zeigeFocusSession) {
            FocusSessionView(pflanze: pflanze)
                .environmentObject(gardenStore)
                .environmentObject(settings)
                .environmentObject(powerUpStore)
        }
    }
}
    private func sicherstellenDassPfadExistiert() {
        let strangExistiert = pfadStore.straenge.contains(where: {
            $0.pflanzenID == pflanze.id
        })
        
        if strangExistiert {
            pfadBereit = true
            return
        }
        
        // Kein Strang → jetzt synchron erstellen
        let ziel = settings.ausgewaehltesZiel.isEmpty ? "fitness" : settings.ausgewaehltesZiel
        let sRaw = pflanze.individualSchwierigkeit ?? PfadSchwierigkeit.anfaenger.rawValue
        let schwierigkeit = PfadSchwierigkeit(rawValue: sRaw) ?? .anfaenger
        
        pfadStore.pflanzeHinzufuegen(pflanze, ziel: ziel, schwierigkeit: schwierigkeit)
        
        // Kurze Pause damit SwiftData committen kann, dann bereit melden
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            pfadBereit = pfadStore.straenge.contains(where: {
                $0.pflanzenID == pflanze.id
            })
        }
    }

    private var statsRow: some View {
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

            Text(pflanze.seltenheit.lokalisiertTitel)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .lineLimit(2)
                .minimumScaleFactor(0.7)
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
    }
    
    @ViewBuilder
    private var streakCardView: some View {
        NavigationLink(destination: StreakView(selectedPlant: pflanze)
            .environmentObject(streakStore)
            .environmentObject(gardenStore)
            .environmentObject(settings)
        ) {
            VStack(spacing: 0) {
                PlantWeeklyStreakView(pflanze: pflanze)
                    .padding(.vertical, 16)
            }
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.orangeSecondary)
                        .offset(y: 4)
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
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
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

// MARK: - Timer Edit Sheet
struct TimerEditSheetView: View {
    @ObservedObject var pflanze: HabitModel
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var shopStore: ShopStore
    @EnvironmentObject var powerUpStore: PowerUpStore
    @EnvironmentObject var pfadStore: GartenPfadStore
    @EnvironmentObject var streakStore: StreakStore
    @Environment(\.dismiss) private var dismiss

    @State private var schedule: ReminderSchedule = ReminderSchedule.defaultSchedule(time: Date())
    
    // UI States
    @State private var expandedDay: Int? = nil
    @State private var isLinkingNotes: Bool = false
    @State private var selectedDaysForLinking: Set<Int> = []
    @State private var selectedNoteForLinking: String? = nil
    @State private var showTimeline = false
    
    // Focus
    @FocusState private var focusedDay: Int?

    let daysKeys = ["days.monday", "days.tuesday", "days.wednesday", "days.thursday", "days.friday", "days.saturday", "days.sunday"]
    
    @AppStorage("customRoutinesData") private var customRoutinesData: Data = Data()
    
    private var parentRoutineWithReminder: RoutineUIData? {
        guard let routines = try? JSONDecoder().decode([RoutineUIData].self, from: customRoutinesData) else { return nil }
        return routines.first(where: { routine in
            routine.contains(habit: pflanze) && (routine.reminderSchedule != nil || routine.reminderTime != nil)
        })
    }
    private var pflanzName: String {
        settings.showHabitInsteadOfName
            ? settings.localizedString(for: pflanze.habitName)
            : settings.localizedString(for: pflanze.name)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(settings.localizedString(for: "plant.detail.timer"))
                            .font(.system(size: 22, weight: .black, design: .rounded))
                        Text(pflanzName)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 16)
                
                if isLinkingNotes, let note = selectedNoteForLinking {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notiz zuweisen: \(note)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                        Text("Wähle die Tage aus, an denen diese Notiz erscheinen soll.")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.orangePrimary.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
                }

                // Days List
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(1...7, id: \.self) { day in
                            dayRow(for: day)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .background(Color.appHintergrund.ignoresSafeArea())
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if isLinkingNotes {
                        Button {
                            // Bestätigen der Verknüpfung
                            withAnimation {
                                for day in selectedDaysForLinking {
                                    schedule.weekdays[dayIndex(for: day)].customMessage = selectedNoteForLinking
                                }
                                isLinkingNotes = false
                                selectedDaysForLinking.removeAll()
                                selectedNoteForLinking = nil
                            }
                        } label: {
                            Text(settings.localizedString(for: "common.done_button"))
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        .disabled(selectedDaysForLinking.isEmpty)
                    } else if focusedDay != nil {
                        Button {
                            focusedDay = nil
                        } label: {
                            Image(systemName: "keyboard.chevron.compact.down")
                        }
                    } else {
                        Button {
                            autoSave()
                            dismiss()
                        } label: {
                            Text(settings.localizedString(for: "common.done_button"))
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                    }
                }

                ToolbarItem(placement: .topBarLeading) {
                    if isLinkingNotes {
                        Button {
                            withAnimation {
                                isLinkingNotes = false
                                selectedDaysForLinking.removeAll()
                                selectedNoteForLinking = nil
                            }
                        } label: {
                            Text(settings.localizedString(for: "common.cancel"))
                                .font(.system(size: 16, weight: .regular))
                                .foregroundStyle(.red)
                        }
                    } else {
                        Menu {
                            // 1. Notizen verknüpfen Sub-Menu
                            Menu {
                                if pflanze.notizen.isEmpty {
                                    Text(settings.localizedString(for: "plant.detail.note.empty"))
                                } else {
                                    ForEach(pflanze.notizen, id: \.self) { notiz in
                                        Button(notiz) {
                                            withAnimation {
                                                selectedNoteForLinking = notiz
                                                isLinkingNotes = true
                                                expandedDay = nil
                                            }
                                        }
                                    }
                                }
                            } label: {
                                Label(settings.localizedString(for: "timer.note.link"), systemImage: "link")
                            }
                            
                            // 2. Wiederholung für alle Sub-Menu
                            Menu {
                                ForEach(ReminderRepeatMode.allCases, id: \.self) { mode in
                                    Button {
                                        withAnimation {
                                            for i in 0..<schedule.weekdays.count {
                                                if schedule.weekdays[i].isEnabled {
                                                    schedule.weekdays[i].repeatMode = mode
                                                }
                                            }
                                        }
                                    } label: {
                                        Label(settings.localizedString(for: mode.localizationKey), systemImage: mode.sfSymbol)
                                    }
                                }
                            } label: {
                                Label(settings.localizedString(for: "timer.repeat.title"), systemImage: "repeat")
                            }
                            
                            // 3. Zeitleiste (Alle Benachrichtigungen)
                            Button {
                                showTimeline = true
                            } label: {
                                Label("Zeitleiste", systemImage: "list.bullet.rectangle.portrait")
                            }
                            
                            // 4. Löschen
                            Button(role: .destructive) {
                                gardenStore.timerEntfernen(pflanze: pflanze)
                                dismiss()
                            } label: {
                                Label(settings.localizedString(for: "plant.detail.timer.delete"), systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 20))
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $showTimeline) {
                PlantTimelineView()
                    .environmentObject(gardenStore)
                    .environmentObject(settings)
                    .environmentObject(shopStore)
                    .environmentObject(powerUpStore)
                    .environmentObject(pfadStore)
                    .environmentObject(streakStore)
            }
        }
        .onAppear {
            if let existing = pflanze.reminderSchedule {
                schedule = existing
            } else if let legacyTime = pflanze.reminderTime {
                schedule = ReminderSchedule.defaultSchedule(time: legacyTime, customMessage: pflanze.customReminderMessage)
            } else {
                var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
                components.hour = 8
                components.minute = 0
                let defaultTime = Calendar.current.date(from: components) ?? Date()
                schedule = ReminderSchedule.defaultSchedule(time: defaultTime)
            }
        }
    }
    
    private func dayIndex(for day: Int) -> Int {
        schedule.weekdays.firstIndex(where: { $0.weekday == day }) ?? 0
    }
    
    private func routineOverrides(day: Int) -> Bool {
        guard let routine = parentRoutineWithReminder, routine.overrideIndividualReminders else {
            return false
        }
        if let sched = routine.reminderSchedule {
            let index = sched.weekdays.firstIndex(where: { $0.weekday == day }) ?? 0
            return sched.weekdays[index].isEnabled
        }
        return true
    }
    
    @ViewBuilder
    private func dayRow(for day: Int) -> some View {
        let index = dayIndex(for: day)
        let isEnabled = schedule.weekdays[index].isEnabled
        let isOverridden = routineOverrides(day: day)
        let isExpanded = expandedDay == day && !isLinkingNotes && !isOverridden
        let isSelectedForLinking = selectedDaysForLinking.contains(day)
        
        VStack(spacing: 12) {
            // Header Row (Tap to expand/link)
            Button {
                if isOverridden { return }
                if isLinkingNotes {
                    if isEnabled {
                        withAnimation {
                            if isSelectedForLinking {
                                selectedDaysForLinking.remove(day)
                            } else {
                                selectedDaysForLinking.insert(day)
                            }
                        }
                    }
                } else {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75, blendDuration: 0)) {
                        if !isEnabled {
                            schedule.weekdays[index].isEnabled = true
                            expandedDay = day
                        } else {
                            if expandedDay == day {
                                expandedDay = nil
                                focusedDay = nil
                            } else {
                                expandedDay = day
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    if isLinkingNotes {
                        Image(systemName: isSelectedForLinking ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 20))
                            .foregroundStyle(isSelectedForLinking ? Color.orangePrimary : Color.secondary.opacity(0.3))
                    }
                    
                    Text(settings.localizedString(for: daysKeys[day-1]))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle((isEnabled && !isOverridden) ? Color.primary : Color.secondary.opacity(0.5))
                    
                    Spacer()
                    
                    if isOverridden {
                        HStack(spacing: 4) {
                            if let routineName = parentRoutineWithReminder?.titleKey {
                                Text(settings.localizedString(for: routineName))
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color(hex: parentRoutineWithReminder!.colorHex))
                            }
                            Text("Pausiert")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary.opacity(0.6))
                        }
                    } else if isEnabled {
                        if !isLinkingNotes {
                            Text(timeFormatted(schedule.weekdays[index].time))
                                .font(.system(size: 16, weight: isExpanded ? .bold : .semibold, design: .rounded))
                                .foregroundStyle(Color.primary)
                            
                            Image(systemName: "chevron.down")
                                .rotationEffect(.degrees(isExpanded ? 180 : 0))
                                .foregroundStyle(.secondary)
                                .font(.system(size: 14, weight: isExpanded ? .bold : .medium))
                        }
                    } else {
                        Text("Ausgeschaltet")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary.opacity(0.6))
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.secondary.opacity(0.3))
                            .font(.system(size: 18))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .contentShape(Rectangle())
            }
            .buttonStyle(PflanzeDetailListRowButtonStyle(isVisualPressed: false))
            
            // Expanded Content
            if isExpanded {
                expandedContent(for: index, day: day)
            }
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        .listRowBackground(
            isLinkingNotes && isSelectedForLinking
                ? Color.orangePrimary.opacity(0.1)
                : nil
        )
    }
    
    @ViewBuilder
    private func expandedContent(for index: Int, day: Int) -> some View {
        VStack(spacing: 16) {
            Divider()
                .padding(.horizontal, 16)
            
            DatePicker(
                "",
                selection: $schedule.weekdays[index].time,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .frame(height: 150)
            .clipped()
            
            // Message Field
            VStack(alignment: .leading, spacing: 6) {
                Text(settings.localizedString(for: "timer.notification.title"))
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                
                TextField(String(format: settings.localizedString(for: "timer.preview.body.example"), pflanzName),
                          text: Binding(
                              get: { schedule.weekdays[index].customMessage ?? "" },
                              set: { schedule.weekdays[index].customMessage = $0.isEmpty ? nil : $0 }
                          ))
                    .focused($focusedDay, equals: day)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .padding(12)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
            
            // Repeat Mode
            VStack(alignment: .leading, spacing: 6) {
                Text(settings.localizedString(for: "timer.repeat.title"))
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    
                Picker("", selection: $schedule.weekdays[index].repeatMode) {
                    ForEach(ReminderRepeatMode.allCases, id: \.self) { mode in
                        Text(settings.localizedString(for: mode.localizationKey)).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            
            // Deaktivieren Button
            Button(role: .destructive) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    schedule.weekdays[index].isEnabled = false
                    if expandedDay == day {
                        expandedDay = nil
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Deaktivieren")
                }
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(Color.red.opacity(0.1))
                .foregroundColor(.red)
                .cornerRadius(10)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(.systemGray4))
                    .offset(y: 4)
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
            }
        )
    }
    
    private func timeFormatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }

    private func autoSave() {
        Task {
            let status = await NotificationManager.shared.checkAuthorizationStatus()
            if status == .denied {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    await UIApplication.shared.open(url)
                }
            } else {
                _ = await NotificationManager.shared.requestPermission()
                gardenStore.timerScheduleSetzen(pflanze: pflanze, schedule: schedule)
            }
        }
    }
}

// MARK: - Timer Create Sheet
struct TimerCreateSheetView: View {
    @ObservedObject var pflanze: HabitModel
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.dismiss) private var dismiss

    @State private var ausgewaehlteZeit: Date = {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 8
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }()

    var body: some View {
        VStack(spacing: 20) {
            Text(settings.localizedString(for: "plant.detail.timer.set"))
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .padding(.top, 24)

            DatePicker("", selection: $ausgewaehlteZeit, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()

            Button {
                Task {
                    let status = await NotificationManager.shared.checkAuthorizationStatus()
                    if status == .denied {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            await UIApplication.shared.open(url)
                        }
                    } else {
                        _ = await NotificationManager.shared.requestPermission()
                        gardenStore.timerSetzen(pflanze: pflanze, datum: ausgewaehlteZeit)
                        dismiss()
                    }
                }
            } label: {
                Text(settings.localizedString(for: "plant.detail.timer.set"))
            }
            .buttonStyle(DuolingoButtonStyle(size: .large, fillWidth: true, backgroundColor: .orangePrimary, shadowColor: .orangePrimary.darker()))
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(Color.appHintergrund.ignoresSafeArea())
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
    @EnvironmentObject var settings: SettingsStore
    private let calendar = Calendar.current
    private var weekdays: [String] {
        [
            settings.localizedString(for: "common.mon"),
            settings.localizedString(for: "common.tue"),
            settings.localizedString(for: "common.wed"),
            settings.localizedString(for: "common.thu"),
            settings.localizedString(for: "common.fri"),
            settings.localizedString(for: "common.sat"),
            settings.localizedString(for: "common.sun")
        ]
    }
    
    var body: some View {
        HStack(spacing: 0) {
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
                    
                    Text(dayXP > 0 ? "+\(dayXP) \(settings.localizedString(for: "common.xp"))" : " ")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundStyle(dayXP > 0 ? .white : .clear)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 8)
    }
    
    private func getXP(for index: Int) -> Int {
        let today = calendar.startOfDay(for: Date())
        let currentWeekday = calendar.component(.weekday, from: today)
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

// MARK: - List Row 3D Button Style
struct PflanzeDetailListRowButtonStyle: ButtonStyle {
    var isVisualPressed: Bool = false
    @AppStorage("isHapticEnabled") var isHapticEnabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed || isVisualPressed
        configuration.label
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color(.systemGray4))
                        .offset(y: isPressed ? 0 : 4)
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white)
                }
            )
            .offset(y: isPressed ? 4 : 0)
            .animation(.spring(response: 0.22, dampingFraction: 0.5), value: isPressed)
            .sensoryFeedback(trigger: isPressed) { _, newValue in
                (isHapticEnabled && newValue) ? .impact(flexibility: .soft, intensity: 0.75) : nil
            }
    }
}

// MARK: - Note Row (own State for isVisualPressed animation)
struct NoteRowView: View {
    @EnvironmentObject var settings: SettingsStore
    let pflanze: HabitModel
    let index: Int
    let onTap: () -> Void
    let onDelete: () -> Void
    let deleteConfirmShowing: Binding<Bool>
    let onConfirmDelete: () -> Void
    let onCancelDelete: () -> Void

    @State private var isVisualPressed = false
    @State private var deletePressed = false

    var body: some View {
        // The entire row (including X) lives in one Button so everything animates together.
        // The X intercepts its own tap via simultaneousGesture without triggering the parent.
        Button {
            isVisualPressed = true
            FeedbackManager.shared.playTap()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                isVisualPressed = false
                onTap()
            }
        } label: {
            HStack(spacing: 12) {
                Image("Notizen")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .scaleEffect(2.5)

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(settings.localizedString(for: "plant.detail.note")) \(index + 1)")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                    Text(pflanze.notizen[index])
                        .lineLimit(2)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }

                Spacer()

                // X delete button — inside the label so it moves with the card.
                // Uses simultaneousGesture so it intercepts the tap independently.
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.red.opacity(0.7))
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                    .simultaneousGesture(
                        TapGesture().onEnded { onDelete() }
                    )
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 14)
        }
        .buttonStyle(PflanzeDetailListRowButtonStyle(isVisualPressed: isVisualPressed))
        .confirmationDialog(
            settings.localizedString(for: "plant.detail.note.delete.confirm"),
            isPresented: deleteConfirmShowing,
            titleVisibility: .visible
        ) {
            Button(settings.localizedString(for: "plant.detail.note.delete.action"), role: .destructive) {
                onConfirmDelete()
            }
            Button(settings.localizedString(for: "button.cancel"), role: .cancel) {
                onCancelDelete()
            }
        }
    }
}

// MARK: - Timer Row (own State for isVisualPressed animation)
struct TimerRowView: View {
    @EnvironmentObject var settings: SettingsStore
    let pflanze: HabitModel
    let onTap: () -> Void
    let onDelete: () -> Void
    let deleteConfirmShowing: Binding<Bool>
    let onConfirmDelete: () -> Void

    @State private var isVisualPressed = false

    var body: some View {
        // The entire row (including X) lives in one Button so everything animates together.
        Button {
            isVisualPressed = true
            FeedbackManager.shared.playTap()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                isVisualPressed = false
                onTap()
            }
        } label: {
            HStack(spacing: 12) {
                Image("Erinnerung")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .scaleEffect(2.5)

                VStack(alignment: .leading, spacing: 2) {
                    Text(settings.localizedString(for: "plant.detail.timer.active"))
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                    if let next = pflanze.nextActiveReminder {
                        Text("\(next.time, style: .time)")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                    } else {
                        Text(settings.localizedString(for: "timer.weekday.title"))
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                    }
                }
                Spacer()

                // X delete button — inside the label so it moves with the card.
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.red.opacity(0.8))
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                    .simultaneousGesture(
                        TapGesture().onEnded { onDelete() }
                    )
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 14)
        }
        .buttonStyle(PflanzeDetailListRowButtonStyle(isVisualPressed: isVisualPressed))
        .confirmationDialog(
            settings.localizedString(for: "plant.detail.timer.cancel.confirm"),
            isPresented: deleteConfirmShowing,
            titleVisibility: .visible
        ) {
            Button(settings.localizedString(for: "plant.detail.timer.cancel.action"), role: .destructive) {
                onConfirmDelete()
            }
            Button(settings.localizedString(for: "button.cancel"), role: .cancel) { }
        }
    }
}

// MARK: - Streak Card Button Style
// Mirrors PflanzenCardButtonStyle: responds to BOTH configuration.isPressed (hold)
// and isVisualPressed (quick tap) so the animation is always visible.
struct StreakCardButtonStyle: ButtonStyle {
    @AppStorage("isHapticEnabled") var isHapticEnabled: Bool = true
    let isVisualPressed: Bool

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed || isVisualPressed

        ZStack {
            // 3D Shadow
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.orangeSecondary)

            // Main Orange Surface
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [.orangePrimary, .orangePrimary.opacity(0.9)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
                )
                .overlay(configuration.label)
                .offset(y: isPressed ? 0 : -4)
        }
        .offset(y: isPressed ? 4 : 0)
        .animation(.spring(response: 0.22, dampingFraction: 0.5), value: isPressed)
        .sensoryFeedback(trigger: isPressed) { _, newValue in
            (isHapticEnabled && newValue) ? .impact(flexibility: .soft, intensity: 0.75) : nil
        }
    }
}
