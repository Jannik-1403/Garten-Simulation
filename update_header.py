import re

file_path = "Garten_Simulation/Views/GartenView.swift"
with open(file_path, "r") as f:
    content = f.read()

# Remove the full width ultraThinMaterial
content = content.replace("staticHeaderBar\n                    .background(.ultraThinMaterial)\n                    .zIndex(1)", "staticHeaderBar\n                    .zIndex(1)")

# Add pill styling inside staticHeaderBar
old_header = """    @ViewBuilder
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
    }"""
new_header = """    @ViewBuilder
    private var staticHeaderBar: some View {
        GartenStatsBar(
            streak: streakStore.currentStreak,
            coins: gardenStore.coins,
            leben: gardenStore.leben,
            onStreakTap: { zeigeStreakDetail = true },
            onCoinsTap: { zeigeCoinsDetail = true },
            onLebenTap: { zeigeLebenDetail = true }
        )
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .padding(.horizontal)
        .padding(.top, 16)
        .frame(maxWidth: 850)
    }"""
content = content.replace(old_header, new_header)

with open(file_path, "w") as f:
    f.write(content)
