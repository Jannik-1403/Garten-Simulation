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
                        VStack(spacing: 28) {
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
                // Difficulty 3D Badge
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
                // Joker Shields 3D Badge
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

    // Layout constants
    private let ringRadius: CGFloat = 74
    private let nodeSize: CGFloat = 38        // Standard-Größe alle Nodes
    private let nodeLastSize: CGFloat = 48    // Tag 7 der Woche etwas größer
    private let lineSpacing: CGFloat = 66
    private let coinDepth: CGFloat = 7        // 3D-Tiefe des Rings

    @State private var expandProgress: CGFloat = 0

    private var isExpanded: Bool { expandedWeek == weekIndex }

    var dayIndices: [Int] {
        let start = weekIndex * 7
        let end = min(start + 7, 90)
        return Array(start..<end)
    }

    private var weekCompletedCount: Int { dayIndices.filter { $0 < firstUnwateredIndex }.count }
    private var weekIsFullyDone: Bool { weekCompletedCount == dayIndices.count }
    private var weekIsCurrent: Bool { dayIndices.contains(firstUnwateredIndex) }

    private var coinTopColor: Color {
        weekIsFullyDone ? Color(hex: "#58CC02")
            : weekIsCurrent ? Color(hex: "#FF9600")
            : colorScheme == .dark ? Color(hex: "#1e2d42") : Color(hex: "#c8d8ea")
    }
    private var coinSideColor: Color {
        weekIsFullyDone ? Color(hex: "#3a8000")
            : weekIsCurrent ? Color(hex: "#a85e00")
            : colorScheme == .dark ? Color(hex: "#0d1520") : Color(hex: "#8faabf")
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
        // Letzter Node schwingt kurz nach links
        let swing = index == total - 1 ? CGFloat(sin(Double(t) * Double.pi)) * -20 : 0
        return CGPoint(
            x: CGFloat(rp.x) + (lp.x - CGFloat(rp.x)) * t + swing,
            y: CGFloat(rp.y) + (lp.y - CGFloat(rp.y)) * t
        )
    }

    private func sizeForIndex(_ idx: Int, total: Int) -> CGFloat {
        idx == total - 1 ? nodeLastSize : nodeSize
    }

    private var frameHeight: CGFloat {
        let total = CGFloat(dayIndices.count)
        let collapsed = ringRadius * 2 + coinDepth + 56
        let expanded = (total - 1) * lineSpacing + nodeLastSize + 80
        return collapsed + (expanded - collapsed) * expandProgress
    }

    // MARK: - Node colors
    private func nodeTop(completed: Bool, current: Bool) -> Color {
        completed ? Color(hex: "#58CC02")
            : current ? Color(hex: "#FF9600")
            : colorScheme == .dark ? Color(hex: "#1e2535") : Color.white
    }
    private func nodeShadow(completed: Bool, current: Bool) -> Color {
        completed ? Color(hex: "#3a8000")
            : current ? Color(hex: "#a85e00")
            : colorScheme == .dark ? Color(hex: "#0a0e18") : Color(hex: "#b0c8e0")
    }
    private func nodeIconColor(completed: Bool, current: Bool) -> Color {
        (completed || current) ? .white : (colorScheme == .dark ? .white.opacity(0.45) : .black.opacity(0.35))
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            // 3D Ring Coin (fades when expanding)
            ringCoin
            // Expanded vertical connector
            expandedConnector
            // Collapse button (appears when expanded)
            collapseButton
            // Day nodes
            ForEach(Array(dayIndices.enumerated()), id: \.element) { idx, dayIndex in
                let total = dayIndices.count
                let pos = currentPos(index: idx, total: total)
                let completed = dayIndex < firstUnwateredIndex
                let current = dayIndex == firstUnwateredIndex
                dayNode(dayNumber: dayIndex + 1, dayIndex: dayIndex,
                        nodeIdx: idx, total: total,
                        completed: completed, current: current)
                    .offset(x: pos.x, y: pos.y)
                    .animation(.spring(response: 0.50, dampingFraction: 0.72).delay(Double(idx) * 0.038), value: expandProgress)
                    .zIndex(Double(total - idx))
            }
            // Center label
            centerLabel
                .opacity(max(0, 1 - expandProgress * 2.8))
                .allowsHitTesting(false)
        }
        .frame(height: frameHeight)
        .animation(.spring(response: 0.50, dampingFraction: 0.76), value: frameHeight)
        .contentShape(Rectangle())
        .onTapGesture {
            // Tap auf freie Fläche wenn collapsed = expand
            if !isExpanded {
                withAnimation { expandedWeek = weekIndex }
            }
        }
        .onChange(of: isExpanded) { _, newValue in
            withAnimation(.spring(response: 0.56, dampingFraction: 0.72)) {
                expandProgress = newValue ? 1.0 : 0.0
            }
        }
        .onAppear { expandProgress = isExpanded ? 1.0 : 0.0 }
    }

    // MARK: - 3D Ring Coin (Item3DButton-Stil)
    private var ringCoin: some View {
        let diameter = ringRadius * 2 + 10
        return ZStack {
            // Seite / Schatten (Coin-Kante sichtbar)
            Circle()
                .fill(coinSideColor)
                .overlay(Circle().stroke(Color.black.opacity(0.2), lineWidth: 1))
                .frame(width: diameter, height: diameter)
            // Oberfläche (leicht nach oben versetzt = 3D-Effekt)
            Circle()
                .fill(
                    LinearGradient(
                        colors: [coinTopColor.opacity(0.22), coinTopColor.opacity(0.08)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [coinTopColor.opacity(0.7), coinTopColor.opacity(0.25)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: 2.5
                        )
                )
                .frame(width: diameter, height: diameter)
                .offset(y: -coinDepth) // 3D-Tiefe
        }
        .opacity(max(0, 1 - expandProgress * 1.6))
    }

    // MARK: - Collapse Button
    private var collapseButton: some View {
        let total = dayIndices.count
        let topNodeY = linePos(index: 0, total: total).y
        return Button(action: {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                expandedWeek = nil
            }
        }) {
            ZStack {
                // Shadow
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(coinSideColor)
                    .frame(width: 100, height: 30)
                // Top
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(coinTopColor.opacity(colorScheme == .dark ? 0.3 : 0.4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(coinTopColor.opacity(0.4), lineWidth: 1)
                    )
                    .overlay {
                        HStack(spacing: 5) {
                            Image(systemName: "chevron.up")
                                .font(.system(size: 11, weight: .bold))
                            Text(String(localized: "pfad.schliessen", defaultValue: "Schließen"))
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.7))
                    }
                    .frame(width: 100, height: 30)
                    .offset(y: -3)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .offset(y: topNodeY - nodeLastSize / 2 - 28)
        .opacity(max(0, (expandProgress - 0.6) * 2.5))
    }

    // MARK: - Expanded 3D Connector
    private var expandedConnector: some View {
        let total = dayIndices.count
        guard total > 1 else { return AnyView(EmptyView()) }
        let connectorHeight = CGFloat(total - 1) * lineSpacing

        let active = weekIsFullyDone
        let topColor: Color = active ? Color(hex: "#58CC02") : (colorScheme == .dark ? Color(hex: "#1e2535") : Color.white)
        let shadowCol: Color = active ? Color(hex: "#3a8000") : (colorScheme == .dark ? Color(hex: "#0a0e18") : Color(hex: "#b0c8e0"))

        return AnyView(
            ZStack {
                // Shadow bar
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(shadowCol)
                    .overlay(RoundedRectangle(cornerRadius: 5, style: .continuous).stroke(Color.black.opacity(0.12), lineWidth: 0.5))
                    .frame(width: 11, height: connectorHeight)
                // Top bar
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(topColor)
                    .overlay(RoundedRectangle(cornerRadius: 5, style: .continuous).stroke(Color.white.opacity(active ? 0.2 : 0.1), lineWidth: 0.5))
                    .frame(width: 11, height: connectorHeight)
                    .offset(x: -2, y: -3)
            }
            .opacity(max(0, (expandProgress - 0.4) * 2.0))
        )
    }

    // MARK: - Center Label
    private var centerLabel: some View {
        VStack(spacing: 4) {
            Text("\(weekIndex + 1)")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundColor(coinTopColor)
            HStack(spacing: 4) {
                ForEach(0..<dayIndices.count, id: \.self) { i in
                    Circle()
                        .fill(dayIndices[i] < firstUnwateredIndex ? coinTopColor : coinTopColor.opacity(0.22))
                        .frame(width: 5, height: 5)
                }
            }
        }
    }

    // MARK: - Day Node (3D Coin-Stil, kein Puls-Sprung)
    @ViewBuilder
    private func dayNode(dayNumber: Int, dayIndex: Int, nodeIdx: Int, total: Int, completed: Bool, current: Bool) -> some View {
        let size = sizeForIndex(nodeIdx, total: total)
        let depth: CGFloat = size * 0.12
        let topColor = nodeTop(completed: completed, current: current)
        let shadowCol = nodeShadow(completed: completed, current: current)
        let iconColor = nodeIconColor(completed: completed, current: current)

        Button(action: {
            if isExpanded {
                onSelectDay(dayIndex)
            } else {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                    expandedWeek = weekIndex
                }
            }
        }) {
            ZStack {
                // Shadow / Coin-Seite
                Circle()
                    .fill(shadowCol)
                    .overlay(Circle().stroke(Color.black.opacity(0.18), lineWidth: 1))
                    .frame(width: size, height: size)
                // Top-Fläche
                Circle()
                    .fill(
                        LinearGradient(
                            colors: completed ? [Color(hex: "#67dd10"), Color(hex: "#48aa00")]
                                : current ? [Color(hex: "#ffaa22"), Color(hex: "#e07800")]
                                : colorScheme == .dark ? [Color(hex: "#253248"), Color(hex: "#1a2535")]
                                : [Color.white, Color(hex: "#e8f0f7")],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .overlay(Circle().stroke(Color.white.opacity(completed || current ? 0.30 : (colorScheme == .dark ? 0.12 : 0.6)), lineWidth: 1))
                    .overlay {
                        if expandProgress > 0.55 {
                            Text("\(dayNumber)")
                                .font(.system(size: size * 0.30, weight: .black, design: .rounded))
                                .foregroundColor(iconColor)
                                .opacity(min(1, (expandProgress - 0.55) * 2.5))
                        } else {
                            Image(systemName: completed ? "checkmark" : current ? "arrow.right" : "minus")
                                .font(.system(size: size * 0.28, weight: .bold))
                                .foregroundColor(iconColor)
                                .opacity(max(0, 1 - expandProgress * 2.8))
                        }
                    }
                    .frame(width: size, height: size)
                    .offset(y: -depth)
            }
            .frame(width: size + 4, height: size + depth + 4)
        }
        .buttonStyle(PlainButtonStyle())
        // KEIN scaleEffect / repeatForever im Ring-Zustand
        .scaleEffect(current && expandProgress > 0.9 ? 1.06 : 1.0)
        .animation(current && expandProgress > 0.9 ? .easeInOut(duration: 1.5).repeatForever(autoreverses: true) : .default, value: current && expandProgress > 0.9)
    }
}
