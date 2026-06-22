import SwiftUI
import Charts
import Photos


// MARK: - ProfilHeaderView
struct ProfilHeaderView: View {
    let name: String
    let seltenheit: PflanzenSeltenheit
    @EnvironmentObject var settings: SettingsStore
    
    var body: some View {
        VStack(spacing: 6) {
            Text(name)
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            Text(seltenheit.lokalisiertTitel)
                .font(.caption.weight(.semibold))
                .foregroundStyle(seltenheit.farbe)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(seltenheit.farbe.opacity(0.15), in: Capsule())
        }
    }
}

// MARK: - Stat Buttons (Item3DButton Wrappers)

struct XPStatButton: View {
    let xp: Int
    @Binding var showDetail: Bool
    @EnvironmentObject var settings: SettingsStore
    
    var body: some View {
        DuolingoCard(action: { showDetail = true }) {
            VStack(spacing: 12) {
                Item3DButton(
                    icon: "XP",
                    farbe: Color(hex: "#FFD000"),
                    sekundaerFarbe: Color(hex: "#D9A300"),
                    groesse: 60,
                    aktion: nil
                )
                
                VStack(spacing: 2) {
                    Text("\(xp)")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(.primary)
                    Text(settings.localizedString(for: "profile.xp.total"))
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct InventoryStatButton: View {
    let count: Int
    @Binding var showDetail: Bool
    @EnvironmentObject var settings: SettingsStore
    
    var body: some View {
        DuolingoCard(action: { showDetail = true }) {
            HStack(spacing: 20) {
                Item3DButton(
                    icon: "Inventar",
                    farbe: Color(hex: "#8B4513"),
                    sekundaerFarbe: Color(hex: "#5C2E0B"),
                    groesse: 60,
                    aktion: nil
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(settings.localizedString(for: "profile.inventory"))
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                    
                    Text("\(count)")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(.primary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.quaternary)
            }
        }
    }
}

struct StreakStatButton: View {
    let currentStreak: Int
    let bestStreak: Int
    var aktion: (() -> Void)? = nil
    @EnvironmentObject var settings: SettingsStore
    
    var body: some View {
        DuolingoCard(action: { aktion?() }) {
            VStack(spacing: 12) {
                Item3DButton(
                    icon: "streak",
                    farbe: Color(hex: "#FF4B00"),
                    sekundaerFarbe: Color(hex: "#C43D00"),
                    groesse: 60,
                    aktion: nil
                )
                
                VStack(spacing: 2) {
                    Text("\(bestStreak)")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(.primary)
                    Text(settings.localizedString(for: "profile.streak.best"))
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct ErfolgeStatButton: View {
    let count: Int
    @Binding var showDetail: Bool
    @EnvironmentObject var settings: SettingsStore
    
    var body: some View {
        DuolingoCard(action: { showDetail = true }) {
            VStack(spacing: 12) {
                Item3DButton(
                    icon: "Erfolg",
                    farbe: Color(hex: "#FFB800"),
                    sekundaerFarbe: Color(hex: "#D99A00"),
                    groesse: 60,
                    aktion: nil
                )
                
                VStack(spacing: 2) {
                    Text("\(count)")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(.primary)
                    Text(settings.localizedString(for: "profile.achievements"))
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct WasserStatButton: View {
    let liter: String
    @Binding var showDetail: Bool
    @EnvironmentObject var settings: SettingsStore
    
    var body: some View {
        DuolingoCard(action: { showDetail = true }) {
            HStack(spacing: 20) {
                Item3DButton(
                    icon: "Drop water",
                    farbe: .blauPrimary,
                    sekundaerFarbe: Color(hex: "#005EB8"),
                    groesse: 60,
                    aktion: nil
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(settings.localizedString(for: "wasser.karte.titel"))
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                    
                    Text(liter)
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(.primary)
                    
                    Text(settings.localizedString(for: "wasser.gesamt"))
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(.tertiary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.quaternary)
            }
        }
    }
}

// MARK: - AssessmentStatButton

struct AssessmentStatButton: View {
    let result: AssessmentResult?
    var aktion: (() -> Void)? = nil
    @EnvironmentObject var settings: SettingsStore

    var body: some View {
        DuolingoCard(action: { aktion?() }) {
            HStack(spacing: 20) {
                Item3DButton(
                    farbe: Color(hex: "#FFD700"),
                    sekundaerFarbe: Color(hex: "#D4AF37"),
                    groesse: 60,
                    iconSkalierung: 1.6,
                    aktion: {}
                ) {
                    Image("Quiz")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 96, height: 96)
                        .offset(x: 3)
                }
                .allowsHitTesting(false)

                VStack(alignment: .leading, spacing: 4) {
                    Text(settings.localizedString(for: "assessment.entry.title"))
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)

                    if let result = result {
                        Text(settings.localizedString(for: result.profile.titleKey))
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundStyle(.primary)

                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 11))
                                .foregroundStyle(.green)
                            Text(settings.localizedString(for: "assessment.entry.done"))
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Text(settings.localizedString(for: "assessment.entry.cta"))
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundStyle(.primary)

                        Text(settings.localizedString(for: "assessment.entry.subtitle"))
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(.tertiary)
                    }
                }

                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.quaternary)
            }
        }
    }
}

// MARK: - NameEditSheet
struct NameEditSheet: View {
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    @Environment(\.dismiss) var dismiss
    
    @State private var tempName: String = ""
    @State private var zeigeZweiteBestaetigung = false
    
    var nameChangeCost: Int {
        let count = settings.igelCustomization.nameChangeCount
        if count == 0 { return 0 }
        var cost = 100.0
        for _ in 1..<count { cost *= 1.5 }
        return Int(cost)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if !zeigeZweiteBestaetigung {
                    VStack(spacing: 8) {
                        Text(settings.localizedString(for: "igel_name_edit_title"))
                            .font(.system(size: 24, weight: .black, design: .rounded))
                        
                        Text(settings.localizedString(for: settings.igelCustomization.nameChangeCount == 0 ? "igel_name_edit_hint_free" : "igel_name_edit_hint_paid"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    TextField(settings.localizedString(for: "igel_name_placeholder"), text: $tempName)
                        .font(.headline)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.blauPrimary.opacity(0.2), lineWidth: 1))
                    
                    Button(action: {
                        withAnimation { zeigeZweiteBestaetigung = true }
                    }) {
                        Text(settings.localizedString(for: "common_continue"))
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(DuolingoButtonStyle(backgroundColor: .blauPrimary, shadowColor: .blauSecondary, foregroundColor: .white))
                    .disabled(tempName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                } else {
                    VStack(spacing: 16) {
                        Image("coin").resizable().scaledToFit().frame(width: 60, height: 60)
                        Text(settings.localizedString(for: "igel_name_confirm_title"))
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .multilineTextAlignment(.center)
                        
                        Text(String(format: settings.localizedString(for: "igel_name_confirm_hint"), tempName))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    let cost = nameChangeCost
                    let canAfford = gardenStore.coins >= cost
                    
                    Button(action: {
                        if canAfford {
                            if cost > 0 { gardenStore.coins -= cost }
                            settings.igelCustomization.name = tempName
                            settings.igelCustomization.nameChangeCount += 1
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            dismiss()
                        }
                    }) {
                        HStack(spacing: 12) {
                            if cost == 0 {
                                Text(settings.localizedString(for: "igel_name_edit_button_free"))
                            } else {
                                Image("coin").resizable().scaledToFit().frame(width: 22, height: 22)
                                Text("\(cost)")
                            }
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(DuolingoButtonStyle(backgroundColor: canAfford ? .blauPrimary : .gray, shadowColor: canAfford ? .blauSecondary : .gray.darker(), foregroundColor: .white))
                    .disabled(!canAfford)
                }
                Spacer()
            }
            .padding(24)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if zeigeZweiteBestaetigung {
                        Button { withAnimation { zeigeZweiteBestaetigung = false } } label: { Image(systemName: "chevron.left").foregroundStyle(.primary) }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    LiquidGlassDismissButton { dismiss() }
                }
            }
            .onAppear { tempName = settings.igelCustomization.name }
        }
    }
}


struct StatisticsDashboard: View {
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var streakStore: StreakStore
    @Environment(\.dismiss) var dismiss
    
    @State private var expandedStat: StatDetail?
    @State private var selectedPeriod: StatsPeriod = .week
    @State private var isGeneratingShareImage = false
    @State private var showPreview = false
    @State private var pendingShareType: ShareCardType?
    
    // MARK: - Computed Data
    
    private var gardenScoreData: (score: Int, konsistenz: Double, streakScore: Double, message: String, bestStreakInPeriod: Int) {
        let habits = gardenStore.pflanzen
        guard !habits.isEmpty else { return (0, 0, 0, settings.localizedString(for: "stats.score.msg.low"), 0) }
        
        let days = selectedPeriod.days
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let now = Date()
        let startDate = calendar.date(byAdding: .day, value: -days, to: today)!

        // +1 to include today in the possible count
        let totalPossible = habits.count * (days + 1)
        let totalDone = habits.reduce(0) { count, habit in
            // Use `now` as upper bound so today's waterings are counted
            count + habit.wateringDates.filter { $0 >= startDate && $0 <= now }.count
        }
        let konsistenz = totalPossible > 0 ? Double(totalDone) / Double(totalPossible) : 0.0

        let bestStreakInPeriod = habits.map { habit -> Int in
            let datesInPeriod = habit.wateringDates
                .filter { $0 >= startDate && $0 <= now }
                .map { calendar.startOfDay(for: $0) }
            
            let uniqueDays = Set(datesInPeriod).sorted()
            var best = 0
            var current = 0
            var lastDay: Date? = nil
            
            for day in uniqueDays {
                if let last = lastDay,
                   calendar.dateComponents([.day], from: last, to: day).day == 1 {
                    current += 1
                } else {
                    current = 1
                }
                best = max(best, current)
                lastDay = day
            }
            return best
        }.max() ?? 0

        let streakScore = min(1.0, Double(bestStreakInPeriod) / Double(days + 1))

        let scoreValue = Int((konsistenz * 0.6 + streakScore * 0.4) * 100)
        
        let message: String
        if scoreValue >= 85 { message = settings.localizedString(for: "stats.score.msg.excellent") }
        else if scoreValue >= 60 { message = settings.localizedString(for: "stats.score.msg.good") }
        else if scoreValue >= 35 { message = settings.localizedString(for: "stats.score.msg.ok") }
        else { message = settings.localizedString(for: "stats.score.msg.low") }
        
        return (scoreValue, konsistenz, streakScore, message, bestStreakInPeriod)
    }




    private var closestToLevelUp: [HabitModel] {
        gardenStore.pflanzen
            .filter { $0.seltenheit != .diamant }
            .sorted { a, b in
                let aRemaining = (a.seltenheit.naechste?.xpSchwelle ?? 0) - a.currentXP
                let bRemaining = (b.seltenheit.naechste?.xpSchwelle ?? 0) - b.currentXP
                return aRemaining < bRemaining
            }
            .prefix(3)
            .map { $0 }
    }
    
    enum StatDetail: String, Identifiable {
        case activity, balance, xp, coins, milestones
        var id: String { self.rawValue }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Picker("", selection: $selectedPeriod) {
                    ForEach(StatsPeriod.allCases, id: \.self) { period in
                        Text(settings.localizedString(for: period.localizationKey))
                            .tag(period)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                if gardenStore.pflanzen.isEmpty {
                    ContentUnavailableView(
                        settings.localizedString(for: "stats.empty.title"),
                        systemImage: "leaf.fill",
                        description: Text(settings.localizedString(for: "stats.empty.desc"))
                    )
                    .padding(.top, 40)
                } else {
                    lifeBalanceCard
                    gardenScoreConsistencyCard
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(Color.appHintergrund.ignoresSafeArea())
        .navigationTitle(settings.localizedString(for: "statistik_titel"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                LiquidGlassDismissButton { dismiss() }
            }
        }
        .fullScreenCover(item: $expandedStat) { detail in
            StatDetailFullscreenView(detail: detail, selectedPeriod: selectedPeriod)
        }
        .sheet(isPresented: $showPreview) {
            if let type = pendingShareType {
                SharePreviewSheet(
                    type: type,
                    period: selectedPeriod,
                    habits: gardenStore.pflanzen
                )
                .environmentObject(settings)
                .environmentObject(gardenStore)
                .environmentObject(streakStore)
            }
        }
    }
    
    enum ShareCardType: Equatable {
        case lifeBalance
        case consistency
        case streak
        case milestones
        case activity
        case xp
        case coins
    }
    
    private func initiateShare(_ type: ShareCardType) {
        self.pendingShareType = type
        self.showPreview = true
    }
    
    private var lifeBalanceCard: some View {
        let habits = gardenStore.pflanzen
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let days = selectedPeriod.days
        let currentStart = calendar.date(byAdding: .day, value: -days, to: today)!
        let prevStart = calendar.date(byAdding: .day, value: -days * 2, to: today)!
        
        let now = Date()
        let currentWaterings = habits.reduce(0) { $0 + $1.wateringDates.filter { $0 >= currentStart && $0 <= now }.count }
        let prevWaterings = habits.reduce(0) { $0 + $1.wateringDates.filter { $0 >= prevStart && $0 < currentStart }.count }
        let wateringsDelta = currentWaterings - prevWaterings
        let currentPlants = habits.count
        let prevPlants = habits.filter { $0.gekauftAm < currentStart }.count
        let plantsDelta = currentPlants - prevPlants
        let currentGems = currentWaterings * GameConstants.gemsProGiessen
        let prevGems = prevWaterings * GameConstants.gemsProGiessen
        let gemsDelta = currentGems - prevGems
        let currentStreak = streakStore.currentStreak

        return VStack(spacing: 0) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(settings.localizedString(for: "statistik_life_balance"))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                    Text(settings.localizedString(for: selectedPeriod.thisPeriodKey))
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.top, .horizontal, .trailing], 20)
            .overlay(alignment: .topTrailing) {
                HStack(spacing: 8) {
                    Button {
                        initiateShare(.lifeBalance)
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.black)
                            .padding(8)
                    }
                    
                    Button {
                        expandedStat = .balance
                    } label: {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.black)
                            .padding(8)
                    }
                }
                .padding(.top, 12)
                .padding(.trailing, 12)
            }
            
            RadarChartView(habits: habits, selectedPeriod: selectedPeriod)
                .padding(.vertical, 10)
        }
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .offset(y: 0)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.black.opacity(0.18))
                .offset(y: 6)
        )
        .padding(.bottom, 6)
    }

    private var gardenScoreConsistencyCard: some View {
        let history = StatsHelper.getWateringHistory(from: gardenStore.pflanzen, badHabitExecutions: gardenStore.badHabitExecutions, days: selectedPeriod.days)
        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label(settings.localizedString(for: "stats.score.konsistenz"), systemImage: "checkmark.circle.fill")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.gruenPrimary)
                Spacer()
                
                HStack(spacing: 8) {
                    Button(action: { initiateShare(.consistency) }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.black)
                            .padding(8)
                    }
                    
                    Button {
                        expandedStat = .activity
                    } label: {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.black)
                            .padding(8)
                    }
                }
            }
            
            // Large Value & Period
            VStack(alignment: .leading, spacing: 2) {
                let currentScore = history.last?.count ?? 0
                Text("\(currentScore)")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(Color.gruenPrimary)
                
                Text(String(format: settings.localizedString(for: "stats.score.konsistenz.period_format"), settings.localizedString(for: selectedPeriod.thisPeriodKey)))
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            
            // Sparkline Line Chart (Stock Chart Style)
            Chart {
                ForEach(history) { item in
                    LineMark(
                        x: .value("Tag", item.date),
                        y: .value("Gegossen", item.count)
                    )
                    .interpolationMethod(.stepEnd)
                    .foregroundStyle(Color.gruenPrimary)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    
                    AreaMark(
                        x: .value("Tag", item.date),
                        y: .value("Gegossen", item.count)
                    )
                    .interpolationMethod(.stepEnd)
                    .foregroundStyle(LinearGradient(
                        colors: [Color.gruenPrimary.opacity(0.25), Color.gruenPrimary.opacity(0)],
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(height: 100)
            .padding(.vertical, 4)
        }
        .padding(20)
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .offset(y: 0)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.black.opacity(0.18))
                .offset(y: 6)
        )
        .padding(.bottom, 6)
    }

    private var gardenScoreStreakCard: some View {
        let data = gardenScoreData
        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label(settings.localizedString(for: "stats.score.streak"), systemImage: "flame.fill")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.orangePrimary)
                Spacer()
                
                Button(action: { initiateShare(.streak) }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.black)
                        .padding(8)
                }
            }
            
            GardenFactorRow(
                icon: "flame.fill",
                color: .orangePrimary,
                label: settings.localizedString(for: "stats.score.streak"),
                sublabel: String(format: settings.localizedString(for: "stats.score.streak.period_format"), settings.localizedString(for: selectedPeriod.thisPeriodKey)),
                value: data.streakScore,
                valueText: "\(data.bestStreakInPeriod)d · \(Int(data.streakScore * 100))%"
            )
        }
        .padding(20)
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .offset(y: 0)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.black.opacity(0.18))
                .offset(y: 6)
        )
        .padding(.bottom, 6)
    }


    private var nextMilestonesCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(settings.localizedString(for: "stats.milestone.title"))
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Button(action: { initiateShare(.milestones) }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.black)
                            .padding(8)
                    }
                    
                    Button {
                        expandedStat = .milestones
                    } label: {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.black)
                            .padding(8)
                    }
                }
            }
            
            VStack(spacing: 14) {
                ForEach(closestToLevelUp) { habit in
                    VStack(spacing: 8) {
                        HStack(spacing: 12) {
                            // Plant Image (Tree)
                            Image(habit.plantImageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(settings.showHabitInsteadOfName ? settings.localizedString(for: habit.habitName) : settings.localizedString(for: habit.name))
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                    Spacer()
                                    if let next = habit.seltenheit.naechste {
                                        Text("→ \(next.lokalisiertTitel)")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(next.farbe)
                                    }
                                }
                                
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        Capsule()
                                            .fill(Color.secondary.opacity(0.1))
                                            .frame(height: 8)
                                        Capsule()
                                            .fill(habit.seltenheit.farbe)
                                            .frame(width: geo.size.width * habit.seltenheit.fortschritt(aktuelleXP: habit.currentXP), height: 8)
                                    }
                                }
                                .frame(height: 8)
                                
                                if let next = habit.seltenheit.naechste {
                                    let remaining = next.xpSchwelle - habit.currentXP
                                    Text(String(format: settings.localizedString(for: "stats.milestone.remaining"), remaining, next.lokalisiertTitel))
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        
                        if habit.id != closestToLevelUp.last?.id {
                            Divider().padding(.leading, 44)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .offset(y: 0)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.black.opacity(0.18))
                .offset(y: 6)
        )
        .padding(.bottom, 6)
    }

}

