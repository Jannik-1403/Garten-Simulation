import SwiftUI

struct InventoryItemDetailSheet: View {
    let item: ShopDetailPayload
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var shopStore: ShopStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var animateIcon = false
    @State private var showPlantPicker = false
    @State private var showSuccessPill = false
    @State private var successMessage = ""
    @State private var showNotizSheet = false
    @State private var noteToEditIndex: Int? = nil
    @State private var noteToDeleteIndex: Int? = nil
    @State private var showTriggerSheet = false
    @State private var showMaxLivesAlert = false

    private var isTrash: Bool { item.id.hasPrefix("trash.") }

    var body: some View {
        if isTrash {
            trashDetailBody
        } else {
            normalDetailBody
        }
    }

    // MARK: - Trash / Bad Habit Detail
    private var trashDetailBody: some View {
        NavigationStack {
            ZStack {
                Color.appHintergrund.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // MARK: Icon (klein)
                        Group {
                            if UIImage(named: item.icon) != nil {
                                Image(item.icon)
                                    .resizable()
                                    .scaledToFit()
                            } else {
                                Image(systemName: item.icon)
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(item.color)
                            }
                        }
                        .frame(width: 80, height: 80)
                        .shadow(color: item.color.opacity(0.25), radius: 12, x: 0, y: 6)
                        .scaleEffect(animateIcon ? 2.08 : 2.0)
                        .padding(.top, 24)

                        // MARK: Title + Subtitle
                        VStack(spacing: 6) {
                            let currentTitleKey = (settings.showHabitInsteadOfName && item.habitTitleKey != nil) ? item.habitTitleKey! : item.titleKey
                            Text(NSLocalizedString(currentTitleKey, comment: ""))
                                .font(.system(size: 26, weight: .black, design: .rounded))
                                .multilineTextAlignment(.center)

                            Text(NSLocalizedString(item.descriptionKey, comment: ""))
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }

                        // MARK: Weekly Streak Card (wie PflanzeDetailSheet)
                        badHabitWeeklyCard
                            .padding(.horizontal, 24)
                            .padding(.top, 8)

                        // MARK: Stats (nur Streak + Gesamt, plain text)
                        badHabitPlainStats
                            .padding(.horizontal, 28)

                        // MARK: Spezifische Tipps
                        if item.id.hasPrefix("trash.") && !item.id.contains("custom") {
                            VStack(spacing: 16) {
                                HStack {
                                    Text(String(localized: "habit.tips.title"))
                                        .font(.system(size: 22, weight: .black, design: .rounded))
                                    Spacer()
                                }
                                .padding(.horizontal, 28)

                                let tips = [
                                    ("BadHabitsUnsichtbar", String(localized: "habit.law.1"), "\(item.id).tip.1"),
                                    ("BadHabitsUnttraktiv", String(localized: "habit.law.2"), "\(item.id).tip.2"),
                                    ("BadHabitsSchwer", String(localized: "habit.law.3"), "\(item.id).tip.3"),
                                    ("BadHabitsUnbefriedigend", String(localized: "habit.law.4"), "\(item.id).tip.4")
                                ]

                                ForEach(tips, id: \.1) { tip in
                                    HStack(alignment: .center, spacing: 14) {
                                        Image(tip.0)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 44, height: 44)
                                            .scaleEffect(2.2)

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(tip.1)
                                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                                .foregroundColor(.primary)

                                            Text(String(localized: String.LocalizationValue(tip.2)))
                                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                                .foregroundColor(.secondary)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                        Spacer(minLength: 0)
                                    }
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                                            .fill(Color.white)
                                            .shadow(color: Color.black.opacity(0.12), radius: 0, x: 0, y: 4)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                                            .stroke(Color.black.opacity(0.04), lineWidth: 1)
                                    )
                                    .padding(.horizontal, 24)
                                }
                            }
                            .padding(.top, 4)
                        }

                        // MARK: Notizen
                        badHabitNotesSection
                            .padding(.horizontal, 24)

                        // MARK: Rückfall melden Button
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            showTriggerSheet = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 16))
                                Text(String(localized: "habit.relapse.report"))
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                            }
                        }
                        .buttonStyle(DuolingoButtonStyle(
                            size: .large,
                            fillWidth: true,
                            backgroundColor: Color.red,
                            shadowColor: Color.red.darker(),
                            foregroundColor: .white
                        ))
                        .padding(.horizontal, 24)
                        .padding(.top, -8)


                    }
                }
            }
            .standardNavigationX()
            .onAppear {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    animateIcon = true
                }
            }
            .sheet(isPresented: $showNotizSheet) {
                BadHabitNotizSheet(habitId: item.id, editIndex: noteToEditIndex)
                    .environmentObject(gardenStore)
                    .environmentObject(settings)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(32)
                    .presentationBackground(Color(UIColor.systemBackground))
            }
            .sheet(isPresented: $showTriggerSheet) {
                TriggerSelectionSheet(habitId: item.id)
                    .environmentObject(gardenStore)
                    .environmentObject(settings)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(32)
            }
            .confirmationDialog(
                String(localized: "plant.detail.note.delete.confirm"),
                isPresented: Binding(
                    get: { noteToDeleteIndex != nil },
                    set: { if !$0 { noteToDeleteIndex = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button(String(localized: "plant.detail.note.delete.action"), role: .destructive) {
                    if let index = noteToDeleteIndex {
                        gardenStore.deleteBadHabitNote(id: item.id, index: index)
                    }
                }
                Button(String(localized: "button.cancel"), role: .cancel) { }
            }

        }
    }
    // MARK: - Weekly Card (Orange, wie Pflanzen)
    @ViewBuilder
    private var badHabitWeeklyCard: some View {
        let calendar = Calendar.current
        let executions = gardenStore.badHabitExecutions[item.id] ?? []
        let weekdays = [
            String(localized: "common.mon"),
            String(localized: "common.tue"),
            String(localized: "common.wed"),
            String(localized: "common.thu"),
            String(localized: "common.fri"),
            String(localized: "common.sat"),
            String(localized: "common.sun")
        ]
        let fakePlant: HabitModel = {
            let model = HabitModel(
                id: item.id,
                name: NSLocalizedString(item.habitTitleKey ?? item.titleKey, comment: ""),
                symbolName: item.icon,
                symbolColor: item.colorHex,
                habitCategory: .lifestyle,
                symbolism: "",
                habitName: NSLocalizedString(item.habitTitleKey ?? item.titleKey, comment: "")
            )
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            for execution in executions {
                let key = formatter.string(from: execution.date)
                model.xpHistory[key] = (model.xpHistory[key] ?? 0) + 1
            }
            if let lastDate = executions.max(by: { $0.date < $1.date })?.date {
                model.streak = max(0, Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: lastDate), to: Calendar.current.startOfDay(for: Date())).day ?? 0)
            } else {
                model.streak = 0
            }
            return model
        }()

        NavigationLink(destination: StreakView(selectedPlant: fakePlant, isBadHabitMode: true)
            .environmentObject(StreakStore())
            .environmentObject(gardenStore)
            .environmentObject(settings)
        ) {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { index in
                        let rCount = relapseCount(on: index, executions: executions, calendar: calendar)
                        VStack(spacing: 8) {
                            Text(weekdays[index])
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.white.opacity(0.8))

                            ZStack {
                                if rCount > 0 {
                                    Circle()
                                        .fill(Color.white.opacity(0.3))
                                        .frame(width: 38, height: 38)
                                        .offset(y: 3)

                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 38, height: 38)

                                    Text(verbatim: "\(rCount)")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.orangePrimary)
                                } else {
                                    Circle()
                                        .fill(Color.white.opacity(0.15))
                                        .frame(width: 38, height: 38)
                                }
                            }
                            .frame(width: 38, height: 41)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 8)
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
    }

    private func relapseCount(on index: Int, executions: [BadHabitExecution], calendar: Calendar) -> Int {
        let today = calendar.startOfDay(for: Date())
        let currentWeekday = calendar.component(.weekday, from: today)
        var normalizedToday = currentWeekday - 2
        if normalizedToday < 0 { normalizedToday = 6 }
        let daysToSubtract = normalizedToday - index
        guard let targetDate = calendar.date(byAdding: .day, value: -daysToSubtract, to: today) else { return 0 }
        let targetStart = calendar.startOfDay(for: targetDate)
        let targetEnd = calendar.date(byAdding: .day, value: 1, to: targetStart)!
        return executions.filter { $0.date >= targetStart && $0.date < targetEnd }.count
    }

    // MARK: - Plain Stats (nur Streak + Gesamt)
    @ViewBuilder
    private var badHabitPlainStats: some View {
        let executions = gardenStore.badHabitExecutions[item.id] ?? []
        let total = executions.count

        let streakDays: Int = {
            if let lastDate = executions.max(by: { $0.date < $1.date })?.date {
                return max(0, Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: lastDate), to: Calendar.current.startOfDay(for: Date())).day ?? 0)
            }
            return 0
        }()

        HStack(spacing: 0) {
            VStack(spacing: 4) {
                HStack(spacing: 6) {
                    Image("Streak_Eis")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    Text(verbatim: total > 0 ? "\(streakDays)" : "-")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                }
                Text(String(localized: "habit.stats.streak").uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)

            Divider().frame(height: 32)

            VStack(spacing: 4) {
                HStack(spacing: 6) {
                    Image("Ablenkung")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    Text(verbatim: "\(total)")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                }
                Text(String(localized: "habit.stats.total").uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 8)
    }

    // MARK: - Notes Section
    @ViewBuilder
    private var badHabitNotesSection: some View {
        let notes = gardenStore.badHabitNotes[item.id] ?? []

        VStack(spacing: 8) {
            // Notizen Header & Liste
            HStack {
                Text(String(localized: "plant.detail.notes_header", defaultValue: "Notizen"))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                Spacer()
            }
            .padding(.bottom, 4)

            // Existing notes
            ForEach(notes.indices, id: \.self) { index in
                BadHabitNoteRowView(
                    index: index,
                    text: notes[index],
                    onTap: {
                        noteToEditIndex = index
                        showNotizSheet = true
                    },
                    onDelete: {
                        noteToDeleteIndex = index
                    },
                    deleteConfirmShowing: Binding(
                        get: { noteToDeleteIndex == index },
                        set: { if !$0 { noteToDeleteIndex = nil } }
                    ),
                    onConfirmDelete: {
                        gardenStore.deleteBadHabitNote(id: item.id, index: index)
                        noteToDeleteIndex = nil
                    },
                    onCancelDelete: {
                        noteToDeleteIndex = nil
                    }
                )
            }

            // Add note button
            Button {
                noteToEditIndex = nil
                showNotizSheet = true
            } label: {
                ZStack {
                    Text(String(localized: "plant.detail.note.add")).textCase(.uppercase)
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
            .padding(.top, 8)
        }
    }

    // MARK: - Normal (nicht-Trash) Detail Body
    private var normalDetailBody: some View {
        NavigationStack {
            ZStack {
                Color.appHintergrund.ignoresSafeArea()

                VStack(spacing: 32) {
                    // Icon Area
                    Group {
                        if UIImage(named: item.icon) != nil {
                            Image(item.icon)
                                .resizable()
                                .scaledToFit()
                        } else {
                            Image(systemName: item.icon)
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(item.color)
                        }
                    }
                    .frame(width: item.itemType == .decoration ? 240 : 120, height: item.itemType == .decoration ? 240 : 120)
                    .padding(.top, 60)
                    .shadow(color: item.itemType == .decoration ? .clear : item.color.opacity(0.3), radius: 20, x: 0, y: 10)
                    .scaleEffect(animateIcon ? 1.05 : 1.0)

                    VStack(spacing: 8) {
                        let currentTitleKey = (settings.showHabitInsteadOfName && item.habitTitleKey != nil) ? item.habitTitleKey! : item.titleKey
                        Text(NSLocalizedString(currentTitleKey, comment: ""))
                            .font(.system(size: 24, weight: .bold, design: .rounded))

                        Text(NSLocalizedString(item.descriptionKey, comment: ""))
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .lineSpacing(4)
                            .padding(.horizontal, 40)
                    }

                    Spacer()

                    // MARK: Button-Bereich
                        Button {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
                                dismiss()
                            }
                        } label: {
                            Text(String(localized: "button.ok"))
                        }
                        .buttonStyle(DuolingoButtonStyle(
                            size: .large,
                            fillWidth: true,
                            backgroundColor: item.color,
                            shadowColor: item.color.darker()
                        ))
                        .padding(.horizontal, 24)

                        // Sell Button
                        let sellPrice = Int(Double(item.price) * 0.5)
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            shopStore.sell(id: item.id, price: item.price, title: NSLocalizedString(item.titleKey, comment: ""))
                            gardenStore.itemEntfernen(id: item.id)
                            dismiss()
                        } label: {
                            VStack(spacing: 2) {
                                Text(String(localized: "shop.item.sell"))
                                    .font(.system(size: 14, weight: .bold))
                                HStack(spacing: 4) {
                                    Image("coin")
                                        .resizable().scaledToFit().frame(width: 14, height: 14)
                                    Text(verbatim: "+\(sellPrice)")
                                        .font(.system(size: 14, weight: .black))
                                }
                            }
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Capsule().stroke(Color.red.opacity(0.3), lineWidth: 2))
                        }
                        .padding(.horizontal, 44)
                        .padding(.bottom, 32)
                    }
                }
                .padding(.horizontal)
                .blur(radius: showSuccessPill ? 2 : 0)

                // Toast
                if showSuccessPill {
                    VStack {
                        Text(successMessage)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.gruenPrimary, in: Capsule())
                            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .padding(.top, 20)
                    }
                    .frame(maxWidth: .infinity, alignment: .top)
                    .zIndex(10)
                }
            }
            .standardNavigationX()
            .onAppear {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    animateIcon = true
                }
            }
        } // NavigationStack
    }


