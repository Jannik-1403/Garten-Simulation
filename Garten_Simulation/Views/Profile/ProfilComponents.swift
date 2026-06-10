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
                    Button { dismiss() } label: { Image(systemName: "xmark").foregroundStyle(.primary) }
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
                    gardenScoreStreakCard
                    nextMilestonesCard
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
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.primary)
                }
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
    
    enum ShareCardType {
        case lifeBalance
        case consistency
        case streak
        case milestones
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
            
            Divider()
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            
            // 2x2 Stats Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                StatTile(title: "statistik_kachel_gewaessert", value: "\(currentWaterings)", delta: wateringsDelta, farbe: Color(uiColor: .systemGray6), sekundaerFarbe: Color(uiColor: .systemGray5), settings: settings)
                StatTile(title: "statistik_kachel_streak", value: "\(currentStreak)", delta: 0, farbe: Color(uiColor: .systemGray6), sekundaerFarbe: Color(uiColor: .systemGray5), settings: settings)
                StatTile(title: "statistik_kachel_pflanzen", value: "\(currentPlants)", delta: plantsDelta, farbe: Color(uiColor: .systemGray6), sekundaerFarbe: Color(uiColor: .systemGray5), settings: settings)
                StatTile(title: "statistik_kachel_gems", value: "\(currentGems)", delta: gemsDelta, farbe: Color(uiColor: .systemGray6), sekundaerFarbe: Color(uiColor: .systemGray5), settings: settings)
            }
            .padding(16)
        }
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
    }

    private var gardenScoreConsistencyCard: some View {
        let data = gardenScoreData
        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label(settings.localizedString(for: "stats.score.konsistenz"), systemImage: "checkmark.circle.fill")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.gruenPrimary)
                Spacer()
                
                Button(action: { initiateShare(.consistency) }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.black)
                        .padding(8)
                }
            }
            
            GardenFactorRow(
                icon: "checkmark.circle.fill",
                color: .gruenPrimary,
                label: settings.localizedString(for: "stats.score.konsistenz"),
                sublabel: String(format: settings.localizedString(for: "stats.score.konsistenz.period_format"), settings.localizedString(for: selectedPeriod.thisPeriodKey)),
                value: data.konsistenz
            )
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
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
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
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
                                .frame(width: 32, height: 32)
                            
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
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
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

