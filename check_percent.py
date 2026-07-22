import json

with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

for key, item in data["strings"].items():
    if "localizations" in item:
        for lang, loc in item["localizations"].items():
            if "stringUnit" in loc and "value" in loc["stringUnit"]:
                val = loc["stringUnit"]["value"]
                if "%" in val:
                    # check if it's %% or % without a format specifier, or just print all % for inspection
                    if "%%" in val or " %" in val or val.endswith("%"):
                        print(f"Key: {key} -> {val}")
                        break
