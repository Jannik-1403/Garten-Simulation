import SwiftUI

struct EditRoutineHabitRow: View {
    @EnvironmentObject var settings: SettingsStore
    let habit: HabitModel
    
    var body: some View {
        HStack(spacing: 16) {
            Image(habit.plantImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
            
            Text(habit.isRoutineOnly ? String(localized: String.LocalizationValue(habit.displayedHabitName)) : (settings.showHabitInsteadOfName ? String(localized: String.LocalizationValue(habit.displayedHabitName)) : String(localized: String.LocalizationValue(habit.name))))
                .font(.system(size: 16, weight: .bold, design: .rounded))
        }
        .padding(.vertical, 4)
    }
}
