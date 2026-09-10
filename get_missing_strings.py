import json

path = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings"
with open(path, "r") as f:
    data = json.load(f)

langs = ["pt-BR", "en", "es", "fr"]
missing = {lang: {} for lang in langs}

for key, item in data.get("strings", {}).items():
    locs = item.get("localizations", {})
    for lang in langs:
        if lang not in locs or "value" not in locs[lang].get("stringUnit", {}):
            missing[lang][key] = item.get("extractionState")

for lang, keys in missing.items():
    print(f"Missing in {lang}: {len(keys)} keys")
    if len(keys) > 0:
        print(list(keys.keys())[:10]) # print first 10 keys

