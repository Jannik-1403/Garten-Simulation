import SwiftUI

struct EffektDetailSheet: View {
    let effekt: PflanzenEffekt

    var body: some View {
        let (typeTitle, typeIcon): (String, String) = {
            switch effekt.typ {
            case .wetter:  
                return (NSLocalizedString("effekt.typ.wetter", comment: ""), "cloud.fill")
            case .powerUp: 
                return (NSLocalizedString("effekt.typ.powerup", comment: ""), "bolt.fill")
            case .status:  
                return (NSLocalizedString("effekt.typ.status", comment: ""), "info.circle.fill")
            }
        }()

        VStack(spacing: 16) {
            Spacer().frame(height: 8)

            Group {
                switch effekt.ikonQuelle {
                case .system(let name):
                    Image(systemName: name)
                        .font(.system(size: 38, weight: .semibold))
                        .foregroundStyle(effekt.typ.ikonFarbe)
                case .asset(let name):
                    Image(name)
                        .resizable()
                        .scaledToFit()
                        .padding(14)
                }
            }
            .frame(width: 76, height: 76)
            .background(Circle().fill(effekt.typ.hintergrundFarbe))
            .overlay(Circle().stroke(effekt.typ.rahmenFarbe, lineWidth: 1.5))

            Text(effekt.titel)
                .font(.title2.bold())

            Text(effekt.beschreibung)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)

            if let expiresAt = effekt.expiresAt {
                HStack(spacing: 6) {
                    Image(systemName: "timer")
                    Text(expiresAt, style: .timer)
                        .font(.system(.subheadline, design: .monospaced).bold())
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(Capsule().fill(Color.primary.opacity(0.05)))
            }

            HStack(spacing: 8) {
                Label(
                    typeTitle,
                    systemImage: typeIcon
                )
                .font(.caption.bold())
                .foregroundStyle(effekt.typ.ikonFarbe)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(Capsule().fill(effekt.typ.hintergrundFarbe))
                
                if effekt.expiresAt != nil {
                    Text(NSLocalizedString("common.active", comment: ""))
                        .font(.system(size: 10, weight: .black))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(effekt.typ.ikonFarbe)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
