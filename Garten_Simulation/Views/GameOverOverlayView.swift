import SwiftUI

struct GameOverOverlayView: View {
    @EnvironmentObject var gardenStore: GardenStore
    @State private var zeigeUmfrage = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.secondary)

                VStack(spacing: 8) {
                    Text(NSLocalizedString("gameover.titel", comment: ""))
                        .font(.title2).fontWeight(.bold)
                    Text(NSLocalizedString("gameover.beschreibung", comment: ""))
                        .font(.subheadline).foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                Button {
                    zeigeUmfrage = true
                } label: {
                    Text(NSLocalizedString("gameover.button", comment: ""))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(DuolingoButtonStyle(size: .large))
            }
            .padding(32)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
            .padding(24)
        }
        .sheet(isPresented: $zeigeUmfrage) {
            RetentionSurveyView()
        }
    }
}
