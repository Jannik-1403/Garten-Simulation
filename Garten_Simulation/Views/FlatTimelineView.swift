import SwiftUI

// MARK: - 3D Timeline View für 90-Tage Challenge
struct FlatTimelineView: View {
    @ObservedObject var habit: HabitModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    private let totalDays = 90
    private let milestones = [7, 14, 21, 30, 45, 60, 90]

    @State private var selectedDay: SelectedDay? = nil

    struct SelectedDay: Identifiable {
        let id = UUID()
        let index: Int
    }

    private var firstUnwateredIndex: Int {
        let calendar = Calendar.current
        let checkedDays = Set(habit.pfadCheckedDates.map { calendar.startOfDay(for: $0) })
        return (0..<totalDays).first { i in
            !checkedDays.contains(calendar.startOfDay(for: dayAt(index: i)))
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
                )
                .ignoresSafeArea()

                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            Color.clear.frame(height: 130)
                            ForEach(0..<totalDays, id: \.self) { i in
                                timelineNode(for: i).id(i)
                            }
                            Color.clear.frame(height: 80)
                        }
                    }
                    .onAppear {
                        let target = firstUnwateredIndex
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                proxy.scrollTo(target, anchor: .center)
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
                // Difficulty Badge (3D)
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

                // Joker Shields (3D)
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
                                        .shadow(color: i < habit.challengeJokers ? Color(hex: "#58CC02").opacity(0.7) : .clear, radius: 5)
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

    // MARK: - Timeline Node
    @ViewBuilder
    private func timelineNode(for i: Int) -> some View {
        let dayNumber = i + 1
        let isMilestone = milestones.contains(dayNumber)
        let calendar = Calendar.current
        let dateOfTile = dayAt(index: i)
        let isFuture = calendar.startOfDay(for: dateOfTile) > calendar.startOfDay(for: Date())
        let isCompleted = i < firstUnwateredIndex
        let isCurrent = i == firstUnwateredIndex && !isFuture
        let rewardIcon = getRewardIcon(for: dayNumber)

        VStack(spacing: 0) {
            // Linie OBERHALB des Nodes (zum vorherigen Tag i-1)
            if i > 0 {
                let prevCompleted = (i - 1) < firstUnwateredIndex
                connectorLine(isActive: prevCompleted || isCompleted)
            }
            if isMilestone {
                milestoneCard(dayNumber: dayNumber, rewardIcon: rewardIcon,
                              isCompleted: isCompleted, isCurrent: isCurrent,
                              isFuture: isFuture, index: i)
            } else {
                normalPill(dayNumber: dayNumber, isCompleted: isCompleted,
                           isCurrent: isCurrent, index: i)
            }
            // Linie UNTERHALB des Nodes (zum nächsten Tag i+1)
            if i < totalDays - 1 {
                connectorLine(isActive: isCompleted || isCurrent)
            }
        }
    }

    private func connectorLine(isActive: Bool) -> some View {
        // 3D-Stab: Breiter Shadow-Stab + schmalerer Top-Stab leicht nach links versetzt = Depth-Illusion
        let topColor: Color = isActive ? Color(hex: "#58CC02") : (colorScheme == .dark ? Color(hex: "#243447") : Color(hex: "#9ab5cf"))
        let shadowColor: Color = isActive ? Color(hex: "#3a8000") : (colorScheme == .dark ? Color(hex: "#141e2d") : Color(hex: "#7295b5"))
        return ZStack(alignment: .leading) {
            // Shadow-Schicht (rechts/unten)
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(shadowColor)
                .frame(width: 10, height: 22)
                .overlay(
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .stroke(Color.black.opacity(0.12), lineWidth: 0.5)
                )
            // Top-Schicht (leicht versetzt nach oben/links = 3D-Effekt)
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(topColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .stroke(Color.white.opacity(isActive ? 0.25 : 0.08), lineWidth: 0.5)
                )
                .frame(width: 10, height: 22)
                .offset(x: -2, y: -3)
        }
        .frame(width: 10, height: 22)
        .padding(.leading, 0)
    }

    // MARK: - Milestone 3D Card
    private func milestoneCard(dayNumber: Int, rewardIcon: String?, isCompleted: Bool, isCurrent: Bool, isFuture: Bool, index: Int) -> some View {
        let topColor: Color = isCompleted ? Color(hex: "#58CC02")
            : isCurrent ? Color(hex: "#FF9600")
            : colorScheme == .dark ? Color(hex: "#2c3e50") : Color(hex: "#8fa8bf")
        let shadowColor: Color = isCompleted ? Color(hex: "#3a8000")
            : isCurrent ? Color(hex: "#a85e00")
            : colorScheme == .dark ? Color(hex: "#1a2533") : Color(hex: "#6d8aaa")

        return Button(action: { selectedDay = SelectedDay(index: index) }) {
            HStack {
                Spacer()
                ZStack {
                    // Base shadow
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(shadowColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(Color.black.opacity(0.18), lineWidth: 1)
                        )
                    // Top layer
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(LinearGradient(
                            colors: [topColor, topColor.opacity(0.8)],
                            startPoint: .topLeading, endPoint: .bottomTrailing))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(Color.white.opacity(isCompleted || isCurrent ? 0.3 : 0.1), lineWidth: 1)
                        )
                        .overlay {
                            HStack(spacing: 14) {
                                // Reward Icon
                                ZStack {
                                    Circle().fill(Color.black.opacity(0.18)).frame(width: 52, height: 52)
                                    if let icon = rewardIcon {
                                        Image(icon).resizable().scaledToFit().frame(width: 36, height: 36)
                                    } else {
                                        Image(systemName: isCurrent ? "star.fill" : "flag.fill")
                                            .font(.system(size: 22, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(String(localized: "pfad.meilenstein", defaultValue: "Meilenstein"))
                                        .font(.system(size: 10, weight: .bold, design: .rounded))
                                        .foregroundColor(.white.opacity(0.7))
                                        .textCase(.uppercase)
                                        .tracking(1)
                                    Text(String(format: String(localized: "pfad_tag_header"), dayNumber))
                                        .font(.system(size: 24, weight: .black, design: .rounded))
                                        .foregroundColor(.white)
                                }
                                Spacer()
                                ZStack {
                                    Circle().fill(Color.black.opacity(0.18)).frame(width: 36, height: 36)
                                    Image(systemName: isCompleted ? "checkmark" : isCurrent ? "play.fill" : "lock.fill")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(isFuture ? .white.opacity(0.3) : .white)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        .offset(y: -5)
                }
                .frame(width: 320, height: 76)
                .shadow(color: topColor.opacity(isCurrent ? 0.55 : isCompleted ? 0.28 : 0), radius: isCurrent ? 14 : 6, x: 0, y: 4)
                Spacer()
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isCurrent ? 1.025 : 1.0)
        .animation(isCurrent ? .easeInOut(duration: 1.5).repeatForever(autoreverses: true) : .default, value: isCurrent)
    }

    // MARK: - Normal 3D Pill
    private func normalPill(dayNumber: Int, isCompleted: Bool, isCurrent: Bool, index: Int) -> some View {
        let topColor: Color = isCompleted ? Color(hex: "#58CC02")
            : isCurrent ? Color(hex: "#FF9600")
            : colorScheme == .dark ? Color(hex: "#243447") : Color(hex: "#9ab5cf")
        let shadowColor: Color = isCompleted ? Color(hex: "#3a8000")
            : isCurrent ? Color(hex: "#a85e00")
            : colorScheme == .dark ? Color(hex: "#141e2d") : Color(hex: "#7295b5")

        return Button(action: { selectedDay = SelectedDay(index: index) }) {
            HStack {
                Spacer()
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(shadowColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.black.opacity(0.12), lineWidth: 1)
                        )
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(topColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.white.opacity(isCompleted || isCurrent ? 0.22 : 0.07), lineWidth: 1)
                        )
                        .overlay {
                            HStack(spacing: 10) {
                                ZStack {
                                    Circle().fill(Color.black.opacity(0.15)).frame(width: 26, height: 26)
                                    Image(systemName: isCompleted ? "checkmark" : isCurrent ? "arrow.right" : "minus")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(isCompleted || isCurrent ? .white : .white.opacity(0.3))
                                }
                                Text(String(format: String(localized: "pfad_tag_header"), dayNumber))
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(isCompleted || isCurrent ? .white : .white.opacity(0.45))
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                        }
                        .offset(y: -3)
                }
                .frame(width: 200, height: 44)
                Spacer()
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Helpers
    private func getRewardIcon(for day: Int) -> String? {
        switch day {
        case 7, 21, 45: return "coin"
        case 14: return "Unkraut_Schild"
        case 30: return "Powerup-Zeitkapsel"
        case 60: return "Powerup-Glückssegen"
        case 90: return "Achievment_Gold"
        default: return nil
        }
    }

    private func dayAt(index: Int) -> Date {
        let cal = Calendar.current
        let start = habit.pfadAktiviertAm ?? Date()
        return cal.date(byAdding: .day, value: index, to: start) ?? Date()
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
