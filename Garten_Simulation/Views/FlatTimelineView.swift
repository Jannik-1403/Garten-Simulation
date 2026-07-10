import SwiftUI

// MARK: - FlatTimelineView
struct FlatTimelineView: View {
    @ObservedObject var habit: HabitModel
    @Environment(\.colorScheme) var colorScheme

    private let totalDays = 90
    private let milestones = Set([7, 14, 21, 30, 45, 60, 90])

    @State private var expandedWeek: Int? = nil
    @State private var selectedDay: SelectedDay? = nil

    struct SelectedDay: Identifiable {
        let id = UUID()
        let index: Int
    }

    private var totalWeeks: Int { (totalDays + 6) / 7 }

    private var firstUnwateredIndex: Int {
        let calendar = Calendar.current
        let checkedDays = Set(habit.pfadCheckedDates.map { calendar.startOfDay(for: $0) })
        let start = habit.pfadAktiviertAm ?? Date()
        return (0..<totalDays).first { i in
            let date = calendar.date(byAdding: .day, value: i, to: start) ?? Date()
            return !checkedDays.contains(calendar.startOfDay(for: date))
        } ?? (totalDays - 1)
    }

    var body: some View {
        if habit.pfadAktiviertAm == nil {
            PfadActivationOverlay(habit: habit)
        } else {
            ZStack(alignment: .top) {
                LinearGradient(
                    colors: colorScheme == .dark
                        ? [Color(hex: "#0f1923"), Color(hex: "#1a2638")]
                        : [Color(hex: "#e8f0f7"), Color(hex: "#d4e4f0")],
                    startPoint: .top, endPoint: .bottom
                ).ignoresSafeArea()

                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 36) {
                            Color.clear.frame(height: 110)
                            ForEach(0..<totalWeeks, id: \.self) { weekIndex in
                                WeekRingView(
                                    weekIndex: weekIndex,
                                    habit: habit,
                                    firstUnwateredIndex: firstUnwateredIndex,
                                    expandedWeek: $expandedWeek,
                                    onSelectDay: { dayIndex in
                                        selectedDay = SelectedDay(index: dayIndex)
                                    }
                                )
                                .id(weekIndex)
                            }
                            Color.clear.frame(height: 60)
                        }
                    }
                    .onAppear {
                        let currentWeek = firstUnwateredIndex / 7
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                proxy.scrollTo(currentWeek, anchor: .center)
                            }
                        }
                    }
                }
                headerOverlay
            }
            .fullScreenCover(item: $selectedDay) { item in
                PfadTagDetailView(tag: makeFakePfadStrangTag(index: item.index))
            }
        }
    }

    private var headerOverlay: some View {
        let diffEnum = PfadSchwierigkeit(rawValue: habit.individualSchwierigkeit ?? "") ?? .anfaenger
        return VStack(spacing: 0) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(diffEnum.farbe.opacity(0.55))
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(diffEnum.farbe)
                        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.white.opacity(0.25), lineWidth: 1))
                        .overlay {
                            HStack(spacing: 5) {
                                Image(systemName: diffEnum.icon).font(.system(size: 13, weight: .bold))
                                Text(NSLocalizedString(diffEnum.titelKey, comment: ""))
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white).padding(.horizontal, 12)
                        }
                        .offset(y: -4)
                }.frame(height: 44)
                Spacer()
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color(hex: "#111d2e"))
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(hex: "#1e2d42"))
                        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.white.opacity(0.12), lineWidth: 1))
                        .overlay {
                            HStack(spacing: 6) {
                                ForEach(0..<habit.maxChallengeJokers, id: \.self) { i in
                                    Image(systemName: i < habit.challengeJokers ? "shield.fill" : "shield")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(i < habit.challengeJokers ? Color(hex: "#58CC02") : Color.white.opacity(0.2))
                                }
                            }.padding(.horizontal, 14)
                        }
                        .offset(y: -4)
                }.frame(height: 44)
            }
            .padding(.horizontal, 20).padding(.top, 60).padding(.bottom, 20)
            .background(LinearGradient(
                colors: colorScheme == .dark
                    ? [Color(hex: "#0f1923"), Color(hex: "#0f1923").opacity(0)]
                    : [Color(hex: "#e8f0f7"), Color(hex: "#e8f0f7").opacity(0)],
                startPoint: .top, endPoint: .bottom
            ))
            Spacer()
        }
    }

    private func makeFakePfadStrangTag(index: Int) -> PfadStrangTag {
        let tag = PfadStrangTag(
            tagNummer: index + 1, titelKey: "Tag \(index + 1)", beschreibungKey: "Beschreibung",
            istErledigt: index < firstUnwateredIndex, istMeilenstein: milestones.contains(index + 1)
        )
        let strang = PfadStrang(pflanzenID: habit.id, farbe: "#58CC02", istAktiv: true, reihenfolgeIndex: 0)
        tag.strang = strang
        return tag
    }
}

