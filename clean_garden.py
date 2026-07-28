import re

path = "Garten_Simulation/Stores/GardenStore.swift"
with open(path, "r") as f:
    lines = f.readlines()

new_lines = []
skip = False
for line in lines:
    # Remove ladeTagesWetter, cycleWetter completely
    if re.search(r'func (ladeTagesWetter|cycleWetter)\(', line):
        skip = True
    if skip and line.strip() == "}":
        skip = False
        continue
    if skip:
        continue
    
    # Remove activePowerUps decoding/encoding
    if "activePowerUps" in line or "ActivePowerUp" in line:
        if "encode" in line or "decode" in line:
            continue
        if "removeAll" in line or "append" in line:
            continue
        if "isZeitkapselActive" in line:
            new_lines.append("    var isZeitkapselActive: Bool { false }\n")
            continue
        if "hasActivePowerUp" in line:
            continue
    
    # We will just write a stronger regex to remove the specific functions we know are failing.
    new_lines.append(line)

with open(path, "w") as f:
    f.writelines(new_lines)

