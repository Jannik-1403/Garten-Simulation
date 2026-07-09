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
        "Ich entscheide mich bewusst dafür, meine produktive Zeit zu opfern und stattdessen sinnlos auf einen Bildschirm zu starren. Ich weiß, dass mich dies nicht weiterbringt, aber ich gebe meiner Bequemlichkeit nach.",
        "Mein Fokus ist mir in diesem Moment weniger wichtig als schnelle Ablenkung. Anstatt an meinen Zielen zu arbeiten, wähle ich den einfachen Weg und akzeptiere, dass ich dadurch meine eigene Entwicklung blockiere.",
        "Ich breche meine eigenen Regeln und entsperre diese App, obwohl ich mir vorgenommen hatte, diszipliniert zu bleiben. Ich bin mir der Konsequenzen bewusst und entscheide mich aktiv gegen meine eigentlichen Vorhaben.",
        "Trotz meiner guten Vorsätze lasse ich mich jetzt ablenken. Ich gestehe mir ein, dass ich in diesem Moment nicht die Willenskraft aufbringe, meine Aufgaben zu erledigen, und vergeude meine wertvolle Zeit.",
        "Ich wähle kurzfristige Befriedigung anstelle von langfristigem Erfolg. Ich verstehe, dass jeder Moment, den ich hier verschwende, mir fehlt, um meine Träume zu verwirklichen, aber ich tue es trotzdem."
    ]
    
    var body: some View {
        NavigationStack {
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
                        Text(String(localized: "focus.giveup.walkofshame.title", defaultValue: "Bewusste Entscheidung"))
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(.primary)
                            .padding(.top, 24)
                    
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if isFocused {
                            isFocused = false
                        } else {
                            onCancel()
                        }
                    } label: {
                        Image(systemName: isFocused ? "keyboard.chevron.compact.down" : "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.primary)
                    }
                }
            }
            .onAppear {
                requiredText = sentencePool.randomElement()!
            }
            } // Close ZStack
        } // Close NavigationStack
    } // Close body
    
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
