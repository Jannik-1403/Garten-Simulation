import SwiftUI

struct ScreenTimePrePromptView: View {
    @Environment(\.dismiss) var dismiss
    var onContinue: () -> Void
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Icon
                Image(systemName: "shield.fill")
                    .font(.system(size: 100))
                    .foregroundStyle(Color.gruenPrimary)
                    .shadow(color: Color.gruenPrimary.opacity(0.3), radius: 20, x: 0, y: 10)
                
                VStack(spacing: 16) {
                    // Titel
                    Text(String(localized: "screentime.preprompt.title", defaultValue: "Schütze deinen Fokus"))
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.center)
                    
                    // Beschreibung
                    Text(String(localized: "screentime.preprompt.desc", defaultValue: "Damit dein Garten wachsen kann und das Unkraut keine Chance hat, müssen wir deine Ablenkungen aussperren. Bitte erlaube den Screen-Time-Zugriff im nächsten Fenster, damit Grovy dich schützen kann."))
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                
                Spacer()
                
                // Button
                Button {
                    dismiss()
                    // Leicht verzögern, damit die Dismiss-Animation durchläuft, bevor der Systemdialog aufploppt
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onContinue()
                    }
                } label: {
                    Text(String(localized: "screentime.preprompt.button", defaultValue: "Verstanden"))
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(
                    DuolingoButtonStyle(
                        size: .large,
                        fillWidth: true,
                        backgroundColor: Color.gruenPrimary,
                        shadowColor: Color.gruenPrimary.darker(),
                        foregroundColor: .white
                    )
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }
}

#Preview {
    ScreenTimePrePromptView(onContinue: {})
}