// MARK: - Bad Habit Notiz Sheet
struct BadHabitNotizSheet: View {
    let habitId: String
    var editIndex: Int? = nil

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
                    Text(NSLocalizedString(isEditing ? "plant.detail.note.edit" : "plant.detail.note.add", comment: ""))
                        .font(.system(size: 24, weight: .black, design: .rounded))
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
                        Text(String(localized: "plant.detail.note.placeholder"))
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(.tertiary)
                            .padding(20)
                            .allowsHitTesting(false)
                    }
                }

            Spacer()

            // Save Button
            Button {
                if let index = editIndex {
                    gardenStore.updateBadHabitNote(id: habitId, index: index, text: notizText)
                } else {
                    gardenStore.addBadHabitNote(id: habitId, text: notizText)
                }
                dismiss()
            } label: {
                Text(NSLocalizedString(isEditing ? "plant.detail.note.save" : "plant.detail.note.add.action", comment: ""))
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
            if let index = editIndex {
                let notes = gardenStore.badHabitNotes[habitId] ?? []
                if index >= 0 && index < notes.count {
                    notizText = notes[index]
                }
            }
        }
    }
}

#Preview {
    InventoryItemDetailSheet(
        item: ShopDetailPayload(
            id: "test",
            titleKey: "Super-Dünger",
            subtitle: "Wachstums-Boost",
            descriptionKey: "inventory.item.desc.growth_boost",
            price: 500,
            icon: "Powerup",
            colorHex: "#FFD000", // yellow
            symbolColor: "yellow",
            shadowColorHex: "#D9B200", // darker yellow
            tag: "POWER-UP",
            itemType: .plant,
            habitCategory: .fitness,
            symbolism: "inventory.item.symbolism.growth_boost",
            howToUse: "item.duenger_blitz.usage"
        )
    )
    .environmentObject(GardenStore())
    .environmentObject(ShopStore())
    .environmentObject(SettingsStore())
}
