import SwiftUI

// MARK: - ProfilXPBarView
struct ProfilXPBarView: View {
    let seltenheit: PflanzenSeltenheit
    let aktuelleXP: Int
    
    @EnvironmentObject var settings: SettingsStore
    @State private var animierterFortschritt: Double = 0.0
    
    private var fortschritt: Double {
        seltenheit.fortschritt(aktuelleXP: aktuelleXP)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(seltenheit.lokalisiertTitel)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(seltenheit.farbe)
                
                Spacer()
                
                if let naechste = seltenheit.naechste {
                    Text("\(aktuelleXP) / \(naechste.xpSchwelle) \(settings.localizedString(for: "common.xp"))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("\(aktuelleXP) \(settings.localizedString(for: "common.xp"))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(UIColor.tertiarySystemFill))
                        .frame(height: 14)
                    
                    Capsule()
                        .fill(seltenheit.farbe)
                        .frame(width: max(0, geo.size.width * CGFloat(animierterFortschritt)), height: 14)
                        .shadow(color: seltenheit.farbe.opacity(0.6), radius: 6, y: 2)
                }
            }
            .frame(height: 14)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                    animierterFortschritt = max(0, min(1, fortschritt))
                }
            }
            .onChange(of: fortschritt) { _, newValue in
                withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                    animierterFortschritt = max(0, min(1, newValue))
                }
            }
            
            if let naechste = seltenheit.naechste {
                Text(String(format: settings.localizedString(for: "stufe.naechste.hinweis"),
                    Int64(max(0, naechste.xpSchwelle - aktuelleXP)),
                    naechste.lokalisiertTitel))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                Text(settings.localizedString(for: "profile.level.max"))
                    .font(.caption2)
                    .foregroundStyle(seltenheit.farbe)
            }
        }
    }
}

// MARK: - ProfilHeaderView
struct ProfilHeaderView: View {
    let name: String
    let seltenheit: PflanzenSeltenheit
    @EnvironmentObject var settings: SettingsStore
    
