import SwiftUI

struct StandardNavigationModifier: ViewModifier {
    @Environment(\.dismiss) private var dismiss
    
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .black))
                            .foregroundStyle(.primary)
                            .padding(8)
                    }
                }
            }
    }
}

extension View {
    func standardNavigationX() -> some View {
        self.modifier(StandardNavigationModifier())
    }
}
