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
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                // Große Überschrift direkt über dem Text
                Text(title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .padding(.top, 16)
                
                // Beschreibungstext direkt darunter
                Text(description)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.secondary)
                    .lineSpacing(6)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .standardNavigationX()
    }
}

#Preview {
    NavigationStack {
        SettingsDetailView(
            title: "Nutzungsbedingungen",
            description: "Dies sind die Nutzungsbedingungen für die Garten-Simulation...",
            actionTitle: "Verstanden",
            icon: "doc.text.fill",
            iconColor: .gray,
            action: {}
        )
    }
}
