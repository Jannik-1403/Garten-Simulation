import SwiftUI

struct WalkOfShameView: View {
    @Environment(\.dismiss) var dismiss
    
    // Actions
    var onConfirmGiveUp: () -> Void
    var onCancel: () -> Void
    
    @State private var typedText: String = ""
    @State private var shakeOffset: CGFloat = 0
    @State private var hasError: Bool = false
    
    let requiredText = String(localized: "focus.giveup.walkofshame.text", defaultValue: "Ich gebe hiermit auf. Ich entscheide mich bewusst für billiges Dopamin und lasse meinen Garten im Stich.")
    
    var body: some View {
        ZStack {
            // Dark background for the "Walk of Shame"
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                // Warning Icon
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                    .padding(.top, 40)
                
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
                    Text(String(localized: "focus.giveup.walkofshame.button", defaultValue: "Aufgeben & Garten sterben lassen"))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(typedText == requiredText ? Color.red : Color.gray.opacity(0.3))
                        .cornerRadius(16)
                }
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