// MARK: - WeekRingView
struct WeekRingView: View {
    let weekIndex: Int
    @ObservedObject var habit: HabitModel
    let firstUnwateredIndex: Int
    @Binding var expandedWeek: Int?
    var onSelectDay: (Int) -> Void
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("isHapticEnabled") private var isHapticEnabled: Bool = true

    private let ringRadius: CGFloat = 80
    private let nodeSize: CGFloat = 38
    private let nodeLastSize: CGFloat = 48
    private let lineSpacing: CGFloat = 68
    private let coinDepth: CGFloat = 14    // Tiefer 3D-Effekt

    @State private var expandProgress: CGFloat = 0
    @State private var isCollapsing: Bool = false

    private var isExpanded: Bool { expandedWeek == weekIndex }

    var dayIndices: [Int] {
        let start = weekIndex * 7
        let end = min(start + 7, 90)
        return Array(start..<end)
    }

    private var weekCompletedCount: Int { dayIndices.filter { $0 < firstUnwateredIndex }.count }
    private var weekIsFullyDone: Bool { weekCompletedCount == dayIndices.count }
    private var weekIsCurrent: Bool { dayIndices.contains(firstUnwateredIndex) }

    // Disk-Farben: gleich wie Item3DButton Charakter-Profil
    private var diskTopColor: Color {
        weekIsFullyDone ? Color(hex: "#58CC02")
            : weekIsCurrent ? Color(hex: "#FF9600")
            : colorScheme == .dark ? Color(hex: "#1e2d42") : Color(hex: "#ccdaeb")
    }
    private var diskSideColor: Color {
        weekIsFullyDone ? Color(hex: "#3a8000")
            : weekIsCurrent ? Color(hex: "#a85e00")
            : colorScheme == .dark ? Color(hex: "#0d1520") : Color(hex: "#8aaccc")
    }

    // Hintergrundfarbe für inaktive Nodes (= exakter Hintergrund)
    private var bgColor: Color {
        colorScheme == .dark ? Color(hex: "#0f1923") : Color(hex: "#e8f0f7")
    }

    // MARK: - Position math
    private func ringPos(index: Int, total: Int) -> CGPoint {
        let angle = (2 * Double.pi / Double(total)) * Double(index) - Double.pi / 2
        return CGPoint(x: cos(angle) * Double(ringRadius), y: sin(angle) * Double(ringRadius))
    }
    private func linePos(index: Int, total: Int) -> CGPoint {
        let totalH = CGFloat(total - 1) * lineSpacing
        return CGPoint(x: 0, y: CGFloat(index) * lineSpacing - totalH / 2)
    }
    private func currentPos(index: Int, total: Int) -> CGPoint {
        let rp = ringPos(index: index, total: total)
        let lp = linePos(index: index, total: total)
        let t = expandProgress
        let swing = index == total - 1 ? CGFloat(sin(Double(t) * Double.pi)) * -18 : 0
        return CGPoint(
            x: CGFloat(rp.x) + (lp.x - CGFloat(rp.x)) * t + swing,
            y: CGFloat(rp.y) + (lp.y - CGFloat(rp.y)) * t
        )
    }
    private func sizeFor(idx: Int, total: Int) -> CGFloat {
        idx == total - 1 ? nodeLastSize : nodeSize
    }

    private var frameHeight: CGFloat {
        let total = CGFloat(dayIndices.count)
        let collapsed = (ringRadius + CGFloat(coinDepth)) * 2 + 60
        let expanded = (total - 1) * lineSpacing + nodeLastSize + 100
        return collapsed + (expanded - collapsed) * expandProgress
    }

