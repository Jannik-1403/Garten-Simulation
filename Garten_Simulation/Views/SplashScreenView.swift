import SwiftUI

struct SplashScreenView: View {
    @State private var step1_shrinkAndMoveLeft = false
    @State private var step2_showText = false
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            HStack(spacing: 8) {
                // Icon
                Image("Splash_Screenicon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: step1_shrinkAndMoveLeft ? 120 : 340, height: step1_shrinkAndMoveLeft ? 120 : 340)
                
                // Text
                Text(String(localized: "app_name_grovy", defaultValue: "Grovy"))
                    .font(.system(size: 44, weight: .bold)) // Deutlich kleiner gemacht
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .fixedSize()
                    // Animiere die Breite von 0 auf die natürliche Breite, um es aus dem Icon "herausfahren" zu lassen
                    .frame(width: step2_showText ? nil : 0, alignment: .leading)
                    .clipped()
            }
        }
        .onAppear {
            // 1. Icon schrumpft (bleibt dabei noch zentriert)
            withAnimation(.easeInOut(duration: 0.4).delay(0.0)) {
                step1_shrinkAndMoveLeft = true
            }
            
            // 2. Text fährt heraus -> dadurch bewegt sich das Icon automatisch exakt so weit nach links,
            // dass beide Elemente ZUSAMMEN am Ende wieder zu 100% perfekt in der Mitte sind!
            withAnimation(.easeOut(duration: 0.4).delay(0.4)) {
                step2_showText = true
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
