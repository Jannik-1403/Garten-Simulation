import SwiftUI

struct SettingsDetailView: View {
    @EnvironmentObject var settings: SettingsStore
    let title: String
    let description: String
    let actionTitle: String
    let icon: String
    let iconColor: Color
    var isDestructive: Bool = false
    let action: () -> Void
    
    @Environment(\.dismiss) var dismiss
    @AppStorage("isHapticEnabled") var isHapticEnabled: Bool = true
    
    var body: some View {
        ZStack {
            Color.appHintergrund.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Icon Header
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: icon)
                        .font(.system(size: 50))
                        .foregroundStyle(iconColor)
                }
                
                VStack(spacing: 16) {
                    Text(title)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    
                    ScrollView {
                        Text(description)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 24)
                            .padding(.top, 8)
                    }
                }
                
                Spacer()
                
                // Action Button
                VStack(spacing: 12) {
                    Button(action: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                            action()
                            dismiss()
                        }
                    }) {
                        Text(actionTitle.uppercased())
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SettingsActionButtonStyle(color: isDestructive ? .red : .blauPrimary))
                    .padding(.horizontal, 24)
                    
                    if isDestructive {
                        Text(settings.localizedString(for: "settings.action.irreversible"))
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingsActionButtonStyle: ButtonStyle {
    @AppStorage("isHapticEnabled") var isHapticEnabled: Bool = true
    let color: Color
    private let depth: CGFloat = 6
    
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        
        ZStack {
            // Shadow
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(color.opacity(0.3))
                .offset(y: depth)
            
            // Base
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(color)
                .overlay(
                    configuration.label
                )
                .offset(y: isPressed ? depth : 0)
        }
        .frame(height: 56)
        .animation(isPressed ? nil : .spring(response: 0.15, dampingFraction: 0.6), value: isPressed)
        .sensoryFeedback(trigger: isPressed) { _, newValue in
            (isHapticEnabled && newValue) ? .impact(flexibility: .rigid, intensity: 0.8) : nil
        }
    }
}

#Preview {
    NavigationStack {
        SettingsDetailView(
            title: "Daten exportieren",
            description: "Möchten Sie alle Ihre Daten exportieren? Sie erhalten eine Datei mit allen Ihren Pflanzen und Fortschritten.",
            actionTitle: "Export starten",
            icon: "square.and.arrow.up.fill",
            iconColor: .orange,
            action: {}
        )
    }
}
