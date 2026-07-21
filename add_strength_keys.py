import json

file_path = "Garten_Simulation/Localizable.xcstrings"
with open(file_path, "r") as f:
    data = json.load(f)

new_keys = {
    "prog_strength_pushup_knie": {"de": "Knie-Liegestütze", "en": "Knee Push-ups"},
    "prog_strength_pushup_archer": {"de": "Archer Push-ups", "en": "Archer Push-ups"},
    "prog_strength_pushup_strict": {"de": "Strict Push-ups", "en": "Strict Push-ups"},
    "prog_strength_dips": {"de": "%lld Dips", "en": "%lld Dips"},
    "prog_strength_neg_liegestuetze": {"de": "%lld Negative Liegestütze", "en": "%lld Negative Push-ups"},
    "prog_strength_pull_strict": {"de": "%lld Strict Pull-ups", "en": "%lld Strict Pull-ups"},
    "prog_strength_pull_neg": {"de": "5 Negative Klimmzüge", "en": "5 Negative Pull-ups"},
    "prog_strength_dist_75": {"de": "75-Meter", "en": "75 meters"},
    "prog_strength_dist_50": {"de": "50-Meter", "en": "50 meters"},
    "prog_strength_lunge_heavy": {"de": "Pistol Squats / schwere Lunges", "en": "Pistol Squats / Heavy Lunges"},
    "prog_strength_lunge_norm": {"de": "Lunges", "en": "Lunges"},
    "prog_strength_run_200": {"de": "200m", "en": "200m"},
    "prog_strength_run_300": {"de": "300m", "en": "300m"},
    "prog_strength_run_400": {"de": "400m", "en": "400m"},
    "prog_strength_pull_norm": {"de": "%lld Pull-ups", "en": "%lld Pull-ups"},
    "prog_strength_rows_10": {"de": "10 Bodyweight Rows", "en": "10 Bodyweight Rows"}
}

languages = ['de', 'en', 'es', 'fr', 'hi', 'it', 'ja', 'ko', 'nl', 'pl', 'pt', 'pt-BR', 'ru', 'tr', 'zh-Hans', 'zh-Hant']

if "strings" in data:
    for key, trans in new_keys.items():
        if key not in data["strings"]:
            data["strings"][key] = {"extractionState": "manual", "localizations": {}}
        for lang in languages:
            val = trans["de"] if lang == "de" else trans["en"]
            if "localizations" not in data["strings"][key]:
                data["strings"][key]["localizations"] = {}
            if lang not in data["strings"][key]["localizations"]:
                data["strings"][key]["localizations"][lang] = {"stringUnit": {"state": "translated", "value": val}}
            else:
                data["strings"][key]["localizations"][lang]["stringUnit"]["value"] = val
                data["strings"][key]["localizations"][lang]["stringUnit"]["state"] = "translated"

with open(file_path, "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Strength keys added successfully.")