struct StatTile: View {
    let title: String
    let value: String
    let delta: Int
    let farbe: Color
    let sekundaerFarbe: Color
    let settings: SettingsStore
    
    var body: some View {
        Item3DButton(
            farbe: farbe,
            sekundaerFarbe: sekundaerFarbe,
            groesse: 70,
            isRectangular: true
        ) {
            VStack(alignment: .leading, spacing: 2) {
                Text(settings.localizedString(for: title))
                    .font(.system(size: 8, weight: .bold, design: .rounded))
                    .foregroundStyle(.black)
                    .textCase(.uppercase)
                
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(.black)
                    
                    if delta != 0 {
                        HStack(spacing: 1) {
                            Image(systemName: delta > 0 ? "arrow.up.right" : "arrow.down.right")
                            Text("\(abs(delta))")
                        }
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(delta > 0 ? .green : .red)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Fullscreen Detail View

struct Stat3DTitleView: View {
    let title: String
    let color: Color
    var size: CGFloat = 28
    
    var body: some View {
        ZStack {
            Text(title)
                .font(.system(size: size, weight: .black, design: .rounded))
                .foregroundStyle(color.opacity(0.35))
                .offset(y: size > 20 ? 6 : 3)
            
            Text(title)
                .font(.system(size: size, weight: .black, design: .rounded))
                .foregroundStyle(color)
        }
    }
}

struct StatDetailFullscreenView: View {
    let detail: StatisticsDashboard.StatDetail
    @State var selectedPeriod: StatsPeriod
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    
    @State private var selectedDate: Date? = nil
    @StateObject private var viewModel = StatDetailViewModel()
    @State private var showPreview = false
    @State private var pendingShareType: StatisticsDashboard.ShareCardType? = nil

    init(detail: StatisticsDashboard.StatDetail, selectedPeriod: StatsPeriod) {
        self.detail = detail
        self._selectedPeriod = State(initialValue: selectedPeriod)
    }
    
    private func getXAxisDates(for period: StatsPeriod) -> [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        if period == .day { return [] }
        let days = period.days
        let start = calendar.date(byAdding: .day, value: -days, to: today)!
        let mid = calendar.date(byAdding: .day, value: -(days / 2), to: today)!
        return [start, mid, today]
    }
    
    private func customXAxisLabel(for date: Date, period: StatsPeriod) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        switch period {
        case .week:
            return date.formatted(.dateTime.weekday(.abbreviated).locale(Locale(identifier: settings.appLanguage)))
        case .month:
            let daysDiff = calendar.dateComponents([.day], from: date, to: today).day ?? 0
            if daysDiff >= 25 {
                return settings.appLanguage == "de" ? "Woche 1" : "Week 1"
            } else if daysDiff >= 10 && daysDiff <= 20 {
                return settings.appLanguage == "de" ? "Woche 2" : "Week 2"
            } else {
                return settings.appLanguage == "de" ? "Woche 4" : "Week 4"
            }
        case .year, .allTime:
            return date.formatted(.dateTime.month(.abbreviated).locale(Locale(identifier: settings.appLanguage)))
        default:
            return ""
        }
    }
    
    private var closestToLevelUp: [HabitModel] {
        gardenStore.pflanzen
            .filter { $0.seltenheit != .diamant }
            .sorted { a, b in
                let aRemaining = (a.seltenheit.naechste?.xpSchwelle ?? 0) - a.currentXP
                let bRemaining = (b.seltenheit.naechste?.xpSchwelle ?? 0) - b.currentXP
                return aRemaining < bRemaining
            }
            .map { $0 }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Picker("", selection: $selectedPeriod) {
                        ForEach(StatsPeriod.allCases, id: \.self) { period in
                            Text(settings.localizedString(for: period.localizationKey))
                                .tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    content
                }
                .padding(20)
            }
            .scrollDisabled(selectedDate != nil)
            .background(Color.appHintergrund.ignoresSafeArea())
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            initiateShare()
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.primary)
                        }
                        
                        LiquidGlassDismissButton { dismiss() }
                    }
                }
            }
            .task(id: selectedPeriod) {
                viewModel.loadData(for: selectedPeriod, detail: detail, gardenStore: gardenStore, settings: settings)
            }
            .sheet(isPresented: $showPreview) {
                if let type = pendingShareType {
                    SharePreviewSheet(
                        type: type,
                        period: selectedPeriod,
                        habits: gardenStore.pflanzen
                    )
                    .environmentObject(settings)
                    .environmentObject(gardenStore)
                    .environmentObject(StreakStore()) // Fallback or retrieve from parent if needed
                }
            }
        }
    }
    
    private func initiateShare() {
        switch detail {
        case .activity: pendingShareType = .activity
        case .balance: pendingShareType = .lifeBalance
        case .xp: pendingShareType = .xp
        case .coins: pendingShareType = .coins
        case .milestones: pendingShareType = .milestones
        }
        showPreview = true
    }
    
    @ViewBuilder
    private var content: some View {
        VStack(alignment: .leading, spacing: 32) {
            switch detail {
            case .activity:
                activityContent
            case .balance:
                balanceContent
            case .xp:
                xpContent
            case .coins:
                coinsContent
            case .milestones:
                milestonesContent
            }
        }
    }
    
    private var title: String {
        switch detail {
        case .activity: return settings.localizedString(for: "stats.activity.title")
        case .balance: return settings.localizedString(for: "stats.balance.title")
        case .xp: return settings.localizedString(for: "stats.xp.title")
        case .coins: return settings.localizedString(for: "stats.coins.title")
        case .milestones: return settings.localizedString(for: "stats.milestone.title")
        }
    }
    
    // Detailed Content Builders
    
    private var activityContent: some View {
        return VStack(spacing: 24) {
            // Interactive Selection Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if let selectedDate = selectedDate {
                        if selectedPeriod == .day {
                            let timeStr = selectedDate.formatted(.dateTime.hour().minute().locale(Locale(identifier: settings.appLanguage)))
                            let label = settings.appLanguage == "de" ? "\(timeStr) Uhr" : timeStr
                            Text(label)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                        } else {
                            Text(selectedDate.formatted(.dateTime.weekday(.wide).day().month().locale(Locale(identifier: settings.appLanguage))))
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        
                        let scoreAtDate = viewModel.score(at: selectedDate)
                        Stat3DTitleView(title: "Score: \(scoreAtDate)", color: Color.gruenPrimary)
                    } else {
                        Text(settings.localizedString(for: selectedPeriod.thisPeriodKey))
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                        
                        let total = viewModel.wateringHistory.last?.count ?? 0
                        Stat3DTitleView(title: "Score: \(total)", color: Color.gruenPrimary)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 4)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selectedDate)
            
            Chart {
                ForEach(viewModel.wateringHistory) { item in
                    LineMark(
                        x: .value("Tag", item.date),
                        y: .value("Gegossen", item.count)
                    )
                    .interpolationMethod(.stepEnd)
                    .foregroundStyle(Color.gruenPrimary)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    
                    AreaMark(
                        x: .value("Tag", item.date),
                        y: .value("Gegossen", item.count)
                    )
                    .interpolationMethod(.stepEnd)
                    .foregroundStyle(LinearGradient(
                        colors: [Color.gruenPrimary.opacity(0.25), Color.gruenPrimary.opacity(0)],
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    
                    if selectedPeriod == .day, viewModel.getEventDetail(at: item.date) != nil {
                        PointMark(
                            x: .value("Tag", item.date),
                            y: .value("Gegossen", item.count)
                        )
                        .foregroundStyle(Color.gruenPrimary)
                        .symbolSize(40)
                    }
                }
                
                if let selectedDate = selectedDate {
                    let scoreAtDate = viewModel.score(at: selectedDate)
                    RuleMark(x: .value("Selected Tag", selectedDate))
                        .foregroundStyle(Color.gruenPrimary.opacity(0.4))
                        .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                    
                    PointMark(
                        x: .value("Selected Tag", selectedDate),
                        y: .value("Selected Gegossen", scoreAtDate)
                    )
                    .foregroundStyle(Color.gruenPrimary)
                    .symbolSize(120)
                }
            }
            .chartXAxis {
                if selectedPeriod == .day {
                    AxisMarks(values: .stride(by: .hour, count: 6)) { value in
                        if let date = value.as(Date.self) {
                            let hour = Calendar.current.component(.hour, from: date)
                            let label = settings.appLanguage == "de" ? "\(hour):00 Uhr" : "\(hour):00"
                            AxisValueLabel(label)
                        }
                    }
                } else {
                    AxisMarks(values: getXAxisDates(for: selectedPeriod)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(customXAxisLabel(for: date, period: selectedPeriod))
                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .chartXSelection(value: $selectedDate)
            .frame(height: 220)
            
            if selectedPeriod != .day {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 20) {
                        DetailInfoBox(
                            title: settings.localizedString(for: "statistik_gute_gewohnheiten"), 
                            value: "\(viewModel.goodHabitsCount)"
                        )
                        DetailInfoBox(
                            title: settings.localizedString(for: "statistik_schlechte_gewohnheiten"), 
                            value: "\(viewModel.badHabitsCount)"
                        )
                    }
                }
            }
        }
        .padding(20)
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.black.opacity(0.18))
                .offset(y: 6)
        )
        .padding(.bottom, 6)
        .padding(.horizontal, 16)
    }
    
    private func splitCoachText(_ text: String) -> (String, String) {
        if let range = text.range(of: ":") {
            return (String(text[..<range.lowerBound]).trimmingCharacters(in: .whitespaces),
                    String(text[range.upperBound...]).trimmingCharacters(in: .whitespaces))
        } else if let range = text.range(of: "：") {
            return (String(text[..<range.lowerBound]).trimmingCharacters(in: .whitespaces),
                    String(text[range.upperBound...]).trimmingCharacters(in: .whitespaces))
        }
        return (text, "")
    }

    private var balanceContent: some View {
        return VStack(spacing: 32) {
            RadarChartView(habits: gardenStore.pflanzen, selectedPeriod: selectedPeriod)
                .frame(height: 350)
                .padding(.vertical, 20)
            
            VStack(spacing: 16) {
                HStack {
                    Text(settings.localizedString(for: "habit.tips.title"))
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundStyle(Color.primary)
                    Spacer()
                }
                
                let coachTips = [
                    ("Geistundseele", "stats.coach.bullet1"),
                    ("Wachstum", "stats.coach.bullet2"),
                    ("Gesundheit", "stats.coach.bullet3"),
                    ("Finanzen", "stats.coach.bullet4")
                ]
                
                ForEach(coachTips, id: \.1) { tip in
                    let localizedText = settings.localizedString(for: tip.1)
                    let split = splitCoachText(localizedText)
                    
                    HStack(alignment: .center, spacing: 14) {
                        Image(tip.0)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 44, height: 44)
                            .scaleEffect(2.2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(split.0)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text(split.1)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.12), radius: 0, x: 0, y: 4)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.black.opacity(0.04), lineWidth: 1)
                    )
                }
            }
            
            Text(settings.localizedString(for: "stats.balance.description"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var xpContent: some View {
        return VStack(spacing: 24) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    if let selectedDate = selectedDate {
                        HStack(spacing: 8) {
                            if selectedPeriod == .day {
                                let timeStr = selectedDate.formatted(.dateTime.hour().minute().locale(Locale(identifier: settings.appLanguage)))
                                let label = settings.appLanguage == "de" ? "\(timeStr) Uhr" : timeStr
                                Text(label)
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(.secondary)
                            } else {
                                Text(selectedDate.formatted(.dateTime.weekday(.wide).day().month().locale(Locale(identifier: settings.appLanguage))))
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                            
                            Text("•")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.secondary)
                            
                            let xpAtDate = viewModel.xp(at: selectedDate)
                            Stat3DTitleView(title: "\(xpAtDate) XP", color: Color.blauPrimary)
                        }
                        
                        if selectedPeriod == .day, let plantXPDetail = viewModel.getXPEventDetail(at: selectedDate) {
                            HStack(spacing: 6) {
                                Image(systemName: "leaf.fill")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(plantXPDetail.color)
                                
                                Text(plantXPDetail.name)
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.primary)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 1)
                        } else {
                            Text("")
                                .font(.system(size: 13))
                        }
                    } else {
                        Text(settings.localizedString(for: selectedPeriod.thisPeriodKey))
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                        
                        Stat3DTitleView(title: "\(gardenStore.gesamtXP) XP", color: Color.blauPrimary)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 4)
            .frame(height: 70)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selectedDate)
            
            Chart {
                ForEach(viewModel.xpHistory) { item in
                    LineMark(x: .value("Tag", item.date), y: .value("XP", item.amount))
                        .interpolationMethod(.stepEnd)
                        .foregroundStyle(Color.blauPrimary)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                    
                    AreaMark(x: .value("Tag", item.date), y: .value("XP", item.amount))
                        .interpolationMethod(.stepEnd)
                        .foregroundStyle(LinearGradient(colors: [.blauPrimary.opacity(0.4), .blauPrimary.opacity(0)], startPoint: .top, endPoint: .bottom))
                    
                    if selectedPeriod == .day, viewModel.getXPEventDetail(at: item.date) != nil {
                        PointMark(
                            x: .value("Tag", item.date),
                            y: .value("XP", item.amount)
                        )
                        .foregroundStyle(Color.blauPrimary)
                        .symbolSize(40)
                    }
                }
                
                if let selectedDate = selectedDate {
                    let xpAtDate = viewModel.xp(at: selectedDate)
                    RuleMark(x: .value("Selected Tag", selectedDate))
                        .foregroundStyle(Color.blauPrimary.opacity(0.4))
                        .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                    
                    PointMark(
                        x: .value("Selected Tag", selectedDate),
                        y: .value("Selected XP", xpAtDate)
                    )
                    .foregroundStyle(Color.blauPrimary)
                    .symbolSize(120)
                }
            }
            .chartXAxis {
                if selectedPeriod == .day {
                    AxisMarks(values: .stride(by: .hour, count: 6)) { value in
                        if let date = value.as(Date.self) {
                            let hour = Calendar.current.component(.hour, from: date)
                            let label = settings.appLanguage == "de" ? "\(hour):00 Uhr" : "\(hour):00"
                            AxisValueLabel(label)
                        }
                    }
                } else {
                    AxisMarks(values: getXAxisDates(for: selectedPeriod)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(customXAxisLabel(for: date, period: selectedPeriod))
                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .chartXSelection(value: $selectedDate)
            .frame(height: 220)
        }
        .padding(20)
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.black.opacity(0.18))
                .offset(y: 6)
        )
        .padding(.bottom, 6)
        .padding(.horizontal, 16)
    }
    
    private var coinsContent: some View {
        return VStack(spacing: 24) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    if let selectedDate = selectedDate {
                        HStack(spacing: 8) {
                            if selectedPeriod == .day {
                                let timeStr = selectedDate.formatted(.dateTime.hour().minute().locale(Locale(identifier: settings.appLanguage)))
                                let label = settings.appLanguage == "de" ? "\(timeStr) Uhr" : timeStr
                                Text(label)
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(.secondary)
                            } else {
                                Text(selectedDate.formatted(.dateTime.weekday(.wide).day().month().locale(Locale(identifier: settings.appLanguage))))
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                            
                            Text("•")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.secondary)
                            
                            let balanceAtDate = viewModel.coins(at: selectedDate)
                            Stat3DTitleView(title: "\(balanceAtDate) \(settings.localizedString(for: "statistik_kachel_gems"))", color: Color.goldPrimary)
                        }
                        
                        if selectedPeriod == .day, let tx = viewModel.getCoinEventDetail(at: selectedDate) {
                            HStack(spacing: 6) {
                                Image(systemName: tx.icon)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(tx.farbe)
                                
                                Text(tx.beschreibung)
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.primary)
                                
                                Text(tx.betrag > 0 ? "(+\(tx.betrag))" : "(\(tx.betrag))")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundStyle(tx.betrag > 0 ? Color.gruenPrimary : .red)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 1)
                        } else {
                            Text("")
                                .font(.system(size: 13))
                        }
                    } else {
                        Text(settings.localizedString(for: selectedPeriod.thisPeriodKey))
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                        
                        Stat3DTitleView(title: "\(gardenStore.coins) \(settings.localizedString(for: "statistik_kachel_gems"))", color: Color.goldPrimary)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 4)
            .frame(height: 70)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selectedDate)
            
            Chart {
                ForEach(viewModel.coinHistory) { item in
                    LineMark(x: .value("Tag", item.date), y: .value("Coins", item.balance))
                        .interpolationMethod(.stepEnd)
                        .foregroundStyle(Color.goldPrimary)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                    
                    AreaMark(x: .value("Tag", item.date), y: .value("Coins", item.balance))
                        .interpolationMethod(.stepEnd)
                        .foregroundStyle(LinearGradient(colors: [Color.goldPrimary.opacity(0.3), Color.goldPrimary.opacity(0)], startPoint: .top, endPoint: .bottom))
                    
                    if selectedPeriod == .day, viewModel.getCoinEventDetail(at: item.date) != nil {
                        PointMark(
                            x: .value("Tag", item.date),
                            y: .value("Coins", item.balance)
                        )
                        .foregroundStyle(Color.goldPrimary)
                        .symbolSize(40)
                    }
                }
                
                if let selectedDate = selectedDate {
                    let balanceAtDate = viewModel.coins(at: selectedDate)
                    RuleMark(x: .value("Selected Tag", selectedDate))
                        .foregroundStyle(Color.goldPrimary.opacity(0.4))
                        .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                    
                    PointMark(
                        x: .value("Selected Tag", selectedDate),
                        y: .value("Selected Coins", balanceAtDate)
                    )
                    .foregroundStyle(Color.goldPrimary)
                    .symbolSize(120)
                }
            }
            .chartXAxis {
                if selectedPeriod == .day {
                    AxisMarks(values: .stride(by: .hour, count: 6)) { value in
                        if let date = value.as(Date.self) {
                            let hour = Calendar.current.component(.hour, from: date)
                            let label = settings.appLanguage == "de" ? "\(hour):00 Uhr" : "\(hour):00"
                            AxisValueLabel(label)
                        }
                    }
                } else {
                    AxisMarks(values: getXAxisDates(for: selectedPeriod)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(customXAxisLabel(for: date, period: selectedPeriod))
                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .chartXSelection(value: $selectedDate)
            .frame(height: 220)
        }
        .padding(20)
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.black.opacity(0.18))
                .offset(y: 6)
        )
        .padding(.bottom, 6)
        .padding(.horizontal, 16)
    }
    
    private var milestonesContent: some View {
        VStack(spacing: 20) {
            ForEach(closestToLevelUp) { habit in
                VStack(spacing: 12) {
                    HStack(spacing: 16) {
                        Image(habit.plantImageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(settings.showHabitInsteadOfName ? settings.localizedString(for: habit.habitName) : settings.localizedString(for: habit.name))
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                Spacer()
                                if let next = habit.seltenheit.naechste {
                                    Text("→ \(next.lokalisiertTitel)")
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                        .foregroundStyle(next.farbe)
                                }
                            }
                            
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.secondary.opacity(0.1))
                                        .frame(height: 10)
                                    Capsule()
                                        .fill(habit.seltenheit.farbe)
                                        .frame(width: geo.size.width * habit.seltenheit.fortschritt(aktuelleXP: habit.currentXP), height: 10)
                                }
                            }
                            .frame(height: 10)
                            
                            if let next = habit.seltenheit.naechste {
                                let remaining = next.xpSchwelle - habit.currentXP
                                Text(String(format: settings.localizedString(for: "stats.milestone.remaining"), remaining, next.lokalisiertTitel))
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 4)
                }
            }
        }
    }
    
}

