import SwiftUI

struct WeeklyReviewTeaserPopup: View {
    let onShowAnalysis: () -> Void
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // 3D-like Icon / Graphic
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(gradient: Gradient(colors: [.yellow, .orange]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 100, height: 100)
                        .shadow(color: .orange.opacity(0.6), radius: 10, x: 0, y: 10)
                    
                    Image(systemName: "star.fill")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(radius: 2)
                }
                .rotation3DEffect(.degrees(10), axis: (x: 1, y: 1, z: 0))
                
                Text(String(localized: "weekly_teaser.title", defaultValue: "Woche gemeistert!"))
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text(String(localized: "weekly_teaser.message", defaultValue: "Herzlichen Glückwunsch! Du hast die Woche erfolgreich überstanden. Lass uns schauen, wie du abgeschnitten hast."))
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button(action: {
                    withAnimation {
                        onShowAnalysis()
                    }
                }) {
                    Text(String(localized: "weekly_teaser.button", defaultValue: "Analyse ansehen"))
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(16)
                        .shadow(color: .purple.opacity(0.4), radius: 8, x: 0, y: 5)
                }
                .padding(.top, 10)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            )
            .padding(40)
            .rotation3DEffect(.degrees(5), axis: (x: 0, y: 1, z: 0))
            // Entry Animation setup would go via ViewModifer if needed
        }
    }
}

#Preview {
    WeeklyReviewTeaserPopup(onShowAnalysis: {})
}
