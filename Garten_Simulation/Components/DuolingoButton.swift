import SwiftUI

struct DuolingoButton: View {
    let title: String
    let color: Color
    var action: (() -> Void)? = nil
    
    var offset: CGFloat {
        isPressed ? 0 : -8
    }
    
    @State private var isPressed = false
    @State private var hapticTrigger = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(color.opacity(0.7))
                .frame(height: 60)
            
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(color)
                .frame(height: 60)
                .overlay {
                    Text(title)
                        .foregroundStyle(.white)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                }
                .offset(y: offset)
                .onTapGesture {
                    hapticTrigger.toggle()
                    action?()
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            withAnimation(.spring(.snappy(duration: 0.02))) {
                                isPressed = true
                            }
                        }
                        .onEnded { _ in
                            withAnimation(.spring(.snappy(duration: 0.02))) {
                                isPressed = false
                            }
                        }
                )
        }
        .sensoryFeedback(.selection, trigger: hapticTrigger)
    }
}

#Preview {
    VStack(spacing: 20) {
        DuolingoButton(title: "GIESSEN 💧", color: .blue)
        DuolingoButton(title: "WEITER", color: .green)
        DuolingoButton(title: "STREAK RETTEN 🔥", color: .orange)
    }
    .padding()
}
