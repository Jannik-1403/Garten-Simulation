import re

with open("Garten_Simulation/Views/GartenView.swift", "r") as f:
    content = f.read()
    
# Replace weed_banner_subtitle
content = re.sub(
    r'"\\\(gardenStore\.weedEffectiveRewardPercent\)%"',
    r'gardenStore.weedEffectiveRewardPercent.formatted(.percent)',
    content
)

# Replace weed.comeback.banner
content = re.sub(
    r'"\\\(gardenStore\.comebackBoostRewardPercent\)%"',
    r'gardenStore.comebackBoostRewardPercent.formatted(.percent)',
    content
)

with open("Garten_Simulation/Views/GartenView.swift", "w") as f:
    f.write(content)


with open("Garten_Simulation/Views/WeedDetailView.swift", "r") as f:
    content = f.read()

content = content.replace(
    'let percentString = "\\(gardenStore.weedEffectiveRewardPercent)%"',
    'let percentString = gardenStore.weedEffectiveRewardPercent.formatted(.percent)'
)
content = content.replace(
    '"\\(gardenStore.weedEffectiveRewardPercent)% XP"',
    '"\\(percentString) XP"'
)
content = content.replace(
    '"\\(gardenStore.weedEffectiveRewardPercent)%"',
    'percentString'
)

with open("Garten_Simulation/Views/WeedDetailView.swift", "w") as f:
    f.write(content)

print("Fixed Views!")
