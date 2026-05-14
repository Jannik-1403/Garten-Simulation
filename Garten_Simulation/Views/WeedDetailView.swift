import SwiftUI

struct WeedDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    
    var body: some View {
        VStack(spacing: 24) {

            // Titel & Text
            VStack(spacing: 8) {
                Text(settings.localizedString(for: "weed_popup_title"))
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(settings.localizedString(for: "weed_popup_body"))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
            }
            .padding(.top, 20)

            // Fortschritts-Dots
            VStack(spacing: 12) {
                HStack(spacing: 16) {
                    ForEach(0..<3) { index in
                        let isCompleted = index < gardenStore.dailyQuestsCompletedSinceWeed

                        ZStack {
                            // Untere Schicht (3D-Schatten)
                            RoundedRectangle(cornerRadius: 14)
                                .fill(isCompleted
                                      ? Color(red: 0.1, green: 0.6, blue: 0.2)   // dunkles Grün
                                      : Color(red: 0.6, green: 0.6, blue: 0.6))  // dunkles Grau
                                .frame(width: 52, height: 52)
                                .offset(y: 4)

                            // Obere Schicht
                            RoundedRectangle(cornerRadius: 14)
                                .fill(isCompleted
                                      ? Color(red: 0.2, green: 0.78, blue: 0.35)  // helles Grün
                                      : Color(red: 0.82, green: 0.82, blue: 0.82)) // helles Grau
                                .frame(width: 52, height: 52)
                                .offset(y: isCompleted ? 2 : 0) // gedrückt wenn erledigt

                            // Checkmark oder Nummer
                            if isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(.white)
                                    .offset(y: isCompleted ? 2 : 0)
                            } else {
                                Text("\(index + 1)")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                        }
                        .animation(.spring(duration: 0.3), value: gardenStore.dailyQuestsCompletedSinceWeed)
                    }
                }

                Text(settings.localizedString(for: "weed_progress_label")
                    .replacingOccurrences(of: "{count}", with: "\(gardenStore.dailyQuestsCompletedSinceWeed)"))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGroupedBackground))
            )

            // Verstanden-Button
            Button(settings.localizedString(for: "weed_popup_button")) {
                dismiss()
            }
            .buttonStyle(DuolingoButtonStyle(size: .large, backgroundColor: .gruenPrimary, shadowColor: .gruenSecondary))
        }
        .padding(24)
        .background(.ultraThinMaterial)
    }
}

#Preview {
    WeedDetailView()
        .environmentObject(GardenStore())
        .environmentObject(SettingsStore())
}
