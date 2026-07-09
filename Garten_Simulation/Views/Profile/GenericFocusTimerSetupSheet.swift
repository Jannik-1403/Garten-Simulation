import SwiftUI

struct GenericFocusTimerSetupSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    
    @State private var taskName: String = ""
    @State private var zeigeFocusSession = false
    @State private var dummyHabit: HabitModel?
    @FocusState private var isTextFieldFocused: Bool
    
    // We need PowerUpStore for FocusSessionView
    @StateObject private var powerUpStore = PowerUpStore()
    
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
                
                Item3DButton(
                    farbe: taskName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.orangePrimary,
                    sekundaerFarbe: taskName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray.darker() : Color.orangePrimary.darker(),
                    groesse: 60,
                    isRectangular: true,
                    isDisabled: taskName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                    aktion: {
                        let habit = HabitModel(
                            name: taskName,
                            symbolName: "timer",
                            habitCategory: .lifestyle,
                            habitName: taskName,
                            xpPerCompletion: 0,
                            isGenericFocus: true
                        )
                        self.dummyHabit = habit
                        self.zeigeFocusSession = true
                    }
                ) {
                    Text(String(localized: "button.continue", defaultValue: "Weiter"))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                }
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
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color(UIColor.tertiaryLabel))
                    }
                }
            }
            .fullScreenCover(isPresented: $zeigeFocusSession, onDismiss: {
                // If the user closed the focus session, dismiss this sheet as well
                dismiss()
            }) {
                if let habit = dummyHabit {
                    FocusSessionView(pflanze: habit)
                        .environmentObject(gardenStore)
                        .environmentObject(settings)
                        .environmentObject(powerUpStore) // Need to provide it since FocusSessionView requires it
                }
            }
        }
    }
}