struct MilestonesShareImage: View {
    let milestones: [HabitModel]
    let username: String
    let theme: ShareImageTheme
    var vibrantColor: Color = Color.purple // Default for milestones
    @EnvironmentObject var settings: SettingsStore

    var body: some View {
            StatShareImage(
                title: settings.localizedString(for: "stats.milestone.title"),
                subtitle: settings.localizedString(for: "statistik_share_status"),
                username: username,
                height: 720, // Reduced height
                theme: theme,
                vibrantColor: .red // Using red as universal base
            ) {
                VStack(spacing: 12) { // Tighter spacing
                    ForEach(milestones.prefix(5)) { habit in
                        HStack(spacing: 16) {
                            Image(habit.plantImageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 44, height: 44) // More compact icons
                                .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text(settings.showHabitInsteadOfName ? settings.localizedString(for: habit.habitName) : settings.localizedString(for: habit.name))
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(theme == .light ? .black : .white)
                                Spacer()
                                if let next = habit.seltenheit.naechste {
                                    Text(next.lokalisiertTitel)
                                        .font(.system(size: 12, weight: .black, design: .rounded))
                                        .foregroundStyle(next.farbe)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(next.farbe.opacity(0.15), in: Capsule())
                                }
                            }
                            
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.secondary.opacity(0.15))
                                        .frame(height: 12)
                                    Capsule()
                                        .fill(habit.seltenheit.farbe)
                                        .frame(width: geo.size.width * habit.seltenheit.fortschritt(aktuelleXP: habit.currentXP), height: 12)
                                        .overlay(
                                            Capsule()
                                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                        )
                                }
                            }
                            .frame(height: 12)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
    }
}


