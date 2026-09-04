import json

file_path = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings"
with open(file_path, "r") as f:
    d = json.load(f)

def update_it(key, value):
    if key in d["strings"]:
        if "localizations" not in d["strings"][key]:
            d["strings"][key]["localizations"] = {}
        d["strings"][key]["localizations"]["it"] = {
            "stringUnit": {
                "state": "translated",
                "value": value
            }
        }
        print(f"Updated {key} to {value}")

update_it("nutrient.status.good", "Buono")
update_it("time.week", "Settimana")
update_it("time.month", "Mese")
update_it("time.year", "Anno")
update_it("plant.detail.sell", "Vendi Pianta")

with open(file_path, "w") as f:
    json.dump(d, f, indent=2, ensure_ascii=False)

print("Patch complete.")
