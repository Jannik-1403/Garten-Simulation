import SwiftUI

struct WeeklyReviewTeaserPopup: View {
    let onShowAnalysis: () -> Void
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            // The whole card is an Item3DButton
            Item3DButton(
                farbe: Color(UIColor.systemBackground),
                sekundaerFarbe: Color(UIColor.systemGray4),
                groesse: 60, // Used for shadow calculation
                shadowDepthFactor: 0.15,
                isRectangular: true,
                aktion: {
                    withAnimation {
                        onShowAnalysis()
                    }
                }
            ) {
                VStack(spacing: 20) {
                    Image(systemName: "calendar.badge.checkmark")
                        .font(.system(size: 50, weight: .semibold))
                        .foregroundColor(.blue)
                        .padding(.top, 20)
                    
                    Text(String(localized: "weekly_teaser.title", defaultValue: "Woche gemeistert!"))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text(String(localized: "weekly_teaser.message", defaultValue: "Herzlichen Glückwunsch! Du hast die Woche erfolgreich überstanden. Lass uns schauen, wie du abgeschnitten hast."))
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)
                    
                    Text(String(localized: "weekly_teaser.button", defaultValue: "Tippe, um die Analyse anzusehen"))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 10)
                }
                .padding(.vertical, 10)
            }
            .padding(30)
        }
    }
}

#Preview {
    WeeklyReviewTeaserPopup(onShowAnalysis: {})
}
