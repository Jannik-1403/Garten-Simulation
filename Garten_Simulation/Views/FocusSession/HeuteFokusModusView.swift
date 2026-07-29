import SwiftUI

enum HeuteFokusItem: Identifiable {
    case routine(RoutineUIData)
    case todo(HabitModel, Int, FocusGoal)
    
    var id: String {
        switch self {
        case .routine(let r): return "r_\(r.id.uuidString)"
        case .todo(_, _, let g): return "t_\(g.id.uuidString)"
        }
    }
}

struct HeuteFokusModusView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var gardenStore: GardenStore
    
    @State var queue: [HeuteFokusItem]
    @State private var currentIndex: Int = 0
    @State private var showingCompletionConfetti = false
    
    // Fallback for saving routines
    var onRoutineCompleted: ((RoutineUIData) -> Void)? = nil
    
    var currentItem: HeuteFokusItem? {
        guard currentIndex < queue.count else { return nil }
        return queue[currentIndex]
    }
    
    var body: some View {
        ZStack {
            Color.appHintergrund.ignoresSafeArea()
            
            if let item = currentItem {
                VStack(spacing: 40) {
                    Spacer()
                    
                    Text(String(localized: "focus.today.title", defaultValue: "Heute im Fokus"))
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                    
                    switch item {
                    case .routine(let routine):
                        VStack(spacing: 24) {
                            ZStack {
                                Circle()
                                    .fill(routine.color.opacity(0.2))
                                    .frame(width: 120, height: 120)
                                
                                Image(systemName: routine.icon)
                                    .font(.system(size: 50))
                                    .foregroundColor(routine.color)
                            }
                            
                            Text(String(localized: String.LocalizationValue(routine.titleKey)))
                                .font(.system(size: 32, weight: .black, design: .rounded))
                                .multilineTextAlignment(.center)
                            
                            Text(String(localized: "focus.today.routine_desc", defaultValue: "Komplette Routine"))
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                    case .todo(let pflanze, _, let todo):
                        VStack(spacing: 24) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: pflanze.symbolColor).opacity(0.2))
                                    .frame(width: 120, height: 120)
                                
                                Image(systemName: pflanze.symbolName)
                                    .font(.system(size: 50))
                                    .foregroundColor(Color(hex: pflanze.symbolColor))
                            }
                            
                            Text(todo.text)
                                .font(.system(size: 32, weight: .black, design: .rounded))
                                .multilineTextAlignment(.center)
                            
                            Text(String(localized: String.LocalizationValue(pflanze.displayedHabitName)))
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        markCompletedAndNext()
                    } label: {
                        HStack {
                            Image(systemName: "checkmark")
                            Text(String(localized: "focus.today.complete", defaultValue: "Erledigt & Weiter"))
                        }
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                    }
                    .buttonStyle(DuolingoButtonStyle(size: .large, fillWidth: true, backgroundColor: .gruenPrimary, shadowColor: .gruenPrimary.darker(), foregroundColor: .white))
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                }
            } else {
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
                    
                    Button {
                        dismiss()
                    } label: {
                        Text(String(localized: "common.close", defaultValue: "Schließen"))
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                    }
                    .buttonStyle(DuolingoButtonStyle(size: .large, fillWidth: true, backgroundColor: .black, shadowColor: .black.opacity(0.8), foregroundColor: .white))
                    .padding(.horizontal, 32)
                    .padding(.top, 40)
                }
                .onAppear {
                    showingCompletionConfetti = true
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                }
            }
        }
        .overlay(alignment: .topTrailing) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.gray.opacity(0.5))
                    .padding(24)
            }
        }
    }
    
    private func markCompletedAndNext() {
        guard let item = currentItem else { return }
        
        withAnimation(.spring()) {
            switch item {
            case .routine(let routine):
                onRoutineCompleted?(routine)
            case .todo(let plant, let idx, _):
                if let plantIndex = gardenStore.pflanzen.firstIndex(where: { $0.id == plant.id }) {
                    gardenStore.pflanzen[plantIndex].todos[idx].isCompleted = true
                    gardenStore.savePlants()
                }
            }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            currentIndex += 1
        }
    }
}
