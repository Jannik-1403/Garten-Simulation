import SwiftUI
import Charts

struct WeeklyReportDashboardView: View {
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var iapStore: IAPStore
    @EnvironmentObject var streakStore: StreakStore
    @EnvironmentObject var assessmentStore: AssessmentStore
    
    @State private var selectedWeekStart: Date = WeeklyStatsManager.shared.startOfWeek(for: Date())
    @State private var selectedFocusDay: DailyFocusTime? = nil
    @State private var selectedHabitsDay: DailyHabitsCount? = nil
    @State private var generatedPDFUrl: URL? = nil
    @State private var isSharing = false
    @State private var zeigePaywall = false
    @State private var isAnalysisExpanded = true
    
    private let calendar = Calendar.current
    
    private var report: WeeklyReportData {
        WeeklyStatsManager.shared.generateReport(for: selectedWeekStart, gardenStore: gardenStore)
    }
    
    private var formattedWeekRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM."
        let startStr = formatter.string(from: report.weekStartDate)
        formatter.dateFormat = "dd.MM.yyyy"
        let endStr = formatter.string(from: report.weekEndDate)
        return "\(startStr) - \(endStr)"
    }
    
    private var canGoForward: Bool {
        let nextWeekStart = calendar.date(byAdding: .day, value: 7, to: selectedWeekStart)!
        return nextWeekStart <= Date()
    }
    
    var body: some View {
        VStack(spacing: 24) {
            
            // 1. Week Navigation (Liquid Glass)
            weekNavigationHeader
            
            // 2. Summary Carousel (TabView anstatt 2x2 Grid)
            TabView {
                summaryCardAsset(
                    title: String(localized: "weekly_report.card.focus_time", defaultValue: "Fokuszeit"),
                    value: "\(report.totalFocusMinutes) Min",
                    change: report.focusMinutesChangePercentage,
                    assetIcon: "Timer full",
                    color: .blauPrimary
                )
                .padding(.horizontal, 4)
                
                summaryCardAsset(
                    title: String(localized: "weekly_report.card.habits", defaultValue: "Gewohnheiten"),
                    value: "\(report.completedHabitsCount)",
                    change: report.habitsChangePercentage,
                    assetIcon: "Drop water",
                    color: .green
                )
                .padding(.horizontal, 4)
                
                summaryCardAsset(
                    title: String(localized: "weekly_report.card.sessions", defaultValue: "Sessions"),
                    value: "\(report.completedSessionsCount)",
                    change: nil,
                    assetIcon: "streak",
                    color: .orangePrimary
                )
                .padding(.horizontal, 4)
                
                summaryCardAsset(
                    title: String(localized: "weekly_report.card.xp", defaultValue: "Verdiente XP"),
                    value: "+\(report.earnedXP)",
                    change: nil,
                    assetIcon: "XP",
                    color: .purple
                )
                .padding(.horizontal, 4)
            }
            .frame(height: 140)
            .tabViewStyle(.page(indexDisplayMode: .always))
            .animation(.easeInOut, value: selectedWeekStart)
            
            // 3. Analyse & Feedback (aufklappbar)
            analysisCard
            
            // 4. Chart: Fokuszeit (3D Balken)
            chartContainer(title: String(localized: "weekly_report.chart.focus_title", defaultValue: "Fokuszeit pro Tag")) {
                Chart {
                    ForEach(report.dailyFocusMinutes) { item in
                        BarMark(
                            x: .value("Tag", item.dayName),
                            y: .value("Minuten", item.minutes)
                        )
                        .foregroundStyle(Color.blauPrimary)
                        .cornerRadius(4)
                        
                        if let selected = selectedFocusDay, selected.dayName == item.dayName {
                            RuleMark(y: .value("Auswahl", selected.minutes))
                                .lineStyle(StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [4, 4]))
                                .foregroundStyle(.primary.opacity(0.5))
                        }
                    }
                }
                .chartXSelection(value: Binding(
                    get: { selectedFocusDay?.dayName },
                    set: { newValue in
                        withAnimation(.snappy) {
                            selectedFocusDay = newValue.flatMap { name in
                                report.dailyFocusMinutes.first(where: { $0.dayName == name })
                            }
                        }
                    }
                ))
                .overlay(alignment: .top) {
                    if let selected = selectedFocusDay, selected.minutes > 0 {
                        Text("\(selected.minutes) Min")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(Color.blauPrimary)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .offset(y: -24)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            
            // 5. Chart: Gewohnheiten (3D Balken)
            chartContainer(title: String(localized: "weekly_report.chart.habits_title", defaultValue: "Erledigte Gewohnheiten")) {
                Chart {
                    ForEach(report.dailyHabitsCompleted) { item in
                        BarMark(
                            x: .value("Tag", item.dayName),
                            y: .value("Erledigt", item.count)
                        )
                        .foregroundStyle(Color.green)
                        .cornerRadius(4)
                        
                        if let selected = selectedHabitsDay, selected.dayName == item.dayName {
                            RuleMark(y: .value("Auswahl", selected.count))
                                .lineStyle(StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [4, 4]))
                                .foregroundStyle(.primary.opacity(0.5))
                        }
                    }
                }
                .chartXSelection(value: Binding(
                    get: { selectedHabitsDay?.dayName },
                    set: { newValue in
                        withAnimation(.snappy) {
                            selectedHabitsDay = newValue.flatMap { name in
                                report.dailyHabitsCompleted.first(where: { $0.dayName == name })
                            }
                        }
                    }
                ))
                .overlay(alignment: .top) {
                    if let selected = selectedHabitsDay, selected.count > 0 {
                        Text("\(selected.count) erledigt")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .offset(y: -24)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            
            // 6. PDF Export Button
            exportButton
        }
        .padding(.horizontal, 8)
        .sheet(isPresented: $isSharing) {
            if let url = generatedPDFUrl {
                PDFExportShareSheet(activityItems: [url])
            }
        }
        .sheet(isPresented: $zeigePaywall) {
            PaywallView()
                .environmentObject(iapStore)
        }
    }
    
    // MARK: - Week Navigation Header
    
    private var weekNavigationHeader: some View {
        HStack {
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    selectedWeekStart = calendar.date(byAdding: .day, value: -7, to: selectedWeekStart)!
                    selectedFocusDay = nil
                    selectedHabitsDay = nil
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(8)
            }
            
            Spacer()
            
            Button {
                // Future: Date Picker overlay
            } label: {
                VStack(spacing: 2) {
                    Text(String(localized: "weekly_report.navigation.title", defaultValue: "Wochenbericht"))
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    Text(formattedWeekRange)
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundColor(.primary)
                        .contentTransition(.numericText())
                }
            }
            
            Spacer()
            
            Button {
                if canGoForward {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        selectedWeekStart = calendar.date(byAdding: .day, value: 7, to: selectedWeekStart)!
                        selectedFocusDay = nil
                        selectedHabitsDay = nil
                    }
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(canGoForward ? .primary : .secondary.opacity(0.3))
                    .padding(8)
            }
            .disabled(!canGoForward)
        }
        .padding(.horizontal, 8)
    }
    
    // MARK: - Analyse Card
    
    private var analysisCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            DisclosureGroup(isExpanded: $isAnalysisExpanded) {
                VStack(alignment: .leading, spacing: 12) {
                    Divider().padding(.vertical, 8)
                    
                    let parts = report.feedbackDescription.components(separatedBy: "\n\n")
                    
                    if !parts.isEmpty {
                        TabView {
                            ForEach(0..<parts.count, id: \.self) { index in
                                ScrollView(showsIndicators: true) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(parts[index])
                                            .font(.system(size: 15, weight: .medium, design: .rounded))
                                            .foregroundColor(.primary.opacity(0.85))
                                            .lineSpacing(4)
                                            .fixedSize(horizontal: false, vertical: true)
                                        Spacer(minLength: 0)
                                    }
                                    .padding(16)
                                    .padding(.bottom, 24)
                                    .frame(maxWidth: .infinity, alignment: .topLeading)
                                }
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color.primary.opacity(0.05), lineWidth: 1))
                                .padding(.horizontal, 4)
                            }
                        }
                        .frame(height: 170)
                        .tabViewStyle(.page(indexDisplayMode: .always))
                        .animation(.easeInOut, value: report.feedbackDescription)
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.yellow)
                        .padding(8)
                        .background(Color.yellow.opacity(0.15))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(report.feedbackTitle)
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundColor(.primary)
                            .contentTransition(.numericText())
                        Text(String(localized: "weekly_report.analysis.subtitle", defaultValue: "Deine Fortschritts-Analyse"))
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
            }
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.black.opacity(0.12))
                .offset(y: 5)
        )
        .padding(.bottom, 6)
        .animation(.easeInOut, value: isAnalysisExpanded)
    }
    
    // MARK: - Export Button
    
    private var exportButton: some View {
        VStack(spacing: 8) {
            Button {
                if iapStore.isProUser {
                    let pdfUrl = PDFExportManager.shared.generateWeeklyPDFReport(
                        for: selectedWeekStart,
                        gardenStore: gardenStore,
                        settings: settings,
                        streakStore: streakStore,
                        assessmentStore: assessmentStore
                    )
                    if let pdfUrl = pdfUrl {
                        self.generatedPDFUrl = pdfUrl
                        self.isSharing = true
                    }
                } else {
                    zeigePaywall = true
                }
            } label: {
                HStack(spacing: 6) {
                    if !iapStore.isProUser {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.white)
                    }
                    Text(String(localized: "weekly_report.button.export_pdf", defaultValue: "PDF Wochenbericht teilen"))
                        .font(.system(size: 18, weight: .black, design: .rounded))
                }
            }
            .buttonStyle(
                DuolingoButtonStyle(
                    size: .large,
                    fillWidth: true,
                    backgroundColor: iapStore.isProUser ? .blauPrimary : .goldPrimary,
                    shadowColor: iapStore.isProUser ? .blauPrimary.darker() : .goldPrimary.darker(),
                    foregroundColor: .white
                )
            )
            
            if !iapStore.isProUser {
                Text(String(localized: "weekly_report.button.pro_badge", defaultValue: "PRO FEATURE"))
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundColor(.goldPrimary)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Color.goldPrimary.opacity(0.15))
                    .clipShape(Capsule())
            }
        }
        .padding(.top, 16)
    }
    
    // MARK: - Summary Card mit Asset-Icon
    
    private func summaryCardAsset(title: String, value: String, change: Double?, assetIcon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                SwiftUI.Image(assetIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                
                Spacer()
                
                if let diff = change, diff != 0 {
                    let isPositive = diff > 0
                    let formattedDiff = String(format: "%.0f%%", abs(diff))
                    HStack(spacing: 2) {
                        Image(systemName: isPositive ? "arrow.up" : "arrow.down")
                            .font(.system(size: 10, weight: .bold))
                        Text(formattedDiff)
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(isPositive ? .green : .red)
                    .padding(.horizontal, 6).padding(.vertical, 3)
                    .background((isPositive ? Color.green : Color.red).opacity(0.1))
                    .cornerRadius(8)
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundColor(.primary)
                    .contentTransition(.numericText())
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.black.opacity(0.12))
                .offset(y: 5)
        )
    }
    
    // MARK: - Chart Container
    
    private func chartContainer<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundColor(.primary)
            content()
                .frame(height: 180)
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.black.opacity(0.12))
                .offset(y: 5)
        )
        .padding(.bottom, 6)
    }
}



