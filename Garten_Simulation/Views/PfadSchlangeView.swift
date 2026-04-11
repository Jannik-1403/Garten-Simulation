import SwiftUI

struct PfadSchlangeView: View {
    let pfadTage: [PfadTag]
    let aktuellerTagIndex: Int
    @Binding var ausgewaehlterTag: PfadTag?
    
    // Abstände
    private let nodeAbstand: CGFloat = 90        // Vertikaler Abstand zwischen Nodes
    private let nodeGroesse: CGFloat = 64         // Normaler Node-Durchmesser
    private let meilensteinGroesse: CGFloat = 82  // Meilenstein-Node-Durchmesser
    private let seitenRand: CGFloat = 44          // Abstand vom Bildschirmrand
    
    // Für jeden Tag ein gedrueckt-State (Fix 1)
    @State private var gedruecktStates: [Int: Bool] = [:]
    
    var body: some View {
        GeometryReader { geo in
            let breite = geo.size.width
            let mitte = breite / 2
            let links = seitenRand + nodeGroesse / 2
            let rechts = breite - seitenRand - nodeGroesse / 2
            
            ZStack {
                // 1. Verbindungslinien
                if !pfadTage.isEmpty {
                    ForEach(0..<pfadTage.count - 1, id: \.self) { i in
                        let posA = nodePosition(index: i, links: links, rechts: rechts, mitte: mitte)
                        let posB = nodePosition(index: i + 1, links: links, rechts: rechts, mitte: mitte)
                        
                        VerbindungslinieView(
                            von: posA,
                            nach: posB,
                            istErledigt: pfadTage[i].istErledigt
                        )
                    }
                }
                
                // 2. Nodes
                ForEach(pfadTage) { tag in
                    let index = tag.tagNummer - 1
                    let pos = nodePosition(index: index, links: links, rechts: rechts, mitte: mitte)
                    let istHeute = index == aktuellerTagIndex
                    
                    let gedrueckt = Binding(
                        get: { gedruecktStates[tag.tagNummer] ?? false },
                        set: { gedruecktStates[tag.tagNummer] = $0 }
                    )
                    
                    PfadNodeView(
                        tag: tag,
                        istHeute: istHeute,
                        groesse: tag.istMeilenstein ? meilensteinGroesse : nodeGroesse,
                        gedrueckt: gedrueckt
                    )
                    .position(x: pos.x, y: pos.y)
                    .id(index)
                    // TAP NUR HIER (Zentraler Fix für Conflict)
                    .onTapGesture {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        // 1. Visuelle Animation starten
                        gedruecktStates[tag.tagNummer] = true
                        // 2. Nach Animation: Sheet öffnen
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            gedruecktStates[tag.tagNummer] = false
                            ausgewaehlterTag = tag
                        }
                    }
                    
                    // 3. Phase-Divider (Fix 2: Kompakt und neben dem Node)
                    if tag.istMeilenstein, let naechste = naechstePhase(nach: tag) {
                        PfadPhaseDivider(
                            phase: naechste,
                            xPosition: pos.x,
                            canvasBreite: breite
                        )
                        .position(x: breite / 2, y: pos.y + 55)
                    }
                }
            }
        }
    }
    
    // Helper um die logisch nächste Phase zu finden
    private func naechstePhase(nach tag: PfadTag) -> PfadPhase? {
        switch tag.tagNummer {
        case 14: return .aufbau
        case 30: return .vertiefung
        case 60: return .meisterschaft
        default: return nil
        }
    }
    
    private func nodePosition(index: Int, links: CGFloat, rechts: CGFloat, mitte: CGFloat) -> CGPoint {
        let y = CGFloat(index) * nodeAbstand + 100
        let xOffset = sin(Double(index) * .pi / 2.5)
        let x = mitte + CGFloat(xOffset) * (mitte - links) * 1.0
        return CGPoint(x: x, y: y)
    }
}

struct VerbindungslinieView: View {
    let von: CGPoint
    let nach: CGPoint
    let istErledigt: Bool
    
    var body: some View {
        Path { path in
            path.move(to: von)
            let kontrollPunkt = CGPoint(
                x: (von.x + nach.x) / 2,
                y: (von.y + nach.y) / 2
            )
            path.addQuadCurve(to: nach, control: kontrollPunkt)
        }
        .stroke(
            istErledigt
                ? Color(hex: "#58CC02").opacity(0.7)
                : Color(uiColor: .systemGray4),
            style: StrokeStyle(
                lineWidth: istErledigt ? 5 : 4,
                dash: istErledigt ? [] : [10, 7]
            )
        )
    }
}

struct PfadPhaseDivider: View {
    @EnvironmentObject var settings: SettingsStore
    let phase: PfadPhase
    let xPosition: CGFloat    // X-Position des zugehörigen Nodes
    let canvasBreite: CGFloat
    
    private var istLinkeSeite: Bool {
        xPosition < canvasBreite / 2
    }
    
    var body: some View {
        HStack(spacing: 6) {
            if istLinkeSeite {
                // Node ist links → Divider zeigt nach rechts
                phasePill
                Spacer()
            } else {
                // Node ist rechts → Divider zeigt nach links
                Spacer()
                phasePill
            }
        }
        .padding(.horizontal, 24)
    }
    
    private var phasePill: some View {
        HStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 2)
                .fill(phase.farbe)
                .frame(width: 3, height: 20)
            
            Text(settings.localizedString(for: "pfad_phase_" + phase.rawValue).uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(phase.farbe)
                .tracking(1.2)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
    }
}
