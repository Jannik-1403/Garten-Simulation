import SwiftUI
import DotLottie

struct LottieView: View {
    let name: String
    var loop: Bool = true
    var speed: Double = 1.0
    
    var body: some View {
        if name.hasPrefix("http") {
            DotLottieAnimation(
                webURL: name,
                config: AnimationConfig(
                    autoplay: true,
                    loop: loop,
                    speed: Float(speed)
                )
            ).view()
        } else {
            DotLottieAnimation(
                fileName: name,
                config: AnimationConfig(
                    autoplay: true,
                    loop: loop,
                    speed: Float(speed)
                )
            ).view()
        }
    }
}