// For Preview
#Preview {
    let settings = SettingsStore()
    let store = GardenStore()
    let sStore = StreakStore()
    
    NavigationStack {
        StatisticsDashboard()
            .environmentObject(settings)
            .environmentObject(store)
            .environmentObject(sStore)
    }
}

// MARK: - Helper Components

enum ShareImageTheme {
    case vibrant
    case light
    case dark
}

struct StatShareImage<Content: View>: View {
    let title: String
    let subtitle: String
    let username: String
    let height: CGFloat
    let theme: ShareImageTheme
    let vibrantColor: Color
    let content: Content
    
    @EnvironmentObject var settings: SettingsStore
    
    init(title: String, subtitle: String, username: String, height: CGFloat, theme: ShareImageTheme = .vibrant, vibrantColor: Color = .gruenPrimary, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.username = username
        self.height = height
        self.theme = theme
        self.vibrantColor = vibrantColor
        self.content = content()
    }

    var body: some View {
        ZStack {
            // Background Layer
            backgroundView
            
            VStack(alignment: .leading, spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 6) {
                    Stat3DTitleView(title: title, color: vibrantColor, size: 34)
                    
                    Text(subtitle)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(textColor.opacity(0.7))
                }
                .padding(.top, 44)
                .padding(.horizontal, 36)
                
                Spacer()
                
                // Content Area (Now in a card)
                content
                    .padding(24)
                    .background(Color.white)
                    .cornerRadius(24)
                    .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
                    .padding(.horizontal, 36)
                    .environment(\.colorScheme, .light)
                
                Spacer()
                
                // Footer
                HStack(spacing: 16) {
                    HStack(spacing: 12) {
                        Image("Appicon")
                            .resizable()
                            .frame(width: 44, height: 44)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                    }
                    
                    Spacer()
                    
                    Text("@\(username)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(textColor.opacity(0.8))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(textColor.opacity(0.1), in: Capsule())
                }
                .padding(.horizontal, 36)
                .padding(.bottom, 44)
            }
        }
        .frame(width: 500, height: height)
        // Kein clipShape – Hintergrundfarbe füllt das volle rechteckige Bild
        .environment(\.colorScheme, theme == .light ? .light : .dark)
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch theme {
        case .vibrant:
            RadialGradient(
                stops: [
                    .init(color: Color(red: 1.0, green: 0.95, blue: 0.4), location: 0.0), // Strahlendes Gold
                    .init(color: Color(red: 1.0, green: 0.6, blue: 0.0), location: 0.4),  // Sattes Orange
                    .init(color: Color(red: 0.9, green: 0.35, blue: 0.0), location: 1.0)  // Kräftiges Bernstein/Orange (weniger rot)
                ],
                center: UnitPoint(x: 0.85, y: 0.85),
                startRadius: 10,
                endRadius: 650
            ).ignoresSafeArea()
        case .light:
            Color.white.ignoresSafeArea()
        case .dark:
            Color(hex: "0A0A0A").ignoresSafeArea()
        }
    }
    
