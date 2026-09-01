import json

path = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings"
with open(path, "r") as f:
    data = json.load(f)

# Fix missing pt-BR value for key '-'
if "-" in data.get("strings", {}):
    if "pt-BR" in data["strings"]["-"].get("localizations", {}):
        unit = data["strings"]["-"]["localizations"]["pt-BR"].get("stringUnit", {})
        if "value" not in unit:
            unit["value"] = "-"
            data["strings"]["-"]["localizations"]["pt-BR"]["stringUnit"] = unit

with open(path, "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Fixed xcstrings file.")
