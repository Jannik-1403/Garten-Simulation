import SwiftUI

struct WetterBanner: View {
    let event: WetterEvent
    var aktion: (() -> Void)? = nil

    @State private var isPressed = false
    @State private var hapticTrigger = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(event.bannerFarbeSekundaer)
                .frame(height: 80)

            RoundedRectangle(cornerRadius: 14)
                .fill(event.bannerFarbe)
                .frame(height: 80)
                .overlay {
                    HStack(spacing: 12) {
                        Image(systemName: event.systemIcon)
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(.white)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(event.untertitel)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(0.85))
                            Text(event.titel)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Rectangle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 1, height: 36)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .offset(y: isPressed ? 0 : -6)
        }
        .padding(.horizontal, 20)
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
