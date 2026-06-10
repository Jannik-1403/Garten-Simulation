import SwiftUI

struct EffektDetailSheet: View {
    let effekt: PflanzenEffekt
    @EnvironmentObject var settings: SettingsStore

    var body: some View {
        let (typeTitle, typeIcon): (String, String) = {
            switch effekt.typ {
            case .wetter:  
                return (settings.localizedString(for: "effekt.typ.wetter"), "cloud.fill")
            case .powerUp: 
                return (settings.localizedString(for: "effekt.typ.powerup"), "bolt.fill")
            case .status:  
                return (settings.localizedString(for: "effekt.typ.status"), "info.circle.fill")
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
                        .frame(width: 76, height: 76)
                }
            }
            .frame(width: 76, height: 76)

            Text(effekt.titel)
                .font(.title2.bold())

            Text(effekt.beschreibung)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)

            if let expiresAt = effekt.expiresAt {
                HStack(spacing: 6) {
                    Image("Timer half")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
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
                
                if effekt.expiresAt != nil {
                    Text(settings.localizedString(for: "common.active"))
                        .font(.system(size: 10, weight: .black))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .foregroundStyle(effekt.typ.ikonFarbe)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
