import json

path = "Garten_Simulation/Localizable.xcstrings"
with open(path, "r") as f:
    data = json.load(f)

strings = data.get("strings", {})

for key in list(strings.keys()):
    if "%lld" in key:
        print(f"Key: {key}")

