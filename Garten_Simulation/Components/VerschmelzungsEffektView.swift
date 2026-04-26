import SwiftUI

struct VerschmelzungsEffektView: View {
    let verschmelzung: PfadVerschmelzung
    @State private var pulsiert = false

    var body: some View {
        ZStack {
            // Pulsierender Ring
            Circle()
                .stroke(Color.goldPrimary.opacity(0.4), lineWidth: 3)
                .frame(width: pulsiert ? 80 : 60, height: pulsiert ? 80 : 60)
                .opacity(pulsiert ? 0 : 0.8)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false),
                           value: pulsiert)

            // Verbindungs-Icon
            Image(systemName: "link.circle.fill")
                .font(.system(size: 28))
                .foregroundColor(.goldPrimary)
        }
        .onAppear { pulsiert = true }
    }
}
