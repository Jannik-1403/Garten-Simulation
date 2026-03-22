import SwiftUI

struct GartenView: View {
    
    @State private var streak: Int = 12
    @State private var gems: Int = 281
    @State private var herzen: Int = 5
    @State private var fortschritt: Double = 0.75
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // MARK: - Stats Bar (ganz oben)
                HStack {
                    Spacer()
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.orange)
                            .font(.title2)
                        Text("\(streak)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.orange)
                    }
                    Spacer()
                    HStack(spacing: 6) {
                        Image(systemName: "diamond.fill")
                            .foregroundStyle(.purple)
                            .font(.title2)
                        Text("\(gems)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.purple)
                    }
                    Spacer()
                    HStack(spacing: 6) {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.red)
                            .font(.title2)
                        Text("\(herzen)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.red)
                    }
                    Spacer()
                }
                .padding(.top, 8)
                .padding(.bottom, 12)
                
                // MARK: - Grüner Banner (unter Stats Bar)
                Button {
                    // Später: Navigation
                } label: {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("ABSCHNITT 1, EINHEIT 1")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                            Text("Starte deine Reise")
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
                    .padding(.vertical, 10)
                }
                .buttonStyle(DepthButtonStyle(
                    foregroundColor: .gruenPrimary,
                    backgroundColor: .gruenSecondary,
                    cornerRadius: 16
                ))
                .padding(.horizontal, 24)
                .padding(.bottom, 8)
                
                Spacer()
                
                // MARK: - Pflanze + Button
                HStack(alignment: .center, spacing: 16) {
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.15), lineWidth: 8)
                            .frame(width: 140, height: 140)
                        
                        Circle()
                            .trim(from: 0, to: fortschritt)
                            .stroke(
                                Color(red: 1.0, green: 0.8, blue: 0.0),
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .frame(width: 140, height: 140)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 1.0), value: fortschritt)
                        
                        PflanzenButton(
                            bildName: "icon-bonsaipng",
                            farbe: .gruenPrimary,
                            sekundaerFarbe: .gruenSecondary,
                            groesse: 110,
                            aktion: nil
                        )
                    }
                    .frame(width: 140, height: 140)
                    
                    Button("GIESSEN") {
                        withAnimation {
                            gems += 10
                            fortschritt = min(fortschritt + 0.05, 1.0)
                        }
                    }
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .buttonStyle(DepthButtonStyle(
                        foregroundColor: .blauPrimary,
                        backgroundColor: .blauSecondary,
                        cornerRadius: 16
                    ))
                    .frame(height: 50)
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.45)
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
    }
}

#Preview {
    GartenView()
}