import re

path = "Garten_Simulation/Stores/GardenStore.swift"
with open(path, "r") as f:
    content = f.read()

# Remove ladeTagesWetter
content = re.sub(r'func ladeTagesWetter\(\) \{.*?\n    \}', '', content, flags=re.DOTALL)
# Remove cycleWetter
content = re.sub(r'func cycleWetter\(\) \{.*?\n    \}', '', content, flags=re.DOTALL)

# Remove encode/decode for activePowerUps
content = re.sub(r'if let encoded = try\? JSONEncoder\(\)\.encode\(activePowerUps\) \{.*?\n        \}', '', content, flags=re.DOTALL)
content = re.sub(r'if let decoded = try\? JSONDecoder\(\)\.decode\(\[ActivePowerUp\]\.self, from: data\) \{.*?\n            \}', '', content, flags=re.DOTALL)

# Remove isZeitkapselActive logic
content = re.sub(r'var isZeitkapselActive: Bool \{.*?\}', 'var isZeitkapselActive: Bool { false }', content, flags=re.DOTALL)

# Remove hasActivePowerUp, blocksNewWeedSpawns
content = re.sub(r'if source != \.decoration && blocksNewWeedSpawns \{ return \}', '', content)
content = re.sub(r'if hasActivePowerUp.*?\{', 'if false {', content)

# Remove applyPowerUp calls remaining
content = re.sub(r'let active = ActivePowerUp\([\s\S]*?\n        \)', '', content)
content = re.sub(r'activePowerUps\.append\(active\)', '', content)
content = re.sub(r'activePowerUps\.removeAll.*?\}', '', content)
content = re.sub(r'activePowerUps\.removeAll\(\)', '', content)
content = re.sub(r'activePowerUps\.removeAll', '', content)

# Remove PowerUpWeedSupport
content = re.sub(r'guard let powerUp = GameDatabase\.allPowerUps\.first.*?return false \}', '', content, flags=re.DOTALL)
content = re.sub(r'guard !hasActivePowerUp.*?return false \}', '', content)
content = re.sub(r'case PowerUpWeedSupport.*?:\n.*?return false', '', content, flags=re.DOTALL)

# Remove shop generation for powerups
content = re.sub(r'if let pu = GameDatabase\.allPowerUps\.first.*?\}\n            \}', '', content, flags=re.DOTALL)

with open(path, "w") as f:
    f.write(content)
