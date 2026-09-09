import SwiftUI

struct DailyHealthScoreCard: View {
    @StateObject private var vm = DailyFeedbackViewModel()
    @EnvironmentObject var gardenStore: GardenStore
    @State private var showDetailSheet: Bool = false

    var body: some View {
        Button {
            showDetailSheet = true
        } label: {
            VStack(spacing: 0) {
                // MARK: Kopfzeile (Score)
                HStack(spacing: 16) {
                    MiniChunkyProgressRing(
                        progress: Double(vm.dailyScore),
                        goal: 100,
                        color: vm.dailyScore >= 80 ? Color(.systemGreen) : (vm.dailyScore >= 50 ? Color(.systemOrange) : Color(.systemRed))
                    )
                        .frame(width: 56, height: 56)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(localized: "fitness.score.title", defaultValue: "Tages-Score"))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
            }
            .clipped()
        }
        .buttonStyle(PillButtonStyle(
            farbe: .white,
            sekundaerFarbe: Color(white: 0.85),
            cornerRadius: 16,
            shadowDepth: 6
        ))
        .fullScreenCover(isPresented: $showDetailSheet) {
            DailyFeedbackDetailView(vm: vm)
        }
        .onAppear {
            vm.activeHabits = gardenStore.sichtbarePflanzen
            vm.reevaluate()
        }
        .onChange(of: gardenStore.sichtbarePflanzen) { newHabits in
            vm.activeHabits = newHabits
            vm.reevaluate()
        }
    }
}

// MARK: - DailyFeedbackDetailView

struct DailyFeedbackDetailView: View {
    @ObservedObject var vm: DailyFeedbackViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if vm.issueFeedbacks.isEmpty {
                        // Alles perfekt
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color(.systemGreen))
                            Text(String(localized: "fitness.score.perfect", defaultValue: "Perfekt! Alle deine Werte liegen im optimalen Bereich. Weiter so!"))
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                                .lineSpacing(4)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white)
                                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.black.opacity(0.15), lineWidth: 1))
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(white: 0.85))
                                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.black.opacity(0.1), lineWidth: 1))
                                .offset(y: 6)
                        )
                        .padding(.bottom, 6)
                    } else {
                        // Begründungen für Warnungen/Kritische Punkte (jetzt alle)
                        VStack(spacing: 24) {
                            ForEach(vm.issueFeedbacks) { feedback in
                                CategoryIssueRow(feedback: feedback)
                                if feedback.id != vm.issueFeedbacks.last?.id {
                                    Divider()
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white)
                                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.black.opacity(0.15), lineWidth: 1))
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(white: 0.85))
                                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.black.opacity(0.1), lineWidth: 1))
                                .offset(y: 6)
                        )
                        .padding(.bottom, 6)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(String(localized: "fitness.score.detail.title", defaultValue: "Tages-Analyse"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
}

// MARK: - MiniChunkyProgressRing

struct MiniChunkyProgressRing: View {
    var progress: Double
    var goal: Double
    var color: Color = .orange
    
    var percent: Double {
        if goal <= 0 { return 0 }
        return min(1.0, progress / goal)
    }
    
    var body: some View {
        ZStack {
            // Background Shadow
            Circle()
                .stroke(color.opacity(0.15), lineWidth: 8)
                .offset(y: 2)
            
            // Background Track
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 8)
            
            // Foreground Progress Shadow
            Circle()
                .trim(from: 0.0, to: percent)
                .stroke(color.opacity(0.5), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(Angle(degrees: -90))
                .offset(y: 2)
            
            // Foreground Progress
            Circle()
                .trim(from: 0.0, to: percent)
                .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(Angle(degrees: -90))
                
            VStack(spacing: 0) {
                Text("\(Int(progress))")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundColor(color)
            }
        }
    }
}

// MARK: - CategoryIssueRow

private struct CategoryIssueRow: View {
    let feedback: CategoryFeedback
    
    @State private var thumbUpScale: CGFloat = 1.0
    @State private var thumbDownScale: CGFloat = 1.0
    @State private var userFeedback: Int = 0 // 1 = up, -1 = down

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Text(categoryName)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            Text(feedback.detailText)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
                
            HStack(spacing: 12) {
                Button {
                    handleThumb(up: false)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: userFeedback == -1 ? "arrow.down.circle.fill" : "arrow.down.circle")
                            .font(.system(size: 14))
                        Text(String(localized: "fitness.goal.decrease", defaultValue: "Ziel senken"))
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(userFeedback == -1 ? .white : .primary)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PillButtonStyle(
                    farbe: userFeedback == -1 ? Color(.systemOrange) : .white,
                    sekundaerFarbe: userFeedback == -1 ? Color(.systemOrange).opacity(0.8) : Color(white: 0.85),
                    cornerRadius: 16,
                    shadowDepth: 4
                ))
                .scaleEffect(thumbDownScale)
                
                Button {
                    handleThumb(up: true)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: userFeedback == 1 ? "arrow.up.circle.fill" : "arrow.up.circle")
                            .font(.system(size: 14))
                        Text(String(localized: "fitness.goal.increase", defaultValue: "Ziel erhöhen"))
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(userFeedback == 1 ? .white : .primary)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PillButtonStyle(
                    farbe: userFeedback == 1 ? Color(.systemGreen) : .white,
                    sekundaerFarbe: userFeedback == 1 ? Color(.systemGreen).opacity(0.8) : Color(white: 0.85),
                    cornerRadius: 16,
                    shadowDepth: 4
                ))
                .scaleEffect(thumbUpScale)
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            let val = UserDefaults.standard.integer(forKey: "feedback_modifier_\(feedback.category.rawValue)")
            if val > 0 { userFeedback = 1 }
            else if val < 0 { userFeedback = -1 }
        }
    }
    
    private func handleThumb(up: Bool) {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        let key = "feedback_modifier_\(feedback.category.rawValue)"
        if up {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) { thumbUpScale = 1.3 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { withAnimation { thumbUpScale = 1.0 } }
            
            userFeedback = (userFeedback == 1) ? 0 : 1
            UserDefaults.standard.set(userFeedback == 1 ? 1 : 0, forKey: key)
        } else {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) { thumbDownScale = 1.3 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { withAnimation { thumbDownScale = 1.0 } }
            
            userFeedback = (userFeedback == -1) ? 0 : -1
            UserDefaults.standard.set(userFeedback == -1 ? -1 : 0, forKey: key)
        }
        
        // Benachrichtige Observer, falls nötig, ansonsten beim nächsten Reevaluate
    }

    private var categoryName: String {
        switch feedback.category {
        case .water:     return String(localized: "fitness.category.water.analysis",     defaultValue: "Tägliche Wasseranalyse")
        case .sleep:     return String(localized: "fitness.category.sleep.analysis",     defaultValue: "Tägliche Schlafanalyse")
        case .strength:  return String(localized: "fitness.category.strength.analysis",  defaultValue: "Tägliche Kraftanalyse")
        case .running:   return String(localized: "fitness.category.running.analysis",   defaultValue: "Tägliche Laufanalyse")
        case .nutrition: return String(localized: "fitness.category.nutrition.analysis", defaultValue: "Tägliche Ernährungsanalyse")
        }
    }
}

#Preview {
    DailyHealthScoreCard()
        .padding()
        .background(Color(.systemGroupedBackground))
}
