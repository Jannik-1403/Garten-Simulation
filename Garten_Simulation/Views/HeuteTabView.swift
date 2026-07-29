import SwiftUI

struct HeuteTabView: View {
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    
    @AppStorage("customRoutinesData", store: SharedUserDefaults.suite) private var customRoutinesData: Data = Data()
    @State private var routines: [RoutineUIData] = []
    
    @State private var showingAddTodoSheet = false
    @State private var selectedPlantForTodo: HabitModel?
    @State private var todoToEditIndex: Int? = nil
    
    @State private var routineToPlay: RoutineUIData?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appHintergrund.ignoresSafeArea()
                
                if uncompletedItems.isEmpty {
                    VStack(spacing: 24) {
                        Image(systemName: "party.popper.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.orange)
                        
                        Text(String(localized: "focus.today.all_done", defaultValue: "Alles erledigt!"))
                            .font(.system(size: 32, weight: .black, design: .rounded))
                        
                        Text(String(localized: "focus.today.all_done_desc", defaultValue: "Du hast alle Fokus-Aufgaben für heute gemeistert."))
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            HStack {
                                Text(String(localized: "tab.heute", defaultValue: "Heute"))
                                    .font(.system(size: 32, weight: .black, design: .rounded))
                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
                            
                            HStack {
                                Text("\(completedCount) \(String(localized: "heute.completed_of", defaultValue: "von")) \(totalCount) \(String(localized: "heute.done", defaultValue: "erledigt"))")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 8)
                            
                            LazyVStack(spacing: 16) {
                                ForEach(uncompletedItems, id: \.id) { item in
                                    HeuteTaskCard(item: item, onComplete: { completedItem in
                                        handleCompletion(of: completedItem)
                                    }, onPriorityTap: { toggledItem in
                                        handlePriorityToggle(for: toggledItem)
                                    })
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)
                        }
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        selectedPlantForTodo = nil
                        todoToEditIndex = nil
                        showingAddTodoSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(.primary)
                    }
                }
            }
            .sheet(isPresented: $showingAddTodoSheet) {
                if let selected = selectedPlantForTodo {
                    TodoSheetView(pflanze: selected, editIndex: todoToEditIndex)
                } else {
                    GlobalTodoAddSheet()
                }
            }
            .fullScreenCover(item: $routineToPlay) { item in
                RoutineSessionView(routine: item, habits: habits(for: item), onComplete: {
                    if let idx = routines.firstIndex(where: { $0.id == item.id }) {
                        routines[idx].lastCompletedDate = Date()
                        saveRoutines()
                    }
                })
            }
            .onAppear(perform: loadRoutines)
            .onChange(of: customRoutinesData) { _ in loadRoutines() }
        }
    }
    
    // MARK: - Data Models & Logic
    
    enum HeuteItemType {
        case routine(RoutineUIData)
        case todo(HabitModel, Int, FocusGoal)
    }
    
    struct HeuteItem: Identifiable {
        let type: HeuteItemType
        let priority: GoalPriority
        
        var id: String {
            switch type {
            case .routine(let r): return "r_\(r.id.uuidString)"
            case .todo(_, _, let g): return "t_\(g.id.uuidString)"
            }
        }
    }
    
    var allItems: [HeuteItem] {
        var items: [HeuteItem] = []
        
        for routine in routines {
            items.append(HeuteItem(type: .routine(routine), priority: routine.priority))
        }
        
        for plant in gardenStore.pflanzen {
            for (index, todo) in plant.todos.enumerated() {
                items.append(HeuteItem(type: .todo(plant, index, todo), priority: todo.priority))
            }
        }
        
        return items.sorted { $0.priority.sortValue < $1.priority.sortValue }
    }
    
    var uncompletedItems: [HeuteItem] {
        allItems.filter { item in
            switch item.type {
            case .routine(let r):
                if let lastCompleted = r.lastCompletedDate, Calendar.current.isDateInToday(lastCompleted) {
                    return false
                }
                return true
            case .todo(_, _, let t):
                return !t.isCompleted
            }
        }
    }
    
    var completedCount: Int {
        allItems.count - uncompletedItems.count
    }
    
    var totalCount: Int {
        allItems.count
    }
    
    private func handleCompletion(of item: HeuteItem) {
        withAnimation {
            switch item.type {
            case .routine(let r):
                routineToPlay = r
            case .todo(let plant, let idx, _):
                if let plantIndex = gardenStore.pflanzen.firstIndex(where: { $0.id == plant.id }) {
                    gardenStore.pflanzen[plantIndex].todos[idx].isCompleted = true
                    gardenStore.savePlants()
                }
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
        }
    }
    
    private func handlePriorityToggle(for item: HeuteItem) {
        withAnimation {
            switch item.type {
            case .routine(let r):
                if let idx = routines.firstIndex(where: { $0.id == r.id }) {
                    routines[idx].priority.next()
                    saveRoutines()
                }
            case .todo(let plant, let idx, _):
                if let plantIndex = gardenStore.pflanzen.firstIndex(where: { $0.id == plant.id }) {
                    gardenStore.pflanzen[plantIndex].todos[idx].priority.next()
                    gardenStore.savePlants()
                }
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }
    
    private func loadRoutines() {
        if let decoded = try? JSONDecoder().decode([RoutineUIData].self, from: customRoutinesData) {
            self.routines = decoded
        }
    }
    
    private func saveRoutines() {
        if let encoded = try? JSONEncoder().encode(routines) {
            customRoutinesData = encoded
        }
    }
    
    private func habits(for routine: RoutineUIData) -> [HabitModel] {
        gardenStore.pflanzen.filter { routine.contains(habit: $0) }
    }
}

struct HeuteTaskCard: View {
    @EnvironmentObject var settings: SettingsStore
    let item: HeuteTabView.HeuteItem
    let onComplete: (HeuteTabView.HeuteItem) -> Void
    let onPriorityTap: (HeuteTabView.HeuteItem) -> Void
    
    var title: String {
        switch item.type {
        case .routine(let r):
            return String(localized: String.LocalizationValue(r.titleKey), locale: Locale(identifier: settings.appLanguage))
        case .todo(_, _, let t):
            return t.text
        }
    }
    
    var subtitle: String {
        switch item.type {
        case .routine(let r):
            let type = String(localized: "type.routine", defaultValue: "Routine")
            let name = String(localized: String.LocalizationValue(r.titleKey), locale: Locale(identifier: settings.appLanguage))
            return "\(type) · \(name)"
        case .todo(let plant, _, _):
            let type = String(localized: "type.todo", defaultValue: "To-Do")
            if plant.isGenericFocus {
                let without = String(localized: "routine.without", defaultValue: "Ohne Routine")
                return "\(without)"
            } else {
                let name = String(localized: String.LocalizationValue(plant.displayedHabitName), locale: Locale(identifier: settings.appLanguage))
                return "\(type) · \(name)"
            }
        }
    }
    
    var iconName: String {
        switch item.type {
        case .routine(let r): return r.icon
        case .todo(let p, _, _): return p.symbolName
        }
    }
    
    var iconColor: Color {
        switch item.type {
        case .routine(let r): return r.color
        case .todo(let p, _, _): return Color(hex: p.symbolColor)
        }
    }
    
    var body: some View {
        Item3DButton(
            farbe: .white,
            sekundaerFarbe: Color(white: 0.9),
            groesse: 90,
            isRectangular: true,
            aktion: {
                onComplete(item)
            }
        ) {
            HStack(spacing: 16) {
                // Circle with icon
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 24))
                        .foregroundColor(iconColor)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 6) {
                    Button {
                        onPriorityTap(item)
                    } label: {
                        Text(item.priority.icon)
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundColor(item.priority.color)
                    }
                    
                    Text(item.priority.displayName)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(16)
        }
    }
}
