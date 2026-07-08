import SwiftUI
import FamilyControls

struct FocusScreenTimePickerView: View {
    /// Called when the user made a choice and we're ready to proceed to the next step
    let onComplete: () -> Void

    @StateObject private var manager = ScreenTimeManager.shared
    @State private var isPickerPresented = false
    @State private var pickerCompleted = false

    var body: some View {
        VStack(spacing: 14) {
            // --- OHNE HANDY ---
            Button {
                manager.blockAllApps()
                onComplete()
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.12))
                            .frame(width: 48, height: 48)
                        Image(systemName: "iphone.slash")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.red)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(String(localized: "focus.screentime.without_phone", defaultValue: "Ohne Handy lernen"))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                        Text(String(localized: "focus.screentime.without_phone.subtitle", defaultValue: "Alle Apps werden blockiert"))
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "checkmark.shield.fill")
                        .foregroundStyle(.red.opacity(0.7))
                }
                .padding(16)
                .background(Color.red.opacity(0.07))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.red.opacity(0.2), lineWidth: 1))
            }
            .buttonStyle(.plain)

            // --- MIT HANDY ---
            Button {
                if manager.isAuthorized {
                    isPickerPresented = true
                } else {
                    Task {
                        await manager.requestAuthorization()
                        isPickerPresented = manager.isAuthorized
                    }
                }
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.12))
                            .frame(width: 48, height: 48)
                        Image(systemName: "iphone")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.green)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(String(localized: "focus.screentime.with_phone", defaultValue: "Mit Handy lernen"))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                        Text(String(localized: "focus.screentime.with_phone.subtitle", defaultValue: "Wähle Apps, die NICHT blockiert werden"))
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.secondary)
                }
                .padding(16)
                .background(Color.green.opacity(0.07))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.green.opacity(0.2), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .familyActivityPicker(isPresented: $isPickerPresented, selection: $manager.allowedSelection)
            .onChange(of: isPickerPresented) { _, isOpen in
                // When the picker closes, apply the selection and continue
                if !isOpen && !pickerCompleted {
                    pickerCompleted = true
                    manager.blockAllExcept(selection: manager.allowedSelection)
                    onComplete()
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }
}