    private var textColor: Color {
        theme == .light ? .black : .white
    }
    
    private var shadowColor: Color {
        theme == .dark ? .black.opacity(0.5) : .clear
    }
    
    private var cardBackground: Color {
        switch theme {
        case .dark: return Color.white.opacity(0.08)
        case .light: return Color.white.opacity(0.8)
        case .vibrant: return Color.white.opacity(0.15)
        }
    }
    
    private var cardBorder: Color {
        theme == .dark ? Color.white.opacity(0.15) : Color.black.opacity(0.05)
    }
}

/// A premium Mesh-like gradient for a luxurious feel
struct MeshGradientView: View {
    var body: some View {
        ZStack {
            AngularGradient(
                colors: [.gruenPrimary, .blauPrimary, .lilaPrimary, .orangePrimary, .gruenPrimary],
                center: .center
            )
            .blur(radius: 80)
            .opacity(0.5)
            
            Circle()
                .fill(Color.blauPrimary)
                .frame(width: 400, height: 400)
                .offset(x: -150, y: -150)
                .blur(radius: 100)
                .opacity(0.4)
            
            Circle()
                .fill(Color.gruenPrimary)
                .frame(width: 400, height: 400)
                .offset(x: 150, y: 150)
                .blur(radius: 100)
                .opacity(0.4)
        }
    }
}
struct SharePreviewSheet: View {
    let type: StatisticsDashboard.ShareCardType
    let period: StatsPeriod
    let habits: [HabitModel]
    
