import json

file_path = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings"
with open(file_path, "r") as f:
    d = json.load(f)

def update_it(key, value):
    if key not in d["strings"]:
        d["strings"][key] = {"extractionState": "manual", "localizations": {}}
    if "localizations" not in d["strings"][key]:
        d["strings"][key]["localizations"] = {}
    d["strings"][key]["localizations"]["it"] = {
        "stringUnit": {
            "state": "translated",
            "value": value
        }
    }
    print(f"Updated {key} to {value}")

update_it("timeframe.1w", "1S")
update_it("timeframe.1m", "1M")
update_it("timeframe.6m", "6M")
update_it("timeframe.1y", "1A")

with open(file_path, "w") as f:
    json.dump(d, f, indent=2, ensure_ascii=False)

print("Patch complete.")
