import SwiftUI

struct WeeklyReviewTeaserPopup: View {
    let onShowAnalysis: () -> Void
    @State private var contentOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Dunkler, semi-transparenter Hintergrund
            Color.black.opacity(0.45)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                
                // Icon
                Image("ProIconAnalytics")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                    .padding(.top, 10)
                
                // Textbereich
                VStack(spacing: 12) {
                    Text(String(localized: "weekly_teaser.title", defaultValue: "Woche gemeistert!"))
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text(String(localized: "weekly_teaser.message", defaultValue: "Herzlichen Glückwunsch! Du hast die Woche erfolgreich überstanden. Lass uns schauen, wie du abgeschnitten hast."))
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Item 3D Button (dunkelblau)
                Item3DButton(
                    farbe: Color.indigo,
                    sekundaerFarbe: Color.indigo.opacity(0.6),
                    groesse: 60,
                    shadowDepthFactor: 0.1,
                    isRectangular: true,
                    aktion: {
                        withAnimation {
                            onShowAnalysis()
                        }
                    }
                ) {
                    Text(String(localized: "weekly_teaser.button", defaultValue: "Analyse ansehen"))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                }
            }
            .padding(28)
            .background(
                ZStack(alignment: .bottom) {
                    // 3D Shadow Layer (Base)
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color(hex: "#E0E0E0"))
                        .offset(y: 8)
                    
                    // Main White Surface
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(Color.black.opacity(0.1), lineWidth: 1.5)
                        )
                }
            )
            .padding(.horizontal, 32)
            .opacity(contentOpacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.42, dampingFraction: 0.8)) {
                contentOpacity = 1.0
            }
        }
    }
}

#Preview {
    WeeklyReviewTeaserPopup(onShowAnalysis: {})
}