    var body: some View {
        VStack(spacing: 6) {
            Text(name)
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            HStack(spacing: 6) {
                Image(systemName: seltenheit.iconName)
                    .foregroundStyle(seltenheit.farbe)
                    .font(.caption)
                
                Text(seltenheit.lokalisiertTitel)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(seltenheit.farbe)
            }
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
        VStack(spacing: 6) {
            Item3DButton(
                icon: "XP",
                farbe: Color(hex: "#FFD000"),          // Blitzgelb
                sekundaerFarbe: Color(hex: "#D9A300"), // dunkles Gelb
                groesse: 80,
                aktion: { showDetail = true }
            )
            Text("\(xp)")
                .font(.system(size: 22, weight: .black, design: .rounded))
            Text(settings.localizedString(for: "profile.xp.total"))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct InventoryStatButton: View {
    let count: Int
    @Binding var showDetail: Bool
    @EnvironmentObject var settings: SettingsStore
    
    var body: some View {
        VStack(spacing: 6) {
            Item3DButton(
                icon: "Inventar",
                farbe: Color(hex: "#8B4513"),          // Holz-Braun
                sekundaerFarbe: Color(hex: "#5D2E0C"), // dunkles Braun
                groesse: 80,
                aktion: { showDetail = true }
            )
            Text("\(count)")
                .font(.system(size: 22, weight: .black, design: .rounded))
            Text(settings.localizedString(for: "profile.inventory"))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct StreakStatButton: View {
    let currentStreak: Int
    let bestStreak: Int
    var aktion: (() -> Void)? = nil
    @EnvironmentObject var settings: SettingsStore
    
    var body: some View {
        VStack(spacing: 6) {
            Item3DButton(
                icon: "streak",
                farbe: Color(hex: "#FF4B00"),          // Flammen-Rot/Orange
                sekundaerFarbe: Color(hex: "#C43D00"), // dunkles Rot
                groesse: 80,
                aktion: aktion
            )
            
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text("\(bestStreak)")
                    .font(.system(size: 22, weight: .black, design: .rounded))
            }
            
            Text(settings.localizedString(for: "profile.streak.best"))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct ErfolgeStatButton: View {
    let count: Int
    @Binding var showDetail: Bool
    @EnvironmentObject var settings: SettingsStore
    
    var body: some View {
        VStack(spacing: 6) {
            Item3DButton(
                icon: "Erfolg",
                farbe: Color(hex: "#FFB800"),          // Trophäen-Gold
                sekundaerFarbe: Color(hex: "#C5A000"), // dunkles Gold
                groesse: 80,
                aktion: { showDetail = true }
            )
            
            Text("\(count)")
                .font(.system(size: 22, weight: .black, design: .rounded))

            Text(settings.localizedString(for: "profile.achievements"))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct WasserStatButton: View {
    let liter: String
    @Binding var showDetail: Bool
    @EnvironmentObject var settings: SettingsStore
    
    var body: some View {
        VStack(spacing: 6) {
            Item3DButton(
                icon: "Drop water",
                farbe: .blauPrimary,
                sekundaerFarbe: .blauSecondary,
                groesse: 80,
                aktion: { showDetail = true }
            )
            
            VStack(spacing: 0) {
                Text(settings.localizedString(for: "wasser.karte.titel"))
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                
                Text(liter)
                    .font(.system(size: 22, weight: .black, design: .rounded))
                
                Text(settings.localizedString(for: "wasser.gesamt"))
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
    }
}
import SwiftUI
import Charts

struct StatisticsDashboard: View {
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var streakStore: StreakStore
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                consistencySection
                plantsAnalysisSection
                coinIncomeSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .padding(.bottom, 40)
        }
        .background(Color.appHintergrund.ignoresSafeArea())
        .navigationTitle(settings.localizedString(for: "stats.title"))
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Consistency (30 Days)
    
    private var consistencySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(settings.localizedString(for: "stats.consistency.title").uppercased())
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
            
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(Color.blauPrimary.opacity(0.15), lineWidth: 12)
                    
                    Circle()
                        .trim(from: 0, to: consistencyRatio)
                        .stroke(Color.blauPrimary, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 1.0, dampingFraction: 0.8), value: consistencyRatio)
                    
                    VStack(spacing: 2) {
                        Text("\(Int(consistencyRatio * 100))%")
                            .font(.system(size: 24, weight: .heavy, design: .rounded))
                        Text("30d")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 80, height: 80)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(String(format: settings.localizedString(for: "stats.consistency.desc"), daysCompleted))
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                    
                    if daysCompleted == 30 {
                        Text("Perfekt! 🔥")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.orange)
                    } else if daysCompleted >= 20 {
                        Text("Starke Leistung! 🌱")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.gruenPrimary)
                    } else {
                        Text("Bleib dran! 💧")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.blue)
                    }
                }
                Spacer()
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(UIColor.secondarySystemGroupedBackground)))
        }
    }
    
    // MARK: - Plants Analysis
    
    private var plantsAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                // Top Plant
                if let best = gardenStore.pflanzen.max(by: { $0.streak < $1.streak }) {
                    PlantStatCard(
                        title: settings.localizedString(for: "stats.plants.top"),
                        plant: best,
                        icon: "trophy.fill",
                        color: .goldPrimary,
                        subtitle: "\(best.streak) Tage"
                    )
                }
                
                // Needs Love
                if let worst = gardenStore.pflanzen.min(by: { ($0.istBewässert ? 1 : 0) > ($1.istBewässert ? 1 : 0) || $0.streak > $1.streak }) {
                    PlantStatCard(
                        title: settings.localizedString(for: "stats.plants.worst"),
                        plant: worst,
                        icon: "heart.slash.fill",
                        color: .red,
                        subtitle: worst.istBewässert ? "Zufrieden" : "Durstig"
                    )
                }
            }
        }
    }
    
    // MARK: - Coin Income
    
    private var coinIncomeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(settings.localizedString(for: "stats.coins.income").uppercased())
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
            
            VStack {
                if monthlyCoinData.isEmpty {
                    Text(settings.localizedString(for: "stats.coins.empty"))
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 40)
                } else {
                    Chart {
                        ForEach(monthlyCoinData) { data in
                            BarMark(
                                x: .value("Monat", data.monthString),
                                y: .value("Münzen", data.amount)
                            )
                            .foregroundStyle(Color.coinBlue.gradient)
                            .cornerRadius(4)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            AxisGridLine()
                            AxisValueLabel() {
                                if let intValue = value.as(Int.self) {
                                    Text("\(intValue)")
                                        .font(.system(size: 10, weight: .bold, design: .rounded))
                                }
                            }
                        }
                    }
                    .chartXAxis {
                        AxisMarks { value in
                            AxisValueLabel() {
                                if let strValue = value.as(String.self) {
                                    Text(strValue)
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                }
                            }
                        }
                    }
                    .frame(height: 200)
                    .padding(.top, 16)
                }
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(UIColor.secondarySystemGroupedBackground)))
        }
    }
    
    // MARK: - Computeds
    
    private var daysCompleted: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var count = 0
        for i in 0..<30 {
            if let d = calendar.date(byAdding: .day, value: -i, to: today),
               streakStore.isDateCompleted(d) {
                count += 1
            }
        }
        return count
    }
    
    private var consistencyRatio: Double {
        return Double(daysCompleted) / 30.0
    }
    
    private struct MonthlyCoin: Identifiable {
        let id = UUID()
        let date: Date
        let amount: Int
        
        var monthString: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            return formatter.string(from: date)
        }
    }
    
    private var monthlyCoinData: [MonthlyCoin] {
        var grouped: [Date: Int] = [:]
        let calendar = Calendar.current
        
        // Filter out expenses, only take income
        let incomeTransactions = gardenStore.transactions.filter { $0.betrag > 0 }
        
        for t in incomeTransactions {
            let components = calendar.dateComponents([.year, .month], from: t.datum)
            if let startOfMonth = calendar.date(from: components) {
                grouped[startOfMonth, default: 0] += t.betrag
            }
        }
        
        // Create array and sort chronologically (oldest first for chart)
        var result = grouped.map { MonthlyCoin(date: $0.key, amount: $0.value) }
        result.sort { $0.date < $1.date }
        
        // Limit to last 6 months
        if result.count > 6 {
            result = Array(result.suffix(6))
        }
        
        return result
    }
}

// MARK: - Subcomponents

struct PlantStatCard: View {
    let title: String
    let plant: HabitModel
    let icon: String
    let color: Color
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: plant.symbolName)
                        .font(.system(size: 20))
                        .foregroundStyle(plant.color)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(plant.displayedHabitName)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        Image(systemName: icon)
                            .font(.system(size: 10))
                        Text(subtitle)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(color)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(UIColor.secondarySystemGroupedBackground)))
    }
}

// For Preview
#Preview {
    let settings = SettingsStore()
    // Mock the data
    let store = GardenStore()
    let sStore = StreakStore()
    
    NavigationStack {
        StatisticsDashboard()
            .environmentObject(settings)
            .environmentObject(store)
            .environmentObject(sStore)
    }
}
