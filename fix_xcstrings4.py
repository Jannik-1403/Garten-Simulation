import json

path = "Garten_Simulation/Localizable.xcstrings"
with open(path, "r") as f:
    data = json.load(f)

strings = data.get("strings", {})

for key, item in list(strings.items())[:20]:
    if "localizations" in item:
        print(f"Key: {key}, Langs: {list(item['localizations'].keys())}")
        break

# Let's count translations per language
lang_counts = {}
total_keys = len(strings)
for key, item in strings.items():
    if "localizations" in item:
        for lang in item["localizations"].keys():
            lang_counts[lang] = lang_counts.get(lang, 0) + 1

print(f"Total keys: {total_keys}")
for lang, count in sorted(lang_counts.items(), key=lambda x: x[0]):
    print(f"{lang}: {count} ({(count/total_keys)*100:.1f}%)")

