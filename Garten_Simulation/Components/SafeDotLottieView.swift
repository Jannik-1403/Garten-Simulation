import SwiftUI
import DotLottie

/// A safety wrapper for DotLottieAnimation that prevents EXC_BAD_ACCESS crashes.
/// The crash occurs because MTKView's Coordinator fires drawableSizeWillChange on
/// a deallocated player during sheet dismissal. By setting isReady = false on
/// disappear, we remove the Lottie view BEFORE the dismiss animation triggers
/// any resize events, preventing the dangling pointer access.
struct SafeDotLottieView: View {
    let url: String
    var animationConfig: AnimationConfig = AnimationConfig(autoplay: true, loop: true)
    var fixedSize: CGSize? = nil
    
    @State private var isReady = false
    @State private var isDisappearing = false
    @State private var safeSize: CGSize = .zero
    
    var body: some View {
        ZStack {
            if isReady && !isDisappearing && hasValidSize {
                DotLottieAnimation(
                    webURL: url,
                    config: animationConfig
                )
                .view()
                .id("\(url)-\(isReady)") // Force clean state
                .frame(width: currentSize.width, height: currentSize.height)
                .allowsHitTesting(false)
                .transition(.opacity)
            } else {
                Color.clear
                    .frame(width: currentSize.width, height: currentSize.height)
            }
        }
        .onAppear {
            isDisappearing = false
            // Delay to let layout settle and prevent MTKView race conditions
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if !isDisappearing {
                    withAnimation(.easeIn(duration: 0.2)) {
                        isReady = true
                    }
                }
            }
        }
        .onDisappear {
            isDisappearing = true
            isReady = false
        }
        // If no fixed size, we need to track geometry
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        if fixedSize == nil {
                            safeSize = geo.size
                        }
                    }
                    .onChange(of: geo.size) { _, newSize in
                        if fixedSize == nil && newSize.width > 5 && newSize.height > 5 {
                            safeSize = newSize
                        }
                    }
            }
        )
    }
    
    private var currentSize: CGSize {
        if let size = fixedSize {
            return size
        }
        return safeSize
    }
    
    private var hasValidSize: Bool {
        let size = currentSize
        return size.width > 5 && size.height > 5
    }
}
