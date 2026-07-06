import SwiftUI

// MARK: - Card 3D Button Style (for plant cards in grid/timeline)
struct Card3DButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.black.opacity(0.15))
                .offset(y: 4)

            configuration.label
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .offset(y: configuration.isPressed ? 4 : 0)
        }
        .animation(.spring(response: 0.22, dampingFraction: 0.5, blendDuration: 0), value: configuration.isPressed)
    }
}

// MARK: - Timeline Card Button Style (mirrors PflanzenCardButtonStyle exactly)
struct TimelineCardButtonStyle: ButtonStyle {
    @AppStorage("isHapticEnabled") var isHapticEnabled: Bool = true
    let isVisualPressed: Bool
    private let depth: CGFloat = 4

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed || isVisualPressed

        ZStack(alignment: .bottom) {
            // Shadow base
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(white: 0.78))
                .padding(.horizontal, 1)

            // White top surface
            configuration.label
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.black.opacity(0.1), lineWidth: 1)
                )
                .offset(y: isPressed ? 0 : -depth)
        }
        .animation(.spring(response: 0.22, dampingFraction: 0.5), value: isPressed)
        .sensoryFeedback(trigger: isPressed) { _, newValue in
            (isHapticEnabled && newValue) ? .impact(flexibility: .soft, intensity: 0.75) : nil
        }
    }
}

// MARK: - Main Timeline View
struct PlantTimelineView: View {
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.dismiss) private var dismiss

    var onClose: (() -> Void)? = nil

    @AppStorage("customRoutinesData") private var customRoutinesData: Data = Data()
    
    @State private var selectedPlant: HabitModel? = nil
    @State private var isNavigating: Bool = false
    
    enum TimelineItem: Identifiable {
        case routine(RoutineUIData, time: Date, plants: [HabitModel])
        case plant(HabitModel)
        
        var id: String {
            switch self {
            case .routine(let r, _, _): return "routine_\(r.id.uuidString)"
            case .plant(let p): return "plant_\(p.id)"
            }
        }
    }

    // Items WITH a reminder time, sorted by time
    var timelineItems: [TimelineItem] {
        let routines = (try? JSONDecoder().decode([RoutineUIData].self, from: customRoutinesData)) ?? []
        
        var items: [TimelineItem] = []
        var processedPlantIDs = Set<String>()
        
        let sortedPlants = gardenStore.pflanzen
            .filter { $0.hasActiveReminder && $0.nextActiveReminder != nil }
            .sorted { (p1, p2) -> Bool in
                guard let t1 = p1.nextActiveReminder?.time, let t2 = p2.nextActiveReminder?.time else { return false }
                let h1 = Calendar.current.component(.hour, from: t1)
                let m1 = Calendar.current.component(.minute, from: t1)
                let h2 = Calendar.current.component(.hour, from: t2)
                let m2 = Calendar.current.component(.minute, from: t2)
                if h1 != h2 { return h1 < h2 }
                return m1 < m2
            }
            
        for pflanze in sortedPlants {
            if processedPlantIDs.contains(pflanze.id) { continue }
            
            if let routine = routines.first(where: { $0.contains(habit: pflanze) && ($0.reminderSchedule != nil || $0.reminderTime != nil) }) {
                let routinePlants = gardenStore.pflanzen.filter { routine.contains(habit: $0) && $0.hasActiveReminder }
                for rp in routinePlants { processedPlantIDs.insert(rp.id) }
                
                let time = routine.reminderTime ?? pflanze.nextActiveReminder!.time
                if !items.contains(where: { if case .routine(let r, _, _) = $0 { return r.id == routine.id } else { return false } }) {
                    items.append(.routine(routine, time: time, plants: routinePlants))
                }
            } else {
                processedPlantIDs.insert(pflanze.id)
                items.append(.plant(pflanze))
            }
        }
        
        items.sort { a, b in
            let t1: Date
            let t2: Date
            switch a { case .routine(_, let time, _): t1 = time; case .plant(let p): t1 = p.nextActiveReminder!.time }
            switch b { case .routine(_, let time, _): t2 = time; case .plant(let p): t2 = p.nextActiveReminder!.time }
            let h1 = Calendar.current.component(.hour, from: t1)
            let m1 = Calendar.current.component(.minute, from: t1)
            let h2 = Calendar.current.component(.hour, from: t2)
            let m2 = Calendar.current.component(.minute, from: t2)
            if h1 != h2 { return h1 < h2 }
            return m1 < m2
        }
        
        return items
    }

    // Plants WITHOUT a reminder time
    var otherPlants: [HabitModel] {
        gardenStore.pflanzen.filter { !($0.hasActiveReminder && $0.nextActiveReminder != nil) }
    }

    let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appHintergrund.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {

                        // MARK: - Scheduled notifications section
                        if !timelineItems.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text(String(localized: "timeline.scheduled_notifications"))
                                    .font(.system(size: 20, weight: .black, design: .rounded))
                                    .foregroundStyle(.primary)
                                    .padding(.horizontal, 24)

                                VStack(spacing: 0) {
                                    ForEach(Array(timelineItems.enumerated()), id: \.element.id) { index, item in
                                        let isLast = index == timelineItems.count - 1
                                        switch item {
                                        case .plant(let pflanze):
                                            TimelineRow(pflanze: pflanze, isLast: isLast) {
                                                selectedPlant = pflanze
                                                isNavigating = true
                                            }
                                        case .routine(let routine, let time, let plants):
                                            RoutineTimelineRow(routine: routine, time: time, plants: plants, isLast: isLast) { pflanze in
                                                selectedPlant = pflanze
                                                isNavigating = true
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                            .padding(.top, 24)
                        }

                        // MARK: - Plants without notifications section
                        if !otherPlants.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text(String(localized: "timeline.no_notification"))
                                    .font(.system(size: 20, weight: .black, design: .rounded))
                                    .foregroundStyle(.primary)
                                    .padding(.horizontal, 24)

                                LazyVGrid(columns: columns, spacing: 16) {
                                    ForEach(otherPlants) { pflanze in
                                        SimplePlantCell(pflanze: pflanze) {
                                            selectedPlant = pflanze
                                            isNavigating = true
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                            .padding(.top, timelineItems.isEmpty ? 24 : 0)
                        }

                        // MARK: - Empty state
                        if gardenStore.pflanzen.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "leaf")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.tertiary)
                                Text(String(localized: "garden.empty.subtitle"))
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 60)
                        }

                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle(String(localized: "common.timeline"))
            .navigationBarTitleDisplayMode(.inline)
            .standardNavigationX()
            .navigationDestination(isPresented: $isNavigating) {
                if let pflanze = selectedPlant {
                    PflanzeDetailSheet(pflanze: pflanze, wetterEvent: gardenStore.aktivesWetter, dismissEntireFlow: onClose)
                }
            }
        }
    }
}

