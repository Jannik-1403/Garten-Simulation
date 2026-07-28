import re

with open('Garten_Simulation/Stores/GardenStore.swift', 'r') as f:
    content = f.read()

# Remove properties
content = re.sub(r'@Published var activePowerUps: \[ActivePowerUp\] = \[\] \{.*?\}', '', content, flags=re.DOTALL)
content = re.sub(r'@Published var aktivesWetter: WetterEvent = \.normal\n', '', content)
content = re.sub(r'var gekauftePowerUps: \[ShopDetailPayload\] \{.*?\}', '', content, flags=re.DOTALL)
content = re.sub(r'var blocksNewWeedSpawns: Bool \{.*?\}', '', content, flags=re.DOTALL)
content = re.sub(r'var availableWeedPowerUpItems: \[ShopDetailPayload\] \{.*?\}', '', content, flags=re.DOTALL)
content = re.sub(r'var hasWeedShieldOption: Bool \{.*?\}', '', content, flags=re.DOTALL)
content = re.sub(r'@Published var pendingWeedPowerUpForRitual: ShopDetailPayload\?\n', '', content)

# In init and reloadData, remove loadActivePowerUps()
content = re.sub(r'\s*loadActivePowerUps\(\)', '', content)

# In debug functions, remove them or empty them
content = re.sub(r'func debugAddWeedPowerUpToInventory.*?\}\n', '', content, flags=re.DOTALL)
content = re.sub(r'func debugActivateGardenPowerUp.*?\}\n', '', content, flags=re.DOTALL)
content = re.sub(r'func debugClearWeedProtection.*?\}\n', '', content, flags=re.DOTALL)
content = re.sub(r'func debugOpenWeedSheetWithShieldPreselected.*?\}\n', '', content, flags=re.DOTALL)

# In pflanzeGestorben
content = re.sub(r'let damage = aktivesWetter == \.sturm \? 2 : 1', 'let damage = 1', content)

# In giessen, remove powerup/weather stuff
content = re.sub(r'let weedPenaltiesApply = isWeedActive && !hasActivePowerUp\(powerUpId: PowerUpWeedSupport\.zauberstabID\)', 'let weedPenaltiesApply = isWeedActive', content)

# In taeglicherStreakCheck, remove zeitkapsel check
content = re.sub(r'let isProtected = activePowerUps\.contains.*?isActive \}\)', 'let isProtected = false', content)
content = re.sub(r'activePowerUps\.removeAll \{ !\$0\.isActive \}', '', content)

# Remove functions
content = re.sub(r'func applyPowerUp\(.*?\n    \}', '', content, flags=re.DOTALL)
content = re.sub(r'func applyZauberstabPowerUp\(.*?\n    \}', '', content, flags=re.DOTALL)
content = re.sub(r'func activePowerUpsFor\(.*?\n    \}', '', content, flags=re.DOTALL)
content = re.sub(r'func plantSpecificActivePowerUps\(.*?\n    \}', '', content, flags=re.DOTALL)
content = re.sub(r'func hasActivePowerUp\(.*?\n    \}', '', content, flags=re.DOTALL)
content = re.sub(r'func saveActivePowerUps\(.*?\n    \}', '', content, flags=re.DOTALL)
content = re.sub(r'private func loadActivePowerUps\(.*?\n    \}', '', content, flags=re.DOTALL)

content = re.sub(r'// MARK: - Wetter-Logik.*?(?=\n\n    // MARK: |\Z)', '', content, flags=re.DOTALL)
content = re.sub(r'func ladeTagesWetter\(.*?\n    \}', '', content, flags=re.DOTALL)
content = re.sub(r'func cycleWetter\(.*?\n    \}', '', content, flags=re.DOTALL)

# Fix multipliers
content = re.sub(r'// 1\. Wetter\n\s*mult \*= aktivesWetter\.xpMultiplikator\n', '', content)
content = re.sub(r'// 1\. Wetter\n\s*mult \*= aktivesWetter\.gemMultiplikator\n', '', content)
content = re.sub(r'// 2\. Wetter\n\s*mult \*= aktivesWetter\.xpMultiplikator\n', '', content)
content = re.sub(r'// 2\. Wetter\n\s*mult \*= aktivesWetter\.gemMultiplikator\n', '', content)

with open('Garten_Simulation/Stores/GardenStore.swift', 'w') as f:
    f.write(content)
