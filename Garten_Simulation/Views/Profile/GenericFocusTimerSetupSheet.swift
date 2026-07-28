import SwiftUI

struct GenericFocusTimerSetupSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var taskName: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var onStart: (HabitModel) -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image("Timer full")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .padding(.top, 40)
                
                Text(String(localized: "focus.generic.title", defaultValue: "Fokus Starten"))
                    .font(.system(size: 28, weight: .black, design: .rounded))
                
                Text(String(localized: "focus.generic.subtitle", defaultValue: "Was möchtest du in dieser Session erreichen?"))
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Item3DButton(
                    farbe: Color(UIColor.secondarySystemBackground),
                    sekundaerFarbe: Color(UIColor.systemGray4),
                    groesse: 60,
                    isRectangular: true,
                    aktion: {
                        isTextFieldFocused = true
                    }
                ) {
                    TextField(String(localized: "focus.generic.placeholder", defaultValue: "z.B. Hausaufgaben, Lesen, ..."), text: $taskName)
                        .focused($isTextFieldFocused)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .padding(.horizontal, 6)
                }
                .padding(.horizontal, 24)
                
                let isTaskEmpty = taskName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                
                Button(action: {
                    let habit = HabitModel(
                        name: taskName,
                        symbolName: "timer",
                        habitCategory: .lifestyle,
                        habitName: taskName,
                        xpPerCompletion: 0,
                        isGenericFocus: true
                    )
                    dismiss()
                    
                    // Wait for sheet to start dismissing before triggering presentation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        onStart(habit)
                    }
                }) {
                    Text(String(localized: "button.continue", defaultValue: "Weiter"))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(DuolingoButtonStyle(
                    size: .large,
                    backgroundColor: .orangePrimary,
                    shadowColor: .orangePrimary.darker()
                ))
                .disabled(isTaskEmpty)
                .animation(.easeInOut(duration: 0.2), value: isTaskEmpty)
                .padding(.horizontal, 24)
                .padding(.top, 8)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.black)
                    }
                }
            }
        }
    }
}

struct GenericFocusSessionContainer: View {
    let habit: HabitModel
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore

    
    var body: some View {
        FocusSessionView(pflanze: habit)
            .environmentObject(gardenStore)
            .environmentObject(settings)
    }
}