// MARK: - Timeline Row Component
struct TimelineRow: View {
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    let pflanze: HabitModel
    let isLast: Bool
    let onSelect: () -> Void

    // Same pattern as PflanzenCard: isVisualPressed for manual animation control
    @State private var isVisualPressed = false

    var timeString: String {
        guard let date = pflanze.nextActiveReminder?.time else { return "--:--" }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Time Column
            VStack {
                Text(timeString)
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundStyle(.primary)
                    .frame(width: 55, alignment: .trailing)
                    .padding(.top, 14)

                if !isLast {
                    Rectangle()
                        .fill(Color.primary.opacity(0.1))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                        .padding(.top, 4)
                }
            }

            // Plant Card
            ZStack {
                // Tappable card — exact same pattern as PflanzenCard
                Button {
                    // 1. Immediately set visual pressed state (animation starts)
                    isVisualPressed = true
                    FeedbackManager.shared.playTap()
                    // 2. After 0.12s (same as PflanzenCard), reset and navigate
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                        isVisualPressed = false
                        onSelect()
                    }
                } label: {
                    HStack(spacing: 12) {
                        // Icon — passes isPermanentlyPressed so it animates in sync with card
                        Item3DButton(
                            icon: pflanze.plantImageName,
                            farbe: pflanze.color,
                            sekundaerFarbe: pflanze.color.darker(),
                            groesse: 50,
                            iconSkalierung: 1.5,
                            isPermanentlyPressed: isVisualPressed,
                            aktion: nil
                        )
                        .allowsHitTesting(false)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(settings.showHabitInsteadOfName
                                ? NSLocalizedString(pflanze.habitName, comment: "")
                                : NSLocalizedString(pflanze.name, comment: ""))
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)
                                .lineLimit(1)

                            if let message = pflanze.customReminderMessage, !message.isEmpty {
                                Text(message)
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            } else {
                                let pflanzName = settings.showHabitInsteadOfName
                                    ? NSLocalizedString(pflanze.habitName, comment: "")
                                    : NSLocalizedString(pflanze.name, comment: "")
                                Text(String(format: String(localized: "timer.preview.body.example"), pflanzName))
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.tertiary)
                    }
                    .padding(12)
                }
                .buttonStyle(TimelineCardButtonStyle(isVisualPressed: isVisualPressed))
            }
            .padding(.bottom, isLast ? 4 : 20)
        }
    }
}

