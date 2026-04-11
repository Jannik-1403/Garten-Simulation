import SwiftUI

struct WetterBanner: View {
    let event: WetterEvent
    var aktion: (() -> Void)? = nil

    @State private var isPressed = false
    @State private var hapticTrigger = false
    @State private var hatAusgeloest = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: event.systemIcon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 0) {
                Text(event.untertitel)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.85))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(event.titel)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Rectangle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 1, height: 28)

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(event.bannerFarbeSekundaer)
                
                RoundedRectangle(cornerRadius: 14)
                    .fill(event.bannerFarbe)
                    .offset(y: isPressed ? 0 : -6)
            }
        }
        .frame(maxWidth: .infinity)
        .fixedSize(horizontal: false, vertical: true)
        .animation(.spring(.snappy(duration: 0.02)), value: isPressed)
        .sensoryFeedback(.selection, trigger: hapticTrigger)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed = true
                    if !hatAusgeloest {
                        hatAusgeloest = true
                        hapticTrigger.toggle()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
                            aktion?()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                            isPressed = false
                            hatAusgeloest = false
                        }
                    }
                }
                .onEnded { _ in
                    isPressed = false
                    hatAusgeloest = false
                }
        )
        .onDisappear {
            isPressed = false
            hatAusgeloest = false
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        WetterBanner(event: .normal)
        WetterBanner(event: .duerre)
        WetterBanner(event: .schnee)
    }
    .padding()
    .background(Color(red: 0.95, green: 0.95, blue: 0.97))
}
