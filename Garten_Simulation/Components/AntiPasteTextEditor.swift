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
        textView.smartInsertDeleteType = .no // Kein schlaues Kopieren
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
    }
}

// 2. Die Magie: UIKit knallhart übersteuern
class CustomTextView: UITextView {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        // Wenn die Aktion "Einfügen" (Paste) ist -> Blockieren!
        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return false
        }
        
        // Copy & Cut blockieren
        if action == #selector(UIResponderStandardEditActions.copy(_:)) ||
           action == #selector(UIResponderStandardEditActions.cut(_:)) {
            return false
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
}
