import SwiftUI
import DotLottie

struct LottieView: View {
    let name: String
    var loop: Bool = true
    var speed: Double = 1.0
    
    @State private var animation: DotLottieAnimation? = nil
    
    var body: some View {
        Group {
            if let animation = animation {
                animation.view()
                    .id(name)
            } else {
                Color.clear
            }
        }
        .onAppear {
            setupAnimation()
        }
        .onChange(of: name) {
            setupAnimation()
        }
    }
    
    private func setupAnimation() {
        let config = AnimationConfig(
            autoplay: true,
            loop: loop,
            speed: Float(speed)
        )
        
        if name.hasPrefix("http") {
            animation = DotLottieAnimation(
                webURL: name,
                config: config
            )
        } else {
            animation = DotLottieAnimation(
                fileName: name,
                config: config
            )
        }
    }
}
