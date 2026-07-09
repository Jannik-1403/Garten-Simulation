import SwiftUI

struct GenericFocusTimerSetupSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    
    @State private var taskName: String = ""
    @State private var zeigeFocusSession = false
    @State private var dummyHabit: HabitModel?
    
    // We need PowerUpStore for FocusSessionView
    @StateObject private var powerUpStore = PowerUpStore()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "timer")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundStyle(Color.orangePrimary)
                    .padding(.top, 40)
                
                Text(String(localized: "focus.generic.title", defaultValue: "Fokus Starten"))
                    .font(.system(size: 28, weight: .black, design: .rounded))
                
                Text(String(localized: "focus.generic.subtitle", defaultValue: "Was möchtest du in dieser Session erreichen?"))
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                TextField(String(localized: "focus.generic.placeholder", defaultValue: "z.B. Hausaufgaben, Lesen, ..."), text: $taskName)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .padding(16)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal, 24)
                
                Button {
                    // Create dummy habit
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
                } label: {
                    Text(String(localized: "button.continue", defaultValue: "Weiter"))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(taskName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.orangePrimary)
                        .cornerRadius(16)
                }
                .disabled(taskName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
