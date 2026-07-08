import SwiftUI
import FamilyControls

struct FocusScreenTimePickerView: View {
    @StateObject private var manager = ScreenTimeManager.shared
    @State private var isPickerPresented = false
    
    var body: some View {
        VStack(spacing: 12) {
            if manager.isAuthorized {
                Button(action: {
                    isPickerPresented = true
                }) {
                    HStack {
                        Image(systemName: "app.badge.shield.fill")
                        Text(String(localized: "focus.screentime.pick_apps", defaultValue: "Apps zum Blockieren wählen"))
                    }
                }
                .buttonStyle(DuolingoButtonStyle(
                    size: .medium,
                    fillWidth: false,
                    backgroundColor: .gray.opacity(0.2),
                    shadowColor: .gray.opacity(0.3),
                    foregroundColor: .primary
                ))
                .familyActivityPicker(
                    isPresented: $isPickerPresented,
                    selection: $manager.selection
                )
                
                if !manager.selection.applicationTokens.isEmpty || !manager.selection.categoryTokens.isEmpty {
                    Text(String(localized: "focus.screentime.apps_selected", defaultValue: "Ausgewählte Apps werden im Fokus blockiert."))
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            } else {
                Text(String(localized: "focus.screentime.unauthorized", defaultValue: "Bildschirmzeit-Berechtigung fehlt. Bitte erlaube den Zugriff in den iOS-Einstellungen, um Apps zu blockieren."))
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.red.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
    }
}