    @State private var selectedTheme: ShareImageTheme = .light
    @State private var isExporting = false
    @State private var savedToPhotos = false
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var streakStore: StreakStore
    
    private var username: String {
        let name = settings.igelCustomization.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty ? settings.localizedString(for: "profile.user.name.default") : name
    }
    
    private let themes: [ShareImageTheme] = [.light, .dark, .vibrant]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Swipable Preview Area
                    TabView(selection: $selectedTheme) {
                        ForEach(themes, id: \.self) { theme in
                            previewCard(for: theme)
                                .tag(theme)
                                .padding(.horizontal, 24)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                    .frame(maxHeight: .infinity)
                    .onAppear {
                        UIPageControl.appearance().currentPageIndicatorTintColor = .black
                        UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
                    }
                    
                    VStack(spacing: 8) {
                        Text(settings.localizedString(for: themeNameKey(for: selectedTheme)))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        
                        Text(settings.localizedString(for: "stats.share.swipe_hint"))
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        if savedToPhotos {
                            Label("In Fotos gespeichert", systemImage: "checkmark.circle.fill")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(.green)
                                .transition(.opacity.combined(with: .scale))
                        }
                    }
                    .animation(.spring(), value: savedToPhotos)
                    .padding(.bottom, 60)
                }
            }
            .navigationTitle(settings.localizedString(for: "stats.share.preview_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        exportSelectedTheme()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.black)
                    }
                    .disabled(isExporting)
                    .buttonStyle(.plain)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { saveToPhotos() } label: {
                        if savedToPhotos {
                            Image(systemName: "checkmark")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.green)
                        } else {
                            Image(systemName: "photo.badge.arrow.down")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.primary)
                        }
                    }
                    .disabled(isExporting)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: savedToPhotos)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    LiquidGlassDismissButton { dismiss() }
                }
            }
        }
    }
    
    // Vorschau-Karte (klein, mit abgerundeten Ecken nur in der Vorschau)
    @ViewBuilder
    private func previewCard(for theme: ShareImageTheme) -> some View {
        VStack {
            renderView(for: theme)
                .clipShape(RoundedRectangle(cornerRadius: 36, style: .continuous))
                .shadow(color: .black.opacity(0.15), radius: 30, x: 0, y: 15)
        }
        .scaleEffect(0.7)
    }
    
    // Das eigentliche Bild ohne Rundungen (für Export)
    @ViewBuilder
    private func renderView(for theme: ShareImageTheme) -> some View {
        let data = gardenScoreData
        let periodLabel: String = {
            switch period {
            case .day:    return settings.localizedString(for: "statistik_share_heute")
            case .week:   return settings.localizedString(for: "statistik_share_letzte_woche")
            case .month:  return settings.localizedString(for: "statistik_share_letzter_monat")
            case .year:   return settings.localizedString(for: "statistik_share_letztes_jahr")
            case .allTime: return settings.localizedString(for: "statistik_share_alle")
            }
        }()
        
        Group {
            switch type {
            case .lifeBalance:
                RadarChartShareImage(
                    habits: habits,
                    selectedPeriod: period,
                    username: username,
                    theme: theme,
                    vibrantColor: .blauPrimary
                )
            case .consistency:
                let history = StatsHelper.getWateringHistory(from: habits, badHabitExecutions: gardenStore.badHabitExecutions, days: period.days)
                let currentScore = history.last?.count ?? 0
                StatShareImage(
                    title: settings.localizedString(for: "stats.score.konsistenz"),
                    subtitle: periodLabel,
                    username: username,
                    height: 520,
                    theme: theme,
                    vibrantColor: .gruenPrimary
                ) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("\(currentScore)")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundStyle(Color.gruenPrimary)
                        
                        Chart {
                            ForEach(history) { item in
                                LineMark(
                                    x: .value("Tag", item.date),
                                    y: .value("Gegossen", item.count)
                                )
                                .interpolationMethod(.stepEnd)
                                .foregroundStyle(Color.gruenPrimary)
                                .lineStyle(StrokeStyle(lineWidth: 2))
                                
                                AreaMark(
                                    x: .value("Tag", item.date),
                                    y: .value("Gegossen", item.count)
                                )
                                .interpolationMethod(.stepEnd)
                                .foregroundStyle(LinearGradient(
                                    colors: [Color.gruenPrimary.opacity(0.25), Color.gruenPrimary.opacity(0)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ))
                            }
                        }
                        .chartXAxis {
                            AxisMarks(values: .automatic) { _ in
                                AxisGridLine()
                                AxisValueLabel()
                            }
                        }
                        .chartYAxis {
                            AxisMarks(values: .automatic) { _ in
                                AxisGridLine()
                                AxisValueLabel()
                            }
                        }
                        .frame(height: 120)
                    }
                    .padding(16)
                }
            case .streak:
                StatShareImage(
                    title: settings.localizedString(for: "stats.score.streak"),
                    subtitle: periodLabel,
                    username: username,
                    height: 520,
                    theme: theme,
                    vibrantColor: .orangePrimary
                ) {
                    VStack(spacing: 28) {
                        GardenFactorRow(
                            icon: "flame.fill",
                            color: Color.orangePrimary,
                            label: settings.localizedString(for: "stats.score.streak"),
                            sublabel: String(format: settings.localizedString(for: "stats.score.streak.period_format"), settings.localizedString(for: period.thisPeriodKey)),
                            value: data.streakScore,
                            valueText: "\(data.bestStreakInPeriod)d · \(Int(data.streakScore * 100))%"
                        )
                        .padding(.horizontal, 8)
                        
                        HStack {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(Color.orange)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(settings.localizedString(for: "stats.streak.best"))
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(.secondary)
                                let dayKey = data.bestStreakInPeriod == 1 ? "common.day" : "common.days"
                                Text("\(data.bestStreakInPeriod) " + settings.localizedString(for: dayKey))
                                    .font(.system(size: 20, weight: .black, design: .rounded))
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 20))
                    }
                    .padding(16)
                }
            case .milestones:
                MilestonesShareImage(
                    milestones: closestToLevelUp,
                    username: username,
                    theme: theme
                )
            case .activity:
                let history = StatsHelper.getWateringHistory(from: habits, badHabitExecutions: gardenStore.badHabitExecutions, days: period.days)
                let currentScore = history.last?.count ?? 0
                StatShareImage(
                    title: settings.localizedString(for: "stats.activity.title"),
                    subtitle: periodLabel,
                    username: username,
                    height: 520,
                    theme: theme,
                    vibrantColor: .gruenPrimary
                ) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("\(currentScore)")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundStyle(Color.gruenPrimary)
                        
                        Chart {
                            ForEach(history) { item in
                                LineMark(
                                    x: .value("Tag", item.date),
                                    y: .value("Gegossen", item.count)
                                )
                                .interpolationMethod(.stepEnd)
                                .foregroundStyle(Color.gruenPrimary)
                                .lineStyle(StrokeStyle(lineWidth: 2))
                                
                                AreaMark(
                                    x: .value("Tag", item.date),
                                    y: .value("Gegossen", item.count)
                                )
                                .interpolationMethod(.stepEnd)
                                .foregroundStyle(LinearGradient(
                                    colors: [Color.gruenPrimary.opacity(0.25), Color.gruenPrimary.opacity(0)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ))
                            }
                        }
                        .chartXAxis {
                            AxisMarks(values: .automatic) { _ in
                                AxisGridLine()
                                AxisValueLabel()
                            }
                        }
                        .chartYAxis {
                            AxisMarks(values: .automatic) { _ in
                                AxisGridLine()
                                AxisValueLabel()
                            }
                        }
                        .frame(height: 120)
                    }
                    .padding(16)
                }
            case .xp:
                let history = StatsHelper.getXPHistory(from: habits, currentTotalXP: gardenStore.gesamtXP, days: period.days)
                let currentScore = history.last?.amount ?? 0
                StatShareImage(
                    title: settings.localizedString(for: "stats.xp.title"),
                    subtitle: periodLabel,
                    username: username,
                    height: 520,
                    theme: theme,
                    vibrantColor: .blauPrimary
                ) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("\(currentScore)")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundStyle(Color.blauPrimary)
                        
                        Chart {
                            ForEach(history) { item in
                                LineMark(
                                    x: .value("Tag", item.date),
                                    y: .value("XP", item.amount)
                                )
                                .foregroundStyle(Color.blauPrimary)
                                .lineStyle(StrokeStyle(lineWidth: 2))
                                
                                AreaMark(
                                    x: .value("Tag", item.date),
                                    y: .value("XP", item.amount)
                                )
                                .foregroundStyle(LinearGradient(
                                    colors: [Color.blauPrimary.opacity(0.25), Color.blauPrimary.opacity(0)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ))
                            }
                        }
                        .chartXAxis {
                            AxisMarks(values: .automatic) { _ in
                                AxisGridLine()
                                AxisValueLabel()
                            }
                        }
                        .chartYAxis {
                            AxisMarks(values: .automatic) { _ in
                                AxisGridLine()
                                AxisValueLabel()
                            }
                        }
                        .frame(height: 120)
                    }
                    .padding(16)
                }
            case .coins:
                let history = StatsHelper.getCoinHistory(from: gardenStore.transactions, currentBalance: gardenStore.coins, days: period.days)
                let currentScore = history.last?.balance ?? 0
                StatShareImage(
                    title: settings.localizedString(for: "stats.coins.title"),
                    subtitle: periodLabel,
                    username: username,
                    height: 520,
                    theme: theme,
                    vibrantColor: .goldPrimary
                ) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("\(currentScore)")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundStyle(Color.goldPrimary)
                        
                        Chart {
                            ForEach(history) { item in
                                LineMark(
                                    x: .value("Tag", item.date),
                                    y: .value("Coins", item.balance)
                                )
                                .foregroundStyle(Color.goldPrimary)
                                .lineStyle(StrokeStyle(lineWidth: 2))
                                
                                AreaMark(
                                    x: .value("Tag", item.date),
                                    y: .value("Coins", item.balance)
                                )
                                .foregroundStyle(LinearGradient(
                                    colors: [Color.goldPrimary.opacity(0.25), Color.goldPrimary.opacity(0)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ))
                            }
                        }
                        .chartXAxis {
                            AxisMarks(values: .automatic) { _ in
                                AxisGridLine()
                                AxisValueLabel()
                            }
                        }
                        .chartYAxis {
                            AxisMarks(values: .automatic) { _ in
                                AxisGridLine()
                                AxisValueLabel()
                            }
                        }
                        .frame(height: 120)
                    }
                    .padding(16)
                }
            }
        }
    }
    
    private func themeNameKey(for theme: ShareImageTheme) -> String {
        switch theme {
        case .vibrant: return "stats.share.style.vibrant"
        case .light: return "stats.share.style.light"
        case .dark: return "stats.share.style.dark"
        }
    }
    
    private func makeImage() -> UIImage? {
        let view = AnyView(
            renderView(for: selectedTheme)
                .environmentObject(settings)
                .environmentObject(gardenStore)
                .environmentObject(streakStore)
        )
        let renderer = ImageRenderer(content: view)
        renderer.scale = 3.0
        return renderer.uiImage
    }
    
    private func saveToPhotos() {
        isExporting = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            guard let image = makeImage() else { isExporting = false; return }
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                DispatchQueue.main.async {
                    if status == .authorized || status == .limited {
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                        withAnimation { savedToPhotos = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation { savedToPhotos = false }
                        }
                    }
                    isExporting = false
                }
            }
        }
    }
    
    private func exportSelectedTheme() {
        isExporting = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            guard let image = makeImage() else { isExporting = false; return }
            let activityVC = UIActivityViewController(
                activityItems: [image],
                applicationActivities: nil
            )
            if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
               let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
                var topVC = window.rootViewController
                while let presented = topVC?.presentedViewController { topVC = presented }
                topVC?.present(activityVC, animated: true)
            }
            isExporting = false
        }
    }
    
    // Duplicate helper logic from StatisticsDashboard
    private var gardenScoreData: (score: Int, konsistenz: Double, streakScore: Double, message: String, bestStreakInPeriod: Int) {
        let days = period.days
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let now = Date()
        let dayOffset = -Int(days)
        let startDate = calendar.date(byAdding: .day, value: dayOffset, to: today)!
        let totalPossible = habits.count * (days + 1)
        let totalDone = habits.reduce(0) { count, habit in
            count + habit.wateringDates.filter { $0 >= startDate && $0 <= now }.count
        }
        let konsistenz = totalPossible > 0 ? Double(totalDone) / Double(totalPossible) : 0.0
        let bestStreakInPeriod = habits.map { habit -> Int in
            let datesInPeriod = habit.wateringDates.filter { $0 >= startDate && $0 <= now }.map { calendar.startOfDay(for: $0) }
            let uniqueDays = Set(datesInPeriod).sorted()
            var best = 0, current = 0, lastDay: Date? = nil
            for day in uniqueDays {
                if let last = lastDay, calendar.dateComponents([.day], from: last, to: day).day == 1 { current += 1 } else { current = 1 }
                best = max(best, current); lastDay = day
            }
            return best
        }.max() ?? 0
        let streakScore = min(1.0, Double(bestStreakInPeriod) / Double(days + 1))
        let scoreValue = Int((konsistenz * 0.6 + streakScore * 0.4) * 100)
        return (scoreValue, konsistenz, streakScore, "", bestStreakInPeriod)
    }
    
    private var closestToLevelUp: [HabitModel] {
        habits.filter { $0.seltenheit != PflanzenSeltenheit.diamant }.sorted { a, b in
            let aRem = (a.seltenheit.naechste?.xpSchwelle ?? 0) - a.currentXP
            let bRem = (b.seltenheit.naechste?.xpSchwelle ?? 0) - b.currentXP
            return aRem < bRem
        }.prefix(3).map { $0 }
    }
}

