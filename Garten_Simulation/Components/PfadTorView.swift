import SwiftUI

struct PfadTorView: View {
    let phase: PfadPhase
    let breite: CGFloat
    @EnvironmentObject var settings: SettingsStore

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                Rectangle()
                    .fill(phase.farbe.opacity(0.3))
                    .frame(height: 2)
                
                HStack(spacing: 8) {
                    Image(systemName: phaseIcon)
                        .font(.system(size: 14, weight: .bold))
                    Text(settings.localizedString(for: "pfad_phase_" + phase.rawValue).uppercased())
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .tracking(1.5)
                }
                .foregroundColor(phase.farbe)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(phase.farbe.opacity(0.1))
                        .overlay(Capsule().stroke(phase.farbe.opacity(0.2), lineWidth: 1))
                )

                Rectangle()
                    .fill(phase.farbe.opacity(0.3))
                    .frame(height: 2)
            }
            .frame(width: breite * 0.9)
        }
    }
    
    private var phaseIcon: String {
        switch phase {
        case .einstieg: return "seedling.fill"
        case .aufbau: return "leaf.fill"
        case .vertiefung: return "sparkles"
        case .meisterschaft: return "trophy.fill"
        }
    }
}
