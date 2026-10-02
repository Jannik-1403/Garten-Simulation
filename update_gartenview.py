import re

file_path = "Garten_Simulation/Views/GartenView.swift"
with open(file_path, "r") as f:
    content = f.read()

# 1. Add dayOffset
if "@State private var dayOffset: Int = 0" not in content:
    content = content.replace("@StateObject private var dailyFeedbackVM", "@State private var dayOffset: Int = 0\n    @StateObject private var dailyFeedbackVM")

# 2. Modify mainContentView to use TabView
new_main_content = """
    @ViewBuilder
    private var mainContentView: some View {
        ZStack {
            Color.appHintergrund.ignoresSafeArea()

            VStack(spacing: 0) {
                // Statische Header Bar (ohne DailyHealthScoreCard)
                staticHeaderBar
                    .background(.ultraThinMaterial)
                    .zIndex(1)

                TabView(selection: $dayOffset) {
                    ForEach(-30...0, id: \.self) { offset in
                        pageContent(for: offset)
                            .tag(offset)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onChange(of: dayOffset) { _, newValue in
                    dailyFeedbackVM.targetDate = Calendar.current.date(byAdding: .day, value: newValue, to: Date()) ?? Date()
                    dailyFeedbackVM.reevaluate()
                }
            }
        }
    }

    @ViewBuilder
    private func pageContent(for offset: Int) -> some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    Spacer().frame(height: 10)
                    
                    if !gardenStore.sichtbarePflanzen.isEmpty {
                        DailyHealthScoreCard(vm: dailyFeedbackVM)
                            .padding(.vertical, 8)
                            .frame(maxWidth: 850)
                            .padding(.horizontal)
                    }
                    
                    xpMultiplierSection
                        .padding(.horizontal)
                    
                    VStack(spacing: 10) {
                        comebackBoostSection
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)

                    if gardenStore.sichtbarePflanzen.isEmpty {
                        GartenIgelView(text: String(localized: "garden.empty.subtitle", defaultValue: "Füge deine erste Pflanze hinzu!"))
                            .padding(.top, 20)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                    } else {
                        pflanzenGridSection
                    }

                    Spacer().frame(height: 60)
                }
                .frame(maxWidth: 850)
                .coordinateSpace(name: "GartenGrid")
            }
        }
    }

    @ViewBuilder
    private var staticHeaderBar: some View {
        GartenStatsBar(
            streak: streakStore.currentStreak,
            coins: gardenStore.coins,
            leben: gardenStore.leben,
            onStreakTap: { zeigeStreakDetail = true },
            onCoinsTap: { zeigeCoinsDetail = true },
            onLebenTap: { zeigeLebenDetail = true }
        )
        .padding(.top, 16)
        .padding(.bottom, 10)
        .frame(maxWidth: 850)
    }
"""

# Replace the whole mainContentView up to stickyHeaderBar
start_str = "    @ViewBuilder\n    private var mainContentView: some View {"
end_str = "    // MARK: - Tages-Event\n    func ladeTagesEvent() {"
start_idx = content.find(start_str)
end_idx = content.find(end_str)

if start_idx != -1 and end_idx != -1:
    content = content[:start_idx] + new_main_content + "\n" + content[end_idx:]

# 3. Remove the old stickyHeaderBar and its related components because they are now in pageContent / staticHeaderBar
start_sticky = "    @ViewBuilder\n    private var stickyHeaderBar: some View {"
end_sticky = "    // MARK: - Filter Sheet\n    private var filterSheet: some View {"
start_idx2 = content.find(start_sticky)
end_idx2 = content.find(end_sticky)
if start_idx2 != -1 and end_idx2 != -1:
    # Just remove it completely
    content = content[:start_idx2] + content[end_idx2:]

with open(file_path, "w") as f:
    f.write(content)