struct MiniScoreIndicator: View {
    let label: String
    let value: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)%")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
    }
}

struct GardenFactorRow: View {
    let icon: String
    let color: Color
    let label: String
    let sublabel: String
    let value: Double  // 0.0 – 1.0
    var valueText: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.system(size: 13, weight: .bold))
                
                Text(label)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                
                Spacer()
                
                Text(valueText ?? "\(Int(value * 100))%")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(color)
            }
            
            // Fortschrittsbalken
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(color.opacity(0.12))
                        .frame(height: 10)
                    
                    Capsule()
                        .fill(color)
                        .frame(width: geo.size.width * CGFloat(max(0, min(1, value))), height: 10)
                        .animation(.spring(response: 0.8, dampingFraction: 0.7), value: value)
                }
            }
            .frame(height: 10)
            
            Text(sublabel)
                .font(.system(size: 11, weight: .regular, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }
}

struct CoachBulletPoint: View {
    let icon: String
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.orangePrimary)
                .frame(width: 24, height: 24)
                .background(Color.orangePrimary.opacity(0.1), in: Circle())
            
            Text(text)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.primary.opacity(0.8))
        }
    }
}

struct DetailInfoBox: View {
    let title: String
    let value: String
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.title2.bold())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.secondary.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
    }
}
