import SwiftUI

// MARK: - Dedicated Wheel UI Components
// These components are shared between Daily Spin, Garten Pass and Tutorial

/// Segment types for the wheel layout
enum SegmentKind: Equatable {
    case weed, safe, gold
}


/// Dots appearing on the outer rim of the 3D wheel
struct WheelRimDot: View {
    let index: Int
    let totalDots: Int
    let rimRadius: CGFloat

    var body: some View {
        let angle = Double(index) * (360.0 / Double(totalDots)) * .pi / 180.0 - .pi / 2.0
        let dx = CGFloat(cos(angle)) * rimRadius
        let dy = CGFloat(sin(angle)) * rimRadius
        RoundedRectangle(cornerRadius: 3)
            .fill(Color.white.opacity(0.85))
            .frame(width: 8, height: 8)
            .offset(x: dx, y: dy)
    }
}

/// The triangle pointer situated at the top of the wheel
struct WheelTrianglePointer: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))  // tip pointing down
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

/// Generic 3D wrapper that pushes a view down when pressed
struct Press3DWrapperButtonStyle: ButtonStyle {
    var depth: CGFloat = 6
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .offset(y: configuration.isPressed ? depth : 0)
            .animation(.spring(response: 0.15, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Daily Spin Logic Support (Segment definitions)

struct WheelSegmentIcon: View {
    let kind: SegmentKind

    var body: some View {
        switch kind {
        case .gold:
            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
        case .weed:
            Image(systemName: "ant.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
        case .safe:
            Image(systemName: "leaf.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
        }
    }
}

struct WheelSlices: View {
    let layout: [SegmentKind]

    var body: some View {
        GeometryReader { geo in
            let rect = geo.frame(in: .local)
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let radius = min(rect.width, rect.height) / 2
            let count = max(layout.count, 1)
            let segDeg = 360.0 / Double(count)

            ZStack {
                ForEach(0..<count, id: \.self) { i in
                    let kind = i < layout.count ? layout[i] : .safe
                    let startDeg = -90.0 + Double(i) * segDeg
                    let endDeg   = startDeg + segDeg
                    let midDeg   = startDeg + segDeg / 2
                    let midRad   = midDeg * .pi / 180
                    let iconR = radius * 0.62
                    
                    let color = colorFor(kind)

                    // Segment fill
                    Path { path in
                        path.move(to: center)
                        path.addArc(center: center, radius: radius,
                                    startAngle: .degrees(startDeg),
                                    endAngle: .degrees(endDeg),
                                    clockwise: false)
                        path.closeSubpath()
                    }
                    .fill(color)

                    // Segment divider
                    Path { path in
                        path.move(to: center)
                        path.addArc(center: center, radius: radius,
                                    startAngle: .degrees(startDeg),
                                    endAngle: .degrees(endDeg),
                                    clockwise: false)
                        path.closeSubpath()
                    }
                    .stroke(Color.black.opacity(0.4), lineWidth: 2)

                    // Icon
                    WheelSegmentIcon(kind: kind)
                        .rotationEffect(.degrees(midDeg + 90))
                        .position(
                            x: center.x + CGFloat(cos(midRad)) * iconR,
                            y: center.y + CGFloat(sin(midRad)) * iconR
                        )
                }
            }
        }
    }
    
    func colorFor(_ kind: SegmentKind) -> Color {
        switch kind {
        case .safe: return Color.gruenPrimary
        case .weed: return Color.rotPrimary
        case .gold: return Color.coinBlue
        }
    }
}
