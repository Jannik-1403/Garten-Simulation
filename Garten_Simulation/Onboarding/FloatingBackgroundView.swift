import SwiftUI
import Combine

struct FloatingBackgroundView: View {
    @State private var animateGradient = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(
                    colors: [Color.orange, Color.red],
                    startPoint: animateGradient ? .topLeading : .bottomLeading,
                    endPoint: animateGradient ? .bottomTrailing : .topTrailing
                )
                .opacity(0.15)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true), value: animateGradient)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                    animateGradient = true
                }
            }
        }
        .ignoresSafeArea()
    }
}


