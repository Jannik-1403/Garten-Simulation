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
    var fixedSize: CGSize? = nil  // Optional: prevent GeometryReader if we know what we want.
    
    @State private var isReady = false
    @State private var isDisappearing = false
    @State private var safeSize: CGSize = .zero
    
    var body: some View {
        if let size = fixedSize {
            // FIXED SIZE PATH (Recommended to prevent EXC_BAD_ACCESS)
            ZStack {
                if isReady && !isDisappearing {
                    DotLottieAnimation(
                        webURL: url,
                        config: animationConfig
                    )
                    .view()
                    .id(url)
                    .frame(width: size.width, height: size.height)
                    .allowsHitTesting(false)
                } else {
                    Color.clear
                        .frame(width: size.width, height: size.height)
                }
            }
            .onAppear {
                isDisappearing = false
                isReady = true
            }
            .onDisappear {
                isDisappearing = true
                isReady = false
            }
        } else {
            // DYNAMIC PATH (GeometryReader)
            GeometryReader { geometry in
                ZStack {
                    if isReady && !isDisappearing {
                        DotLottieAnimation(
                            webURL: url,
                            config: animationConfig
                        )
                        .view()
                        .id(url)
                        // Use the fixed safeSize once we are disappearing to prevent the library 
                        // from trying to resize to collapsing container dimensions (0,0).
                        .frame(width: max(1, safeSize.width), height: max(1, safeSize.height))
                        .allowsHitTesting(false)
                    } else {
                        Color.clear
                            .frame(width: max(1, safeSize.width), height: max(1, safeSize.height))
                    }
                }
                .onAppear {
                    isDisappearing = false
                    checkSizeAndReady(size: geometry.size)
                }
                .onDisappear {
                    isDisappearing = true
                    isReady = false
                }
                .onChange(of: geometry.size) { newSize in
                    guard !isDisappearing else { return }
                    if newSize.width > 5 && newSize.height > 5 {
                        safeSize = newSize
                        checkSizeAndReady(size: newSize)
                    }
                }
            }
        }
    }
    
    private func checkSizeAndReady(size: CGSize) {
        guard !isDisappearing else { return }
        guard size.width > 5, size.height > 5 else { return }
        
        if !isReady {
            safeSize = size
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if !isDisappearing {
                    isReady = true
                }
            }
        }
    }
}
