import SwiftUI

struct SeltenheitProgressRing: View {
    let progress: CGFloat           // 0.0 ... 1.0
    let color: Color
    var lineWidth: CGFloat = 8
    var size: CGFloat = 100
    var celebrateTrigger: Bool = false

    @State private var displayed: CGFloat = 0

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.15), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: max(0, min(1, displayed)))
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
        }
        .frame(width: size, height: size)
        .onAppear {
            displayed = clamp(progress)
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.easeInOut(duration: 0.8)) {
                displayed = clamp(newValue)
            }
        }
        .onChange(of: celebrateTrigger) { _, newValue in
            guard newValue else { return }
            let target = clamp(progress)
            withAnimation(.easeInOut(duration: 0.6)) {
                displayed = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.62) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    displayed = target
                }
            }
        }
    }

    private func clamp(_ value: CGFloat) -> CGFloat {
        max(0, min(1, value))
    }
}

#Preview {
    VStack(spacing: 20) {
        SeltenheitProgressRing(progress: 0.65, color: .blue, lineWidth: 10, size: 120)
        SeltenheitProgressRing(progress: 0.25, color: .green, lineWidth: 6, size: 80)
    }
    .padding()
}
