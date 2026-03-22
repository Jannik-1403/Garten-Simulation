import SwiftUI

struct WetterBanner: View {
    let event: WetterEvent
    var aktion: (() -> Void)? = nil

    @State private var isPressed = false
    @State private var hapticTrigger = false
    @State private var blinken = false

    var body: some View {
        ZStack {
            // Schatten unten
            RoundedRectangle(cornerRadius: 16)
                .fill(event.bannerFarbeSekundaer)
                .frame(height: 70)

            // Haupt-Banner
            RoundedRectangle(cornerRadius: 16)
                .fill(event.bannerFarbe)
                .frame(height: 70)
                .overlay {
                    HStack(spacing: 12) {

                        // Event Icon
                        Image(systemName: event.systemIcon)
                            .font(.system(size: 28))
                            .foregroundStyle(.white)
                            .scaleEffect(blinken ? 1.2 : 1.0)
                            .animation(
                                event == .sturm || event == .duerre
                                    ? .easeInOut(duration: 0.6)
                                    .repeatForever(autoreverses: true)
                                    : .default,
                                value: blinken
                            )

                        // Texte
                        VStack(alignment: .leading, spacing: 2) {
                            Text(event.untertitel)
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white.opacity(0.85))
                            Text(event.titel)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        // Trennlinie
                        Rectangle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 1, height: 36)

                        // Rechtes Icon
                        Image(systemName: event.systemIcon)
                            .font(.title3)
                            .foregroundStyle(.white)
                            .symbolEffect(.bounce, value: blinken)
                    }
                    .padding(.horizontal, 16)
                }
                .offset(y: isPressed ? 0 : -6)
        }
        .padding(.horizontal, 24)
        .animation(.spring(.snappy(duration: 0.02)), value: isPressed)
        .sensoryFeedback(.selection, trigger: hapticTrigger)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed = true
                    hapticTrigger.toggle()
                    aktion?()
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
        .onAppear {
            if event == .sturm || event == .duerre || event == .perfekt {
                blinken = true
            }
        }
        .onChange(of: event) { _, _ in
            blinken = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if event == .sturm || event == .duerre || event == .perfekt {
                    blinken = true
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        WetterBanner(event: .normal)
        WetterBanner(event: .duerre)
        WetterBanner(event: .schnee)
        WetterBanner(event: .sturm)
        WetterBanner(event: .perfekt)
    }
    .padding(.vertical)
    .background(Color(red: 0.95, green: 0.95, blue: 0.97))
}
