import SwiftUI

struct DailyWateringRingView: View {
    let progress: Double // 0.0 bis 1.0
    let count: Int
    let total: Int
    var onTap: (() -> Void)? = nil

    @EnvironmentObject var settings: SettingsStore
    @State private var animatedProgress: Double = 0

    private let ringSize: CGFloat = 70
    private let lineWidth: CGFloat = 11

    private var trackColor: Color {
        animatedProgress >= 1.0 ? Color.gruenPrimary.opacity(0.2) : Color.blauPrimary.opacity(0.2)
    }
    private var ringColor: Color {
        animatedProgress >= 1.0 ? Color.gruenPrimary : Color.blauPrimary
    }

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onTap?()
        } label: {
            HStack(spacing: 16) {

                // MARK: - Progress Ring
                ZStack {
                    // Track (Hintergrund-Spur)
                    Circle()
                        .stroke(trackColor, lineWidth: lineWidth)

                    // Fortschrittsbogen
                    Circle()
                        .trim(from: 0, to: animatedProgress)
                        .stroke(ringColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                        .rotationEffect(.degrees(-90))

                    // Icon in der Mitte
                    ZStack {
                        if animatedProgress >= 1.0 {
                            Image(systemName: "checkmark")
                                .font(.system(size: 20, weight: .black))
                                .foregroundStyle(ringColor)
                                .transition(.scale.combined(with: .opacity))
                        } else {
                            Image("Drop water")
                                .resizable()
                                .scaledToFit()
                                .frame(width: ringSize * 0.44, height: ringSize * 0.44)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: animatedProgress >= 1.0)
                }
                .frame(width: ringSize, height: ringSize)

                // MARK: - Text
                VStack(alignment: .leading, spacing: 2) {
                    Text(settings.localizedString(for: "garden.daily_ring.title"))
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(count)")
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .foregroundStyle(.primary)
                            .contentTransition(.numericText())

                        Text("/ \(total)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .liquidGlass(opacity: 0.05)
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(.spring(response: 1.2, dampingFraction: 0.8)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { oldValue, newValue in
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                animatedProgress = newValue
            }
            if newValue >= 1.0 && oldValue < 1.0 {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        DailyWateringRingView(progress: 0.6, count: 6, total: 10)
        DailyWateringRingView(progress: 1.0, count: 10, total: 10)
    }
    .environmentObject(SettingsStore())
    .padding()
    .background(Color.appHintergrund)
}
