import re

with open("/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Models/GameDatabase.swift", "r") as f:
    text = f.read()

def repl(m):
    id_val = m.group(1)
    # The original matched string might have different whitespace, just reconstruct it
    # DecorationItem(id: "trash.fast_food_abo",         objectNameKey: "trash.fast_food_abo.obj_name", objectDescriptionKey: "trash.fast_food_abo.obj_desc", habitNameKey: "trash.fast_food_abo.name", habitDescriptionKey: "trash.fast_food_abo.desc",
    res = re.sub(r'habitNameKey:\s*"",\s*habitDescriptionKey:\s*""', f'habitNameKey: "{id_val}.name", habitDescriptionKey: "{id_val}.desc"', m.group(0))
    return res

text = re.sub(r'DecorationItem\(id:\s*"([^"]+)",[^)]+habitNameKey:\s*"",\s*habitDescriptionKey:\s*""[^)]+\)', repl, text)

with open("/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Models/GameDatabase.swift", "w") as f:
    f.write(text)

