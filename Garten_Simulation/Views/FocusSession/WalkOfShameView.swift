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
        "Ich bin schwach und wähle den einfachen Weg, weil ich keine Disziplin habe.",
        "Anstatt produktiv zu sein, verschwende ich meine Zeit mit billigem Dopamin.",
        "Ich entscheide mich bewusst dafür, meine Ziele zu ignorieren und aufzugeben.",
        "Ich habe nicht die mentale Stärke, diesen Fokus durchzuhalten."
    ]
    
    var body: some View {
        ZStack {
            // Dark background for the "Walk of Shame"
            Color.black.edgesIgnoringSafeArea(.all)
                .onTapGesture { isFocused = false }
            
            VStack(spacing: 20) {
                // Top bar with dismiss keyboard button
                HStack {
                    Spacer()
                    Button {
                        isFocused = false
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 24)
                    .padding(.top, 16)
                }
                
                // Warning Icon
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.red)
                
                Text(String(localized: "focus.giveup.walkofshame.title", defaultValue: "Der Walk of Shame"))
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                
                Text(String(localized: "focus.giveup.walkofshame.subtitle", defaultValue: "Du bist dabei, deinen Fokus abzubrechen. Tippe diesen Text exakt und fehlerfrei ab, um zu bestätigen:"))
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                
                // Required Text Box
                Text(requiredText)
                    .font(.system(size: 16, weight: .bold))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.15))
                    .foregroundColor(.red)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.red.opacity(0.5), lineWidth: 1)
                    )
                    .padding(.horizontal, 24)
                
                // Anti-Paste Editor
                AntiPasteTextEditor(text: $typedText)
                    .focused($isFocused)
                    .frame(height: 120)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(hasError ? Color.red : Color.gray.opacity(0.3), lineWidth: 2)
                    )
                    .offset(x: shakeOffset)
                    .padding(.horizontal, 24)
                    .onChange(of: typedText) { newValue in
                        checkTextForErrors(newValue)
                    }
                
                Spacer()
                
                // Give up button (disabled until perfect)
                Button(action: {
                    if typedText == requiredText {
                        onConfirmGiveUp()
                    } else {
                        triggerShake()
                    }
                }) {
                    Text(String(localized: "focus.giveup.walkofshame.button", defaultValue: "Aufgeben & Apps entsperren"))
                }
                .buttonStyle(DuolingoButtonStyle(size: .large, fillWidth: true, backgroundColor: typedText == requiredText ? .red : Color.gray.opacity(0.3), shadowColor: typedText == requiredText ? .red.darker() : .clear))
                .disabled(typedText != requiredText)
                .padding(.horizontal, 24)
                
                // Go back button (Salvation)
                Button(action: {
                    onCancel()
                }) {
                    Text(String(localized: "common.cancel", defaultValue: "Abbrechen & Zurück zum Fokus"))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            requiredText = sentencePool.randomElement()!
        }
    }
    
    // Checks if the user made a typo along the way
    private func checkTextForErrors(_ newText: String) {
        // If the typed text is longer than required, it's definitely an error
        if newText.count > requiredText.count {
            triggerShake()
            return
        }
        
        // Compare what's typed so far with the required text prefix
        let prefix = String(requiredText.prefix(newText.count))
        if newText != prefix {
            triggerShake()
        } else {
            hasError = false
        }
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