struct StatDetailFullscreenView: View {
    let detail: StatisticsDashboard.StatDetail
    let selectedPeriod: StatsPeriod
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    
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
                    content
                }
                .padding(20)
            }
            .background(Color.appHintergrund.ignoresSafeArea())
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .black))
                            .foregroundStyle(.primary)
                    }
                }
            }
        }
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
        let history = StatsHelper.getWateringHistory(from: gardenStore.pflanzen)
        return VStack(spacing: 24) {
            Chart {
                ForEach(history) { item in
                    BarMark(
                        x: .value("Tag", item.date, unit: .day),
                        y: .value("Gegossen", item.count)
                    )
                    .foregroundStyle(Color.blauPrimary.gradient)
                    .cornerRadius(8)
                }
            }
            .frame(height: 300)
            
            VStack(alignment: .leading, spacing: 16) {
                Text(settings.localizedString(for: selectedPeriod.thisPeriodKey))
                    .font(.headline)
                
                HStack(spacing: 20) {
                    DetailInfoBox(title: settings.localizedString(for: "stats.succeeded"), value: "\(gardenStore.pflanzen.filter { $0.istBewässert }.count)")
                    DetailInfoBox(title: settings.localizedString(for: "stats.missed"), value: "\(gardenStore.pflanzen.filter { !$0.istBewässert }.count)")
                }
            }
        }
    }
    
    private var balanceContent: some View {
        return VStack(spacing: 32) {
            RadarChartView(habits: gardenStore.pflanzen, selectedPeriod: selectedPeriod)
                .frame(height: 350)
                .padding(.vertical, 20)
            
            VStack(alignment: .leading, spacing: 16) {
                Label(settings.localizedString(for: "stats.coach.title"), systemImage: "lightbulb.fill")
                    .font(.headline)
                    .foregroundStyle(Color.orangePrimary)
                
                VStack(alignment: .leading, spacing: 12) {
                    CoachBulletPoint(icon: "center.circle.fill", text: settings.localizedString(for: "stats.coach.bullet1"))
                    CoachBulletPoint(icon: "circle.circle.fill", text: settings.localizedString(for: "stats.coach.bullet2"))
                    CoachBulletPoint(icon: "waveform.path.ecg", text: settings.localizedString(for: "stats.coach.bullet3"))
                    CoachBulletPoint(icon: "checkmark.seal.fill", text: settings.localizedString(for: "stats.coach.bullet4"))
                }
                .padding()
                .background(Color.orangePrimary.opacity(0.05), in: RoundedRectangle(cornerRadius: 16))
            }
            
            Text(settings.localizedString(for: "stats.balance.description"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var xpContent: some View {
        let history = StatsHelper.getXPHistory(from: gardenStore.pflanzen, currentTotalXP: gardenStore.gesamtXP)
        return VStack(spacing: 24) {
            Chart {
                ForEach(history) { item in
                    LineMark(x: .value("Tag", item.date), y: .value("XP", item.amount))
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(Color.blauPrimary)
                        .lineStyle(StrokeStyle(lineWidth: 4))
                    
                    AreaMark(x: .value("Tag", item.date), y: .value("XP", item.amount))
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(LinearGradient(colors: [.blauPrimary.opacity(0.4), .blauPrimary.opacity(0)], startPoint: .top, endPoint: .bottom))
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 1)) { _ in
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                }
            }
            .frame(height: 300)
        }
    }
    
    private var coinsContent: some View {
        let history = StatsHelper.getCoinHistory(from: gardenStore.transactions, currentBalance: gardenStore.coins)
        return VStack(spacing: 24) {
            Chart {
                ForEach(history) { item in
                    LineMark(x: .value("Tag", item.date), y: .value("Coins", item.balance))
                        .interpolationMethod(.monotone)
                        .foregroundStyle(Color.blauPrimary)
                        .lineStyle(StrokeStyle(lineWidth: 3))
                    
                    AreaMark(x: .value("Tag", item.date), y: .value("Coins", item.balance))
                        .interpolationMethod(.monotone)
                        .foregroundStyle(Color.blauPrimary.opacity(0.2))
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 1)) { _ in
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                }
            }
            .frame(height: 300)
        }
    }
    
    private var milestonesContent: some View {
        VStack(spacing: 20) {
            ForEach(closestToLevelUp) { habit in
                VStack(spacing: 12) {
                    HStack(spacing: 16) {
                        Image(habit.plantImageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                        
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
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(theme == .light ? Color.white.opacity(0.4) : Color.white.opacity(0.08))
                            .shadow(color: .black.opacity(theme == .light ? 0.05 : 0.2), radius: 10, x: 0, y: 5)
                    )
                }
            }
            .padding(24)
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
                    Text(title)
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundColor(textColor)
                        .shadow(color: shadowColor, radius: 1, x: 0, y: 1)
                    
                    Text(subtitle)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(textColor.opacity(0.7))
                }
                .padding(.top, 44)
                .padding(.horizontal, 36)
                
                Spacer()
                
                // Content Area (Direct on Background - No Card/Glass)
                content
                    .padding(24)
                
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
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .black))
                            .foregroundStyle(.primary)
                    }
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
            case .week:   return settings.localizedString(for: "statistik_share_letzte_woche")
            case .month:  return settings.localizedString(for: "statistik_share_letzter_monat")
            case .year:   return settings.localizedString(for: "statistik_share_letztes_jahr")
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
                StatShareImage(
                    title: settings.localizedString(for: "stats.score.konsistenz"),
                    subtitle: periodLabel,
                    username: username,
                    height: 520,
                    theme: theme,
                    vibrantColor: .orangePrimary
                ) {
                    VStack(spacing: 28) {
                        GardenFactorRow(
                            icon: "checkmark.circle.fill",
                            color: Color.orangePrimary,
                            label: settings.localizedString(for: "stats.score.konsistenz"),
                            sublabel: String(format: settings.localizedString(for: "stats.score.konsistenz.period_format"), settings.localizedString(for: period.thisPeriodKey)),
                            value: data.konsistenz
                        )
                        .padding(.horizontal, 8)
                        
                        HStack(spacing: 20) {
                            DetailInfoBox(title: settings.localizedString(for: "stats.succeeded"), value: "\(habits.filter { $0.istBewässert }.count)")
                            DetailInfoBox(title: settings.localizedString(for: "stats.missed"), value: "\(habits.filter { !$0.istBewässert }.count)")
                        }
                    }
                    .padding(32)
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
                    .padding(32)
                }
            case .milestones:
                MilestonesShareImage(
                    milestones: closestToLevelUp,
                    username: username,
                    theme: theme
                )
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
