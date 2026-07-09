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
        String(localized: "focus.giveup.walkofshame.sentence1", defaultValue: "Ich kapituliere zu einhundert Prozent! Statt an meinen Zielen zu arbeiten, wähle ich den null-acht-fünfzehn Weg. Ich opfere meine #Disziplin für fünf Min. billiges Dopamin. Das ist armselig; aber ich tue es trotzdem (und akzeptiere den HP-Verlust)."),
        String(localized: "focus.giveup.walkofshame.sentence2", defaultValue: "[Achtung] Ich bin zu schwach für neunundneunzig Prozent meiner Aufgaben. Ich breche ab: X-Y-Z statt A-B-C. Mein Fokus sinkt auf null Punkt null; ich wähle #Versagen über #Wachstum. Warum? Weil mein Dopamin-Spiegel < zehn Prozent ist."),
        String(localized: "focus.giveup.walkofshame.sentence3", defaultValue: "Fehler-Code vierhundertvier: Willenskraft nicht gefunden! Ich tausche meine erste Priorität gegen zehn Min. sinnlosen Feed-Scroll. Ist das schlau? Nein. Mache ich es trotzdem? Ja!! (Tschüss, wertvolle Zeit...)"),
        String(localized: "focus.giveup.walkofshame.sentence4", defaultValue: "Ich bestätige hiermit den Abbruch (Status: einhundert Prozent undiszipliniert). Statt plus eins Schritt nach vorne, mache ich minus drei Schritte zurück. Meine #Ziele sind mir gerade egal; ich klicke auf [Entsperren] & vergeude eine halbe Stunde."),
        String(localized: "focus.giveup.walkofshame.sentence5", defaultValue: "Warum aufgeben? Weil ich null Prozent Frustrationstoleranz habe. Ich wähle den Shortcut (Typ B) und ignoriere Regel Nummer eins: Bleib fokussiert! Meine HP sinken um minus fünfzehn Punkte; das ist der Preis für zwei Min. Schwäche.")
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
                let randomSentence = sentencePool.randomElement()!
                requiredText = randomizeCase(of: randomSentence)
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(.default) { shakeOffset = 0 }
            }
        }
    }
    
    // Zerstört das Tipp-Gedächtnis komplett, indem wahllos Zeichen groß und klein gemacht werden
    private func randomizeCase(of text: String) -> String {
        var result = ""
        for char in text {
            if char.isLetter {
                // 40% Chance die Groß-/Kleinschreibung zu invertieren
                if Bool.random() && Bool.random() {
                    if char.isUppercase {
                        result.append(char.lowercased())
                    } else {
                        result.append(char.uppercased())
                    }
                } else {
                    result.append(char)
                }
            } else {
                result.append(char)
            }
        }
        return result
    }
}
