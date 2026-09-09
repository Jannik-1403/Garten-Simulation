import SwiftUI

struct WaterDuolingoButtonStyle: ButtonStyle {
    var color: Color
    var shadowColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(shadowColor)
                        .offset(y: configuration.isPressed ? 0 : 6)
                    
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(color)
                        .offset(y: configuration.isPressed ? 6 : 0)
                }
            )
            .offset(y: configuration.isPressed ? 6 : 0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// Custom View for 3D Progress Ring
struct ChunkyProgressRing: View {
    var progress: Double
    var goal: Double
    
    var percent: Double {
        if goal <= 0 { return 0 }
        return min(1.0, progress / goal)
    }
    
    var body: some View {
        ZStack {
            // Background Shadow
            Circle()
                .stroke(Color.blue.opacity(0.15), lineWidth: 24)
                .offset(y: 4)
            
            // Background Track
            Circle()
                .stroke(Color.blue.opacity(0.2), lineWidth: 24)
            
            // Foreground Progress Shadow
            Circle()
                .trim(from: 0.0, to: percent)
                .stroke(Color.blue.opacity(0.5), style: StrokeStyle(lineWidth: 24, lineCap: .round))
                .rotationEffect(Angle(degrees: -90))
                .offset(y: 4)
            
            // Foreground Progress
            Circle()
                .trim(from: 0.0, to: percent)
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 24, lineCap: .round))
                .rotationEffect(Angle(degrees: -90))
                
            VStack(spacing: 4) {
                Text("\(Int(progress))")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundColor(.blue)
                
                Text(String(localized: "water.target.text", defaultValue: "von %@ ml").replacingOccurrences(of: "%@", with: "\(Int(goal))"))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
            }
        }
        .padding(12)
    }
}
