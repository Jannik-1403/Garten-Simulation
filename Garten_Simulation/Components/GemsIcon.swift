import SwiftUI

// MARK: - Custom Hexagon Shape with Rounded Corners
struct HexagonShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cx = rect.midX
        let cy = rect.midY
        let r = min(rect.width, rect.height) / 2
        let cornerRadius = r * 0.28

        var points: [CGPoint] = []
        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3 - .pi / 6
            points.append(CGPoint(
                x: cx + r * cos(angle),
                y: cy + r * sin(angle)
            ))
        }

        for i in 0..<6 {
            let prev = points[(i + 5) % 6]
            let curr = points[i]
            let next = points[(i + 1) % 6]

            let v1 = CGPoint(x: curr.x - prev.x, y: curr.y - prev.y)
            let len1 = sqrt(v1.x * v1.x + v1.y * v1.y)
            let n1 = CGPoint(x: v1.x / len1, y: v1.y / len1)

            let v2 = CGPoint(x: next.x - curr.x, y: next.y - curr.y)
            let len2 = sqrt(v2.x * v2.x + v2.y * v2.y)
            let n2 = CGPoint(x: v2.x / len2, y: v2.y / len2)

            let start = CGPoint(
                x: curr.x - n1.x * cornerRadius,
                y: curr.y - n1.y * cornerRadius
            )
            let end = CGPoint(
                x: curr.x + n2.x * cornerRadius,
                y: curr.y + n2.y * cornerRadius
            )

            if i == 0 {
                path.move(to: start)
            } else {
                path.addLine(to: start)
            }
            path.addQuadCurve(to: end, control: curr)
        }
        path.closeSubpath()
        return path
    }
}



// MARK: - Gem Icon View
struct GemIconView: View {
    var body: some View {
        ZStack {
            HexagonShape()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.42, green: 0.85, blue: 0.08),
                            Color(red: 0.30, green: 0.72, blue: 0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

        }
    }
}

// MARK: - GemsIcon
struct GemsIcon: View {
    let wert: Int

    var body: some View {
        HStack(spacing: 7) {
            GemIconView()
                .frame(width: 30, height: 30)

            Text("\(wert)")
                .font(.appStats)
                .foregroundStyle(Color(red: 0.30, green: 0.72, blue: 0.05))
        }
    }
}

#Preview {
    ZStack {
        Color(UIColor.systemBackground)
        GemsIcon(wert: 505)
            .padding()
    }
}
