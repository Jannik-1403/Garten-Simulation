import SwiftUI

struct GruenerBanner: View {
    let abschnitt: String
    let titel: String
    var aktion: (() -> Void)? = nil
    
    @State private var isPressed = false
    @State private var hapticTrigger = false
    @State private var hatAusgeloest = false
    
    var body: some View {
        ZStack {
            // Dunkler Schatten unten
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gruenSecondary)
                .frame(height: 70)
            
            // Heller grüner Banner oben
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gruenPrimary)
                .frame(height: 70)
                .overlay {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(abschnitt)
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                            Text(titel)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Rectangle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 1, height: 36)
                        
                        Image(systemName: "list.bullet.rectangle")
                            .font(.title3)
                            .foregroundStyle(.white)
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
                    if !hatAusgeloest {
                        hatAusgeloest = true
                        hapticTrigger.toggle()
                        aktion?()
                    }
                }
                .onEnded { _ in
                    isPressed = false
                    hatAusgeloest = false
                }
        )
    }
}

#Preview {
    GruenerBanner(
        abschnitt: "ABSCHNITT 1, EINHEIT 1",
        titel: "Starte deine Reise"
    )
    .padding()
}
