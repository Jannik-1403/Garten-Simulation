import json

file_path = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings"

with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

strings = data.get("strings", {})

# 1. Remove stale keys
keys_to_remove = []
for key, value in strings.items():
    if value.get("extractionState") == "stale":
        keys_to_remove.append(key)

for k in keys_to_remove:
    del strings[k]

print(f"Removed {len(keys_to_remove)} stale keys.")

# 2. Fix known formatting issues in 'weekly_report.chart.habits.value'
problem_key = "weekly_report.chart.habits.value"
if problem_key in strings:
    locs = strings[problem_key].get("localizations", {})
    for lang, ldata in locs.items():
        v = ldata.get("stringUnit", {}).get("value", "")
        original_v = v
        # fixes for specific languages
        if lang == "es" and v == "% ya hecho":
            v = "%lld ya hecho"
        elif lang == "it" and v == "%fatto":
            v = "%lld fatto"
        elif lang == "tr" and v == "%ld bitti":
            v = "%lld bitti"
        elif "%lld" not in v and "%" in v:
            v = v.replace("%", "%lld ")
            v = v.replace("  ", " ").strip()
        
        if v != original_v:
            ldata["stringUnit"]["value"] = v
            print(f"Fixed {problem_key} for {lang}: '{original_v}' -> '{v}'")

# Check for any other mismatch by just looking for %f, %ld
for key, value in strings.items():
    locs = value.get("localizations", {})
    for lang, ldata in locs.items():
        v = ldata.get("stringUnit", {}).get("value", "")
        original_v = v
        
        if "%f" in v and "%f" not in key:
            v = v.replace("%f", "%lld")
        if "%ld" in v and "%ld" not in key and "%lld" not in v:
            v = v.replace("%ld", "%lld")
            
        if v != original_v:
            ldata["stringUnit"]["value"] = v
            print(f"Fixed format mismatch in {key} for {lang}: '{original_v}' -> '{v}'")

with open(file_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write("\n")

