import SwiftUI
import UIKit

// 1. Die SwiftUI-Brücke
struct AntiPasteTextEditor: UIViewRepresentable {
    @Binding var text: String
    
    func makeUIView(context: Context) -> CustomTextView {
        let textView = CustomTextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = .clear
        textView.textColor = .white
        textView.autocorrectionType = .no // Keine Autokorrektur-Hilfe!
        textView.spellCheckingType = .no // Keine Rechtschreibprüfung
        textView.smartQuotesType = .no // Verhindert automatische Anführungszeichen
        textView.smartDashesType = .no // Verhindert automatische Gedankenstriche
        textView.smartInsertDeleteType = .no // Kein schlaues Kopieren
        textView.keyboardType = .asciiCapable // Erzwingt die Standard-Tastatur ohne Schnickschnack
        return textView
    }
    
    func updateUIView(_ uiView: CustomTextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: AntiPasteTextEditor
        
        init(_ parent: AntiPasteTextEditor) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
        
        // HIER IST DIE NEUE FALLE
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            // 1. Erlaube das Löschen (Rücktaste erzeugt einen leeren String)
            if text.isEmpty {
                return true
            }
            
            // 2. Der Chunk-Blocker: Wenn mehr als 1 Zeichen auf einmal kommt -> Blockieren!
            // Das vernichtet die Diktierfunktion und Auto-Fill komplett.
            if text.count > 1 {
                print("🚨 Cheat-Versuch erkannt: Diktierfunktion oder Copy-Paste blockiert!")
                return false
            }
            
            return true
        }
    }
}

// 2. Die Magie: UIKit knallhart übersteuern
class CustomTextView: UITextView {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        // Blockiert das komplette Kontextmenü (Einfügen, Kopieren, Live Text / Text scannen, etc.)
        return false
    }
}