    // MARK: - Node colors
    private func nodeGradient(completed: Bool, current: Bool) -> LinearGradient {
        if completed {
            return LinearGradient(colors: [Color(hex: "#67dd10"), Color(hex: "#48aa00")], startPoint: .topLeading, endPoint: .bottomTrailing)
        } else if current {
            return LinearGradient(colors: [Color(hex: "#ffaa22"), Color(hex: "#e07800")], startPoint: .topLeading, endPoint: .bottomTrailing)
        } else {
            // Inaktiv = Hintergrundfarbe (unsichtbar im Ring)
            return colorScheme == .dark
                ? LinearGradient(colors: [Color(hex: "#0f1923"), Color(hex: "#0d1520")], startPoint: .topLeading, endPoint: .bottomTrailing)
                : LinearGradient(colors: [Color(hex: "#e8f0f7"), Color(hex: "#d4e4f0")], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
    private func nodeShadowCol(completed: Bool, current: Bool) -> Color {
        completed ? Color(hex: "#3a8000")
            : current ? Color(hex: "#a85e00")
            : colorScheme == .dark ? Color(hex: "#080d14") : Color(hex: "#b0c8e0")
    }
    private func nodeIconColor(completed: Bool, current: Bool) -> Color {
        if completed || current { return .white }
        return colorScheme == .dark ? Color(hex: "#0f1923") : Color(hex: "#e8f0f7") // icon same as bg = invisible
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            // 3D Disk (Item3DButton-Stil, wie Profil-Charakter)
            platformDisk
            // Expanded connector
            expandedConnector
            // Collapse button (Item3DButton)
            collapseButton
            // Nodes
            ForEach(Array(dayIndices.enumerated()), id: \.element) { idx, dayIndex in
                let total = dayIndices.count
                let pos = currentPos(index: idx, total: total)
                let completed = dayIndex < firstUnwateredIndex
                let current = dayIndex == firstUnwateredIndex
                dayNode(dayNumber: dayIndex + 1, dayIndex: dayIndex,
                        nodeIdx: idx, total: total,
                        completed: completed, current: current)
                    .offset(x: pos.x, y: pos.y)
                    .animation(
                        isCollapsing
                            // Langsam & zusammen beim Schließen
                            ? .spring(response: 0.90, dampingFraction: 0.88)
                            // Staggered beim Öffnen
                            : .spring(response: 0.50, dampingFraction: 0.72).delay(Double(idx) * 0.040),
                        value: expandProgress
                    )
                    .zIndex(Double(total - idx))
            }
            // Center label
            centerLabel
                .opacity(max(0, 1 - expandProgress * 2.5))
                .allowsHitTesting(false)
        }
        .frame(height: frameHeight)
        .animation(.spring(response: isCollapsing ? 0.9 : 0.52, dampingFraction: isCollapsing ? 0.88 : 0.76), value: frameHeight)
        .contentShape(Rectangle())
        .onTapGesture {
            if !isExpanded {
                haptic()
                withAnimation { expandedWeek = weekIndex }
            }
        }
        .onChange(of: isExpanded) { _, newValue in
            if newValue {
                isCollapsing = false
                withAnimation(.spring(response: 0.56, dampingFraction: 0.72)) { expandProgress = 1.0 }
            } else {
                isCollapsing = true
                withAnimation(.spring(response: 0.95, dampingFraction: 0.90)) { expandProgress = 0.0 }
                // Nach Ende der Animation isCollapsing zurücksetzen
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    isCollapsing = false
                }
            }
        }
        .onAppear { expandProgress = isExpanded ? 1.0 : 0.0 }
    }

    // MARK: - 3D Platform Disk (wie Profil-Charakter mit Item3DButton)
    private var platformDisk: some View {
        let diameter = ringRadius * 2 + 60  // Großer Hintergrund

        return ZStack {
            // Elliptischer Schatten unten (Perspektiv-Effekt)
            Ellipse()
                .fill(diskSideColor.opacity(colorScheme == .dark ? 0.6 : 0.35))
                .frame(width: diameter * 1.1, height: diameter * 0.22)
                .blur(radius: 16)
                .offset(y: diameter * 0.52)

            // Seite (unten = 3D-Kante sichtbar)
            Circle()
                .fill(diskSideColor)
                .overlay(Circle().stroke(Color.black.opacity(0.15), lineWidth: 1))
                .frame(width: diameter, height: diameter)

            // Top-Fläche (leicht nach oben versetzt — coinDepth)
            Circle()
                .fill(
                    LinearGradient(
                        colors: [diskTopColor.opacity(colorScheme == .dark ? 0.18 : 0.22),
                                 diskTopColor.opacity(colorScheme == .dark ? 0.06 : 0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Circle()
                        .stroke(diskTopColor.opacity(colorScheme == .dark ? 0.45 : 0.55), lineWidth: 2.5)
                )
                .frame(width: diameter, height: diameter)
                .offset(y: -coinDepth) // 3D-Tiefe wie Item3DButton
        }
        .opacity(max(0, 1 - expandProgress * 1.4))
    }

    // MARK: - Expanded 3D Connector
    private var expandedConnector: some View {
        let total = dayIndices.count
        guard total > 1 else { return AnyView(EmptyView()) }
        let h = CGFloat(total - 1) * lineSpacing
        let isActive = weekIsFullyDone
        let topC: Color = isActive ? Color(hex: "#58CC02") : bgColor
        let sideC: Color = isActive ? Color(hex: "#3a8000") : (colorScheme == .dark ? Color(hex: "#080d14") : Color(hex: "#b0c8e0"))

        return AnyView(
            ZStack {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(sideC)
                    .overlay(RoundedRectangle(cornerRadius: 5, style: .continuous).stroke(Color.black.opacity(0.10), lineWidth: 0.5))
                    .frame(width: 11, height: h)
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(topC)
                    .overlay(RoundedRectangle(cornerRadius: 5, style: .continuous).stroke(Color.white.opacity(isActive ? 0.18 : 0.0), lineWidth: 0.5))
                    .frame(width: 11, height: h)
                    .offset(x: -2, y: -3)
            }
            .opacity(max(0, (expandProgress - 0.42) * 2.0))
        )
    }

    // MARK: - Collapse Button als Item3DButton
    private var collapseButton: some View {
        let total = dayIndices.count
        let topNodeY = linePos(index: 0, total: total).y

        return Item3DButton(
            farbe: weekIsCurrent ? Color(hex: "#FF9600") : (weekIsFullyDone ? Color(hex: "#58CC02") : (colorScheme == .dark ? Color(hex: "#1e2d42") : Color(hex: "#8aaccc"))),
            sekundaerFarbe: weekIsCurrent ? Color(hex: "#a85e00") : (weekIsFullyDone ? Color(hex: "#3a8000") : (colorScheme == .dark ? Color(hex: "#0d1520") : Color(hex: "#5580a0"))),
            groesse: 38,
            shadowDepthFactor: 0.12,
            isRectangular: true,
            aktion: {
                haptic()
                isCollapsing = true
                withAnimation(.spring(response: 0.95, dampingFraction: 0.90)) {
                    expandedWeek = nil
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { isCollapsing = false }
            }
        ) {
            HStack(spacing: 5) {
                Image(systemName: "chevron.up")
                    .font(.system(size: 11, weight: .bold))
                Text(String(localized: "pfad.schliessen", defaultValue: "Schließen"))
                    .font(.system(size: 12, weight: .bold, design: .rounded))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 14)
        }
        .offset(y: topNodeY - nodeLastSize / 2 - 34)
        .opacity(max(0, (expandProgress - 0.65) * 2.8))
        .allowsHitTesting(expandProgress > 0.8)
    }

    // MARK: - Center Label (weiße Zahlen)
    private var centerLabel: some View {
        VStack(spacing: 5) {
            Text("\(weekIndex + 1)")
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
            HStack(spacing: 4) {
                ForEach(0..<dayIndices.count, id: \.self) { i in
                    Circle()
                        .fill(dayIndices[i] < firstUnwateredIndex ? Color.white : Color.white.opacity(0.22))
                        .frame(width: 5, height: 5)
                }
            }
        }
    }

    // MARK: - Day Node
    @ViewBuilder
    private func dayNode(dayNumber: Int, dayIndex: Int, nodeIdx: Int, total: Int, completed: Bool, current: Bool) -> some View {
        let size = sizeFor(idx: nodeIdx, total: total)
        let depth: CGFloat = size * 0.14

        Button(action: {
            if isExpanded {
                haptic()
                onSelectDay(dayIndex)
            } else {
                haptic()
                withAnimation { expandedWeek = weekIndex }
            }
        }) {
            ZStack {
                // Shadow
                Circle()
                    .fill(nodeShadowCol(completed: completed, current: current))
                    .overlay(Circle().stroke(Color.black.opacity(0.15), lineWidth: 1))
                    .frame(width: size, height: size)
                // Top (Hintergrundfarbe wenn inaktiv)
                Circle()
                    .fill(nodeGradient(completed: completed, current: current))
                    .overlay(Circle().stroke(
                        Color.white.opacity(completed ? 0.28 : current ? 0.25 : 0.0),
                        lineWidth: 1
                    ))
                    .overlay {
                        if expandProgress > 0.55 {
                            Text("\(dayNumber)")
                                .font(.system(size: size * 0.30, weight: .black, design: .rounded))
                                .foregroundColor(completed || current ? .white : nodeIconColor(completed: completed, current: current))
                                .opacity(min(1, (expandProgress - 0.55) * 2.5))
                        } else {
                            Image(systemName: completed ? "checkmark" : current ? "arrow.right" : "circle.fill")
                                .font(.system(size: size * 0.26, weight: .bold))
                                .foregroundColor(nodeIconColor(completed: completed, current: current))
                                .opacity(max(0, 1 - expandProgress * 3.0))
                        }
                    }
                    .frame(width: size, height: size)
                    .offset(y: -depth)
            }
            .frame(width: size + 4, height: size + depth + 4)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func haptic() {
        guard isHapticEnabled else { return }
        let g = UIImpactFeedbackGenerator(style: .soft)
        g.impactOccurred(intensity: 0.7)
    }
}