// MARK: - Routine Timeline Row
struct RoutineTimelineRow: View {
    @EnvironmentObject var settings: SettingsStore
    let routine: RoutineUIData
    let time: Date
    let plants: [HabitModel]
    let isLast: Bool
    let onSelect: (HabitModel) -> Void

    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Time Column
            VStack {
                Text(timeString)
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundStyle(.primary)
                    .frame(width: 55, alignment: .trailing)
                    .padding(.top, 14)

                if !isLast {
                    Rectangle()
                        .fill(Color.primary.opacity(0.1))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                        .padding(.top, 4)
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                // Routine Header
                HStack(spacing: 8) {
                    Image(systemName: routine.icon)
                        .font(.system(size: 14, weight: .bold))
                    Text(NSLocalizedString(routine.titleKey, comment: ""))
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .textCase(.uppercase)
                }
                .foregroundStyle(routine.color)
                .padding(.top, 14)
                .padding(.bottom, 2)
                .padding(.horizontal, 4)
                
                // Cards
                VStack(spacing: 12) {
                    ForEach(plants) { pflanze in
                        RoutinePlantCard(pflanze: pflanze) {
                            onSelect(pflanze)
                        }
                    }
                }
            }
            .padding(.bottom, isLast ? 4 : 20)
        }
    }
}

// MARK: - Routine Plant Card (without the subtitle text)
struct RoutinePlantCard: View {
    @EnvironmentObject var settings: SettingsStore
    let pflanze: HabitModel
    let onSelect: () -> Void

    @State private var isVisualPressed = false

    var body: some View {
        Button {
            isVisualPressed = true
            FeedbackManager.shared.playTap()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                isVisualPressed = false
                onSelect()
            }
        } label: {
            HStack(spacing: 12) {
                Item3DButton(
                    icon: pflanze.plantImageName,
                    farbe: pflanze.color,
                    sekundaerFarbe: pflanze.color.darker(),
                    groesse: 50,
                    iconSkalierung: 1.5,
                    isPermanentlyPressed: isVisualPressed,
                    aktion: nil
                )
                .allowsHitTesting(false)

                VStack(alignment: .leading, spacing: 4) {
                    Text(settings.showHabitInsteadOfName
                        ? NSLocalizedString(pflanze.habitName, comment: "")
                        : NSLocalizedString(pflanze.name, comment: ""))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.tertiary)
            }
            .padding(12)
        }
        .buttonStyle(TimelineCardButtonStyle(isVisualPressed: isVisualPressed))
    }
}

// MARK: - Simple Plant Cell for Grid (plants without timer)
struct SimplePlantCell: View {
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    let pflanze: HabitModel
    let onSelect: () -> Void

    // Same pattern as PflanzenCard: isVisualPressed for manual animation control
    @State private var isVisualPressed = false

    var body: some View {
        ZStack {
            // Tappable card — exact same pattern as PflanzenCard
            Button {
                // 1. Immediately set visual pressed state (animation starts)
                isVisualPressed = true
                FeedbackManager.shared.playTap()
                // 2. After 0.12s (same as PflanzenCard), reset and navigate
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    isVisualPressed = false
                    onSelect()
                }
            } label: {
                VStack(spacing: 12) {
                    // Icon — passes isPermanentlyPressed so it animates in sync with card
                    Item3DButton(
                        icon: pflanze.plantImageName,
                        farbe: pflanze.color,
                        sekundaerFarbe: pflanze.color.darker(),
                        groesse: 70,
                        iconSkalierung: 1.5,
                        isPermanentlyPressed: isVisualPressed,
                        aktion: nil
                    )
                    .allowsHitTesting(false)

                    Text(settings.showHabitInsteadOfName
                        ? NSLocalizedString(pflanze.habitName, comment: "")
                        : NSLocalizedString(pflanze.name, comment: ""))
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .padding(.horizontal, 8)
            }
            .buttonStyle(TimelineCardButtonStyle(isVisualPressed: isVisualPressed))
        }
    }
}
