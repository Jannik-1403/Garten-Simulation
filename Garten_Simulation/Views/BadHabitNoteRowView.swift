import SwiftUI

struct BadHabitNoteRowView: View {
    @EnvironmentObject var settings: SettingsStore
    let index: Int
    let text: String
    let onTap: () -> Void
    let onDelete: () -> Void
    let deleteConfirmShowing: Binding<Bool>
    let onConfirmDelete: () -> Void
    let onCancelDelete: () -> Void

    @State private var isVisualPressed = false

    var body: some View {
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
                    Text(verbatim: "\(String(localized: "plant.detail.note")) \(index + 1)")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                    Text(text)
                        .lineLimit(2)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }

                Spacer()

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
            String(localized: "plant.detail.note.delete.confirm"),
            isPresented: deleteConfirmShowing,
            titleVisibility: .visible
        ) {
            Button(String(localized: "plant.detail.note.delete.action"), role: .destructive) {
                onConfirmDelete()
            }
            Button(String(localized: "button.cancel"), role: .cancel) {
                onCancelDelete()
            }
        }
    }
}
