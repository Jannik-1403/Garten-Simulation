import SwiftUI
import Combine

struct MultiStrangCanvas: View {
    let verschmelzungen: [PfadVerschmelzung]
    @Binding var ausgewaehlterTag: PfadStrangTag?
    let selectedDay: Int
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var pfadStore: GartenPfadStore
    @EnvironmentObject var gardenStore: GardenStore
    let dynamicScale: CGFloat
    /// When set, only this plant's strand is displayed (Verlauf-Tab mode)
    var filterHabit: HabitModel? = nil

    private let grassBackground = Color(hex: "#E8F5E9")
    
    // Basis-Maße
    private let blockBaseSize: CGFloat = 280 // Larger to fit bigger nodes
    private let nodeSize: CGFloat = 115     // Up from 96
    private let hNodeSpacing: CGFloat = 180 // Up from 160
    private let laneWidth: CGFloat = 180    // Up from 160
    private let vNodeSpacingInside: CGFloat = 145 // Up from 120
    private let vGroupSpacing: CGFloat = 50 // Up from 40

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var content: some View {
        // When filtering for a single habit, compute groups locally
        // (avoids touching the shared pfadStore.focusedPflanzenID state)
        let straenge = pfadStore.straenge
        let groups: [[Int]]
        
        if let filter = filterHabit {
            // Suche zuerst nach Instanz-ID, dann nach Typ-ID, dann nach Name als letzter Fallback
            let idx = straenge.firstIndex(where: { $0.pflanzenID == filter.id })
                   ?? straenge.firstIndex(where: { $0.pflanzenName == filter.name })
            
            if let found = idx {
                groups = [[found]]
            } else {
                groups = [] // Spinner bleibt, aber onAppear repariert es (siehe unten)
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
                            Text(String(localized: "canvas.show_all"))
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

                if groups.isEmpty && filterHabit != nil {
                    VStack(spacing: 16) {
                        ProgressView()
                            .tint(.orangePrimary)
                            .scaleEffect(1.2)
                    }
                    .padding(.top, 100)
                } else {
                    VStack(spacing: vGroupSpacing * dynamicScale) {
                        ForEach(groups, id: \.self) { indices in
                            groupRow(indices: indices, scale: dynamicScale)
                        }
                    }
                }
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
        let straenge = pfadStore.straenge
        let alleTags = pfadStore.alleTags  // Direkt gefetchte Tags — kein Lazy-Loading
        VStack(spacing: (vNodeSpacingInside - nodeSize) * scale) {
            ForEach(Array(slices.indices), id: \.self) { r in
                let rowIndices = slices[r]
                
                HStack(spacing: (hNodeSpacing - nodeSize) * scale) {
                    ForEach(rowIndices, id: \.self) { idx in
                        if let strang = straenge[safe: idx],
                           let t = alleTags.first(where: {
                               $0.strang?.id == strang.id && $0.tagNummer == selectedDay
                           }) {
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
            // Flower Layer
            flowersLayer(indices: indices, width: groupWidth, height: groupHeight, scale: scale)

            renderGrid(indices: indices, buckets: buckets, scale: scale)
                .offset(y: -25 * scale) // Pulled up significantly to prevent bottom labels from clipping
        }
    }
    
    private func flowersLayer(indices: [Int], width: CGFloat, height: CGFloat, scale: CGFloat) -> some View {
        let straenge = pfadStore.straenge
        let alleTags = pfadStore.alleTags
        return ZStack {
            ForEach(indices, id: \.self) { idx in
                if let strang = straenge[safe: idx],
                   let t = alleTags.first(where: {
                       $0.strang?.id == strang.id && $0.tagNummer == selectedDay
                   }),
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
            
            VStack(spacing: 8) {
                Text(String(format: String(localized: "common.day_format"), String(selectedDay)))
                    .font(.system(size: 32 * min(1.0, scale * 1.2), weight: .black, design: .rounded))
                    .foregroundColor(.black)
                
                if let habit = filterHabit {
                    HStack(spacing: 6) {
                        ForEach(0..<habit.maxChallengeJokers, id: \.self) { i in
                            Image(systemName: i < habit.challengeJokers ? "shield.fill" : "shield")
                                .foregroundColor(i < habit.challengeJokers ? Color.blauPrimary : .gray.opacity(0.4))
                                .font(.system(size: 16 * scale))
                                .shadow(radius: i < habit.challengeJokers ? 2 : 0)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.8), in: Capsule())
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 0)
        .padding(.bottom, 30)
    }

    private func isTagActionable(tag: PfadStrangTag, strang: PfadStrang) -> Bool {
        if tag.istErledigt { return false }
        let strangTags = pfadStore.alleTags
            .filter { $0.strang?.id == strang.id }
            .sorted(by: { $0.tagNummer < $1.tagNummer })
        guard let firstIncomplete = strangTags.first(where: { !$0.istErledigt }) else { return false }
        
        if tag.id == firstIncomplete.id {
            if tag.tagNummer > 1,
               let prevTag = strangTags.first(where: { $0.tagNummer == tag.tagNummer - 1 }) {
                if let cd = prevTag.datum, Calendar.current.isDateInToday(cd) {
                    return false
                }
            }
            return true
        }
        return false
    }

    private func calculateProgress(for day: Int) -> Double {
        let thresholds: [Int]
        // Default to anfaenger for this calculation to avoid fixed switch warning
        thresholds = [1, 20, 45, 65, 80, 91]
        
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



}
