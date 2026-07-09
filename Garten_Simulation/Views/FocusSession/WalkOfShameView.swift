import SwiftUI

struct WalkOfShameView: View {
    @Environment(\.dismiss) var dismiss
    
    // Actions
    var onConfirmGiveUp: () -> Void
    var onCancel: () -> Void
    
    @State private var typedText: String = ""
    @State private var shakeOffset: CGFloat = 0
    @State private var hasError: Bool = false
    @State private var requiredText: String = ""
    
    @FocusState private var isFocused: Bool
    
    let sentencePool = [
        "Ich bin mir vollkommen bewusst, dass ich gerade den einfachsten Ausweg wähle. Anstatt mich meiner eigentlichen Aufgabe zu widmen und produktiv an meinen Zielen zu arbeiten, entscheide ich mich freiwillig dafür, meine Zeit mit billigem Dopamin zu verschwenden. Ich gebe hiermit offiziell auf und akzeptiere die Konsequenzen meiner mangelnden Disziplin.",
        
        "Anstatt an mir selbst zu arbeiten und meine Konzentration zu trainieren, lasse ich mich lieber ablenken. Ich habe nicht die mentale Stärke, diesen Fokus durchzuhalten, und entscheide mich ganz bewusst dafür, meine Ziele zu ignorieren. Ich weiß, dass ich es später bereuen werde, aber ich wähle trotzdem den Weg des geringsten Widerstands.",
        
        "Ich breche diesen Vorgang ab, weil ich meine eigenen Vorgaben nicht einhalten kann. Es ist mir wichtiger, mich sofort belohnen zu lassen, als langfristig an meinen Zielen festzuhalten. Ich entscheide mich aktiv gegen meine eigene Produktivität und nehme in Kauf, dass ich dadurch meine Gewohnheiten sabotiere und meine Zeit sinnlos verstreichen lasse."
    ]
    
    var body: some View {
        ZStack {
            // Premium Liquid Glass Background
            ZStack {
                LinearGradient(
                    colors: [Color.blue.opacity(0.15), Color.purple.opacity(0.15)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Rectangle()
                    .fill(.ultraThinMaterial)
            }
            .ignoresSafeArea(.all)
            .onTapGesture { isFocused = false }
            
            ScrollView {
                VStack(spacing: 20) {
                    // Top bar with morphing dismiss/cancel button
                    HStack {
                        Spacer()
                        Button {
                            if isFocused {
                                isFocused = false
                            } else {
                                onCancel()
                            }
                        } label: {
                            Image(systemName: isFocused ? "keyboard.chevron.compact.down" : "xmark.circle.fill")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundStyle(Color(UIColor.tertiaryLabel), Color(UIColor.tertiarySystemFill))
                        }
                        .padding(.trailing, 24)
                        .padding(.top, 16)
                    }
                    
                    Text(String(localized: "focus.giveup.walkofshame.title", defaultValue: "Bewusste Entscheidung"))
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(String(localized: "focus.giveup.walkofshame.subtitle", defaultValue: "Tippe diesen Text exakt und fehlerfrei ab, um zu bestätigen, dass du die Sperre aufheben willst:"))
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    
                    // Required Text Box (3D Liquid Glass)
                    Text(requiredText)
                        .font(.system(size: 15, weight: .semibold))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.regularMaterial)
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 0, x: 0, y: 3)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        )
                        .padding(.horizontal, 24)
                        .fixedSize(horizontal: false, vertical: true)
                        .textSelection(.disabled)
                    
                    // Anti-Paste Editor (Liquid Glass)
                    AntiPasteTextEditor(text: $typedText)
                        .focused($isFocused)
                        .frame(minHeight: 180)
                        .padding()
                        .background(.regularMaterial)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.03), radius: 0, x: 0, y: 2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(hasError ? Color.red : Color.white.opacity(0.5), lineWidth: 2)
                        )
                        .offset(x: shakeOffset)
                        .padding(.horizontal, 24)
                    
                    Spacer(minLength: 40)
                    
                    // Verify button
                    Button(action: {
                        if typedText == requiredText {
                            onConfirmGiveUp()
                        } else {
                            triggerShake()
                        }
                    }) {
                        Text(String(localized: "focus.giveup.walkofshame.verify", defaultValue: "Überprüfen & Entsperren"))
                    }
                    .buttonStyle(DuolingoButtonStyle(size: .large, fillWidth: true, backgroundColor: Color.blue, shadowColor: Color.blue.darker()))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .onAppear {
            requiredText = sentencePool.randomElement()!
        }
    }
    
    // Checks if the user made a typo along the way (no longer used for real-time validation, but kept for logical completeness if needed)
    private func checkTextForErrors(_ newText: String) {
        // Obsolete function since user wants delayed checking. 
    }
    
    // Punishes the user with a red shaking border
    private func triggerShake() {
        hasError = true
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        
        withAnimation(.default) {
            shakeOffset = 10
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.default) { shakeOffset = -10 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.default) { shakeOffset = 10 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.default) { shakeOffset = 0 }
        }
    }
}
