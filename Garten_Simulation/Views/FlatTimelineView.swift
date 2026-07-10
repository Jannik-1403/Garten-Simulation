import SwiftUI

struct FlatTimelineView: View {
    @ObservedObject var habit: HabitModel
    @Environment(\.dismiss) var dismiss
    
    private let totalDays = 90
    private let milestones = [7, 14, 21, 30, 45, 60, 90]
    
    @State private var selectedDay: SelectedDay? = nil
    
    struct SelectedDay: Identifiable {
        let id = UUID()
        let index: Int
    }
    
    var body: some View {
        if habit.pfadAktiviertAm == nil {
            PfadActivationOverlay(habit: habit)
        } else {
            ZStack(alignment: .top) {
                Color.appHintergrund.ignoresSafeArea()
                
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            // Extra space at the top to clear the header
                            Color.clear.frame(height: 120)
                            
                            ForEach((0..<totalDays).reversed(), id: \.self) { i in
                                timelineNode(for: i)
                                    .id(i)
                            }
                            
                            Color.clear.frame(height: 80)
                        }
                    }
                    .onAppear {
                        let calendar = Calendar.current
                        let checkedStartOfDays = Set(habit.pfadCheckedDates.map { calendar.startOfDay(for: $0) })
                        let firstUnwateredIndex = (0..<totalDays).first { i in
                            let date = dayAt(index: i)
                            return !checkedStartOfDays.contains(calendar.startOfDay(for: date))
                        } ?? (totalDays - 1)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            withAnimation(.easeInOut(duration: 0.6)) {
                                proxy.scrollTo(firstUnwateredIndex, anchor: .center)
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
        
        return VStack {
            HStack {
                // Difficulty Badge
                HStack(spacing: 6) {
                    Image(systemName: diffEnum.icon)
                        .font(.system(size: 16, weight: .bold))
                    Text(NSLocalizedString(diffEnum.titelKey, comment: ""))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(diffEnum.farbe)
                .cornerRadius(16)
                
                Spacer()
                
                // Joker / Shields
                HStack(spacing: 4) {
                    ForEach(0..<habit.maxChallengeJokers, id: \.self) { i in
                        Image(systemName: i < habit.challengeJokers ? "shield.fill" : "shield")
                            .foregroundColor(i < habit.challengeJokers ? Color(hex: "#58CC02") : .gray.opacity(0.4))
                            .shadow(radius: i < habit.challengeJokers ? 2 : 0)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.regularMaterial)
                .cornerRadius(16)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.gray, .regularMaterial)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            Spacer()
        }
    }
    
    private func timelineNode(for i: Int) -> some View {
        let dayNumber = i + 1
        let isMilestone = milestones.contains(dayNumber)
        
        let calendar = Calendar.current
        let checkedStartOfDays = Set(habit.pfadCheckedDates.map { calendar.startOfDay(for: $0) })
        let firstUnwateredIndex = (0..<totalDays).first { idx in
            let date = dayAt(index: idx)
            return !checkedStartOfDays.contains(calendar.startOfDay(for: date))
        } ?? (totalDays - 1)
        
        let dateOfTile = dayAt(index: i)
        let isFuture = calendar.startOfDay(for: dateOfTile) > calendar.startOfDay(for: Date())
        
        let isCompleted = i < firstUnwateredIndex
        let isCurrent = i == firstUnwateredIndex && !isFuture
        let isLocked = i > firstUnwateredIndex || (i == firstUnwateredIndex && isFuture)
        
        let rewardIcon = getRewardIcon(for: dayNumber)
        
        return Button(action: {
            selectedDay = SelectedDay(index: i)
        }) {
            HStack {
                // Left Spacing
                Spacer()
                
                // The Node Line + Circle
                VStack(spacing: 0) {
                    if i < totalDays - 1 {
                        Rectangle()
                            .fill(isCompleted || isCurrent ? Color(hex: "#58CC02") : Color.gray.opacity(0.3))
                            .frame(width: 4, height: isMilestone ? 40 : 20)
                    }
                    
                    ZStack {
                        if isMilestone {
                            Circle()
                                .fill(isCompleted ? Color(hex: "#58CC02") : (isCurrent ? Color.orange : Color.gray.opacity(0.3)))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Circle().stroke(Color.white, lineWidth: 3)
                                )
                                .shadow(radius: isCurrent ? 8 : 2)
                            
                            if let icon = rewardIcon {
                                Image(icon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 32, height: 32)
                            }
                        } else {
                            Circle()
                                .fill(isCompleted ? Color(hex: "#58CC02") : (isCurrent ? Color.orange : Color.gray.opacity(0.3)))
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Circle().stroke(Color.white, lineWidth: 2)
                                )
                        }
                    }
                    
                    if i > 0 {
                        Rectangle()
                            .fill(isCompleted ? Color(hex: "#58CC02") : Color.gray.opacity(0.3))
                            .frame(width: 4, height: isMilestone ? 40 : 20)
                    }
                }
                .frame(width: 80)
                
                // Right Spacing (Day Label)
                HStack {
                    Text(String(format: String(localized: "pfad_tag_header"), dayNumber))
                        .font(.system(size: isMilestone ? 18 : 14, weight: isMilestone ? .bold : .semibold, design: .rounded))
                        .foregroundColor(isCompleted ? .primary : .secondary)
                    Spacer()
                }
                .frame(width: 100)
                
                Spacer()
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getRewardIcon(for day: Int) -> String? {
        switch day {
        case 7, 21, 45: return "coin"
        case 14: return "Unkraut_Schild"
        case 30: return "Powerup-Zeitkapsel"
        case 60: return "Powerup-Glückssegen"
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
        let dummyStrang = GartenPfadStrang(
            id: UUID(),
            nameKey: "challenge.90days",
            beschreibungKey: "challenge.90days.desc",
            farbe: "#58CC02",
            voraussetzungKey: nil,
            pflanzenID: habit.id,
            reihenfolge: 0,
            tage: [],
            istAktiv: true
        )
        return PfadStrangTag(
            id: UUID(),
            tagNummer: index + 1,
            strang: dummyStrang,
            titelKey: "Tag \(index + 1)",
            beschreibungKey: "Beschreibung",
            phase: (index + 1) <= 14 ? .einstieg : ((index + 1) <= 45 ? .aufbau : .meisterschaft),
            istMeilenstein: milestones.contains(index + 1),
            neuerPflanzenHinweis: nil,
            reward: nil,
            istErledigt: false,
            freigeschaltetAm: nil,
            abgeschlossenAm: nil
        )
    }
}
