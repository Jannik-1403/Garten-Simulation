import SwiftUI

struct WetterDetailView: View {
    let event: WetterEvent
    @EnvironmentObject var settings: SettingsStore
    @State private var perfektIconPressed = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 28) {
                // MARK: - 3D Header Icon
                ZStack {
                    // Shadows/Extrusion (Base)
                    Circle()
                        .fill(event.bannerFarbeSekundaer)
                        .frame(width: 120, height: 120)

                    // Main Surface (Top Layer)
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [event.bannerFarbe, event.bannerFarbe.opacity(0.9)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .overlay {
                            Image(systemName: event.systemIcon)
                                .font(.system(size: 48, weight: .bold))
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.15), radius: 2)
                        }
                        .overlay {
                            Circle()
                                .stroke(.white.opacity(0.25), lineWidth: 2)
                        }
                        .offset(y: perfektIconPressed ? 0 : -6) // Raised when not pressed
                }
                .animation(perfektIconPressed ? nil : .spring(response: 0.15, dampingFraction: 0.6), value: perfektIconPressed)
                .onTapGesture {
                    handleIconPress()
                }
                .padding(.top, 32)

                VStack(spacing: 6) {
                    Text(event.titel)
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.primary)
                    
                    Text(event.untertitel)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                // MARK: - 3D Info Cards
                HStack(spacing: 16) {
                    Weather3DCard(
                        icon: "diamond.fill",
                        title: "GEMS",
                        value: gemsText,
                        color: .purple,
                        shadowColor: .purple.darker()
                    )
                    
                    Weather3DCard(
                        icon: "drop.fill",
                        title: "GIESSEN",
                        value: giessText,
                        color: event.bannerFarbe,
                        shadowColor: event.bannerFarbeSekundaer
                    )
                }

                // MARK: - 3D Rules Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 10) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(event.bannerFarbe)
                        Text(settings.localizedString(for: "weather.today_is").uppercased())
                            .font(.system(size: 12, weight: .black, design: .rounded))
                            .tracking(1.2)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text(ruleText)
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundStyle(.primary)
                        .lineSpacing(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color.primary.opacity(0.05))
                            .offset(y: 4)
                        
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                            )
                    }
                )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(
            ZStack {
                event.hintergrundFarbe.ignoresSafeArea()
                
                // Subtile Glow-Spheres im Hintergrund
                Circle()
                    .fill(event.bannerFarbe.opacity(0.08))
                    .frame(width: 300)
                    .blur(radius: 60)
                    .offset(x: -150, y: -200)
            }
        )
    }

    private func handleIconPress() {
        perfektIconPressed = true
        UISelectionFeedbackGenerator().selectionChanged()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            perfektIconPressed = false
        }
    }

    private var gemsText: String {
        switch event {
        case .perfekt: return "2x"
        case .schnee: return "0.5x"
        default: return "1x"
        }
    }

    private var giessText: String {
        switch event {
        case .duerre: return "2x"
        case .schnee: return "Erschwert"
        default: return "Normal"
        }
    }

    private var ruleText: String {
        switch event {
        case .normal: return "Alles läuft normal. Einmal gießen reicht."
        case .duerre: return "Dürre-Alarm: Du musst heute zweimal gießen."
        case .schnee: return "Frost: Du bekommst nur halbe Gems."
        case .sturm: return "Sturm: Empfindliche Pflanzen verlieren schneller an Level."
        case .perfekt: return "Perfektes Wetter: Heute gibt es doppelte Gems."
        }
    }
}

// MARK: - Weather 3D Card
struct Weather3DCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    let shadowColor: Color

    var body: some View {
        ZStack {
            // Shadow (Extrusion)
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(shadowColor.opacity(0.6))
                .frame(height: 90)
                .offset(y: 4)

            // Surface
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white)
                .frame(height: 90)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                )
                .overlay {
                    VStack(spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: icon)
                                .font(.system(size: 13, weight: .black))
                                .foregroundStyle(color)
                            Text(title)
                                .font(.system(size: 11, weight: .heavy, design: .rounded))
                                .foregroundStyle(.secondary)
                                .tracking(1.0)
                        }
                        
                        Text(value)
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundStyle(.primary)
                    }
                }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    WetterDetailView(event: .perfekt)
}
