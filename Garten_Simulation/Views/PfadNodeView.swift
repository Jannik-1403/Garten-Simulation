import SwiftUI

struct PfadNodeView: View {
    let tag: PfadTag
    let istHeute: Bool
    let groesse: CGFloat
    
    @Binding var gedrueckt: Bool
    @EnvironmentObject var settings: SettingsStore
    
    var body: some View {
        let shadowDepth: CGFloat = 4
        
        ZStack {
            // 3D UNTERER LAYER (Schatten/Tiefe) — Bleibt statisch als Basis
            Circle()
                .fill(untereFarbe)
                .frame(width: groesse, height: groesse)

            // 3D OBERER LAYER (eigentlicher Button) — Schwebt standardmäßig oben
            Circle()
                .fill(obereFarbe)
                .frame(width: groesse, height: groesse)
                .offset(y: gedrueckt ? 0 : -shadowDepth)
                .overlay {
                    // Innerer Glanz oben
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(glanzOpacity), .clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .frame(width: groesse, height: groesse)
                }
                .overlay {
                    // Icon
                    nodeIcon
                        .font(.system(size: groesse * 0.36, weight: .bold))
                        .foregroundColor(ikonFarbe)
                }
        }
        .frame(width: groesse, height: groesse)
        // Meilenstein-Badge oben rechts
        .overlay(alignment: .topTrailing) {
            if tag.istMeilenstein && !tag.istErledigt {
                ZStack {
                    Circle()
                        .fill(Color.goldPrimary)
                        .frame(width: 22, height: 22)
                    Image(systemName: "star.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                }
                .offset(x: 4, y: -4)
            }
        }
        // Tag-Nummer direkt unter Node, zentriert
        .overlay(alignment: .bottom) {
            let headerPattern = settings.localizedString(for: "pfad_tag_header")
            Text(String(format: headerPattern, tag.tagNummer))
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(istHeute ? .blauPrimary : .secondary)
                .fixedSize()
                .offset(y: groesse / 2 + 10)
        }
        // Identisch zum Item3DButton Animation-Style
        .animation(.spring(response: 0.22, dampingFraction: 0.5, blendDuration: 0), value: gedrueckt)
        .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.8), trigger: gedrueckt)
    }

    @ViewBuilder
    private var nodeIcon: some View {
        if let plantID = tag.pflanzenIDs.first,
           let plant = GameDatabase.allPlants.first(where: { $0.id == plantID }),
           let assetName = plant.assetName {
            
            ZStack {
                // Das Pflanzen-Asset als Basis-Icon
                Image(assetName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: groesse * 0.65, height: groesse * 0.65)
                    .grayscale(tag.istErledigt || istHeute ? 0 : 1.0)
                    .opacity(tag.istErledigt || istHeute ? 1.0 : 0.6)
                
                // Status-Overlay
                if tag.istErledigt {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: groesse * 0.25, weight: .bold))
                        .foregroundColor(.white)
                        .background(Circle().fill(Color(hex: "#58CC02")))
                        .offset(x: groesse * 0.2, y: groesse * 0.2)
                } else if istHeute {
                    Image(systemName: "flame.fill")
                        .font(.system(size: groesse * 0.25, weight: .bold))
                        .foregroundColor(.orange)
                        .offset(x: groesse * 0.2, y: groesse * 0.2)
                        .shadow(color: .orange.opacity(0.8), radius: 4)
                } else if !tag.istErledigt && !istHeute && !tag.istMeilenstein {
                    Image(systemName: "lock.fill")
                        .font(.system(size: groesse * 0.2, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        } else {
            // Fallback auf System-Icons falls kein Asset gefunden wurde
            if tag.istErledigt {
                Image(systemName: "checkmark")
            } else if istHeute {
                Image(systemName: "flame.fill")
            } else if tag.istMeilenstein {
                Image(systemName: "star.fill")
            } else {
                Image(systemName: "lock.fill")
            }
        }
    }

    // FARBEN — oberer Layer
    private var obereFarbe: Color {
        if tag.istErledigt { return Color(hex: "#58CC02") }        // Duolingo-Grün
        if istHeute        { return Color.blauPrimary }
        if tag.istMeilenstein { return Color(hex: "#FFD700") }     // Gold
        return Color(uiColor: .systemGray4)
    }

    // FARBEN — unterer Layer (dunkler = Tiefeneffekt)
    private var untereFarbe: Color {
        if tag.istErledigt { return Color(hex: "#46A302") }
        if istHeute        { return Color.blauPrimary.opacity(0.6) }
        if tag.istMeilenstein { return Color(hex: "#C8A800") }
        return Color(uiColor: .systemGray3)
    }

    private var ikonFarbe: Color {
        if tag.istErledigt || istHeute || tag.istMeilenstein { return .white }
        return Color(uiColor: .systemGray2)
    }

    private var glanzOpacity: Double {
        if tag.istErledigt || istHeute || tag.istMeilenstein { return 0.25 }
        return 0.1
    }
}
