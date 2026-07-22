import json

with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

for key, item in data["strings"].items():
    if "localizations" in item:
        for lang, loc in item["localizations"].items():
            if "stringUnit" in loc and "value" in loc["stringUnit"]:
                val = loc["stringUnit"]["value"]
                if "%d%" in val or "%lld%" in val or "%d %" in val or "%lld %" in val or "%@%" in val or "%@ %" in val or "%%" in val:
                    print(f"Match in Key '{key}' for lang '{lang}': {val}")
