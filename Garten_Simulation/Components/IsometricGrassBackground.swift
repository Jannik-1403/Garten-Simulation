import SwiftUI

struct IsometricGrassBackground: View {
    let grassTop   = Color(hex: "#4a8a3a")
    let grassLeft  = Color(hex: "#4a8a3a").darker(by: 0.08)
    let grassRight = Color(hex: "#4a8a3a").darker(by: 0.15)

    var contentHeight: CGFloat = UIScreen.main.bounds.height
    var pathPositions: [CGPoint] = []

    var body: some View {
        let screenW = UIScreen.main.bounds.width
        let totalH  = max(contentHeight, UIScreen.main.bounds.height) + 400
        // Render in 1500pt chunks to stay under GPU texture limit
        let chunkH: CGFloat = 1500
        let numChunks = max(1, Int(ceil(totalH / chunkH)))

        VStack(spacing: 0) {
            ForEach(0..<numChunks, id: \.self) { ci in
                let offset = CGFloat(ci) * chunkH
                let thisH  = min(chunkH, totalH - offset)
                GrassTileChunk(
                    chunkOffset: offset,
                    chunkHeight: thisH,
                    screenWidth: screenW,
                    grassTop:   grassTop,
                    grassLeft:  grassLeft,
                    grassRight: grassRight
                )
                .frame(width: screenW, height: thisH)
                .clipped()
            }
        }
        .frame(width: screenW, height: totalH, alignment: .top)
    }
}

private struct GrassTileChunk: View {
    let chunkOffset: CGFloat
    let chunkHeight: CGFloat
    let screenWidth: CGFloat
    let grassTop:   Color
    let grassLeft:  Color
    let grassRight: Color

    private let blockH: CGFloat = IsometricMath.tileSide

    var body: some View {
        let tw = IsometricMath.tileWidth
        let th = IsometricMath.tileHeight

        Canvas { context, size in
            // Convert visible y-range (in absolute coords) to isometric row range.
            // absoluteY = (col+row)*(th/2) + offsetY  where offsetY = -th*2
            // The MINIMUM absoluteY visible in this chunk = chunkOffset (top edge)
            // The MAXIMUM absoluteY visible in this chunk = chunkOffset + chunkHeight
            // (col+row) = (absoluteY - offsetY) / (th/2)
            let offsetY = -th * 2
            let halfTH  = th / 2
            let halfTW  = tw / 2

            let minSum = Int((chunkOffset - offsetY) / halfTH) - 2
            let maxSum = Int((chunkOffset + chunkHeight - offsetY) / halfTH) + 4

            // We iterate over the diagonal sum S = col+row which directly maps to Y.
            // For each S we derive col range from X constraints.
            // X = (col-row)*halfTW + screenWidth/2
            // col - row = (X - screenWidth/2) / halfTW
            // X range: [-tw .. screenWidth+tw]  → diff range:
            let cx = screenWidth / 2
            let minDiff = Int((-tw - cx) / halfTW) - 2
            let maxDiff = Int((screenWidth + tw - cx) / halfTW) + 2

            for s in minSum...maxSum {          // s = col + row
                for d in minDiff...maxDiff {    // d = col - row
                    // Only valid integer pairs where s+d is even (so col,row are integers)
                    guard (s + d) % 2 == 0 else { continue }
                    let col = (s + d) / 2
                    let row = (s - d) / 2

                    let absX = CGFloat(d) * halfTW + cx
                    let absY = CGFloat(s) * halfTH + offsetY
                    let locY = absY - chunkOffset   // local Y within this chunk

                    // Skip tiles completely outside this chunk (with margin)
                    if locY + th + blockH < -th { continue }
                    if locY > chunkHeight + th    { continue }

                    let isDark  = (col + row) % 2 == 0
                    let topCol  = isDark ? grassTop.darker(by: 0.04) : grassTop

                    // Top face (diamond)
                    var top = Path()
                    top.move(to:    CGPoint(x: absX,        y: locY))
                    top.addLine(to: CGPoint(x: absX + halfTW, y: locY + halfTH))
                    top.addLine(to: CGPoint(x: absX,        y: locY + th))
                    top.addLine(to: CGPoint(x: absX - halfTW, y: locY + halfTH))
                    top.closeSubpath()
                    context.fill(top, with: .color(topCol))

                    // Left face
                    var left = Path()
                    left.move(to:    CGPoint(x: absX - halfTW, y: locY + halfTH))
                    left.addLine(to: CGPoint(x: absX,          y: locY + th))
                    left.addLine(to: CGPoint(x: absX,          y: locY + th + blockH))
                    left.addLine(to: CGPoint(x: absX - halfTW, y: locY + halfTH + blockH))
                    left.closeSubpath()
                    context.fill(left, with: .color(grassLeft))

                    // Right face
                    var right = Path()
                    right.move(to:    CGPoint(x: absX,          y: locY + th))
                    right.addLine(to: CGPoint(x: absX + halfTW, y: locY + halfTH))
                    right.addLine(to: CGPoint(x: absX + halfTW, y: locY + halfTH + blockH))
                    right.addLine(to: CGPoint(x: absX,          y: locY + th + blockH))
                    right.closeSubpath()
                    context.fill(right, with: .color(grassRight))
                }
            }
        }
    }
}

#Preview {
    ScrollView {
        IsometricGrassBackground(contentHeight: 6000)
    }
}
