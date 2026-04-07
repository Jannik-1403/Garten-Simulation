import SwiftUI

struct WeedDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var gardenStore: GardenStore
    
    var body: some View {
        VStack(spacing: 32) {
            // Header Image/Icon
            ZStack {
                Circle()
                    .fill(Color.gruenPrimary.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundStyle(Color.orangePrimary)
            }
            .padding(.top, 40)
            
            VStack(spacing: 16) {
                Text(NSLocalizedString("weed.detail.titel", comment: ""))
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .multilineTextAlignment(.center)
                
                Text(NSLocalizedString("weed.detail.beschreibung", comment: ""))
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            
            // Progress Indicator
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(index < gardenStore.dailyQuestsCompletedSinceWeed ? Color.gruenPrimary : Color.gray.opacity(0.2))
                            .frame(width: 20, height: 20)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
                
                Text(String(format: NSLocalizedString("weed.detail.fortschritt", comment: ""), gardenStore.dailyQuestsCompletedSinceWeed))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
            }
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.primary.opacity(0.03))
            )
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Success Action
            Button {
                dismiss()
            } label: {
                Text(NSLocalizedString("weed.detail.button", comment: ""))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(DuolingoButtonStyle(
                size: .large,
                backgroundColor: .gruenPrimary,
                shadowColor: .gruenSecondary
            ))
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
        .background(Color.appHintergrund)
    }
}

#Preview {
    WeedDetailView()
        .environmentObject(GardenStore())
}
