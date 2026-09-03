with open("Garten_Simulation/Views/ComebackBoostOverlayView.swift", "r") as f:
    content = f.read()

content = content.replace(
    '"\\(rewardPercent)%"',
    'rewardPercent.formatted(.percent)'
)

with open("Garten_Simulation/Views/ComebackBoostOverlayView.swift", "w") as f:
    f.write(content)
print("Done")
