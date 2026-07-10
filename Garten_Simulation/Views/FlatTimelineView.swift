import SwiftUI

// MARK: - FlatTimelineView (Ring-basierte 90-Tage Challenge)
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
                        VStack(spacing: 32) {
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

    // MARK: - Header
    private var headerOverlay: some View {
        let diffEnum = PfadSchwierigkeit(rawValue: habit.individualSchwierigkeit ?? "") ?? .anfaenger

        return VStack(spacing: 0) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(diffEnum.farbe.opacity(0.55))
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(diffEnum.farbe)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.white.opacity(0.25), lineWidth: 1)
                        )
                        .overlay {
                            HStack(spacing: 5) {
                                Image(systemName: diffEnum.icon).font(.system(size: 13, weight: .bold))
                                Text(NSLocalizedString(diffEnum.titelKey, comment: ""))
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                        }
                        .offset(y: -4)
                }
                .frame(height: 44)

                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(hex: "#111d2e"))
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(hex: "#1e2d42"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                        .overlay {
                            HStack(spacing: 6) {
                                ForEach(0..<habit.maxChallengeJokers, id: \.self) { i in
                                    Image(systemName: i < habit.challengeJokers ? "shield.fill" : "shield")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(i < habit.challengeJokers ? Color(hex: "#58CC02") : Color.white.opacity(0.2))
                                }
                            }
                            .padding(.horizontal, 14)
                        }
                        .offset(y: -4)
                }
                .frame(height: 44)
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .padding(.bottom, 20)
            .background(
                LinearGradient(
                    colors: colorScheme == .dark
                        ? [Color(hex: "#0f1923"), Color(hex: "#0f1923").opacity(0)]
                        : [Color(hex: "#e8f0f7"), Color(hex: "#e8f0f7").opacity(0)],
                    startPoint: .top, endPoint: .bottom
                )
            )
            Spacer()
        }
    }

    private func makeFakePfadStrangTag(index: Int) -> PfadStrangTag {
        let tag = PfadStrangTag(
            tagNummer: index + 1,
            titelKey: "Tag \(index + 1)",
            beschreibungKey: "Beschreibung",
            istErledigt: index < firstUnwateredIndex,
            istMeilenstein: milestones.contains(index + 1)
        )
        let strang = PfadStrang(
            pflanzenID: habit.id,
            farbe: "#58CC02",
            istAktiv: true,
            reihenfolgeIndex: 0
        )
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

    private let ringRadius: CGFloat = 72
    private let nodeNormalSize: CGFloat = 36
    private let nodeMilestoneSize: CGFloat = 50
    private let lineSpacing: CGFloat = 64
    private let milestones = Set([7, 14, 21, 30, 45, 60, 90])

    @State private var expandProgress: CGFloat = 0

    private var isExpanded: Bool { expandedWeek == weekIndex }

    private var dayIndices: [Int] {
        let start = weekIndex * 7
        let end = min(start + 7, 90)
        return Array(start..<end)
    }

    private var weekCompletedCount: Int {
        dayIndices.filter { $0 < firstUnwateredIndex }.count
    }
    private var weekIsFullyDone: Bool { weekCompletedCount == dayIndices.count }
    private var weekIsCurrent: Bool { dayIndices.contains(firstUnwateredIndex) }

    private var ringTopColor: Color {
        weekIsFullyDone ? Color(hex: "#58CC02")
            : weekIsCurrent ? Color(hex: "#FF9600")
            : colorScheme == .dark ? Color(hex: "#243447") : Color(hex: "#9ab5cf")
    }
    private var ringShadowColor: Color {
        weekIsFullyDone ? Color(hex: "#3a8000")
            : weekIsCurrent ? Color(hex: "#a85e00")
            : colorScheme == .dark ? Color(hex: "#141e2d") : Color(hex: "#7295b5")
    }

    // MARK: - Position Math
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

        // Last node (bottom of week) swings left during mid-animation
        let swing = index == total - 1 ? CGFloat(sin(Double(t) * Double.pi)) * -24 : 0

        return CGPoint(
            x: CGFloat(rp.x) + (lp.x - CGFloat(rp.x)) * t + swing,
            y: CGFloat(rp.y) + (lp.y - CGFloat(rp.y)) * t
        )
    }

    private var frameHeight: CGFloat {
        let total = CGFloat(dayIndices.count)
        let collapsed = ringRadius * 2 + 56
        let expanded = (total - 1) * lineSpacing + nodeMilestoneSize + 72
        return collapsed + (expanded - collapsed) * expandProgress
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            // Ring background disk (fades when expanding)
            ringBackground

            // Connector line (appears when expanded)
            expandedConnector

            // Day nodes
            ForEach(Array(dayIndices.enumerated()), id: \.element) { idx, dayIndex in
                let total = dayIndices.count
                let pos = currentPos(index: idx, total: total)
                let dayNumber = dayIndex + 1
                let completed = dayIndex < firstUnwateredIndex
                let current = dayIndex == firstUnwateredIndex
                let milestone = milestones.contains(dayNumber)

                dayNode(
                    dayNumber: dayNumber,
                    dayIndex: dayIndex,
                    completed: completed,
                    current: current,
                    milestone: milestone
                )
                .offset(x: pos.x, y: pos.y)
                .animation(
                    .spring(response: 0.52, dampingFraction: 0.70)
                        .delay(Double(idx) * 0.042),
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
        .animation(.spring(response: 0.5, dampingFraction: 0.76), value: frameHeight)
        .contentShape(Rectangle())
        .onTapGesture {
            if isExpanded {
                withAnimation { expandedWeek = nil }
            }
        }
        .onChange(of: isExpanded) { _, newValue in
            withAnimation(.spring(response: 0.58, dampingFraction: 0.72)) {
                expandProgress = newValue ? 1.0 : 0.0
            }
        }
        .onAppear {
            expandProgress = isExpanded ? 1.0 : 0.0
        }
    }

    // MARK: - Ring Background
    private var ringBackground: some View {
        ZStack {
            // Shadow disk
            Circle()
                .fill(ringShadowColor.opacity(0.45))
                .frame(width: ringRadius * 2 + 12, height: ringRadius * 2 + 12)
            // Top disk
            Circle()
                .fill(
                    RadialGradient(
                        colors: [ringTopColor.opacity(0.14), ringTopColor.opacity(0.04)],
                        center: .center, startRadius: 0, endRadius: ringRadius
                    )
                )
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [ringTopColor.opacity(0.6), ringTopColor.opacity(0.2)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: 2.5
                        )
                )
                .frame(width: ringRadius * 2 + 12, height: ringRadius * 2 + 12)
                .offset(y: -4)
        }
        .opacity(max(0, 1 - expandProgress * 1.8))
    }

    // MARK: - Expanded 3D Connector Line
    private var expandedConnector: some View {
        let total = dayIndices.count
        let connectorHeight = CGFloat(total - 1) * lineSpacing
        let active = weekIsFullyDone
        let topColor: Color = active ? Color(hex: "#58CC02") : (colorScheme == .dark ? Color(hex: "#243447") : Color(hex: "#9ab5cf"))
        let shadowCol: Color = active ? Color(hex: "#3a8000") : (colorScheme == .dark ? Color(hex: "#141e2d") : Color(hex: "#7295b5"))

        return ZStack {
            // Shadow bar
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(shadowCol)
                .overlay(
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .stroke(Color.black.opacity(0.15), lineWidth: 0.5)
                )
                .frame(width: 12, height: connectorHeight)
            // Top bar with 3D offset
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(topColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .stroke(Color.white.opacity(active ? 0.22 : 0.08), lineWidth: 0.5)
                )
                .frame(width: 12, height: connectorHeight)
                .offset(x: -2, y: -3)
        }
        .opacity(max(0, (expandProgress - 0.38) * 2.2))
    }

    // MARK: - Center Label
    private var centerLabel: some View {
        VStack(spacing: 3) {
            Text(String(localized: "pfad.woche", defaultValue: "Woche"))
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundColor(ringTopColor.opacity(0.75))
                .textCase(.uppercase)
                .tracking(1.5)
            Text("\(weekIndex + 1)")
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundColor(ringTopColor)
            HStack(spacing: 4) {
                ForEach(0..<dayIndices.count, id: \.self) { i in
                    Circle()
                        .fill(dayIndices[i] < firstUnwateredIndex ? ringTopColor : ringTopColor.opacity(0.25))
                        .frame(width: 5, height: 5)
                }
            }
        }
    }

    // MARK: - Day Node
    @ViewBuilder
    private func dayNode(dayNumber: Int, dayIndex: Int, completed: Bool, current: Bool, milestone: Bool) -> some View {
        let nodeSize: CGFloat = milestone ? nodeMilestoneSize : nodeNormalSize
        let topColor: Color = completed ? Color(hex: "#58CC02")
            : current ? Color(hex: "#FF9600")
            : colorScheme == .dark ? Color(hex: "#243447") : Color(hex: "#9ab5cf")
        let nodeShadow: Color = completed ? Color(hex: "#3a8000")
            : current ? Color(hex: "#a85e00")
            : colorScheme == .dark ? Color(hex: "#141e2d") : Color(hex: "#7295b5")

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
                // Shadow circle (3D base)
                Circle()
                    .fill(nodeShadow)
                    .overlay(Circle().stroke(Color.black.opacity(0.18), lineWidth: 1))

                // Top circle (3D surface)
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [topColor, topColor.opacity(0.82)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .overlay(Circle().stroke(Color.white.opacity(completed || current ? 0.28 : 0.08), lineWidth: 1))
                    .overlay {
                        if expandProgress > 0.6 {
                            // Expanded: day number / status icon
                            Group {
                                if milestone {
                                    Image(systemName: completed ? "checkmark" : current ? "star.fill" : "lock.fill")
                                        .font(.system(size: nodeSize * 0.3, weight: .bold))
                                        .foregroundColor(completed || current ? .white : .white.opacity(0.3))
                                } else {
                                    Text("\(dayNumber)")
                                        .font(.system(size: nodeSize * 0.35, weight: .black, design: .rounded))
                                        .foregroundColor(completed || current ? .white : .white.opacity(0.4))
                                }
                            }
                            .opacity(min(1, (expandProgress - 0.6) * 3))
                        } else {
                            // Collapsed: checkmark / arrow
                            Image(systemName: completed ? "checkmark" : current ? "arrow.right" : "minus")
                                .font(.system(size: nodeSize * 0.28, weight: .bold))
                                .foregroundColor(completed || current ? .white : .white.opacity(0.28))
                                .opacity(max(0, 1 - expandProgress * 3))
                        }
                    }
                    .frame(width: nodeSize, height: nodeSize)
                    .offset(y: -(nodeSize * 0.13)) // 3D top-layer lift
            }
            .frame(width: nodeSize + 6, height: nodeSize + 6)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(current && expandProgress > 0.85 ? 1.07 : 1.0)
        .animation(
            current && expandProgress > 0.85
                ? .easeInOut(duration: 1.4).repeatForever(autoreverses: true)
                : .default,
            value: current && expandProgress > 0.85
        )
    }
}
