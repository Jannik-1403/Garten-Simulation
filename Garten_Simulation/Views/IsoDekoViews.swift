import SwiftUI

struct IsoBushView: View {
    var size: CGFloat = 110
    
    var body: some View {
        ZStack {
            // Schatten unten (gibt Tiefe)
            Ellipse()
                .fill(Color.black.opacity(0.15))
                .frame(width: size * 0.70, height: size * 0.22)
                .offset(y: size * 0.30)
                .blur(radius: 4)
            
            // Hinterer linker H\u00fcgel (dunkel = weiter weg)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "#5ab830"), Color(hex: "#2d6b18")],
                        center: .init(x: 0.35, y: 0.35),
                        startRadius: 0,
                        endRadius: size * 0.22
                    )
                )
                .frame(width: size * 0.48, height: size * 0.48)
                .offset(x: -size * 0.18, y: size * 0.05)
            
            // Hinterer rechter H\u00fcgel
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "#52aa2a"), Color(hex: "#2a6015")],
                        center: .init(x: 0.35, y: 0.35),
                        startRadius: 0,
                        endRadius: size * 0.20
                    )
                )
                .frame(width: size * 0.42, height: size * 0.42)
                .offset(x: size * 0.20, y: size * 0.08)
            
            // Vorderer gro\u00dfer mittlerer H\u00fcgel (hell = vorne)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "#72d040"), Color(hex: "#3a8a20")],
                        center: .init(x: 0.38, y: 0.30),
                        startRadius: 0,
                        endRadius: size * 0.30
                    )
                )
                .frame(width: size * 0.62, height: size * 0.62)
                .offset(x: size * 0.00, y: -size * 0.02)
            
            // Glanz-Highlight oben links
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.55), Color.white.opacity(0.0)],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.12
                    )
                )
                .frame(width: size * 0.24, height: size * 0.24)
                .offset(x: -size * 0.12, y: -size * 0.18)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Baum (smooth, kein Pixel)
struct IsoTreeView: View {
    var size: CGFloat = 140
    
    var body: some View {
        ZStack {
            // Schatten
            Ellipse()
                .fill(Color.black.opacity(0.12))
                .frame(width: size * 0.40, height: size * 0.12)
                .offset(y: size * 0.40)
                .blur(radius: 5)
            
            // Stamm
            RoundedRectangle(cornerRadius: 4)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#a0622a"), Color(hex: "#6b3d18")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: size * 0.11, height: size * 0.30)
                .offset(y: size * 0.22)
            
            // Krone hinten (dunkler)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "#4aaa28"), Color(hex: "#1f5510")],
                        center: .init(x: 0.4, y: 0.4),
                        startRadius: 0,
                        endRadius: size * 0.30
                    )
                )
                .frame(width: size * 0.62, height: size * 0.62)
                .offset(x: size * 0.05, y: -size * 0.04)
            
            // Krone links
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "#5ec432"), Color(hex: "#2d7018")],
                        center: .init(x: 0.4, y: 0.35),
                        startRadius: 0,
                        endRadius: size * 0.25
                    )
                )
                .frame(width: size * 0.52, height: size * 0.52)
                .offset(x: -size * 0.12, y: -size * 0.02)
            
            // Krone vorne (hell)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "#78e040"), Color(hex: "#3a9020")],
                        center: .init(x: 0.38, y: 0.28),
                        startRadius: 0,
                        endRadius: size * 0.28
                    )
                )
                .frame(width: size * 0.56, height: size * 0.56)
                .offset(x: size * 0.00, y: -size * 0.10)
            
            // Highlight
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.50), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.10
                    )
                )
                .frame(width: size * 0.20, height: size * 0.20)
                .offset(x: -size * 0.10, y: -size * 0.24)
        }
        .frame(width: size, height: size)
    }
}
