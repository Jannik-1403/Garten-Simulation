with open("Garten_Simulation/Views/LevelUpOverlayView.swift", "r") as f:
    content = f.read()

content = content.replace(
    'String(localized: String.LocalizationValue(reward.beschreibung))',
    'PercentHelper.localizedWithPercents(reward.beschreibung)'
)

with open("Garten_Simulation/Views/LevelUpOverlayView.swift", "w") as f:
    f.write(content)
