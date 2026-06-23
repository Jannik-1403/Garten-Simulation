import SwiftUI

struct StandardNavigationModifier: ViewModifier {
    @Environment(\.dismiss) private var dismiss
    var show: Bool = true

    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if show {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 17, weight: .black))
                                .foregroundStyle(.primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
    }
}

extension View {
    func standardNavigationX(show: Bool = true) -> some View {
        self.modifier(StandardNavigationModifier(show: show))
    }
}
