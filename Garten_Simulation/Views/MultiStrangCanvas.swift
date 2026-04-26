import SwiftUI
import Combine

struct MultiStrangCanvas: View {
    let straenge: [PfadStrang]
    let verschmelzungen: [PfadVerschmelzung]
    @Binding var ausgewaehlterTag: PfadStrangTag?
    let selectedDay: Int
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var pfadStore: GartenPfadStore
    let dynamicScale: CGFloat
    /// When set, only this plant's strand is displayed (Verlauf-Tab mode)
    var filterHabit: HabitModel? = nil

    private let grassBackground = Color(hex: "#E8F5E9")
    private let ackerBraun = Color(hex: "#C68252") 
    
    // Basis-Maße
    private let blockBaseSize: CGFloat = 280 // Larger to fit bigger nodes
    private let nodeSize: CGFloat = 115     // Up from 96
    private let hNodeSpacing: CGFloat = 180 // Up from 160
    private let laneWidth: CGFloat = 180    // Up from 160
    private let vNodeSpacingInside: CGFloat = 145 // Up from 120
    private let vGroupSpacing: CGFloat = 50 // Up from 40

    var body: some View {
        GeometryReader { geo in
            content
                .frame(minHeight: geo.size.height, alignment: .top)
        }
    }

    private var content: some View {
        // When filtering for a single habit, compute groups locally
        // (avoids touching the shared pfadStore.focusedPflanzenID state)
        let groups: [[Int]]
        if let filter = filterHabit {
            if let idx = straenge.firstIndex(where: { $0.pflanzenID == filter.plantID }) {
                groups = [[idx]]
            } else {
                groups = []
            }
        } else {
            groups = pfadStore.getGroups(forDay: selectedDay)
        }
        let dynamicScale = calculateDynamicScale(for: groups)

        return ZStack(alignment: .top) {
            // MARK: - Acker (Field) Grid Background
            ZStack {
                LinearGradient(
                    colors: [Color.green.opacity(0.01), Color.brown.opacity(0.01)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            .ignoresSafeArea()

            // Content — always anchored to top
            VStack(spacing: 0) {
                // "Show all" back button — only relevant on the global path tab, not in embedded mode
                if pfadStore.focusedPflanzenID != nil && filterHabit == nil {
                    Button {
                        withAnimation {
                            pfadStore.focusedPflanzenID = nil
                        }
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Alle Gewohnheiten anzeigen")
                        }
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: Capsule())
                    }
                    .padding(.top, 100)
                    .zIndex(100)
                }

                dayHeaderView(scale: dynamicScale)

                VStack(spacing: vGroupSpacing * dynamicScale) {
                    if groups.isEmpty {
                        Text("No habits found")
                            .padding()
                    } else {
                        ForEach(groups, id: \.self) { indices in
                            groupRow(indices: indices, scale: dynamicScale)
                        }
                    }
                }

                Spacer(minLength: 120 * dynamicScale)
            }
            .frame(maxWidth: .infinity, alignment: .top)
        }
    }

    private func calculateDynamicScale(for groups: [[Int]]) -> CGFloat {
        var maxColsInView = 1
        for indices in groups {
            let buckets = getRowBuckets(for: indices.count)
            let cols = buckets.max() ?? 1
            maxColsInView = max(maxColsInView, cols)
        }
        
        // Wenn mehr als 3 Spalten nebeneinander stehen, skalieren wir alles runter
        if maxColsInView > 3 {
            return 3.0 / CGFloat(maxColsInView)
        }
        return 1.0 * dynamicScale // Nutze die übergebene Basis-Skalierung
    }

    private func getRowBuckets(for n: Int) -> [Int] {
        switch n {
        case 1: return [1]
        case 2: return [2]
        case 3: return [2, 1] // Dreieck
        case 4: return [2, 2] // Viereck
        case 5: return [2, 2, 1] // Viereck + 1
        case 6: return [3, 3] // 2x3
        default:
            // Fallback für n > 6: 3er Reihen
            let rows = Int(ceil(Double(n) / 3.0))
            var res: [Int] = []
            var remaining = n
            for _ in 0..<rows {
                let take = min(remaining, 3)
                res.append(take)
                remaining -= take
            }
            return res
        }
    }

    // MARK: - Layout Helpers
    
    private func getRowSlices(indices: [Int], buckets: [Int]) -> [[Int]] {
        var slices: [[Int]] = []
        var current = 0
        for b in buckets {
            let slice = Array(indices[current..<min(current + b, indices.count)])
            slices.append(slice)
            current += b
        }
        return slices
    }

    @ViewBuilder
    private func renderGrid(indices: [Int], buckets: [Int], scale: CGFloat) -> some View {
        let slices = getRowSlices(indices: indices, buckets: buckets)
        VStack(spacing: (vNodeSpacingInside - nodeSize) * scale) {
            ForEach(0..<slices.count, id: \.self) { r in
                let rowIndices = slices[r]
                
                HStack(spacing: (hNodeSpacing - nodeSize) * scale) {
                    ForEach(rowIndices, id: \.self) { idx in
                        if let strang = straenge[safe: idx],
                           let t = strang.tags.first(where: { $0.tagNummer == selectedDay }) {
                            SingleHabitNode(
                                tag: t,
                                strang: strang,
                                groesse: nodeSize * scale,
                                istHeute: isTagActionable(tag: t, strang: strang),
                                progress: calculateProgress(for: selectedDay),
                                action: { ausgewaehlterTag = t }
                            )
                        }
                    }
                }
            }
        }
    }
    
    // Die bereinigte groupLayout Methode:
    @ViewBuilder
    private func groupRow(indices: [Int], scale: CGFloat) -> some View {
        let n = indices.count
        let buckets = getRowBuckets(for: n)
        let rows = buckets.count
        let maxCols = buckets.max() ?? 1
        
        let groupWidth = (CGFloat(maxCols - 1) * hNodeSpacing + blockBaseSize) * scale
        let groupHeight = (CGFloat(rows - 1) * vNodeSpacingInside + blockBaseSize) * scale
        
        ZStack {
            Canvas { context, size in
                draw3DBlock(context: context, at: CGPoint(x: size.width/2, y: size.height/2), width: groupWidth, height: groupHeight, color: ackerBraun, scale: scale)
            }
            .frame(width: groupWidth, height: groupHeight + 10 * scale)
            
            // Flower Layer
            flowersLayer(indices: indices, width: groupWidth, height: groupHeight, scale: scale)

            renderGrid(indices: indices, buckets: buckets, scale: scale)
                .offset(y: -25 * scale) // Pulled up significantly to prevent bottom labels from clipping
        }
    }
    
    @ViewBuilder
    private func flowersLayer(indices: [Int], width: CGFloat, height: CGFloat, scale: CGFloat) -> some View {
        ZStack {
            ForEach(indices, id: \.self) { idx in
                if let strang = straenge[safe: idx],
                   let t = strang.tags.first(where: { $0.tagNummer == selectedDay }),
                   t.istErledigt {
                    // Sprout flowers around the completed plant
                    ForEach(0..<3, id: \.self) { fIdx in
                        let flowerColor = Color(hex: strang.farbe)
                        // Use a deterministic hash for stable positions
                        let seed = idx + fIdx * 10 
                        let dx = CGFloat((seed * 17) % 50 - 25)
                        let dy = CGFloat((seed * 23) % 50 - 25)
                        
                        Image(systemName: "flower.fill")
                            .font(.system(size: 10 * scale))
                            .foregroundColor(flowerColor.opacity(0.6))
                            .offset(x: dx * scale, y: dy * scale)
                            .shadow(radius: 1)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func dayHeaderView(scale: CGFloat) -> some View {
        HStack {
            Spacer()
            
            VStack(spacing: 0) {
                Text("Tag \(selectedDay)")
                    .font(.system(size: 32 * min(1.0, scale * 1.2), weight: .black, design: .rounded))
                    .foregroundColor(.black)
                
                // Wir haben kein globales "HEUTE" mehr, weil jeder Strang einzeln fortschreitet
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 0)
        .padding(.bottom, 30)
    }

    private func isTagActionable(tag: PfadStrangTag, strang: PfadStrang) -> Bool {
        if tag.istErledigt { return false }
        let alleTags = strang.tags.sorted(by: { $0.tagNummer < $1.tagNummer })
        guard let firstIncomplete = alleTags.first(where: { !$0.istErledigt }) else { return false }
        
        if tag.id == firstIncomplete.id {
            if tag.tagNummer > 1, let prevTag = alleTags.first(where: { $0.tagNummer == tag.tagNummer - 1 }) {
                if let cd = prevTag.datum, Calendar.current.isDateInToday(cd) {
                    return false
                }
            }
            return true
        }
        return false
    }

    private func calculateProgress(for day: Int) -> Double {
        let diff = PfadSchwierigkeit.anfaenger
        let thresholds: [Int]
        switch diff {
        case .anfaenger:       thresholds = [1, 20, 45, 65, 80, 91]
        case .fortgeschritten: thresholds = [1, 14, 30, 50, 70, 91]
        case .experte:         thresholds = [1, 7, 21, 35, 50, 91]
        }
        
        var start = 1
        var end = 90
        for i in 0..<thresholds.count-1 {
            if day >= thresholds[i] && day < thresholds[i+1] {
                start = thresholds[i]
                end = thresholds[i+1]
                break
            }
        }
        return Double(day - start) / Double(max(1, end - start))
    }

    private func draw3DBlock(context: GraphicsContext, at: CGPoint, width: CGFloat, height: CGFloat, color: Color, scale: CGFloat) {
        let depth: CGFloat = 8 * scale
        let radius: CGFloat = 20 * scale // Merging nodes, so we need more roundness
        
        // Organic uneven path instead of RoundedRectangle
        var path = Path()
        let rect = CGRect(x: at.x - width/2, y: at.y - height/2, width: width, height: height)
        
        // Custom 'Wobble' for organic look
        path.addRoundedRect(in: rect, cornerSize: CGSize(width: radius, height: radius))
        
        // Shadow / Depth
        context.fill(path.offsetBy(dx: 0, dy: depth), with: .color(color.darker(by: 0.2)))
        
        // Main Surface
        context.fill(path, with: .color(color))
        
        // Soil Texture (Grain)
        for _ in 0..<Int(width * height / 100) {
            let px = CGFloat.random(in: rect.minX...rect.maxX)
            let py = CGFloat.random(in: rect.minY...rect.maxY)
            let size = CGFloat.random(in: 1...2) * scale
            context.fill(Path(ellipseIn: CGRect(x: px, y: py, width: size, height: size)), with: .color(Color.black.opacity(0.08)))
        }
        
        context.stroke(path, with: .color(Color.black.opacity(0.1)), style: StrokeStyle(lineWidth: 1))
    }


}
