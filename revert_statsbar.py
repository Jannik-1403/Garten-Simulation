import re

file_path = "Garten_Simulation/Components/GartenStatsBar.swift"
with open(file_path, "r") as f:
    content = f.read()

# Ersetze onCalendarTap und Body
old_body = """    var onCalendarTap: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 16) {
            // Coins
            statSektion(
                assetName: "coin",
                wert: coins.formatted(),
                farbe: .primary, // Im Screenshot ist die Zahl Schwarz
                tourStep: .coinsIntro
            )
            .scaleEffect(coinPopScale)
            .contentShape(Rectangle())
            .onTapGesture {
                onCoinsTap?()
            }
            
            // Streak
            statSektion(
                assetName: "streak",
                wert: "\\(streak)",
                farbe: .primary, // Im Screenshot ist die Zahl Schwarz
                tourStep: .streakHeaderIntro
            )
            .contentShape(Rectangle())
            .onTapGesture {
                onStreakTap?()
            }
            .accessibilityIdentifier("button_streak")
            
            // Calendar
            Button {
                onCalendarTap?()
            } label: {
                Image(systemName: "calendar")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(Capsule().stroke(Color.primary.opacity(0.1), lineWidth: 1))
        )
    }"""

new_body = """    var body: some View {
        HStack(spacing: 16) {
            // Coins
            statSektion(
                assetName: "coin",
                wert: coins.formatted(),
                farbe: .primary,
                tourStep: .coinsIntro
            )
            .scaleEffect(coinPopScale)
            .contentShape(Rectangle())
            .onTapGesture {
                onCoinsTap?()
            }
            
            // Streak
            statSektion(
                assetName: "streak",
                wert: "\\(streak)",
                farbe: .primary,
                tourStep: .streakHeaderIntro
            )
            .contentShape(Rectangle())
            .onTapGesture {
                onStreakTap?()
            }
            .accessibilityIdentifier("button_streak")
            
            // Leben
            statSektion(
                assetName: leben <= 0 ? "Heart death" : (leben <= 3 ? "Heart half" : "Heart"),
                wert: "\\(leben)",
                farbe: .primary,
                tourStep: .livesIntro
            )
            .contentShape(Rectangle())
            .onTapGesture {
                onLebenTap?()
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(Capsule().stroke(Color.primary.opacity(0.1), lineWidth: 1))
        )
    }"""
content = content.replace(old_body, new_body)

with open(file_path, "w") as f:
    f.write(content)
